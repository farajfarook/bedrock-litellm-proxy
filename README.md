# bedrock-litellm-proxy

A Docker-based LiteLLM proxy server for accessing AWS Bedrock Claude models with AWS Vault credential management.

## Quick Start

1. **Clone and setup:**

   ```bash
   git clone <your-repo-url>
   cd bedrock-litellm-proxy
   cp config.sample.yaml config.yaml
   ```

2. **Edit configuration:**

   - Replace `YOUR_ACCOUNT_ID` with your AWS account ID
   - Replace `YOUR_REGION` with your AWS region

3. **Setup AWS Vault:**

   ```bash
   aws-vault add pageup-dev
   ```

4. **Run with Docker:**

   ```bash
   .\setup-docker.ps1
   ```

5. **Access the API:** `http://localhost:4000`

## Setup

### 1. Configuration

Copy the sample configuration and customize it for your environment:

```bash
cp config.sample.yaml config.yaml
```

Edit `config.yaml` and replace the placeholders:

- `YOUR_REGION`: Your AWS region (e.g., `ap-southeast-2`)
- `YOUR_ACCOUNT_ID`: Your AWS account ID (12-digit number)

### 2. AWS Vault Setup

Install and configure AWS Vault with your credentials:

```bash
# Add your AWS profile
aws-vault add pageup-dev

# Or for long-term IAM user credentials
aws-vault add pageup-dev-iam
```

### 3. Docker Deployment Options

Run the setup script to choose your deployment method:

```bash
.\setup-docker.ps1
```

**Options:**

1. **ECS Credential Server** - Automatic credential refresh (recommended for development)
2. **Long-term IAM Credentials** - No expiration (recommended for production)
3. **Auto-Restarting Container** - Handles credential expiration automatically

### 4. Manual Deployment

#### Option 1: ECS Credential Server

```bash
.\run-docker.ps1
```

#### Option 2: Long-term IAM Credentials

```bash
.\run-docker-iam.ps1
```

#### Option 3: Auto-Restarting Container

```bash
.\run-docker-auto-restart.ps1
```

### 5. Non-Docker Deployment

For running without Docker:

```bash
# Standard execution
.\run.ps1

# Auto-restarting service
.\run-with-auto-restart.ps1
```

## Usage

Once running, the LiteLLM proxy will be available at `http://localhost:4000`

### Available Models

- `claude-4-sonnet` - Claude 4 Sonnet (latest)
- `claude-3-5-sonnet` - Claude 3.5 Sonnet
- `claude-3-7-sonnet` - Claude 3.7 Sonnet

### Example API Call

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

## Requirements

- Docker Desktop (for Docker deployment)
- PowerShell
- AWS Vault
- AWS Bedrock access with appropriate permissions

## Files

- `config.sample.yaml` - Sample configuration (safe for Git)
- `config.yaml` - Your actual configuration (excluded from Git)
- `run.ps1` - Simple execution script
- `run-docker.ps1` - Docker deployment with ECS credential server
- `setup-docker.ps1` - Interactive setup menu
- Various auto-restart and credential management scripts

## Security Notes

- Never commit `config.yaml` to version control
- Use environment variables for AWS credentials
- The actual configuration file is excluded in `.gitignore`
- AWS account IDs and regions should be configured per environment
