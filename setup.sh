#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

echo "🚀 Updating system packages..."
apt update && apt upgrade -y

# ------------------------
# 🐳 Install Docker
# ------------------------
echo "🐳 Installing Docker..."

apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker service
systemctl enable docker
systemctl start docker

# Add current user to docker group
usermod -aG docker "$SUDO_USER"

echo "✅ Docker installed and started."

# ------------------------
# 🌐 Install GNS3
# ------------------------
echo "🌐 Installing GNS3..."

add-apt-repository ppa:gns3/ppa -y
apt update

# GNS3 and dependencies
apt install -y gns3-gui gns3-server \
    dynamips ubridge vpcs \
    qemu qemu-kvm libvirt-daemon-system \
    libvirt-clients bridge-utils virt-manager

# Add user to groups
usermod -aG ubridge "$SUDO_USER"
usermod -aG libvirt "$SUDO_USER"
usermod -aG kvm "$SUDO_USER"

echo "✅ GNS3 installed."

echo ""
echo "⚠️ Please log out and log back in for group changes to take effect."
echo "✅ Installation complete!"
