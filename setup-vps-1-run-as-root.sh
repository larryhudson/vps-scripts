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

	read -rp "Install Git? (Y/n) " install_git
	install_git=${install_git:-Y}

	if [[ $install_git =~ ^[Yy]$ ]]; then
		sudo apt install -y git
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

echo ""
echo "Setup completed!"
echo "Next, run the setup-vps-2-run-as-deploy.sh script as the deploy user."
echo ""
echo "su - deploy"
echo "chmod +x setup-vps-2-run-as-deploy.sh"
echo "./setup-vps-2-run-as-deploy.sh"
