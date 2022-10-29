#/bin/bash

### Gnome settings ###
gsettings set org.gnome.desktop.session idle-delay 600
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
	'discord.desktop',\
	'org.remmina.Remmina.desktop'\
]"

# Enable gnome extensions
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable gTile@vibou

# Git config
git config --global user.email "andreas@anvo.dk"
git config --global user.name "Andreas Voss"

# Install and apply theme
mkdir -p ~/temp-themes && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git ~/temp-themes && ~/temp-themes/install.sh; rm -rf ~/temp-themes
gsettings set org.gnome.desktop.interface gtk-theme Matcha-dark-azul

# ulauncher settings
tmp=$(mktemp) && cat ~/.config/ulauncher/settings.json | jq '."hotkey-show-app" = "<Primary><Alt>Control_R" | ."render-on-screen" = "default-monitor" | ."theme-name" = "dark"' > "$tmp" && mv -f "$tmp" ~/.config/ulauncher/settings.json

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


# Google setup
# gcloud auth login
# gcloud auth configure-docker europe-west3-docker.pkg.dev

# TODO: Remove everything below this line if the setup works
#if ! grep -q NUGET_PLUGIN_PATHS ~/.zshrc; then
#	echo "export NUGET_PLUGIN_PATHS=\"~/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.dll\"" >> ~/.zshrc;
#fi

# This section might not be required - I need to test it
#if [ "$pat" = "" ]; then
#	echo "No Azure PAT";
#else
#	echo "export VSS_NUGET_EXTERNAL_FEED_ENDPOINTS='{\"endpointCredentials\": [{\"endpoint\":\"https://okamba.pkgs.visualstudio.com/_packaging/OK.Web/nuget/v3/index.json\", \"username\":\"optional\", \"password\":\"$pat\"},{\"endpoint\":\"https://okamba.pkgs.visualstudio.com/_packaging/OK.Shared/nuget/v3/index.json\", \"username\":\"optional\", \"password\":\"$pat\"}]}'" >> ~/.zshrc;
#fi

