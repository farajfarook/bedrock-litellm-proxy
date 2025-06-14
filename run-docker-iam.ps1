# Setup for long-term IAM user credentials (no expiration)
# This uses permanent IAM user access keys instead of temporary STS tokens

param(
    [string]$ProfileName = "pageup-dev-iam"
)

Write-Host "Setting up long-term IAM user credentials..."

# Check if we have the IAM user profile configured
$profileExists = aws-vault list | Select-String -Pattern $ProfileName

if (-not $profileExists) {
    Write-Host "IAM user profile '$ProfileName' not found."
    Write-Host "Please add your IAM user credentials with:"
    Write-Host "aws-vault add $ProfileName"
    Write-Host ""
    Write-Host "You'll need:"
    Write-Host "1. IAM user Access Key ID"
    Write-Host "2. IAM user Secret Access Key"
    Write-Host ""
    Write-Host "These credentials should have the necessary permissions for Bedrock access."
    exit 1
}

Write-Host "Exporting long-term IAM credentials to environment..."

# Export the credentials to a .env file for Docker
aws-vault exec $ProfileName -- pwsh -Command {
    $env:AWS_ACCESS_KEY_ID | Out-File -FilePath ".env" -Encoding ascii -NoNewline
    "`n" | Out-File -FilePath ".env" -Append -Encoding ascii -NoNewline
    "AWS_ACCESS_KEY_ID=$($env:AWS_ACCESS_KEY_ID)" | Out-File -FilePath ".env" -Append -Encoding ascii
    "AWS_SECRET_ACCESS_KEY=$($env:AWS_SECRET_ACCESS_KEY)" | Out-File -FilePath ".env" -Append -Encoding ascii
    "AWS_DEFAULT_REGION=$($env:AWS_DEFAULT_REGION)" | Out-File -FilePath ".env" -Append -Encoding ascii
    "AWS_REGION=$($env:AWS_REGION)" | Out-File -FilePath ".env" -Append -Encoding ascii
}

Write-Host "Credentials exported to .env file"
Write-Host "Starting Docker containers with long-term credentials..."

# Start Docker with the exported credentials
docker-compose -f docker-compose-iam.yml up --build
