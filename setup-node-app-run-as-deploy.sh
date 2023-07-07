#!/bin/bash

# Script for setting up a new Node.js app on an existing server

# Function to prompt for user input
function prompt_user() {
  read -rp "$1 (Y/n) " input
  if [[ $input =~ ^[Yy]$ || -z $input ]]; then
    return 0
  else
    return 1
  fi
}

echo "This script will guide you through the setup process for your new Node.js app."
echo "You can choose to skip any step if you have already completed it."

prompt_user "Press Enter to continue or Ctrl+C to cancel..."

# Read repository name from user
read -rp "Enter the repository name in the format 'owner/repo': " REPO_NAME

# Extract owner and repo from repository name
OWNER=$(echo $REPO_NAME | cut -d'/' -f1)
REPO=$(echo $REPO_NAME | cut -d'/' -f2)

# Function to check if a port is available
function is_port_available() {
  nc -z localhost "$1" </dev/null >/dev/null 2>&1
  local result=$?
  return $result
}

# Find an available port starting from 3000
PORT=3000
while ! is_port_available "$PORT"; do
  PORT=$((PORT + 1))
done


# Step 2: Clone the Git repo as the deploy user
echo ""
echo "Step 2: Clone the Git repo"
echo "--------------------------"

if prompt_user "Clone the Git repo '$REPO_NAME' as the deploy user?"; then
  git clone https://github.com/$REPO_NAME /home/$DEPLOY_USER/$REPO
fi

# Step 3: Build the app
echo ""
echo "Step 3: Build the app"
echo "----------------------"

if prompt_user "Build the app?"; then
  cd /home/$DEPLOY_USER/$REPO
  npm install
  npm run build
fi

# Step 4: Add the app to PM2
echo ""
echo "Step 4: Add the app to PM2"
echo "---------------------------"

if prompt_user "Add the app to PM2?"; then
  # Read the relative path of the Node.js script to run
  read -rp "Enter the relative path of the Node.js script to run (e.g., app.js): " SCRIPT_PATH
  cd /home/$DEPLOY_USER/$REPO
  pm2 start /home/$DEPLOY_USER/$REPO/$SCRIPT_PATH --name $REPO --env PORT=$PORT
fi

# Step 5: Configure Nginx
echo ""
echo "Step 5: Configure Nginx"
echo "------------------------"

read -rp "Enter the subdomain for your app: " SUBDOMAIN

if prompt_user "Configure Nginx for the app?"; then
  sudo tee "/etc/nginx/sites-available/$REPO" > /dev/null << EOF
server {
    listen 80;
    server_name $SUBDOMAIN;

    location / {
	proxy_pass http://localhost:$PORT;
	proxy_http_version 1.1;
	proxy_set_header Upgrade \$http_upgrade;
	proxy_set_header Connection 'upgrade';
	proxy_set_header Host \$host;
	proxy_cache_bypass \$http_upgrade;
      }
    }
EOF

  # Enable the Nginx site
  sudo ln -s /etc/nginx/sites-available/$REPO /etc/nginx/sites-enabled/

  # Test Nginx configuration and restart Nginx
  if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "Nginx configuration applied successfully."
  else
    echo "Error: There was an issue with the Nginx configuration. Please check the configuration file."
  fi
fi

# Step 6: Create a new A record in DNS
echo ""
echo "Step 7: Create a new A record in DNS"
echo "-----------------------------------"

if prompt_user "Create a new A record in your DNS for the domain?"; then
  SERVER_IP=$(curl -s http://checkip.amazonaws.com)
  echo "Please create an A record in your DNS configuration with the following details:"
  echo "Type: A"
  echo "Name: $SUBDOMAIN"
  echo "Value: $SERVER_IP"
fi

# Step 8: Generate and configure an SSL certificate with Certbot
echo ""
echo "Step 8: Generate and configure an SSL certificate with Certbot"
echo "-------------------------------------------------------------"

if prompt_user "Generate and configure an SSL certificate with Certbot?"; then
  sudo certbot --nginx -d $SUBDOMAIN
fi

echo ""
echo "Setup process completed."
echo "Please verify the app's functionality by accessing https://$SUBDOMAIN in a web browser."
