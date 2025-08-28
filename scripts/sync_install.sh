#!/bin/bash

##############################################################
#                     SETUP SCRIPT                           #
# ( CAN BE USED TO SYNC AN ALREADY CONFIGURED INSTALLATION ) #
##############################################################
# DISTRO: ARCH LINUX                                         #
##############################################################

# VARIABLES
USER="railgun"
REPO_PATH="/home/${USER}/configs"
HOME_PATH="/home/${USER}"

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

echo_red "Make sure to enable multilib in /etc/pacman.conf before you continue"
read -p "Press Enter to continue..."

echo_blue "Installing packages..."
packages=(
    firefox
    nano
    vim
    git
    base-devel
    tmux
    ntfs-3g
    os-prober
    keepassxc
    hyfetch
    fastfetch
    less
    dpkg
    discord
    noto-fonts-emoji
    noto-fonts
    ttf-dejavu
    kitty
    steam
    gparted
    dosfstools
    mtools
    unzip
    zip
    nvim
    xclip
    xorg-xcursorgen
    xcur2png
    tree
    icoutils
    imagemagick
    xfwm4-themes
    lxappearance
    glxinfo
    gnome-tweaks
    obs-studio
    flameshot
    libva
    libva-nvidia-driver
    wine
    wine-mono
    wine-gecko
    lib32-glibc
    lib32-gcc-libs
    lib32-mesa
    lib32-nvidia-utils
    winetricks
)

sudo pacman -Sy --needed "${packages[@]}"

git config --global init.defaultBranch master
echo_green "Set git config to use master as default branch"

# Create directories
echo_blue "Creating directories..."
dirs=(
    "$HOME/git"
    "$HOME/deb"
    "$HOME/.config/nvim"
    "$HOME/.config/nvim/lua"
    "$HOME/.config/kitty"
    "$HOME/.config/flameshot"
    "$HOME/.themes/railv1"
    "$HOME/.icons"
    "$HOME/.icons/default"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    echo_green "Created: $dir"
done

# Create symlinks for configs
echo_blue "Creating symlinks for config files"

declare -A SYMLINKS=(
  ["${REPO_PATH}/bash/.bashrc"]="${HOME_PATH}/.bashrc"
  ["${REPO_PATH}/vim/.vimrc"]="${HOME_PATH}/.vimrc"
  ["${REPO_PATH}/tmux/tmux.conf"]="${HOME_PATH}/.tmux.conf"
  ["${REPO_PATH}/nvim/init.vim"]="${HOME_PATH}/.config/nvim/init.vim"
  ["${REPO_PATH}/kitty/kitty.conf"]="${HOME_PATH}/.config/kitty/kitty.conf"
  ["${REPO_PATH}/flameshot/flameshot.ini"]="${HOME_PATH}/.config/flameshot/flameshot.ini"
  ["${REPO_PATH}/theme/wm/railv1/xfwm4"]="${HOME_PATH}/.themes/railv1/xfwm4" #broken but works
  ["${REPO_PATH}/theme/cursor/ml_blau"]="${HOME_PATH}/.icons/ml_blau"
  ["${REPO_PATH}/theme/cursor/default_index.theme"]="${HOME_PATH}/.icons/default.theme"
  ["${REPO_PATH}/theme/icons/breeze_chameleon_dark"]="${HOME_PATH}/.icons/breeze_chameleon_dark"
  ["${REPO_PATH}/theme/gtk-theme/Nord-Black-Frost"]="${HOME_PATH}/.themes/Nord-Black-Frost"
)

for SRC in "${!SYMLINKS[@]}"; do
    DEST="${SYMLINKS[$SRC]}"
    mkdir -p "$(dirname "$DEST")"
    ln -sf "$SRC" "$DEST"
    echo_green "Symlinked: $SRC -> $DEST"
done

echo_blue "Applying WM Theme..."
xfconf-query -c xfwm4 -p /general/theme -s "railv1"

# Download and install AUR
echo_blue "Checking yay..."
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
  win2xcur
  nvtop
  debtap
  steam-acolyte
  lutris
  opentabletdriver
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

cd "${HOME_PATH}"

echo_blue "Loading .bashrc config..."
source "$HOME_PATH/.bashrc"

echo_blue "Note: You need to restart an Application to apply the cursor"
