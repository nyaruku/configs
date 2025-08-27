#!/bin/bash

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

# Install TPM if missing
echo_blue "Checking TPM (tmux plugin manager)..."
if [ ! -d "${HOME_PATH}/.tmux/plugins/tpm" ]; then
    echo_blue "TPM not found, cloning..."
    git clone https://github.com/tmux-plugins/tpm "${HOME_PATH}/.tmux/plugins/tpm"
    echo_green "TPM installed successfully."
else
    echo_green "TPM already installed."
fi

# Create symlink for tmux.conf
echo_blue "Creating symlink for tmux.conf..."
ln -sf "${REPO_PATH}/tmux/.tmux.conf" "${HOME_PATH}/.tmux.conf"
echo_green "Symlink created: ${HOME_PATH}/.tmux.conf -> ${REPO_PATH}/tmux/.tmux.conf"

# Reload tmux config if tmux server is running
if tmux info &> /dev/null; then
    echo_blue "Reloading tmux config..."
    tmux source-file "${HOME_PATH}/.tmux.conf"
else
    echo_blue "Tmux server not running, start a tmux session to load config."
fi

# Install plugins via TPM (needs tmux session)
if tmux info &> /dev/null; then
    echo_blue "Installing tmux plugins via TPM..."
    # Run TPM install command in tmux client mode to avoid attaching
    tmux run-shell "${HOME_PATH}/.tmux/plugins/tpm/bin/install_plugins"
    echo_green "Plugins installed successfully."
else
    echo_red "Tmux is not running. Please start a tmux session and press prefix + I to install plugins."
fi

echo_green "Tmux configuration complete!"

