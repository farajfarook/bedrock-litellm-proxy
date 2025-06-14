# Option 1: Standard execution (will need restart every ~8 hours)
# aws-vault exec pageup-dev -- litellm --config config.yaml

# Option 2: With extended 12-hour session
# aws-vault exec pageup-dev --duration=12h -- litellm --config config.yaml

# Option 3: With ECS credential server (automatic credential refresh)
aws-vault exec pageup-dev --ecs-server -- litellm --config config.yaml