#!/bin/bash
# NOTE: script is designed to be run from the root of the project

# Get environment variables from .env file
source .env

# Overwrite the subdonain in the config with the configures subdomain in the .env
sed -i "s/PROXY_DASHBOARD_SUBDOMAIN/$PROXY_DASHBOARD_SUBDOMAIN/g" ./swag/nginx/proxy-confs/sorry-cypress.subdomain.conf
sed -i "s/PROXY_API_SUBDOMAIN/$PROXY_API_SUBDOMAIN/g" ./swag/nginx/proxy-confs/sorry-cypress.subdomain.conf
sed -i "s/PROXY_DIRECTOR_SUBDOMAIN/$PROXY_DIRECTOR_SUBDOMAIN/g" ./swag/nginx/proxy-confs/sorry-cypress.subdomain.conf
sed -i "s/PROXY_SERVER_DOMAIN/$PROXY_SERVER_DOMAIN/g" ./swag/nginx/proxy-confs/sorry-cypress.subdomain.conf

# Install the .htpasswd file based on the ENV
$users_exhausted
$user_number
while [[ ! $users_exhausted ]]; do

    user_variable="PROXY_USER$user_number"
    password_variable="PROXY_PASSWORD$user_number"

    echo "Checking for $user_variable, value ${!user_variable}"

    # If no user was found for this number, we are done
    if [[ ! ${!user_variable} ]]; then
        echo "✅ No more users to add to .htpasswd, proceeding"
        users_exhausted=true
        exit 0
    fi
    

    # If the user was found, add it to the .htpasswd file
    echo "Adding $user_variable ${!user_variable} to .htpasswd"

    # If this is the first run, do not use the variable expansion for user_number as it is null
    # Check if this user has a password set
    if [[ ! ${!password_variable} ]]; then
        echo "🚨 Please set $password_variable for $user_variable ${!user_variable}"
        exit 1
    fi

    # Write password hash to .htpasswd
    # NOTE: this line OVERWRITES the existing .htpasswd
    echo "${!user_variable}:$(openssl passwd -5 ${!password_variable})" > ./swag/nginx/.htpasswd

    # Increment user number
    ((user_number++))
    sleep 2

done
