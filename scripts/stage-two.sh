#/bin/bash

pat=$1

# Enable gnome extensions
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable gTile@vibou
systemctl --user enable --now ulauncher

# Azure artifacts credential provider
sh -c "$(wget -O- https://aka.ms/install-artifacts-credprovider.sh)"
if ! grep -q NUGET_PLUGIN_PATHS ~/.zshrc; then
	echo "export NUGET_PLUGIN_PATHS=\"~/.nuget/plugins/netcore/CredentialProvider.Microsoft/CredentialProvider.Microsoft.dll\"" >> ~/.zshrc;
fi

# This section might not be required - I need to test it
if [ "$pat" = "" ]; then
	echo "No Azure PAT";
else
	echo "export VSS_NUGET_EXTERNAL_FEED_ENDPOINTS='{\"endpointCredentials\": [{\"endpoint\":\"https://okamba.pkgs.visualstudio.com/_packaging/OK.Web/nuget/v3/index.json\", \"username\":\"optional\", \"password\":\"$pat\"},{\"endpoint\":\"https://okamba.pkgs.visualstudio.com/_packaging/OK.Shared/nuget/v3/index.json\", \"username\":\"optional\", \"password\":\"$pat\"}]}'" >> ~/.zshrc;
fi

# Google setup
gcloud auth login
gcloud auth configure-docker europe-west3-docker.pkg.dev
