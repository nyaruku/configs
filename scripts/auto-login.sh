#!/bin/bash
# one-time-ly-autologin.sh
# This script enables a one-time auto-login for the ly login manager and reboots immediately.

USER="railgun"
LY_CONFIG="/etc/ly/config.ini"
LY_BACKUP="/etc/ly/config.ini.bak"

# Check if ly config exists
if [ ! -f "$LY_CONFIG" ]; then
    echo "Error: $LY_CONFIG not found. Is ly installed?"
    exit 1
fi

echo "Backing up original ly config..."
sudo cp "$LY_CONFIG" "$LY_BACKUP"

echo "Setting one-time auto-login for user: $USER..."
sudo sed -i "s/^autologin *=.*$/autologin = $USER/" "$LY_CONFIG"

echo "Rebooting now..."
sudo reboot

# Note: After reboot, restore original config manually or via another script:
# sudo mv /etc/ly/config.ini.bak /etc/ly/config.ini

