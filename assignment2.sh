#!/bin/bash

set -e  # Exit the  script if any command fails

# Update netplan configuration
echo "Updating netplan configuration..."
cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.16.21/24
EOF

# Update /etc/hosts
echo "Updating /etc/hosts..."
sed -i '/server1/d' /etc/hosts  # Remove old entry if exists
echo "192.168.16.21 server1" >> /etc/hosts

# Install the required  software
echo "Installing apache2 and squid..."
apt-get update
apt-get install -y apache2 squid

# Configure firewall (ufw)
echo "Configuring firewall (ufw)..."
ufw allow from 192.168.16.0/24 to any port 22  
ufw allow from 192.168.16.0/24 to any port 80  
ufw allow from 192.168.16.0/24 to any port 3128  
ufw --force enable

# Create user accounts and configure SSH keys
echo "Creating user accounts and configuring SSH keys..."
declare -A users=(
  ["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
  ["aubrey"]=""
  ["captain"]=""
  ["snibbles"]=""
  ["brownie"]=""
  ["scooter"]=""
  ["sandy"]=""
  ["perrier"]=""
  ["cindy"]=""
  ["tiger"]=""
  ["yoda"]=""
)

for user in "${!users[@]}"; do
  # Create user if not exists
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
  fi

  # Add SSH keys
  mkdir -p "/home/$user/.ssh"
  echo "${users[$user]}" >> "/home/$user/.ssh/authorized_keys"
  chown -R "$user:$user" "/home/$user/.ssh"
  chmod 700 "/home/$user/.ssh"
  chmod 600 "/home/$user/.ssh/authorized_keys"

  # Add sudo access for dennis
  if [ "$user" == "dennis" ]; then
    usermod -aG sudo "$user"
  fi
done

echo "Setup complete."
