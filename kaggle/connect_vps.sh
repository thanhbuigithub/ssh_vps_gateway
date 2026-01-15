#!/bin/bash
# connect_vps.sh - Script to connect Kaggle to VPS
# Usage: bash connect_vps.sh [VPS_IP] [VPS_PASSWORD]

VPS_HOST=${1:-""}
VPS_USER="tunnel"
VPS_PASS=${2:-""}

# 1. Input Collection
if [ -z "$VPS_HOST" ]; then
    read -p "Enter VPS IP/Domain: " VPS_HOST
fi

if [ -z "$VPS_PASS" ]; then
    echo "Enter VPS 'tunnel' user password:"
    read -s VPS_PASS
    echo ""
fi

# 2. Setup Local SSH Server (Target)
echo "========================================"
echo "   Setting up Kaggle SSH Server"
echo "========================================"

# Install dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq > /dev/null
apt-get install -y -qq openssh-server sshpass > /dev/null

# Configure SSHD
# Set a default password for the 'root' user on Kaggle so we can login
KAGGLE_PASSWORD="kaggle" # You can change this
echo "root:$KAGGLE_PASSWORD" | chpasswd

# Enable Root Login and Password Auth
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
echo "Connecting to $VPS_USER@$VPS_HOST..."

# We need to forward remote port 2222 to local port 22
# -o StrictHostKeyChecking=no : Auto accept fingerprint
# -R 2222:localhost:22 : Reverse port forward
# -N : No remote command
# -o ServerAliveInterval=60 : Keepalive

while true; do
    sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no \
                               -o UserKnownHostsFile=/dev/null \
                               -o ServerAliveInterval=60 \
                               -o ExitOnForwardFailure=yes \
                               -N -R 2222:localhost:22 \
                               $VPS_USER@$VPS_HOST
    
    echo ">> Tunnel Disconnected. Retrying in 5 seconds..."
    sleep 5
done
