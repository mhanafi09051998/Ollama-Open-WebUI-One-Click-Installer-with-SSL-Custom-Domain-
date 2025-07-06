#!/usr/bin/env bash

# install.sh - Instalasi Ollama CLI & Web GUI dengan Docker, plus SSL Let's Encrypt via Nginx
# Menambahkan wrapper sehingga 'ollama run' otomatis melakukan pull model.
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

# 3. Buat wrapper untuk 'ollama run' -> auto pull
echo "[*] Membuat wrapper untuk 'ollama run' sehingga auto pull..."
# Pindahkan binary asli
ORIG_BIN="$(which ollama)"
mv "$ORIG_BIN" /usr/local/bin/ollama-real
# Buat wrapper baru
cat > /usr/local/bin/ollama << 'EOF'
#!/usr/bin/env bash
if [ "$1" = "run" ]; then
  shift
  /usr/local/bin/ollama-real pull "$@"
  exec /usr/local/bin/ollama-real run "$@"
else
  exec /usr/local/bin/ollama-real "$@"
fi
EOF
chmod +x /usr/local/bin/ollama

# 4. Enable & start Docker & Nginx
echo "[*] Mengaktifkan layanan Docker & Nginx..."
systemctl enable docker.service nginx.service
systemctl start docker.service nginx.service

# 5. Jalankan Open WebUI (Ollama) di Docker, mount model dari host
echo "[*] Menarik dan menjalankan container Open-WebUI..."
docker pull ${WEBUI_IMAGE}
docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 127.0.0.1:${HOST_PORT}:${CONTAINER_PORT} \
  -v /root/.ollama:/root/.ollama \
  ${WEBUI_IMAGE}

# 6. Konfigurasi Nginx sebagai reverse proxy
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

# 7. Dapatkan & pasang SSL Let's Encrypt
echo "[*] Mengambil sertifikat SSL untuk ${DOMAIN}..."
certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL}

# 8. Reload Nginx akhir
systemctl reload nginx

# 9. Ringkasan
cat <<EOF

🎉 Instalasi Selesai!
- Ollama CLI terinstal dengan wrapper auto-pull.
- Untuk menjalankan model: 'ollama run <model-name>' otomatis akan mengunduh model jika belum ada.
- Open WebUI + Ollama berjalan di Docker pada localhost:${HOST_PORT}
- Akses: https://${DOMAIN}/
- SSL dikelola otomatis oleh Let's Encrypt

EOF
