FROM python:3.11-slim

# Install LiteLLM
RUN pip install litellm[proxy]

# Create app directory
WORKDIR /app

# Copy config file
COPY config.yaml .

# Expose the default LiteLLM port
EXPOSE 4000

# Run LiteLLM
CMD ["litellm", "--config", "config.yaml", "--port", "4000", "--host", "0.0.0.0"]
