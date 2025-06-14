# Auto-restarting LiteLLM with AWS Vault
# This script will automatically restart the service when AWS credentials expire

param(
    [int]$SessionDurationHours = 8,
    [int]$RestartBufferMinutes = 10  # Restart 10 minutes before expiry
)

$RestartIntervalSeconds = ($SessionDurationHours * 3600) - ($RestartBufferMinutes * 60)

Write-Host "Starting LiteLLM with auto-restart every $($RestartIntervalSeconds / 3600) hours..."

while ($true) {
    Write-Host "$(Get-Date): Starting/Restarting LiteLLM service..."
    
    # Start the process in background
    $job = Start-Job -ScriptBlock {
        param($ConfigPath)
        aws-vault exec pageup-dev --duration=12h -- litellm --config $ConfigPath
    } -ArgumentList (Resolve-Path "config.yaml")
    
    # Wait for the restart interval or job completion
    $completed = Wait-Job -Job $job -Timeout $RestartIntervalSeconds
    
    if ($completed) {
        Write-Host "$(Get-Date): LiteLLM service ended unexpectedly"
        Receive-Job -Job $job
    }
    else {
        Write-Host "$(Get-Date): Restarting due to credential expiry..."
        Stop-Job -Job $job
    }
    
    Remove-Job -Job $job -Force
    
    Write-Host "$(Get-Date): Waiting 5 seconds before restart..."
    Start-Sleep -Seconds 5
}
