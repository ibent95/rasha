# 📑 DOKUMEN IDENTITAS MEREK: RASHA

RASHA adalah super app modern dengan fondasi filosofis luhur yang dirancang
untuk menjadi ruang ekosistem digital terpadu demi memenuhi segala kebutuhan,
harapan, dan kenyamanan mobilitas masyarakat modern.

------------------------------

## 1. STRUKTUR KONSEP & FILOSOFI

* Asal Kata Murni: Dilahirkan dari peleburan jujur tata bahasa Sansekerta
  antara kata Manoratha (मनोरथ - Impian/Cita-cita)
  dan Akasha (आकाश - Ruang/Semesta Terbuka Tanpa Batas).
* Arti Harfiah: "Ruang Impian" (The Universe of Dreams).
* Dinamisme Nama: Penggunaan inisial huruf R memberikan impresi psikologis
  berupa kecepatan (velocity), ketepatan (precision), dan solusi instan.
* Slogan Resmi (Tagline):

RASHA: Ruang Impian dalam Satu Genggaman.

------------------------------

## 2. PENJABARAN PALET WARNA (BRAND COLORS)

Kombinasi warna ini mengawinkan energi teknologi yang berani
(Merah/Jingga/Kuning) dengan stabilitas fungsionalitas harian
yang ramah lingkungan dan aman (Hijau & Putih).

|-------------------|-------------|----------|---------------------------------|
|       Peran       |    Nama     |   Kode   | Representasi Filosofis          |
|       Warna       |    Warna    |   HEX    | & Psikologis                    |

|-------------------|-------------|----------|---------------------------------|
| Utama (Primary)   | Crimson Red | #E53935  | Melambangkan hasrat,            |
|                   |             |          | energi tanpa batas,             |
|                   |             |          | keberanian berinovasi,          |
|                   |             |          | dan aksi nyata.                 |

|-------------------|-------------|----------|---------------------------------|
| Sekunder          | Blaze       | #FB8C00  | Melambangkan kreativitas,       |
| (Secondary)       | Orange      |          | kehangatan layanan,             |
|                   |             |          | optimisme, dan aksesibilitas.   |

|-------------------|-------------|----------|---------------------------------|
| Aksen Impian      | Vivid       | #FDD835  | Melambangkan kejayaan,          |
|                   | Yellow      |          | keceriaan,                      |
|                   |             |          | masa depan cerah,               |
|                   |             |          | dan pencapaian cita-cita.       |

|-------------------|-------------|----------|---------------------------------|
| Aksen Ekosistem   | Eco Green   | #4CAF50  | Melambangkan pertumbuhan        |
|                   |             |          | ekonomi, keberlanjutan,         |
|                   |             |          | rasa aman, dan                  |
|                   |             |          | keseimbangan hidup.             |

|-------------------|-------------|----------|---------------------------------|
| Warna Dasar       | Pure White  | #FFFFFF  | Melambangkan transparansi       |
|                   |             |          | sistem, integritas,             |
|                   |             |          | kejelasan visi, dan kemudahan.  |

|-------------------|-------------|----------|---------------------------------|
| Latar Aplikasi    | Dark        | #121214  | Latar belakang premium yang     |
|                   | Obsidian    |          | memberikan kontras tinggi dan   |
|                   |             |          | kenyamanan visual mata (UI).    |

------------------------------

## 3. IDENTITAS VISUAL (KODE SVG ASSET)

Kode SVG di bawah ini adalah representasi logo RASHA v9 (Professional). Logo ini
menggabungkan huruf "R" geometris tebal yang dibangun dari tiga stroke terstruktur
(batang vertikal, lengkung mangkuk melengkung, kaki diagonal) menggunakan gradien
Merah-Jingga-Kuning (passion -> kreativitas -> kejayaan). Sebuah cincin orbit Hijau
miring mengelilingi R dari belakang (simbol Akasha/Ruang Multi-layanan) dengan
gradien kedalaman (terang -> redup) yang menunjukkan dimensi 3D. Kaki huruf R
menembus cincin orbit dan berujung pada Bintang Kutub Putih (simbol Manoratha/
Impian tertinggi) yang berbentuk kompas 4-titik memanjang. Titik Bulan kecil di
sisi berlawanan cincin melengkapi pemandangan "semesta kecil".

