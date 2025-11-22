#!/bin/bash
set -e

WORKING_DIR="/srv"

cd "$WORKING_DIR"
git fetch origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" == "$REMOTE" ]; then
    echo "No updates found; skipping..."
    exit 0
fi

# We only run this if updates were found
echo "Found updates!"
$WORKING_DIR/helpers/deploy.sh
