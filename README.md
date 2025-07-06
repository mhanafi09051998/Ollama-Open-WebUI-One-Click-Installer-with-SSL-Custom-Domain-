# *Ollama Auto-Pull Installer with SSL* 🔥

*README ini akan memandu Anda untuk instalasi Ollama CLI & Web UI dengan Docker, plus Sertifikat SSL Let's Encrypt melalui Nginx.* 😊

## *✨ Fitur Utama*:

1. Instalasi **Ollama CLI** tanpa Snap
2. Wrapper `ollama run` otomatis melakukan *pull* model sebelum dijalankan
3. Deploy **Open WebUI** (Ollama) di Docker
4. Konfigurasi **Nginx** sebagai *reverse proxy*
5. Otomatisasi **Let's Encrypt SSL** untuk domain Anda

## *🚀 Persiapan*:

1. VPS dengan sistem operasi **Ubuntu** (atau turunannya)
2. Akses **root** atau `sudo`
3. Domain aktif dan dapat diakses publik

## *💡 Cara Penggunaan*:

1. *Clone* repo ini:

   ```bash
   git clone https://github.com/username/ollama-auto-pull-ssl.git
   cd ollama-auto-pull-ssl
   ```
2. Beri izin eksekusi pada `install.sh`:

   ```bash
   sudo chmod +x install.sh
   ```
3. Jalankan skrip instalasi:

   ```bash
   sudo bash install.sh
   ```
4. Ikuti *prompt* untuk memasukkan:
   • Domain Anda (misal: `contoh.com`)
   • Email untuk registrasi Let's Encrypt

## *📑 Ringkasan Hasil*:

* **Ollama CLI** terpasang dengan wrapper auto-pull
* **Open WebUI** berjalan di Docker pada `localhost:3000`
* **Nginx** melayani permintaan dan mengarahkan ke WebUI
* **SSL** aktif dan dikelola otomatis oleh Let's Encrypt
* Akses: `https://DOMAIN-ANDAMU/` 🔒

## *👨‍💻 Struktur Folder*:

1. `install.sh` • Skrip utama instalasi
2. `README.md` • Dokumentasi ini

## *⚙️ Kustomisasi*:

1. Ubah port Docker di variabel `HOST_PORT` jika perlu
2. Sesuaikan nama image WebUI di `WEBUI_IMAGE`
3. Edit template Nginx di file `install.sh` untuk opsi lanjutan

## *👍 Lisensi*

Repository ini dilisensikan di bawah *MIT License*. Lihat file `LICENSE` untuk detail.

---

*Selamat mencoba dan semoga sukses!* 🎉
