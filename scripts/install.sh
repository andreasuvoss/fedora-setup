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

# Install zsh-completions
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_36/shells:zsh-users:zsh-completions.repo

# VPN
sudo dnf copr -y enable yuezk/globalprotect-openconnect

# Starship
sudo dnf copr -y enable atim/starship

# Install from default repos
sudo dnf install -y \
    neovim \
    flameshot \
    dotnet-sdk-6.0 \
    dotnet-sdk-7.0 \
    dotnet-sdk-8.0 \
    nodejs \
    ulauncher \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    gnome-shell-extension-appindicator \
    jq \
    wmctrl \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    gnome-shell-extension-dash-to-dock \
    papirus-icon-theme \
    azure-cli \
    enpass \
    gtk-murrine-engine \
    gtk2-engines \
    helm \
    ffmpeg-libs \
    tilix \
    libgtop2-devel \
    lm_sensors \
    gnome-extensions-app \
    gnome-tweaks \
    remmina \
    remmina-plugins-rdp \
    zsh \
    util-linux-user \
    zsh-completions \
    bat \
    ripgrep \
    tree-sitter-cli \
    libstdc++-static \
    libstdc++ \
    gcc-c++ \
    rust \
    cargo \
    globalprotect-openconnect \
    gthumb \
    lynx \
    pandoc \
    python3-pip \
    python3-nautilus \
    task \
    kubectl \
    starship \
    --best \
    --allowerasing

# Right click in Nautilis to open Tilix
pip install --user nautilus-open-any-terminal

# Install flatpaks
sudo flatpak install --noninteractive --assumeyes com.spotify.Client discord

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

# Install Tilix Dracula theme
wget https://github.com/dracula/tilix/archive/master.zip && unzip master.zip && rm master.zip && mkdir -p ~/.config/tilix/schemes && mv -f ./tilix-master/Dracula.json ~/.config/tilix/schemes && rm -rf ./tilix-master

# Install Yarn + Prettier
sudo npm install --global yarn
sudo npm install --global prettier

# Install zsh and nvim config 
echo 'ZDOTDIR=$HOME/.config/zsh' > $HOME/.zshenv
mkdir -p ~/repos/dotfiles
git clone https://github.com/andreasuvoss/dotfiles.git ~/repos/dotfiles
ln -sf ~/repos/dotfiles/nvim ~/.config
ln -sf ~/repos/dotfiles/zsh ~/.config
ln -sf ~/repos/dotfiles/idea/.ideavimrc ~/.ideavimrc
ln -sf ~/repos/dotfiles/starship/starship.toml ~/.config/starship.toml
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
