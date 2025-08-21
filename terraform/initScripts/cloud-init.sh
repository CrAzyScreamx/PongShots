#! /bin/bash

sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$${VERSION_CODENAME}}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Setting up environment
mkdir /app
cd /app

sudo tee /app/docker-compose.yml.tmp > /dev/null <<'EOF'
${docker_compose_yml}
EOF

export WATCHTOWER_INTERVAL=${watchtower_interval}
envsubst < /app/docker-compose.yml.tmp > /app/docker-compose.yml

# Clean up temporary file
rm /app/docker-compose.yml.tmp

sudo docker compose up -d