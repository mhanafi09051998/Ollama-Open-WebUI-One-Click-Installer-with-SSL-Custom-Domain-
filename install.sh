# 1. Update sistem & install dependensi
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git docker.io docker-compose

# 2. Enable & start docker
sudo systemctl enable --now docker

# 3. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 4. Enable & start ollama service
sudo systemctl enable --now ollama

# 5. Setup folder kerja untuk Open WebUI
mkdir ~/ollama-webui && cd ~/ollama-webui

# 6. Buat file docker-compose.yml
cat <<EOF > docker-compose.yml
version: "3.8"
services:
  ollama-webui:
    image: open-webui/open-webui:main
    restart: always
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://host.docker.internal:11434
    volumes:
      - open-webui-data:/app/backend/data
    depends_on:
      - ollama
  ollama:
    image: ollama/ollama
    restart: always
    volumes:
      - ollama-data:/root/.ollama
    network_mode: host
volumes:
  open-webui-data:
  ollama-data:
EOF

# 7. Jalankan WebUI & Ollama via Docker
docker compose up -d
