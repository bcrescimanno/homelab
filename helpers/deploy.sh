!/bin/bash
set -e

# ----------------------------------------
# Configuration - adjust paths as needed
# ----------------------------------------
COMPOSE_DIR="/srv/compose"
SECRETS_FILE="$COMPOSE_DIR/secrets.enc.yaml"
ENV_FILE="$COMPOSE_DIR/.env"
AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Optional: Docker Compose file if not default
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"

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
# 3. Deploy the Docker Compose stack
# ----------------------------------------
echo "Deploying Docker Compose stack..."
cd "$COMPOSE_DIR"

# Pull updated images and start services
#docker compose pull
#docker compose up -d

echo "Deployment complete."

