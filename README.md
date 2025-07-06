# 🚀 Ollama + Open WebUI One Click Installer [with SSL & Custom Domain] 🚀

![banner](https://user-images.githubusercontent.com/12424215/288237098-c5e6f8a6-1fd8-4efc-aea3-b5e295c3e7e7.png)

> **Instalasi AI Lokal Ter-CEPAT & Ter-Mudah!**  
> Satu script, deploy Ollama + Open WebUI dalam Docker, reverse proxy Nginx, dan SSL Let's Encrypt siap pakai—cukup 1x klik, langsung online di domain kamu!

---

## ✨ Fitur Utama

- ⚡ **Instalasi Otomatis:** Semua dependensi (Docker, Compose, Nginx, Certbot, dsb.) auto install!
- 🌍 **Custom Domain Support:** Langsung minta nama domain sendiri, siap HTTPS.
- 🔒 **SSL Let's Encrypt:** Gratis, otomatis, renew otomatis—langsung aman!
- 💬 **Open WebUI Modern:** Tampilan bersih, powerful, dan mudah diakses siap digunakan siapa saja.
- 🐳 **Dockerized:** Gampang deploy, gampang update, mudah backup, tanpa ribet setup manual.
- 🧠 **CPU Ready:** Tidak butuh GPU, langsung jalan di VPS/cloud manapun.
- 🚀 **Proven untuk Pemula & Pro!**

---

## 📸 Demo Screenshot

<img src="https://raw.githubusercontent.com/open-webui/open-webui/main/docs/screenshot.png" alt="Open WebUI Screenshot" width="700"/>

---

## 🛠️ Cara Instalasi

### 1. **Siapkan VPS/Server**
- OS **Ubuntu 22.04/24.04** (direkomendasikan)
- Punya **akses root/sudo**
- Domain aktif (A Record sudah diarahkan ke IP VPS Anda)

### 2. **Jalankan Script Installer**

```bash
wget https://raw.githubusercontent.com/your-repo/ollama-openwebui-nginx-ssl/main/install.sh
bash install.sh
