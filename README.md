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
