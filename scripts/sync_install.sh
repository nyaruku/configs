#!/bin/bash

##############################################################
#                     SETUP SCRIPT                           #
# ( CAN BE USED TO SYNC AN ALREADY CONFIGURED INSTALLATION ) #
##############################################################
# DISTRO: ARCH LINUX                                         #
# WM: HYPRLAND (WAYLAND)                                     #
# ( MAY NOT WORK WITH OTHER DISTRIBUTIONS )                  #
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

# --------------------
# ARGUMENT PARSING / HELP
# --------------------

HEADLESS=0
FORCE_GPU=""

# Check if --help exists anywhere in the arguments
if [[ " $* " == *" --help "* ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -n        Force NVIDIA GPU package selection"
    echo "  -a        Force AMD GPU package selection"
    echo "  -h        Headless mode (no GUI packages)"
    echo "  --help    Show this help message and exit"
    exit 0
fi

# Parse short flags
while getopts "nah" opt; do
    case $opt in
        n) FORCE_GPU="NVIDIA" ;;
        a) FORCE_GPU="AMD" ;;
        h) HEADLESS=1 ;;
        *) echo "Try '$0 --help' for usage."; exit 1 ;;
    esac
done

# --------------------
# NOW SET VARIABLES
# --------------------
SYNC_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(realpath "$SYNC_PATH/../")"

echo_blue "USER: '$USER'"
echo_blue "HOME_PATH: '$HOME'"
echo_blue "REPO_PATH: '$REPO_PATH'"
echo_blue "SYNC_PATH: '$SYNC_PATH'"

echo_red "Make sure to enable multilib in /etc/pacman.conf before you continue"
read -p "Press Enter to continue..."

base_packages=(
    nano
    vim
    nvim
    git
    base-devel
    tmux
    ntfs-3g
    os-prober
    hyfetch
    fastfetch
    less
    dpkg
    noto-fonts-emoji
    noto-fonts
    ttf-dejavu
    unzip
    zip
    xclip
    tree
    imagemagick
    cmake
    noto-fonts-cjk
	btop
)

desktop_packages=(
    firefox
    chromium
    discord
    kitty
    steam
    gparted
    dosfstools
    mtools
    xorg-xcursorgen
    xcur2png
    icoutils
    xfwm4-themes
    lxappearance
    glxinfo
    gnome-tweaks
    libva
    mpv
	keepassxc
    #obs-studio
    #flameshot
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
    "${HOME}/.config/pipewire"
    "${HOME}/.config/mpv"
)

# Add GUI dirs only if not headless
if [[ "$HEADLESS" != 1 ]]; then
    dirs+=(
        "${HOME}/.config/kitty"
        #"${HOME}/.config/flameshot"
        #"${HOME}/.config/emacs"
        "${HOME}/.themes/railv1"
        "${HOME}/.icons"
        "${HOME}/.icons/default"
    )
fi

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    echo_green "Created: $dir"
done

# Create symlinks for configs
echo_blue "Creating symlinks for config files"

# Non-GUI symlinks (always)
declare -A SYMLINKS=(
  ["${REPO_PATH}/bash/.bashrc"]="${HOME}/.bashrc"
  ["${REPO_PATH}/vim/.vimrc"]="${HOME}/.vimrc"
  ["${REPO_PATH}/tmux/tmux.conf"]="${HOME}/.tmux.conf"
  ["${REPO_PATH}/nvim/init.lua"]="${HOME}/.config/nvim/init.lua"
  ["${REPO_PATH}/nvim/lua"]="${HOME}/.config/nvim/lua"
  ["${REPO_PATH}/mpv/mpv.conf"]="${HOME}/.config/mpv/mpv.conf"
  ["${REPO_PATH}/bash-git-prompt"]="${HOME}/.bash-git-prompt"
  ["${REPO_PATH}/starship/starship.toml"]="${HOME}/.config/starship.toml"
)

# GUI symlinks (only desktop)
if [[ "$HEADLESS" != 1 ]]; then
    SYMLINKS["${REPO_PATH}/kitty/kitty.conf"]="${HOME}/.config/kitty/kitty.conf"
    #SYMLINKS["${REPO_PATH}/emacs/init.el"]="${HOME}/.emacs"
    SYMLINKS["${REPO_PATH}/theme/gtk-theme/Nord-Black-Frost"]="${HOME}/.themes/Nord-Black-Frost"
    SYMLINKS["${REPO_PATH}/hypr"]="${HOME}/.config/hypr"
    SYMLINKS["${REPO_PATH}/anyrun"]="${HOME}/.config/anyrun"
    SYMLINKS["${REPO_PATH}/waybar"]="${HOME}/.config/waybar"
    SYMLINKS["${REPO_PATH}/fontconfig"]="${HOME}/.config/fontconfig"
    SYMLINKS["${REPO_PATH}/fastfetch"]="${HOME}/.config/fastfetch"
fi

for SRC in "${!SYMLINKS[@]}"; do
    DEST="${SYMLINKS[$SRC]}"
    mkdir -p "$(dirname "$DEST")"

    # prevent accidental self-referential symlinks
    if [[ "$(realpath -m "$SRC")" == "$(realpath -m "$DEST")" ]]; then
        echo_red "Skipping self-symlink: $SRC == $DEST"
        continue
    fi

    ln -snf "$SRC" "$DEST"
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

aur_packages_desktop=(
  spotify
  bauh
  pulsemeeter
  win2xcur
  nvtop
  steam-acolyte
  lutris
  opentabletdriver
  obs-studio-browser
  ffmpeg-obs
  pinta
  spotify-1.1
)

aur_packages_server=(
  debtap
)

# Select AUR packages based on HEADLESS
if [[ "$HEADLESS" == 1 ]]; then
    aur_packages=("${aur_packages_server[@]}")
    echo_blue "Headless mode: Installing server AUR packages only"
else
    aur_packages=("${aur_packages_desktop[@]}" "${aur_packages_server[@]}")
    echo_blue "Desktop mode: Installing desktop + server AUR packages"
fi

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
