# 🚀 Ollama + WebUI Installer with Auto SSL & CLI Integration

Skrip `install.sh` ini akan mengatur seluruh ekosistem AI Ollama kamu hanya dalam satu perintah!  
Cocok untuk VPS atau server Linux Ubuntu. Tersedia GUI Web dan kontrol penuh lewat SSH/CLI. 😎

---

## 🔧 Fitur Utama

✅ Instalasi otomatis **Ollama CLI**  
✅ Jalankan **WebUI di Docker** dengan dukungan model lokal  
✅ Otomatis **SSL HTTPS** dengan Let's Encrypt  
✅ **CLI auto-pull model**: `ollama run` langsung unduh model jika belum ada  
✅ Bisa **install model dari SSH**, dan langsung muncul di WebUI  
✅ Support **reverse proxy** Nginx

---

## 🧠 Persyaratan

- VPS dengan OS Ubuntu 20.04/22.04
- Akses root (`sudo`)
- Domain aktif & sudah mengarah ke IP VPS (A Record)

---

## 🚀 Cara Instalasi

```bash
sudo bash install.sh
