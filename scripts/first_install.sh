#!/bin/bash

sudo pacman -S --needed firefox nano vim git base-devel tmux ntfs-3g os-prober keepassxc hyfetch fastfetch

# Load bash config if it exists
if [ -f ../bash/.bashrc ]; then
    source ../bash/.bashrc
else
    echo "Warning: ~/.bashrc not found!"
fi

# create git folder for git clones
mkdir -p ~/git

# Template
# git clone --branch <package_name> --single-branch https://github.com/archlinux/aur.git

echo "Cloning yay from AUR..."


mkdir -p ~/git/yay
git clone --branch yay --single-branch https://github.com/archlinux/aur.git ~/git/yay && cd ~/git/yay && makepkg -si
