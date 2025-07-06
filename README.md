# 🚀 Ollama & Open WebUI Autoinstall Script for Ubuntu 24.04 LTS

**Automated, secure, and production-ready installation of [Ollama](https://ollama.com/) and [Open WebUI](https://github.com/open-webui/open-webui) on Ubuntu 24.04 LTS, with full SSL support, reverse proxy, automatic Docker image update, and robust firewall.**

---

## ✨ Features

- **One-command installation** for Ollama (LLM inference backend) & Open WebUI (beautiful AI chat interface)
- **Domain validation**: Ensures your custom domain is properly pointed to your server before proceeding
- **Automatic SSL (Let's Encrypt)**: Secures your WebUI with HTTPS
- **Nginx reverse proxy**: Your WebUI accessible via your domain with SSL
- **Firewall (UFW)**: Locks down the server to SSH, HTTP, HTTPS only — Docker’s internal port is NOT exposed publicly
- **Docker auto-update**: Always pulls the latest stable Open WebUI image at every install/upgrade
- **Certbot auto-renewal check**: Reminds you if SSL renewal is not active
- **Idempotent**: Re-running the script will never break your system or reinstall what is already configured

---

## 🖥️ Requirements

- Ubuntu 24.04 LTS (clean VPS recommended)
- A domain/subdomain pointing **A record** to your server’s public IPv4
- Port 22, 80, 443 must be available and not blocked by any other service
- Access as a user with `sudo` privileges

---

## 🚦 Quick Start

1. **Clone or download this repository:**
    ```bash
    git clone https://github.com/yourusername/ollama-openwebui-autoinstall.git
    cd ollama-openwebui-autoinstall
    ```

2. **Make the installer executable:**
    ```bash
    chmod +x install.sh
    ```

3. **Run the script:**
    ```bash
    ./install.sh
    ```

4. **Follow the prompts:**
   - Input your domain (must already resolve to this server’s public IP)
   - The script will handle everything else automatically!

---

## 🔒 Security & Best Practice

- **Firewall**: Only SSH (22), HTTP (80), and HTTPS (443) are open. Docker port (3000) is only accessible via Nginx on localhost.
- **SSL**: HTTPS enabled by default using Let’s Encrypt and auto-renew checked via systemd.
- **Automatic Updates**: Open WebUI Docker image is updated every script run for latest security/features.
- **Reverse Proxy**: All traffic routed through Nginx; your AI interface never exposed on a raw port.

---

## 🛠️ What’s Installed & Configured

- **Docker Engine**
- **Ollama** (runs as a systemd service for robust LLM inference backend)
- **Nginx** (reverse proxy for SSL/HTTPS)
- **Certbot** for free SSL certificate with Let’s Encrypt
- **UFW** firewall (automatically configured)
- **Open WebUI** as a Docker container (auto-updated and restart policy enabled)

---

## 📦 Script Logic Overview

- Installs Docker, Nginx, Certbot, UFW if not present
- Sets up systemd service for Ollama backend (runs at boot)
- Prompts for domain and verifies domain resolves to server IP
- Configures Nginx reverse proxy for Open WebUI
- Requests SSL certificate for your domain (auto renew enabled)
- Pulls and runs latest Open WebUI container, mapping to localhost only
- Enables UFW, only allows necessary ports
- Script is safe to rerun anytime

---

## 🌐 Accessing Your AI WebUI

- Once finished, open:

*(Replace with your real domain.)*

---

## 💡 Troubleshooting

- **Domain/IP mismatch:**  
If your domain does not resolve to your server’s IP, the script will halt and prompt you to fix your DNS.

- **SSL renewal warnings:**  
If certbot.timer is not active, follow instructions in the script output to activate automatic renewal.

- **Firewall issues:**  
Only port 22, 80, 443 are open; ensure your SSH port is 22 or adapt the script if you use custom SSH.

- **Docker/WebUI not starting:**  
Run `docker logs open-webui -f` or check `journalctl -u ollama -f` for backend logs.

---

## 🤝 Contributing

PRs, issues, and improvements are welcome!  
Feel free to fork or open issues for enhancements.

---

## ⚠️ Disclaimer

- This script is intended for **personal/self-hosted and internal use**.
- **No warranty provided. Use at your own risk.**
- For commercial/production, further hardening and monitoring are recommended.

---

## 📃 License

MIT

---

## ✨ Credits

- [Ollama](https://ollama.com/)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Let's Encrypt](https://letsencrypt.org/)

---

> **Deploy local AI models securely, with a professional chat UI, in minutes.**

---

**Happy self-hosting! 🚀**
