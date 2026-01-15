#!/bin/bash
# connect_vps.sh - Script to connect Kaggle to VPS
# Usage: bash connect_vps.sh [VPS_HOST] [KEY_FILE]
# Example: bash connect_vps.sh 1.2.3.4 ./kaggle_key

VPS_HOST=${1:-""}
KEY_FILE=${2:-""}
VPS_USER="tunnel"

# 1. Input Validation
if [ -z "$VPS_HOST" ]; then
    echo "Error: VPS_HOST argument missing."
    echo "Usage: bash connect_vps.sh <VPS_IP> <KEY_FILE>"
    exit 1
fi

if [ -z "$KEY_FILE" ]; then
    echo "Error: KEY_FILE argument missing."
    exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file '$KEY_FILE' not found."
    exit 1
fi

# Set correct permissions for key (SSH is picky)
chmod 600 "$KEY_FILE"

# 2. Setup Local SSH Server (Target)
echo "========================================"
echo "   Setting up Kaggle SSH Server"
echo "========================================"

# Install dependencies - Removed sshpass as we are using keys
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq > /dev/null
apt-get install -y -qq openssh-server > /dev/null

# Configure SSHD
# Set a default password for the 'root' user on Kaggle so we can login
KAGGLE_PASSWORD="kaggle" # You can change this
echo "root:$KAGGLE_PASSWORD" | chpasswd

# Enable Root Login and Password Auth for INCOMING connections (from Windows)
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

echo ">> SSH Server Installed."
echo ">> Local Root Password: $KAGGLE_PASSWORD"

# 3. Establish Tunnel
echo "========================================"
echo "   Establishing Reverse Tunnel"
echo "========================================"
echo "Connecting to $VPS_USER@$VPS_HOST using Key: $KEY_FILE..."

# We need to forward remote port 2222 to local port 22
# -i $KEY_FILE : Use Private Key
# -R 2222:localhost:22 : Reverse port forward
while true; do
    ssh -i "$KEY_FILE" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ServerAliveInterval=60 \
        -o ExitOnForwardFailure=yes \
        -N -R 2222:localhost:22 \
        $VPS_USER@$VPS_HOST
    
    echo ">> Tunnel Disconnected. Retrying in 5 seconds..."
    sleep 5
done
