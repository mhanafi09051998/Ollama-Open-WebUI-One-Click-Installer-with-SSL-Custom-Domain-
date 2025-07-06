#!/usr/bin/env bash
set -e

# ====== 🔍 Logging semua output ke file ======
exec > >(tee -i /var/log/ollama-install.log)
exec 2>&1

echo "🚀 Installer Ollama + Open WebUI + SSL + CLI-GUI Sinkron oleh Gahar Inovasi Teknologi"

# 1. Input domain
read -rp "🌐 Masukkan domain Anda (contoh: gaharai.fun): " DOMAIN

# 2. Install dependensi
echo "📦 Menginstall Docker, Certbot, dan Nginx..."
apt update
apt install -y curl apt-transport-https ca-certificates gnupg software-properties-common lsb-release
apt install -y nginx certbot python3-certbot-nginx ufw

# 3. Firewall setup (UFW)
echo "🛡️ Mengatur firewall..."
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

# 4. Install Docker jika belum ada
if ! command -v docker &> /dev/null; then
  echo "🐳 Menginstall Docker..."
  curl -fsSL https://get.docker.com | sh
fi

# 5. Pastikan Docker aktif
echo "▶️ Memastikan Docker aktif..."
systemctl start docker
systemctl enable docker

# 6. Deteksi GPU
USE_CPU="false"
if ! command -v nvidia-smi &> /dev/null; then
  echo "⚠️ GPU tidak terdeteksi. Menggunakan mode CPU."
  USE_CPU="true"
else
  echo "✅ GPU terdeteksi. Menggunakan mode GPU."
fi

# 7. Jalankan container Ollama (jika belum ada)
if docker ps -a --format '{{.Names}}' | grep -q "^ollama$"; then
  echo "♻️ Container 'ollama' sudah ada. Melewati pembuatan ulang."
else
  echo "🧠 Menjalankan container Ollama..."
  if [ "$USE_CPU" = "true" ]; then
    docker run -d \
      --name ollama \
      --restart always \
      -v ollama:/root/.ollama \
      -e OLLAMA_MODE=cpu \
      -p 11434:11434 \
      ollama/ollama
  else
    docker run -d \
      --gpus all \
      --name ollama \
      --restart always \
      -v ollama:/root/.ollama \
      -p 11434:11434 \
      ollama/ollama
  fi
fi

# 8. Jalankan Open WebUI (jika belum ada)
if docker ps -a --format '{{.Names}}' | grep -q "^open-webui$"; then
  echo "♻️ Container 'open-webui' sudah ada. Melewati pembuatan ulang."
else
  echo "🖥️ Menjalankan Open WebUI..."
  docker run -d \
    --name open-webui \
    --restart always \
    -p 8080:8080 \
    -v ollama:/root/.ollama \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:ollama
fi

# 9. Setup Nginx reverse proxy
echo "⚙️ Menyiapkan Nginx reverse proxy untuk $DOMAIN..."
cat > /etc/nginx/sites-available/open-webui <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/open-webui /etc/nginx/sites-enabled/open-webui
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl start nginx && systemctl reload nginx

# 10. Deteksi SSL
SSL_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
if [ -f "$SSL_PATH" ]; then
  echo "🔒 SSL sudah ada. Melewati Certbot."
else
  echo "🔐 Mendapatkan sertifikat SSL Let's Encrypt..."
  certbot --nginx --non-interactive --agree-tos -m admin@$DOMAIN -d $DOMAIN
fi

# 11. Tambahkan auto-renew SSL via cron
echo "🔁 Menjadwalkan perpanjangan otomatis SSL..."
echo "0 3 * * * root certbot renew --quiet" > /etc/cron.d/ssl-renew

# 12. Jalankan model llama3
echo "📥 Menarik dan menjalankan model llama3..."
docker exec ollama ollama pull llama3
docker exec ollama ollama run llama3

# 13. Tambah banner login SSH
echo "🎉 Menambahkan banner login SSH..."
echo "🚀 Selamat datang di server Gahar AI - https://$DOMAIN" > /etc/motd

# DONE!
echo "✅ Instalasi selesai!"
echo "🌐 GUI: https://$DOMAIN"
echo "💡 Jalankan model lain via CLI: docker exec -it ollama ollama run <nama_model>"
