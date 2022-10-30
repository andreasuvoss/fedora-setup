# Quick setup
This is a repository containing scripts for easily setting up my C# development environment.

## Installation
Run at your own risk. Run in multiple stages. 
### Install
The install script downloads and installs a lot of important applications and tools
```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/scripts/install.sh)"
```
Restart or relog before running stage two
### Configure
This scrips sets a lot of Gnome settings
```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/scripts/configure.sh)"
```
### Install Oh My Zsh
Follow the guide at https://github.com/ohmyzsh/ohmyzsh/wiki or pray and run the script
```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
### Installing Rider with JetBrains Toolbox
Use the JetBrains toolbox to install Rider, the toolbox can be found here
https://www.jetbrains.com/lp/toolbox/

### NuGet restore in Rider
The installation script already installs and sets up the required CredentialProvider plugin, however you need to set that in Rider aswell. On the following screenshot, you will see the setting at the very bottom

![Rider settings](https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/blob/rider-nuget.png)
Furthermore the first time you want to restore NuGet packages from a private feed, you will have to use the 
```shell
dotnet restore --interactive
```
command in the given project / solution and follow the instructions. Rider will not ask you for credentials.

### Gnome extensions
Not all gnome extension installations can be scripted, so a few will have to be installed manually.

* https://github.com/corecoding/Vitals
* https://github.com/gTile/gTile