Keunggulan v9 dibanding versi sebelumnya:
- Huruf R menggunakan stroke tebal 62px dengan geometri yang presisi (bukan sketsa)
- Gradien menggunakan gradientUnits="userSpaceOnUse" agar bekerja pada semua bentuk
- Konsisten di semua ukuran dari favicon 16px hingga billboard
Anda dapat menyalin (copy) seluruh kode di bawah ini secara utuh dan menyimpannya
sebagai file berformat .svg untuk langsung digunakan pada web atau aplikasi:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" width="100%" height="100%">
  <defs>
    <linearGradient id="rGrad" gradientUnits="userSpaceOnUse" x1="260" y1="590" x2="560" y2="210">
      <stop offset="0%" stop-color="#E53935"/>
      <stop offset="50%" stop-color="#FB8C00"/>
      <stop offset="100%" stop-color="#FDD835"/>
    </linearGradient>
    <linearGradient id="orbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4CAF50" stop-opacity="0.95"/>
      <stop offset="55%" stop-color="#4CAF50" stop-opacity="0.55"/>
      <stop offset="100%" stop-color="#4CAF50" stop-opacity="0.10"/>
    </linearGradient>
    <radialGradient id="starGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FDD835" stop-opacity="0.4"/>
      <stop offset="40%" stop-color="#FDD835" stop-opacity="0.12"/>
      <stop offset="100%" stop-color="#FDD835" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <rect width="800" height="800" fill="#121214"/>

  <!-- Cahaya Bintang (di belakang segalanya) -->
  <circle cx="560" cy="565" r="75" fill="url(#starGlow)"/>

  <!-- Cincin Orbit Akasha: ellipse miring di belakang R -->
  <ellipse cx="410" cy="400" rx="260" ry="195" transform="rotate(-18 410 400)"
    fill="none" stroke="url(#orbitGrad)" stroke-width="18"
    stroke-linecap="round" opacity="0.85"/>

  <!-- Huruf R Geometris: batang -> lengkung mangkuk -> kaki diagonal -->
  <path d="M 300,580 L 300,230"
    fill="none" stroke="url(#rGrad)" stroke-width="62" stroke-linecap="round"/>
  <path d="M 300,230 C 400,218 530,260 530,370 C 530,450 460,490 380,490"
    fill="none" stroke="url(#rGrad)" stroke-width="62"
    stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M 380,490 L 560,565"
    fill="none" stroke="url(#rGrad)" stroke-width="62" stroke-linecap="round"/>

  <!-- Bintang Kutub Putih: kompas 4-titik memanjang -->
  <path d="M 560,525 L 567,550 L 592,565 L 567,580 L 560,605 L 553,580 L 528,565 L 553,550 Z"
    fill="#FFFFFF"/>

  <!-- Titik Bulan di sisi berlawanan cincin -->
  <circle cx="200" cy="310" r="11" fill="#FFFFFF" opacity="0.85"/>

  <!-- Wordmark -->
  <text x="400" y="700" font-family="Inter,'Segoe UI',system-ui,sans-serif" font-size="44" font-weight="800" fill="#FFFFFF" letter-spacing="14" text-anchor="middle">RASHA</text>
  <text x="400" y="738" font-family="Inter,'Segoe UI',system-ui,sans-serif" font-size="15" font-weight="500" fill="#8E8E93" letter-spacing="5" text-anchor="middle">RUANG IMPIAN</text>
</svg>
```

------------------------------

## 4. IMPLEMENTASI STRUKTUR ORGANISASI KORPORASI

Untuk menjaga agar sisi komersial aplikasi tetap tajam di mata publik
tanpa membuang nama legalitas Anda, berikut adalah rekomendasi arsitektur penamaannya:

   1. Nama Entitas Hukum (PT):
       PT Rohan Manorathakasha Digital atau PT Rasha Ekosistem Nusantara
   2. Nama Merek Konsumen (App Store / Play Store):
       RASHA atau RASHA Super App

```txt
rasha\
...
 services\
  svc-core-laravel (can be accessed by all apps / websites if necessary)
  svc-crm-laravel
  svc-dynamic-form-laravel
  svc-erp-laravel (or maube can be moduliraze more)
  ...
...
 websites\
  web-portal-angular (main page, first website)
  web-crm-angular (customer relationship management)
  web-dynamic-form-angular (form builder like Google Forms)
  web-erp-angular (or maube can be moduliraze more)
  ...
...
```
