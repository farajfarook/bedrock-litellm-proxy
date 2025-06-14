# Auto-restarting Docker container with credential refresh
# This handles both Docker container management and AWS credential refresh

param(
    [int]$SessionDurationHours = 11,  # Restart every 11 hours (before 12h expiry)
    [int]$RestartBufferMinutes = 30   # Stop 30 minutes before expiry for safety
)

$RestartIntervalSeconds = ($SessionDurationHours * 3600) - ($RestartBufferMinutes * 60)

Write-Host "Starting auto-restarting Docker LiteLLM service..."
Write-Host "Will restart every $($RestartIntervalSeconds / 3600) hours to refresh credentials"

# Create a cleanup function
function Stop-Services {
    Write-Host "Stopping Docker containers..."
    docker-compose down 2>$null
    
    Write-Host "Stopping AWS Vault processes..."
    Get-Process aws-vault -ErrorAction SilentlyContinue | Stop-Process -Force
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Stop-Services
}

while ($true) {
    try {
        Write-Host "$(Get-Date): Starting AWS Vault ECS credential server..."
        
        # Start ECS credential server
        $ecsServerJob = Start-Job -ScriptBlock {
            aws-vault exec pageup-dev --ecs-server --ecs-server-port 9999 --duration 12h
        }
        
        Start-Sleep -Seconds 5  # Wait for ECS server to start
        
        Write-Host "$(Get-Date): Starting Docker containers..."
        
        # Start Docker containers
        $dockerJob = Start-Job -ScriptBlock {
            docker-compose up
        }
        
        Write-Host "$(Get-Date): Services started. Waiting $($RestartIntervalSeconds / 3600) hours before restart..."
        
        # Wait for restart interval
        $completed = Wait-Job -Job $dockerJob -Timeout $RestartIntervalSeconds
        
        if ($completed) {
            Write-Host "$(Get-Date): Docker service ended unexpectedly"
            Receive-Job -Job $dockerJob
            break
        } else {
            Write-Host "$(Get-Date): Restarting due to credential refresh schedule..."
        }
        
        # Clean up current services
        Stop-Job -Job $dockerJob -ErrorAction SilentlyContinue
        Stop-Job -Job $ecsServerJob -ErrorAction SilentlyContinue
        Remove-Job -Job $dockerJob -Force -ErrorAction SilentlyContinue
        Remove-Job -Job $ecsServerJob -Force -ErrorAction SilentlyContinue
        
        docker-compose down
        
        Write-Host "$(Get-Date): Waiting 10 seconds before restart..."
        Start-Sleep -Seconds 10
        
    } catch {
        Write-Host "$(Get-Date): Error occurred: $($_.Exception.Message)"
        Stop-Services
        Start-Sleep -Seconds 30
    }
}

# Final cleanup
Stop-Services
