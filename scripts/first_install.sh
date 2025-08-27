#!/bin/bash

# VARIABLES
USER="railgun"
REPO_PATH="/home/$USER/configs"
HOME_PATH="/home/$USER"

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

echo_red "Make sure to enable multilib in /etc/pacman.conf"
read -p "Press Enter to continue..."

echo_blue "Installing packages..."
sudo pacman -Sy --needed firefox nano vim git base-devel tmux ntfs-3g os-prober keepassxc hyfetch fastfetch less dpkg discord noto-fonts-emoji noto-fonts ttf-dejavu kitty steam gparted dosfstools mtools unzip zip spotify

git config --global init.defaultBranch master
echo_green "Set git config to use master as default branch"

# Create symlinks for configs
echo_blue "Creating symlinks for config files"
rm "$BASHRC_PATH"
ln -sf "$REPO_PATH/bash/.bashrc" "$HOME_PATH/.bashrc"
ln -sf "$REPO_PATH/vim/.vimrc" "$HOME_PATH/.vimrc"

echo_blue "Loading .bashrc config..."
source "$HOME_PATH/.bashrc"

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

echo_blue "Installing packages from AUR..."
# AUR package list
aur_packages=(
  spotify
  bauh
  pulsemeeter
)
# Loop through each package
for pkg in "${aur_packages[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo_green "$pkg is already installed..."
    else
        echo_blue "Installing $pkg..."
        yay -S --noconfirm "$pkg"
        echo_green "Installed $pkg"
    fi
done


cd "$HOME_PATH"

