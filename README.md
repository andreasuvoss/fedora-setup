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
### Getting Rider to show in the dock
In order for Rider to create a shortcut you need to run it once. Do it from the terminal with the following command and activate it with your JetBrains account
```
/opt/JetBrains\ Rider-2022.2.3/bin/rider.sh
```

### NuGet restore in Rider
The installation script already installs and sets up the required CredentialProvider plugin, however you need to set that in Rider aswell. On the following screenshot, you will see the setting at the very bottom

![Rider settings](https://raw.githubusercontent.com/andreasuvoss/fedora-setup/main/blob/rider-nuget.png)
Furthermore the first time you want to restore NuGet packages from a private feed, you will have to use the 
```shell
dotnet restore --interactive
```
command in the given project / solution and follow the instructions. Rider will not ask you for credentials.
