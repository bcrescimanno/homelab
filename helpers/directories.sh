#!/bin/sh
set -e

yq -r '.services[].volumes[]? | select(startswith("/srv/volumes")) | split(":")[0]' $1 | while read -r dir; do
mkdir -p "$dir"
done
