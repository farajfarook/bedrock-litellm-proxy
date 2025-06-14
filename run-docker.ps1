# Docker deployment with AWS Vault ECS credential server
# This provides long-term credential management for Docker containers

Write-Host "Starting AWS Vault ECS credential server..."

# Start the ECS credential server in the background
Start-Process -WindowStyle Hidden -FilePath "aws-vault" -ArgumentList @(
    "exec", "pageup-dev", 
    "--ecs-server", 
    "--ecs-server-port", "9999",
    "--duration", "12h"
) -PassThru

# Wait a moment for the credential server to start
Start-Sleep -Seconds 3

Write-Host "ECS credential server started on port 9999"
Write-Host "Starting Docker containers..."

# Start the Docker containers
docker-compose up --build

Write-Host "Docker containers started. LiteLLM is available at http://localhost:4000"
