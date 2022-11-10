#!/bin/bash

# Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org

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

# Install zsh-completions
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_36/shells:zsh-users:zsh-completions.repo

# Install from default repos
sudo dnf install -y neovim dotnet-sdk-6.0 nodejs ulauncher gnome-shell-extension-appindicator jq wmctrl google-cloud-cli gnome-shell-extension-dash-to-dock papirus-icon-theme azure-cli enpass gtk-murrine-engine gtk2-engines helm pgadmin4 ffmpeg-libs discord tilix libgtop2-devel lm_sensors gnome-extensions-app gnome-tweaks remmina remmina-plugins-rdp zsh util-linux-user zsh-completions ripgrep

# Install flatpaks
sudo flatpak install --noninteractive --assumeyes com.slack.Slack com.microsoft.Teams com.spotify.Client com.getpostman.Postman

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

# Install Azure Data Studio
wget https://sqlopsbuilds.azureedge.net/stable/7553f799e175f471b7590302dd65c997b838b29b/azuredatastudio-linux-1.39.1.rpm && sudo dnf -y install azuredatastudio-linux-1.39.1.rpm && rm azuredatastudio-linux-1.39.1.rpm

# Install Tilix Dracula theme
wget https://github.com/dracula/tilix/archive/master.zip && unzip master.zip && rm master.zip && mkdir -p ~/.config/tilix/schemes && mv -f ./tilix-master/Dracula.json ~/.config/tilix/schemes && rm -rf ./tilix-master

# Install zsh and nvim config 
wget https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/config/.ideavimrc mv .ideavimrc ~; rm .ideavimrc
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
echo 'ZDOTDIR=$HOME/.config/zsh' > $HOME/.zshenv
mkdir -p ~/repos/dotfiles
git clone https://github.com/andreasuvoss/dotfiles.git ~/repos/dotfiles
ln -sf ~/repos/dotfiles/nvim ~/.config
ln -sf ~/repos/dotfiles/zsh ~/.config
ln -sf ~/repos/dotfiles/idea/.ideavimrc ~/.ideavimrc
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
chsh -s $(which zsh)

# Generate SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa;
fi

# Add this in order to use SSH with Azure Devops git
if ! grep -q ssh.dev.azure.com ~/.ssh/config; then
	echo -e "Host ssh.dev.azure.com\n\tUser git\n\tPubkeyAcceptedAlgorithms +ssh-rsa\n\tHostkeyAlgorithms +ssh-rsa" >> ~/.ssh/config;
	chmod 600 ~/.ssh/config;
fi
