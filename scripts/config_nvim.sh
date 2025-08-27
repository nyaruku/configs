#!/bin/bash

# VARIABLES
USER="railgun"
REPO_PATH="/home/${USER}/configs"
NVIM_CONFIG_DIR="/home/${USER}/.config/nvim"
LAZY_PATH="/home/${USER}/.local/share/nvim/site/pack/lazy/start/lazy.nvim"

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

echo_blue "Installing lazy.nvim if missing..."
if [ ! -d "$LAZY_PATH" ]; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
    echo_green "lazy.nvim installed successfully."
else
    echo_green "lazy.nvim already installed."
fi

echo_blue "Creating Neovim config directory..."
mkdir -p "$NVIM_CONFIG_DIR"
echo_green "Config directory ensured at $NVIM_CONFIG_DIR."

echo_blue "Creating symlink for init.lua from repo..."
ln -sf "${REPO_PATH}/nvim/init.lua" "${NVIM_CONFIG_DIR}/init.lua"
echo_green "Symlink created: ${NVIM_CONFIG_DIR}/init.lua -> ${REPO_PATH}/nvim/init.lua"

echo_blue "Installing plugins with lazy.nvim (this may take a moment)..."
nvim --headless -c 'Lazy sync' -c 'qa'
echo_green "Plugins installed successfully!"

echo_blue "Setup complete! Launch nvim and enjoy your configured setup."

