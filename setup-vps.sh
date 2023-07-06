#!/bin/bash

# Interactive script for setting up a fresh VPS server for Node.js app deployment

echo "This script will guide you through the setup process for your fresh VPS server."
echo "You can choose to skip any step if you have already completed it."

read -rp "Press Enter to continue or Ctrl+C to cancel..."

# Step 1: Initial Server Setup

echo ""
echo "Step 1: Initial Server Setup"
echo "------------------------------"

read -rp "Update system packages? (Y/n) " update_system
update_system=${update_system:-Y}

if [[ $update_system =~ ^[Yy]$ ]]; then
	sudo apt update && sudo apt upgrade -y
fi

# Step 2: Install System Dependencies

echo ""
echo "Step 2: Install System Dependencies"
echo "------------------------------------"


read -rp "Install Redis? (Y/n) " install_redis
install_redis=${install_redis:-Y}

if [[ $install_redis =~ ^[Yy]$ ]]; then
	sudo apt install -y redis-server
fi

read -rp "Install Nginx? (Y/n) " install_nginx
install_nginx=${install_nginx:-Y}

if [[ $install_nginx =~ ^[Yy]$ ]]; then
	sudo apt install -y nginx
fi

read -rp "Install Certbot? (Y/n) " install_certbot
install_certbot=${install_certbot:-Y}

if [[ $install_certbot =~ ^[Yy]$ ]]; then
	sudo apt install -y certbot python3-certbot-nginx
fi


# Step 3: Setup deploy user and install Node

echo ""
echo "Step 3: Setup deploy user and install Node"
echo "------------------------------------"


read -rp "Setup deploy user? (Y/n) " setup_deploy_user
setup_deploy_user=${setup_deploy_user:-Y}

DEPLOY_USERNAME=deploy

if [[ $setup_deploy_user =~ ^[Yy]$ ]]; then
    # Create 'deploy' user
    sudo adduser $DEPLOY_USERNAME --disabled-password --gecos ""
fi


read -rp "Install Node LTS using nvm? (Y/n) " install_node_lts
install_node_lts=${install_node_lts:-Y}


if [[ $install_node_lts =~ ^[Yy]$ ]]; then
   # Switch to the 'deploy' user and install nvm
    sudo -u $DEPLOY_USERNAME bash << EOF
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        source ~/.bashrc
EOF

# Install the latest LTS version of Node.js as 'deploy'
    sudo -u $DEPLOY_USERNAME bash << EOF
        nvm install --lts
        nvm use --lts
EOF
fi

read -rp "Install PM2 as deploy user? (Y/n) " install_pm2
install_pm2=${install_pm2:-Y}

if [[ $install_pm2 =~ ^[Yy]$ ]]; then

# Install PM2 as 'deploy'
    sudo -u deploy bash << EOF
        npm install -g pm2
EOF
    
fi


# Step 4: Enable Firewall

echo ""
echo "Step 4: Enable Firewall"
echo "-------------------------"

read -rp "Enable firewall? (Y/n) " enable_firewall
enable_firewall=${enable_firewall:-Y}

if [[ $enable_firewall =~ ^[Yy]$ ]]; then
	sudo ufw allow OpenSSH
	sudo ufw allow 'Nginx Full'
	sudo ufw enable
fi

# Step 5: Set Up Git as Root User

echo ""
echo "Step 5: Set Up Git as Deploy User"
echo "---------------------------------"

read -rp "Configure Git as deploy user? (Y/n) " configure_git
configure_git=${configure_git:-Y}

if [[ $configure_git =~ ^[Yy]$ ]]; then
	sudo apt install -y git

	read -rp "Enter your name for Git user config: " git_username
	read -rp "Enter your email address for Git user config: " git_email

	sudo -u $DEPLOY_USER git config --global user.name "$git_username"
	sudo -u $DEPLOY_USER git config --global user.email "$git_email"

	echo "Generating SSH key..."
	sudo -u $DEPLOY_USER ssh-keygen -t rsa -b 4096 -C "$git_email"

	echo ""
	echo "Copy and paste the following public key into your Git platform:"
	echo "-----------------------------"
	cat /home/$DEPLOY_USER/.ssh/id_rsa.pub
	echo "-----------------------------"
fi

echo ""
echo "Setup completed!"
