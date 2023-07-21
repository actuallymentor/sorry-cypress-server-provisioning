#!/bin/bash
# NOTE: script is designed to be run from the root of the project

# Get environment variables from .env file
source .env

# Send locally checked out version to remote
echo -e "\nSending local version to remote $SSH_USER@$SSH_IP:$SSH_PORT"
rsync -avzq ./ -e "ssh -p $SSH_PORT" $SSH_USER@$SSH_IP:~/sorry-cypress/
echo -e "Transfer complete!\n"

# Helpful message
echo "ℹ️  On the remote machine you should run:"
echo -e "cd ~/sorry-cypress && bash scripts/install-docker.sh && bash scripts/start-stack.sh\n"
read -p "Press enter to SSH into the machine..."

# SSH into the machine
ssh -p $SSH_PORT $SSH_USER@$SSH_IP