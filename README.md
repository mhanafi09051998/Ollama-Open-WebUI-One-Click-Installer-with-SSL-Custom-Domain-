# Ollama + Open WebUI Auto Installer

A production-ready, automated installer script for deploying [Ollama](https://ollama.com/) and [Open WebUI](https://github.com/open-webui/open-webui) with Docker, SSL (Let's Encrypt), and a custom domain on Ubuntu 24.04 LTS.  
This script streamlines the setup of an AI inference server complete with a secure reverse proxy and firewall, suitable for production VPS environments.

---

## Features

- **Automated installation** of Docker & Docker Compose
- **Deploys Ollama & Open WebUI** in Docker containers
- **Reverse proxy** with Nginx and SSL (Let's Encrypt/Certbot)
- **Custom domain setup** with domain verification (via IPv4 ping)
- **Automatic UFW firewall** configuration
- **Simple and interactive CLI**

---

## Requirements

- Ubuntu 24.04 LTS (fresh server recommended)
- A root or sudo-enabled user
- An active domain already pointing (A record) to your server's IPv4 address

---

## Usage

1. **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/ollama-openwebui-auto-installer.git
    cd ollama-openwebui-auto-installer
    ```

2. **Make the installer executable:**
    ```bash
    chmod +x install.sh
    ```

3. **Run the installer as root (or with sudo):**
    ```bash
    sudo ./install.sh
    ```

4. **Follow the on-screen instructions:**
   - Enter your custom domain (e.g. `yourdomain.com`) when prompted.
   - Ensure your domain's A record points to your VPS IPv4 before proceeding.

---

## What Does The Script Do?

- Installs Docker, Docker Compose, Nginx, and Certbot
- Pulls and runs [Ollama](https://ollama.com/) and [Open WebUI](https://github.com/open-webui/open-webui) via Docker containers
- Prompts for your domain, then verifies it via IPv4 ping
- Configures Nginx as a secure reverse proxy with SSL
- Opens necessary firewall ports (80, 443, 3000, 11434, SSH)

---

## Add Models to Ollama

After installation, you can add models using:

```bash
docker exec -it ollama ollama pull llama3
