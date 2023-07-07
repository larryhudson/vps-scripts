

read -rp "Install Node LTS using nvm? (Y/n) " install_node_lts
install_node_lts=${install_node_lts:-Y}


if [[ $install_node_lts =~ ^[Yy]$ ]]; then
   # Switch to the 'deploy' user and install nvm
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
   source ~/.bashrc

   nvm install --lts
   nvm use --lts
fi

read -rp "Install PM2 (Y/n) " install_pm2
install_pm2=${install_pm2:-Y}

if [[ $install_pm2 =~ ^[Yy]$ ]]; then
  npm install -g pm2
fi

# Step 5: Set Up Git as Root User

echo ""
echo "Step 5: Set Up Git as Deploy User"
echo "---------------------------------"

read -rp "Configure Git as deploy user? (Y/n) " configure_git
configure_git=${configure_git:-Y}

if [[ $configure_git =~ ^[Yy]$ ]]; then

	read -rp "Enter your name for Git user config: " git_username
	read -rp "Enter your email address for Git user config: " git_email

	sudo -u $DEPLOY_USERNAME git config --global user.name "$git_username"
	sudo -u $DEPLOY_USERNAME git config --global user.email "$git_email"

	echo "Generating SSH key..."
	sudo -u $DEPLOY_USERNAME ssh-keygen -t rsa -b 4096 -C "$git_email"

	echo ""
	echo "Copy and paste the following public key into your Git platform:"
	echo "-----------------------------"
	cat /home/$DEPLOY_USERNAME/.ssh/id_rsa.pub
	echo "-----------------------------"
fi
