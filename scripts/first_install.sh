#!/bin/bash

# VARIABLES
USER="railgun"
REPO_PATH="/home/$USER/configs"
BASHRC_PATH="/home/$USER/.bashrc"

# COLORED ECHO OUTPUT FUNCTIONS
echo_blue() {
    echo -e "\033[1;36m$1\033[0m"
}
echo_red() {
    echo -e "\033[1;31m$1\033[0m"
}
echo_green() {
    echo -e "\033[1;32m$1\033[0m"
}

echo_blue "Installing packages..."
sudo pacman -S --needed firefox nano vim git base-devel tmux ntfs-3g os-prober keepassxc hyfetch fastfetch less dpkg discord noto-fonts-emoji noto-fonts ttf-dejavu

# Create symlink and load .bashrc config
echo_blue "Deleting .bashrc from ~ and symlink to the repo's config"
rm "$BASHRC_PATH"
ln -sf "$REPO_PATH/bash/.bashrc" "$BASHRC_PATH"
echo_blue "Created symlink, loading config..."
source "$BASHRC_PATH"

# create directories
echo_blue "Creating directories..."
mkdir -p ~/git  ~/deb

# Template
# git clone --branch <package_name> --single-branch https://github.com/archlinux/aur.git

echo_blue "Cloning yay from AUR..."
if [ -d ~/git/yay ]; then
    echo_green "~/git/yay already exists"
    
    if command -v yay >/dev/null 2>&1; then
        echo_green "yay is installed"
    else
        echo_red "yay is not installed, attempting to clone and build..."
        git clone --branch yay --single-branch https://github.com/archlinux/aur.git ~/git/yay && cd ~/git/yay && makepkg -si
    fi   
else
    echo_red "~/git/yay not found"
    mkdir -p ~/git/yay
    echo_blue "Created ~/git/yay, cloning and buildung yay..."
    git clone --branch yay --single-branch https://github.com/archlinux/aur.git ~/git/yay && cd ~/git/yay && makepkg -si
fi


