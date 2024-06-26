#/bin/bash

### Install nerd-font
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git; cd nerd-fonts; git sparse-checkout add patched-fonts/Hack; ./install.sh Hack; cd ..; rm -rf nerd-fonts;
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git; cd nerd-fonts; git sparse-checkout add patched-fonts/JetBrainsMono; ./install.sh JetBrainsMono; cd ..; rm -rf nerd-fonts;

### Gnome settings ###
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+altgr-intl')]"
gsettings set org.gnome.desktop.session idle-delay 120
gsettings set org.gnome.desktop.peripherals.mouse accel-profile flat 
gsettings set org.gnome.desktop.peripherals.mouse speed -0.24545454545454548
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"
gsettings set org.gnome.desktop.interface icon-theme Papirus
gsettings set org.gnome.desktop.background picture-uri ""
gsettings set org.gnome.desktop.background picture-uri-dark ""
gsettings set org.gnome.desktop.background primary-color "#000000"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.nautilus.preferences default-folder-viewer list-view
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set com.gexperts.Tilix.Settings terminal-title-style none

# Better Alt-tabbing (each window not each application)
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward  "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward  "[]"

# Switch workspace shortcut (works on 60% keyboards)
gsettings set org.freedesktop.ibus.panel.emoji hotkey "@as []"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>comma']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>period']"

# Dash to dock settings
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 28
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style "SQUARES"
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell favorite-apps "[\
	'org.gnome.Nautilus.desktop',\
	'firefox.desktop',\
	'jetbrains-rider.desktop',\
	'com.microsoft.Teams.desktop',\
	'com.gexperts.Tilix.desktop',\
	'com.getpostman.Postman.desktop',\
	'pgadmin4.desktop',\
	'com.slack.Slack.desktop',\
	'discord.desktop',\
	'org.remmina.Remmina.desktop',\
	'com.spotify.Client.desktop'\
]"

# Enable gnome extensions
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com

# Git config
git config --global user.email "andreas@anvo.dk"
git config --global user.name "Andreas Voss"
git config --global --add --bool push.autoSetupRemote true

# Install and apply theme
mkdir -p ~/temp-themes && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git ~/temp-themes && ~/temp-themes/install.sh; rm -rf ~/temp-themes
gsettings set org.gnome.desktop.interface gtk-theme Matcha-dark-azul

# ulauncher settings
tmp=$(mktemp) && cat ~/.config/ulauncher/settings.json | jq '."hotkey-show-app" = "<Primary><Alt>Control_R" | ."render-on-screen" = "default-monitor" | ."theme-name" = "dark"' > "$tmp" && mv -f "$tmp" ~/.config/ulauncher/settings.json
systemctl --user restart ulauncher

### Custom keyboard shortcuts ###
# This might not work perfectly yet
# I would like to automate this more, but shell scripting it kind of sucks.

# Flameshot workaround for Wayland
sudo tee /usr/local/bin/flameshot-gui-workaround > /dev/null <<'EOF'
#!/bin/bash
flameshot gui

EOF

sudo chmod a+x /usr/local/bin/flameshot-gui-workaround

# In the for loop put the number of indicies you have defined shortcuts for
total_list="[";
for i in {0..2}; do
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

# Flameshot shortcut
gsettings set org.gnome.shell.keybindings show-screenshot-ui '[]'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "'Flameshot'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "'Print'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "'/usr/local/bin/flameshot-gui-workaround'"

# More Tilix
wget https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/config/tilix.dconf
dconf load /com/gexperts/Tilix/ < tilix.dconf
rm tilix.dconf
nautilus -q
glib-compile-schemas ~/.local/share/glib-2.0/schemas/
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal tilix

# GDM Monitors
if [ -f ~/.config/monitors.xml ]; then
	sudo cp -v ~/.config/monitors.xml /var/lib/gdm/.config/
    sudo chown gdm:gdm /var/lib/gdm/.config/monitors.xml
fi

sudo echo 'GTK_THEME="Matcha-dark-azul"' >> /etc/environment

# Azure
az config set core.output=table

# Google setup
if [ ! -f ~/.config/gcloud/application_default_credentials.json ]; then
		gcloud auth login
		gcloud auth application-default login
		gcloud auth configure-docker europe-west3-docker.pkg.dev
fi
