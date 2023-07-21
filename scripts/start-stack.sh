#!/bin/bash
# NOTE: script is designed to be run from the root of the project

# Get environment variables from .env file
source .env

# Apply configs to swag
bash scripts/apply-configs.sh

echo -e "\n\nStarting sorry-cypress docker stack\n\n"
cd ~/sorry-cypress
docker compose down --remove-orphans
docker compose pull
docker compose up -d
yes | docker system prune -a | grep 'Total reclaimed space'
docker compose ps
echo -e "\n\nDocker stack started\n\n"
echo "You can track the status of the docker stack by running: docker compose logs -f"