#!/bin/bash

# Variables
rider_file="JetBrains.Rider-2022.2.3.tar.gz";

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

# Git config
git config --global user.email "andreas@anvo.dk"
git config --global user.name "Andreas Voss"

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
sudo dnf install -y neovim dotnet-sdk-6.0 nodejs ulauncher gnome-shell-extension-appindicator jq wmctrl google-cloud-cli gnome-shell-extension-dash-to-dock papirus-icon-theme azure-cli enpass gtk-murrine-engine gtk2-engines helm pgadmin4 ffmpeg-libs discord

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
wget https://gist.githubusercontent.com/andreasuvoss/5c890bb8c60d68f3d4fa3c618c220df0/raw/5531450e81b18cf31d2255bc672686aa9cf3ab9c/init.vim && mkdir -p ~/.config/nvim && mv -f init.vim ~/.config/nvim

# Themes
mkdir -p ~/temp-themes && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git ~/temp-themes && ~/temp-themes/install.sh; rm -rf ~/temp-themes
gsettings set org.gnome.desktop.interface gtk-theme Matcha-dark-azul

# Install Rider - To launch go to /opt/Jetbrains../bin and run rider.sh
if ( ! ls /opt | grep -q Rider); then
	wget https://download.jetbrains.com/rider/${rider_file}
	sudo tar -xzf ${rider_file} -C /opt
	rm ${rider_file}
fi

# Tilix config
wget https://github.com/dracula/tilix/archive/master.zip && unzip master.zip && rm master.zip && mkdir -p ~/.config/tilix/schemes && mv -f ./tilix-master/Dracula.json ~/.config/tilix/schemes && rm -rf ./tilix-master

### Custom keyboard shortcuts ###
# This might not work perfectly yet
# I would like to automate this more, but shell scripting it kind of sucks.

# In the for loop put the number of indicies you have defined shortcuts for
total_list="[";
for i in {0..1}; do
	total_list+="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}/', "
done
total_list=${total_list::-2};
total_list+="]";
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${total_list}"

# ULauncher settings
tmp=$(mktemp) && cat ~/.config/ulauncher/settings.json | jq '."hotkey-show-app" = "<Primary><Alt>Control_R" | ."render-on-screen" = "default-monitor"' > "$tmp" && mv -f "$tmp" ~/.config/ulauncher/settings.json
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Toggle ULauncher'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Alt>space'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'ulauncher-toggle'"

# Terminal shortcut
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "'Terminal'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "'<Control><Alt>t'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "'tilix'"


# Settings
gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat 
gsettings set org.gnome.desktop.peripherals.mouse speed -0.24545454545454548
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"
gsettings set org.gnome.desktop.interface icon-theme Papirus
gsettings set org.gnome.desktop.background picture-uri ""
gsettings set org.gnome.desktop.background picture-uri-dark ""
gsettings set org.gnome.desktop.background primary-color "#122938"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.nautilus.preferences default-folder-viewer list-view
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set com.gexperts.Tilix.Settings terminal-title-style none

# Better Alt-tabbing (each window not each application)
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward  "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward  "[]"

# Dash to dock settings
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style "SQUARES"
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell favorite-apps "[\
	'org.gnome.Nautilus.desktop',\
	'firefox.desktop',\
	'jetbrains-rider.desktop',\
	'teams.desktop',\
	'com.gexperts.Tilix.desktop',\
	'pgadmin4.desktop',\
	'azuredatastudio.desktop',\
	'slack.desktop',\
	'discord.desktop'\
]"

# SSH + Azure specific scheisse
if [ ! -f ~/.ssh/id_rsa ]; then
	ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa;
fi

if ! grep -q ssh.dev.azure.com ~/.ssh/config; then
	echo "Host ssh.dev.azure.com\n    User git\n    PubkeyAcceptedAlgorithms +ssh-rsa\n    HostkeyAlgorithms +ssh-rsa" >> ~/.ssh/config;
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
