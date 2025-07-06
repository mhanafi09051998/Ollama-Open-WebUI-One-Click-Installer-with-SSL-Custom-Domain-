#!/usr/bin/env bash

# install.sh - Instalasi Ollama CLI & Web GUI dengan Docker, plus SSL Let's Encrypt via Nginx
# Penggunaan: sudo bash install.sh

set -euo pipefail

# 0. Input domain & email
read -rp "🌐 Masukkan domain Anda (misal: gaharinovasiteknologi.com): " DOMAIN
read -rp "📧 Masukkan email untuk registrasi Let's Encrypt: " EMAIL

# Konstanta
WEBUI_IMAGE="ghcr.io/open-webui/open-webui:ollama"
CONTAINER_NAME="open-webui"
HOST_PORT=3000
CONTAINER_PORT=8080
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}.conf"

# 1. Update & install dependensi
echo "[*] Memperbarui sistem dan menginstal paket dasar..."
apt-get update && apt-get upgrade -y
apt-get install -y docker.io nginx certbot python3-certbot-nginx curl

# 2. Install Ollama CLI (tanpa Snap)
echo "[*] Menginstal Ollama CLI..."
curl -fsSL https://ollama.com/install.sh | sh

# 3. Enable & start Docker & Nginx
echo "[*] Mengaktifkan layanan Docker & Nginx..."
systemctl enable docker.service nginx.service
systemctl start docker.service nginx.service

# 4. Jalankan Open WebUI (Ollama) di Docker, mount model dari host
echo "[*] Menarik dan menjalankan container Open-WebUI..."
docker pull ${WEBUI_IMAGE}
docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 127.0.0.1:${HOST_PORT}:${CONTAINER_PORT} \
  -v /root/.ollama:/root/.ollama \
  ${WEBUI_IMAGE}

# 5. Konfigurasi Nginx sebagai reverse proxy
echo "[*] Menulis konfigurasi Nginx untuk ${DOMAIN}..."
cat > ${NGINX_CONF} <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${HOST_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# 6. Dapatkan & pasang SSL Let's Encrypt
echo "[*] Mengambil sertifikat SSL untuk ${DOMAIN}..."
certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL}

# 7. Reload Nginx akhir
systemctl reload nginx

# 8. Ringkasan
cat <<EOF

🎉 Instalasi Selesai!
- Ollama CLI terinstal: jalankan 'ollama pull <model>' via SSH.
- Open WebUI + Ollama berjalan di Docker pada localhost:${HOST_PORT}
- Akses: https://${DOMAIN}/
- SSL dikelola otomatis oleh Let's Encrypt

EOF


