#!/bin/bash
set -e

echo "Beginning deployment on $HOSTNAME"

# ----------------------------------------
# Configuration - adjust paths as needed
# ----------------------------------------
WORKING_DIR="/srv"
HELPERS_DIR="$WORKING_DIR/helpers"
COMPOSE_DIR="$WORKING_DIR/$HOSTNAME/compose"
SECRETS_FILE="$COMPOSE_DIR/secrets.enc.yaml"
ENV_FILE="$COMPOSE_DIR/$HOSTNAME/.env"
AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# ----------------------------------------
# 1. Ensure age key exists
# ----------------------------------------
if [ ! -f "$AGE_KEY_FILE" ]; then
    echo "ERROR: Age key not found at $AGE_KEY_FILE"
    exit 1
fi

# ----------------------------------------
# 2. Decrypt secrets and generate .env
# ----------------------------------------
if [ ! -f "$SECRETS_FILE" ]; then
    echo "ERROR: Encrypted secrets file not found: $SECRETS_FILE"
    exit 1
fi

echo "Decrypting secrets..."
sops -d "$SECRETS_FILE" | yq -r 'to_entries | .[] | "\(.key)=\(.value)"' > "$ENV_FILE"

# Ensure .env is readable only by current user
chmod 600 "$ENV_FILE"
echo ".env file generated at $ENV_FILE"

# ----------------------------------------
# 3. Ensure directories exist
# ----------------------------------------
echo "Creating any missing directories..."
$HELPERS_DIR/directories.sh $COMPOSE_DIR/docker-compose.yml


# ----------------------------------------
# 4. Deploy the Docker Compose stack
# ----------------------------------------
echo "Deploying Docker Compose stack..."
cd "$COMPOSE_DIR"

# Pull updated images and start services
docker compose pull
docker compose up -d

echo "Deployment complete."

