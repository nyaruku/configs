#!/bin/bash

##############################################################
#                     SETUP SCRIPT                           #
# ( CAN BE USED TO SYNC AN ALREADY CONFIGURED INSTALLATION ) #
##############################################################
# DISTRO: ARCH LINUX                                         #
##############################################################

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

# VARIABLES
SYNC_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(realpath "$SYNC_PATH/../")"

echo_blue "USER: '$USER'"
echo_blue "REPO_PATH: '$REPO_PATH'"
echo_blue "HOME_PATH: '$HOME'"

echo_red "Make sure to enable multilib in /etc/pacman.conf before you continue"
read -p "Press Enter to continue..."

packages=(
    firefox
	chromium
    nano
    vim
	nvim
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
    #obs-studio
    #flameshot
    libva
    libva-nvidia-driver
    wine-staging
    wine-mono
    wine-gecko
    winetricks
    mpv
	noto-fonts-cjk
	cmake
)

nvidia_packages=(
    libva-nvidia-driver
    lib32-glibc
    lib32-gcc-libs
    lib32-mesa
    lib32-nvidia-utils
)

amd_packages=(
    mesa
    mesa-vdpau
    lib32-mesa
    lib32-mesa-vdpau
    vulkan-radeon
    lib32-vulkan-radeon
)

# --------------------

FORCE_GPU=""
while getopts "na" opt; do
    case $opt in
        n) FORCE_GPU="NVIDIA" ;;
        a) FORCE_GPU="AMD" ;;
        *) echo "Usage: $0 [-n (force NVIDIA)] [-a (force AMD)]"; exit 1 ;;
    esac
done

# -------------------------
# DETECT GPU
# -------------------------
if [[ -n "$FORCE_GPU" ]]; then
    GPU_VENDOR="$FORCE_GPU"
    echo_blue "GPU override: $GPU_VENDOR"
else
    GPU_VENDOR=$(lspci | grep -E "VGA|3D" | grep -E "AMD|NVIDIA" | awk '{print $5}' | head -n1)
fi

# -------------------------
# SELECT PACKAGES
# -------------------------
if [[ "$GPU_VENDOR" == "NVIDIA" ]]; then
    echo_blue "Detected NVIDIA GPU"
    packages=("${base_packages[@]}" "${nvidia_packages[@]}")
elif [[ "$GPU_VENDOR" == "AMD" ]]; then
    echo_blue "Detected AMD GPU"
    packages=("${base_packages[@]}" "${amd_packages[@]}")
else
    echo_red "No AMD or NVIDIA GPU detected. Installing only base packages."
    packages=("${base_packages[@]}")
fi

# -------------------------

echo_blue "Installing packages..."
sudo pacman -Sy --needed "${packages[@]}"

git config --global init.defaultBranch master
echo_green "Set git config to use master as default branch"

# Create directories
echo_blue "Creating directories..."
dirs=(
    "${HOME}/git"
    "${HOME}/deb"
    "${HOME}/.config/nvim"
    "${HOME}/.config/nvim/lua"
    "${HOME}/.config/kitty"
    #"${HOME}/.config/flameshot"
    #"${HOME}/.config/emacs"
    "${HOME}/.config/pipewire"
    "${HOME}/.themes/railv1"
    "${HOME}/.icons"
    "${HOME}/.icons/default"
    "${HOME}/.config/mpv"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    echo_green "Created: $dir"
done

# Create symlinks for configs
echo_blue "Creating symlinks for config files"

declare -A SYMLINKS=(
  ["${REPO_PATH}/bash/.bashrc"]="${HOME}/.bashrc"
  ["${REPO_PATH}/vim/.vimrc"]="${HOME}/.vimrc"
  ["${REPO_PATH}/tmux/tmux.conf"]="${HOME}/.tmux.conf"
  ["${REPO_PATH}/nvim/init.vim"]="${HOME}/.config/nvim/init.vim"
  ["${REPO_PATH}/kitty/kitty.conf"]="${HOME}/.config/kitty/kitty.conf"
  #["${REPO_PATH}/flameshot/flameshot.ini"]="${HOME}/.config/flameshot/flameshot.ini"
  #["${REPO_PATH}/emacs/init.el"]="${HOME}/.emacs"
  ["${REPO_PATH}/mpv/mpv.conf"]="${HOME}/.config/mpv/mpv.conf"
  ["${REPO_PATH}/bash-git-prompt"]="${HOME}/.bash-git-prompt"

  # OLD THEME (x11 | xfce4), TODO: (KDE | Wayland)
  #["${REPO_PATH}/theme/wm/railv1/xfwm4"]="${HOME}/.themes/railv1/xfwm4" #broken but works
  #["${REPO_PATH}/theme/cursor/ml_blau"]="${HOME}/.icons/ml_blau"
  #["${REPO_PATH}/theme/cursor/default_index.theme"]="${HOME}/.icons/default.theme"
  #["${REPO_PATH}/theme/icons/breeze_chameleon_dark"]="${HOME}/.icons/breeze_chameleon_dark"
  ["${REPO_PATH}/theme/gtk-theme/Nord-Black-Frost"]="${HOME}/.themes/Nord-Black-Frost"
)

for SRC in "${!SYMLINKS[@]}"; do
    DEST="${SYMLINKS[$SRC]}"
    mkdir -p "$(dirname "$DEST")"
    ln -sf "$SRC" "$DEST"
    echo_green "Symlinked: $SRC -> $DEST"
done

# symlink pipewire
for f in ${REPO_PATH}/pipewire/*; do
    ln -sf "$f" "${HOME}/.config/pipewire/"
    echo_green "Symlinked: $f -> ${HOME}/.config/pipewire/"
done

#echo_blue "Applying WM Theme..."
#xfconf-query -c xfwm4 -p /general/theme -s "railv1"

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
  debtap
  obs-studio-browser
  ffmpeg-obs
  #gamescope-git
  pinta
  spotify-1.1
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

cd "$HOME"

echo_blue "Loading .bashrc config..."
source "${HOME}/.bashrc"

echo_blue "All Done"
