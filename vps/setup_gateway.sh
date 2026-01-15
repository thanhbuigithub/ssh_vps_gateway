#!/bin/bash
# setup_gateway.sh - Configuration script for the VPS Gateway
# Run this script on your VPS as root.

set -e

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting VPS Gateway Setup...${NC}"

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

# 1. Create 'tunnel' user
# This user is used by Kaggle to establish the reverse tunnel.
USERNAME="tunnel"
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists."
else
    echo "Creating user '$USERNAME'..."
    useradd -m -s /bin/bash $USERNAME
fi

echo -e "${GREEN}Set a password for the '${USERNAME}' user (You will need this for Kaggle):${NC}"
passwd $USERNAME

# 2. Configure SSHD
# functionality: AllowTcpForwarding is required for -R.
# GatewayPorts: 'clientspecified' allows binding to specific interfaces if needed, 
# but for localhost binding it's not strictly necessary, though good to ensure no restrictions.
SSHD_CONFIG="/etc/ssh/sshd_config"

echo "Configuring SSH Daemon..."

# Ensure AllowTcpForwarding is yes
if grep -q "^AllowTcpForwarding" $SSHD_CONFIG; then
    sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/' $SSHD_CONFIG
else
    echo "AllowTcpForwarding yes" >> $SSHD_CONFIG
fi

# Ensure GatewayPorts is yes or clientspecified (optional for loopback but good for flexibility)
if grep -q "^GatewayPorts" $SSHD_CONFIG; then
    sed -i 's/^GatewayPorts.*/GatewayPorts clientspecified/' $SSHD_CONFIG
else
    echo "GatewayPorts clientspecified" >> $SSHD_CONFIG
fi

# 3. Restart SSH
echo "Restarting SSH Service..."
service ssh restart

echo -e "${GREEN}VPS Setup Complete!${NC}"
echo "------------------------------------------------"
echo "Public IP: $(curl -s ifconfig.me)"
echo "User: $USERNAME"
echo "------------------------------------------------"
echo "You can now verify connection from Kaggle."
