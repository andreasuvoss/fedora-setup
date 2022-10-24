#!/bin/bash

# Variables
rider_file="JetBrains.Rider-2022.2.3.tar.gz";

# Set idle delay - Do it here to keep monitor awake during installation
gsettings set org.gnome.desktop.session idle-delay 0

# Add Google Cloud stuff - https://cloud.google.com/sdk/docs/install#rpm
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

# Azure stuff - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm

# Azure artifacts credential provider - Remove exe file since Rider will otherwise try to use it >.<
sh -c "$(wget -O- https://aka.ms/install-artifacts-credprovider.sh)"
rm ~/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.exe

# Enpass - password manager
wget https://yum.enpass.io/enpass-yum.repo
sudo mv -f enpass-yum.repo /etc/yum.repos.d

# RPMFusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install yq (needed for some configuration later)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq

# pgadmin repo
sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-fedora-repo-2-1.noarch.rpm

# Install from default repos
sudo dnf install -y neovim dotnet-sdk-6.0 nodejs ulauncher gnome-shell-extension-appindicator jq wmctrl google-cloud-cli gnome-shell-extension-dash-to-dock papirus-icon-theme azure-cli enpass gtk-murrine-engine gtk2-engines helm pgadmin4 ffmpeg-libs discord tilix

# Enable ulauncher
systemctl --user enable --now ulauncher

# Install Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

# gTile
if [ ! -d ~/.local/share/gnome-shell/extensions/gTile@vibou ]; then
	sudo dnf copr enable -y vbatts/bazel
	sudo dnf install -y bazel4
	mkdir -p $HOME/.local/share/gnome-shell/extensions/gTile@vibou
	git clone https://github.com/gTile/gTile.git $HOME/.local/share/gnome-shell/extensions/gTile@vibou
	current_dir=$(pwd)
	cd $HOME/.local/share/gnome-shell/extensions/gTile@vibou 
	bazel run :install-extension
	cd $current_dir
fi

# Install Azure Data Studio
wget https://sqlopsbuilds.azureedge.net/stable/7553f799e175f471b7590302dd65c997b838b29b/azuredatastudio-linux-1.39.1.rpm && sudo dnf -y install azuredatastudio-linux-1.39.1.rpm && rm azuredatastudio-linux-1.39.1.rpm

# Install slack
wget https://downloads.slack-edge.com/releases/linux/4.28.184/prod/x64/slack-4.28.184-0.1.el8.x86_64.rpm && sudo dnf -y install slack-4.28.184-0.1.el8.x86_64.rpm && rm slack-4.28.184-0.1.el8.x86_64.rpm

# Install teams
wget https://packages.microsoft.com/yumrepos/ms-teams/teams-1.5.00.23861-1.x86_64.rpm && sudo dnf -y install teams-1.5.00.23861-1.x86_64.rpm; rm teams-1.5.00.23861-1.x86_64.rpm

# vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# nvim config
wget https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/nvim/init.vim && mkdir -p ~/.config/nvim && mv -f init.vim ~/.config/nvim
nvim --headless +PlugInstall +qa

# Install Rider - To launch go to /opt/Jetbrains../bin and run rider.sh
if ( ! ls /opt | grep -q Rider); then
	wget https://download.jetbrains.com/rider/${rider_file}
	sudo tar -xzf ${rider_file} -C /opt
	rm ${rider_file}
fi

# Install Tilix Dracula theme
wget https://github.com/dracula/tilix/archive/master.zip && unzip master.zip && rm master.zip && mkdir -p ~/.config/tilix/schemes && mv -f ./tilix-master/Dracula.json ~/.config/tilix/schemes && rm -rf ./tilix-master

# Generate SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
	ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa;
fi

# Add this in order to use SSH with Azure Devops git
if ! grep -q ssh.dev.azure.com ~/.ssh/config; then
	echo -e "Host ssh.dev.azure.com\n\tUser git\n\tPubkeyAcceptedAlgorithms +ssh-rsa\n\tHostkeyAlgorithms +ssh-rsa" >> ~/.ssh/config;
	chmod 600 ~/.ssh/config;
fi

# Oh My Zsh - This needs to be done as the last thing in stage one
# Default installation is fine for now, theme and plugins can be added later - This installation hijacks the script and stops  further execution
if [ ! -d ~/.oh-my-zsh ] 
then
	sudo dnf install -y zsh util-linux-user
	chsh -s $(which zsh)
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
else
	echo "Oh My Zsh already installed";
fi
