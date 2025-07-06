#!/bin/bash

# install.sh – Full setup: Docker Ollama + Open WebUI + Nginx SSL (custom domain, https)
# Jalankan dengan: bash install.sh

set -e

echo "==========================================="
echo "   INSTALASI OLLAMA + OPEN WEBUI + SSL"
echo "==========================================="
read -rp "Masukkan domain untuk akses (contoh: gaharai.fun): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
    echo "ERROR: Domain tidak boleh kosong!"
    exit 1
fi

EMAIL="admin@$DOMAIN"
PROJECT_DIR="$HOME/ollama-webui"
WEBUI_PORT=3000

echo
echo "Domain yang digunakan: $DOMAIN"
echo "Email untuk SSL: $EMAIL"
echo "Pastikan domain sudah diarahkan ke IP server ini (A record DNS sudah benar)!"
echo "Tekan ENTER untuk melanjutkan, CTRL+C untuk batalkan..."
read

echo "==== [1/7] Update & install dependencies ===="
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "==== [2/7] Install Docker & Compose ===="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "==== [3/7] Add user ke grup docker ===="
sudo usermod -aG docker $USER
echo "===> Jika baru pertama kali install Docker, logout/login ulang agar akses Docker tanpa sudo."

echo "==== [4/7] Deploy Docker Compose Ollama + Open WebUI ===="
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

cat << EOF > docker-compose.yml
version: '3.8'
services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    ports:
      - "0.0.0.0:11434:11434"
    volumes:
      - ollama-data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
    restart: always

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    depends_on:
      - ollama
    ports:
      - "0.0.0.0:${WEBUI_PORT}:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434
      - WEBUI_HOST=0.0.0.0
    restart: always

volumes:
  ollama-data:
EOF

docker compose up -d

echo "==== [5/7] Install Nginx & Certbot ===="
sudo apt install -y nginx certbot python3-certbot-nginx

echo "==== [6/7] Konfigurasi Nginx reverse proxy ===="
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:${WEBUI_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # Websocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
sudo nginx -t && sudo systemctl reload nginx

echo "==== [7/7] Request & Pasang SSL (Let's Encrypt) ===="
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

echo
echo "==============================================="
echo "Semua proses selesai!"
echo
echo "Open WebUI Ollama siap diakses di: https://$DOMAIN"
echo
echo "Catatan:"
echo "- Jika install Docker pertama kali, logout-login dulu agar bisa pakai Docker tanpa sudo."
echo "- Jika port 80/443 error saat SSL, cek firewall/cloud provider."
echo "- Untuk cek status Docker: cd \$HOME/ollama-webui && docker compose ps"
echo "- Untuk log error: docker compose logs"
echo "- Untuk stop service: docker compose down"
echo
echo "SSL dari Let's Encrypt otomatis diperpanjang oleh certbot."
echo "==============================================="
