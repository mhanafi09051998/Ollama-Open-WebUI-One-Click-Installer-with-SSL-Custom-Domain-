#!/bin/bash
# ===================================================================================
# Skrip Instalasi Otomatis untuk Ollama, Open WebUI, dan Nginx dengan SSL
# ===================================================================================
#
# Deskripsi:
# Skrip ini akan menginstal dan mengonfigurasi komponen berikut:
# 1. Docker & Docker Compose - Untuk menjalankan Open WebUI dalam container.
# 2. Nginx - Sebagai reverse proxy dengan SSL (HTTPS) dari Let's Encrypt.
# 3. Certbot - Untuk mengelola sertifikat SSL secara otomatis.
# 4. Ollama - LLM runner yang berjalan sebagai service di host.
# 5. Open WebUI - Antarmuka web untuk Ollama.
#
# Prasyarat:
# - Server baru dengan sistem operasi Debian/Ubuntu.
# - Akses root atau pengguna dengan hak sudo.
# - DNS A Record untuk domain Anda HARUS sudah mengarah ke IP server ini.
#
# ===================================================================================

# --- Konfigurasi ---
# Domain yang akan digunakan untuk mengakses Open WebUI.
# PASTIKAN DNS A Record untuk domain ini sudah menunjuk ke IP server Anda.
DOMAIN="gaharaiv2.com"

# Email untuk pendaftaran Let's Encrypt (penting untuk notifikasi pemulihan/perpanjangan).
ADMIN_EMAIL="admin@example.com" # <-- GANTI DENGAN EMAIL ANDA YANG VALID

# Port internal yang akan digunakan oleh container Open WebUI.
# Sebaiknya tidak diubah kecuali ada konflik port di server Anda.
WEBUI_HOST_PORT="8080"

# --- Akhir Konfigurasi ---


# Hentikan skrip jika terjadi error
set -e

echo "============================================================"
echo "Memulai Instalasi Ollama & Open WebUI untuk domain: $DOMAIN"
echo "Dengan konfigurasi SSL (Let's Encrypt)."
echo "============================================================"
echo ""

# --- Langkah 1: Update Sistem dan Instal Dependensi Dasar ---
echo "--> Langkah 1: Memperbarui sistem dan menginstal dependensi..."
sudo apt-get update
sudo apt-get install -y curl wget gnupg apt-transport-https ca-certificates software-properties-common

echo "Dependensi dasar berhasil diinstal."
echo ""


# --- Langkah 2: Instal Docker Engine ---
echo "--> Langkah 2: Menginstal Docker Engine..."
if ! command -v docker &> /dev/null
then
    echo "Docker tidak ditemukan. Memulai instalasi..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker berhasil diinstal dan dijalankan."
else
    echo "Docker sudah terinstal. Melewati langkah ini."
fi
echo ""


# --- Langkah 3: Instal Nginx dan Certbot ---
echo "--> Langkah 3: Menginstal Nginx dan Certbot..."
if ! command -v nginx &> /dev/null
then
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "Nginx berhasil diinstal."
else
    echo "Nginx sudah terinstal."
fi
if ! command -v certbot &> /dev/null
then
    sudo apt-get install -y certbot python3-certbot-nginx
    echo "Certbot berhasil diinstal."
else
    echo "Certbot sudah terinstal."
fi
echo ""


# --- Langkah 4: Instal Ollama ---
echo "--> Langkah 4: Menginstal Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
echo "Ollama berhasil diinstal. Service ollama sedang berjalan."
echo ""

# --- Langkah 4.1: Unduh Model Awal (Contoh: llama3) ---
echo "--> Langkah 4.1: Mengunduh model awal 'llama3' melalui CLI..."
# Perintah ini akan mengunduh model dan membuatnya langsung tersedia di WebUI
sudo ollama pull llama3
echo "Model 'llama3' berhasil diunduh."
echo ""


# --- Langkah 5: Jalankan Open WebUI menggunakan Docker ---
echo "--> Langkah 5: Menjalankan Open WebUI melalui Docker..."
if [ "$(sudo docker ps -q -f name=open-webui)" ]; then
    echo "Container open-webui yang sudah ada ditemukan. Menghentikan dan menghapusnya..."
    sudo docker stop open-webui
    sudo docker rm open-webui
fi
sudo docker run -d -p ${WEBUI_HOST_PORT}:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
echo "Container Open WebUI berhasil dijalankan pada port $WEBUI_HOST_PORT."
echo ""


# --- Langkah 6: Konfigurasi Nginx dan Ambil Sertifikat SSL ---
echo "--> Langkah 6: Mengonfigurasi Nginx dan mendapatkan sertifikat SSL..."

# Buat file konfigurasi Nginx dasar untuk domain
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$WEBUI_HOST_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Aktifkan site
if [ ! -L /etc/nginx/sites-enabled/$DOMAIN ]; then
    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
fi

# Hapus link konfigurasi default jika ada
if [ -L /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Cek apakah sertifikat sudah ada. Jika tidak, minta sertifikat baru.
if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
    echo "Sertifikat SSL untuk $DOMAIN tidak ditemukan. Meminta sertifikat baru..."
    # Hentikan Nginx sementara untuk certbot standalone atau pastikan port 80 bebas
    sudo systemctl stop nginx
    # Minta sertifikat. Certbot akan memodifikasi konfigurasi Nginx secara otomatis.
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $ADMIN_EMAIL --redirect
    echo "Sertifikat SSL berhasil dibuat."
else
    echo "Sertifikat SSL untuk $DOMAIN sudah ada. Melewati permintaan sertifikat."
fi

# Restart Nginx untuk menerapkan semua perubahan
echo "Restart Nginx untuk menerapkan konfigurasi akhir..."
sudo systemctl restart nginx
echo ""


# --- Selesai ---
echo "============================================================"
echo "🎉 Instalasi Selesai! 🎉"
echo "============================================================"
echo ""
echo "Open WebUI sekarang seharusnya dapat diakses melalui URL aman:"
echo "URL: https://$DOMAIN"
echo ""
echo "Catatan Penting:"
echo "1. Pengguna pertama yang mendaftar di web UI akan otomatis menjadi admin."
echo "2. Model 'llama3' sudah terinstal. Anda bisa langsung menggunakannya."
echo "3. Untuk menambah model lain via SSH, cukup jalankan perintah:"
echo "   sudo ollama run <nama_model_lain>"
echo "   Contoh: sudo ollama run mistral"
echo "   Model tersebut akan otomatis muncul di daftar model pada WebUI."
echo "4. Perpanjangan SSL akan berjalan otomatis."
echo ""
