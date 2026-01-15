#!/bin/bash
# setup_gateway.sh - Configuration script for the VPS Gateway
# Run this script on your VPS as root.

set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
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

# Note: We do NOT force a password set if the goal is Key Auth, 
# but it's good practice to have one or lock it.
# echo -e "${GREEN}Set a password for the '${USERNAME}' user (Optional if using keys):${NC}"
# passwd $USERNAME

# 2. SSH Key Setup
echo -e "\n${GREEN}SSH Key Setup${NC}"
USER_HOME=$(eval echo ~$USERNAME)
SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
mkdir -p $SSH_DIR
chmod 700 $SSH_DIR
chown $USERNAME:$USERNAME $SSH_DIR

KEY_NAME="kaggle_key"
KEY_PATH="$USER_HOME/$KEY_NAME"

read -p "Generate a new SSH Key Pair for Kaggle? [y/N] " GENERATE_KEY
if [[ "$GENERATE_KEY" =~ ^[Yy]$ ]]; then
    if [ -f "$KEY_PATH" ]; then
        echo "Key $KEY_PATH already exists. Skipping generation."
    else
        echo "Generating new SSH Key Pair..."
        # Generate key as the user to get permissions right
        su - $USERNAME -c "ssh-keygen -t rsa -b 4096 -f ~/$KEY_NAME -q -N \"\""
    fi
    
    # Add public key to authorized_keys
    cat "$KEY_PATH.pub" >> "$AUTH_KEYS"
    chmod 600 "$AUTH_KEYS"
    chown $USERNAME:$USERNAME "$AUTH_KEYS"
    
    echo -e "${GREEN}Key Generated!${NC}"
    echo "----------------------------------------------------------------"
    echo -e "${RED}COPY THE PRIVATE KEY BELOW TO YOUR KAGGLE NOTEBOOK:${NC}"
    echo "----------------------------------------------------------------"
    cat "$KEY_PATH"
    echo "----------------------------------------------------------------"
    echo -e "${GREEN}End of Private Key${NC}"
else
    echo "Skipping key generation."
    echo "Ensure you add your Public Key to: $AUTH_KEYS"
# fi

# # 3. Configure SSHD
# # functionality: AllowTcpForwarding is required for -R.
# # GatewayPorts: 'clientspecified' allows binding to specific interfaces if needed.
# SSHD_CONFIG="/etc/ssh/sshd_config"

# echo -e "\nConfiguring SSH Daemon..."

# # Ensure AllowTcpForwarding is yes
# if grep -q "^AllowTcpForwarding" $SSHD_CONFIG; then
#     sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/' $SSHD_CONFIG
# else
#     echo "AllowTcpForwarding yes" >> $SSHD_CONFIG
# fi

# # Ensure GatewayPorts is yes or clientspecified
# if grep -q "^GatewayPorts" $SSHD_CONFIG; then
#     sed -i 's/^GatewayPorts.*/GatewayPorts clientspecified/' $SSHD_CONFIG
# else
#     echo "GatewayPorts clientspecified" >> $SSHD_CONFIG
# fi

# # Ensure PubkeyAuthentication is yes
# if grep -q "^PubkeyAuthentication" $SSHD_CONFIG; then
#     sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD_CONFIG
# else
#     echo "PubkeyAuthentication yes" >> $SSHD_CONFIG
# fi

# 4. Restart SSH
echo "Restarting SSH Service..."
service ssh restart

echo -e "${GREEN}VPS Setup Complete!${NC}"
echo "------------------------------------------------"
echo "Public IP: $(curl -s ifconfig.me)"
echo "User: $USERNAME"
echo "------------------------------------------------"
if [[ "$GENERATE_KEY" =~ ^[Yy]$ ]]; then
    echo "Don't forget to save the Private Key from above!"
fi
