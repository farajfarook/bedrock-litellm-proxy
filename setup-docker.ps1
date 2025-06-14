# LiteLLM Docker Setup Menu
# Choose your preferred deployment method

Write-Host "=== LiteLLM Docker Deployment Options ===" -ForegroundColor Green
Write-Host ""
Write-Host "1. ECS Credential Server (Automatic credential refresh)" -ForegroundColor Yellow
Write-Host "   - Uses temporary credentials with automatic refresh"
Write-Host "   - No manual restarts needed"
Write-Host "   - Recommended for development"
Write-Host ""
Write-Host "2. Long-term IAM User Credentials (No expiration)" -ForegroundColor Yellow  
Write-Host "   - Uses permanent IAM user access keys"
Write-Host "   - Most stable for production"
Write-Host "   - Requires IAM user setup"
Write-Host ""
Write-Host "3. Auto-Restarting Container (Handles expiration)" -ForegroundColor Yellow
Write-Host "   - Automatically restarts before credentials expire"
Write-Host "   - Good for long-running services"
Write-Host "   - Handles credential refresh automatically"
Write-Host ""

$choice = Read-Host "Select option (1-3)"

switch ($choice) {
    "1" {
        Write-Host "Starting with ECS Credential Server..." -ForegroundColor Green
        .\run-docker.ps1
    }
    "2" {
        Write-Host "Setting up with long-term IAM credentials..." -ForegroundColor Green
        .\run-docker-iam.ps1
    }
    "3" {
        Write-Host "Starting auto-restarting container..." -ForegroundColor Green
        .\run-docker-auto-restart.ps1
    }
    default {
        Write-Host "Invalid choice. Please run the script again and select 1, 2, or 3." -ForegroundColor Red
    }
}
