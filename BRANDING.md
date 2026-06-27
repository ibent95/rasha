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

Kode SVG di bawah ini adalah representasi logo RASHA. Logo ini menggabungkan
huruf "R" geometris yang melebur dinamis menggunakan gradien Merah-Jingga-Kuning,
melintasi sebuah cincin orbit Hijau (simbol Akasha/Ruang Multi-layanan),
dan berujung pada Bintang Kutub Putih (simbol Manoratha/Impian tertinggi).
Anda dapat menyalin (copy) seluruh kode di bawah ini secara utuh dan menyimpannya
sebagai file berformat .svg untuk langsung digunakan pada web atau aplikasi:

```svg
<svg
  xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 800 800"
  width="100%"
  height="100%"
>
  <defs>
    <!-- Gradien Utama R: Merah -> Jingga -> Kuning -->
    <linearGradient id="r-grad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#E53935" />
      <stop offset="50%" stop-color="#FB8C00" />
      <stop offset="100%" stop-color="#FDD835" />
    </linearGradient>

    <!-- Gradien Aksen Cincin/Lintasan: Hijau Energi -> Transparan -->
    <linearGradient id="orbit-grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4CAF50" stop-opacity="0.8" />
      <stop offset="100%" stop-color="#4CAF50" stop-opacity="0.1" />
    </linearGradient>

    <!-- Drop Shadow untuk Efek Kedalaman Dimensi -->
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow
        dx="4"
        dy="10"
        stdDeviation="8"
        flood-color="#000000"
        flood-opacity="0.25" />
    </filter>
  </defs>

  <!-- Background Kontemporer Minimalistik (Dark Mode) -->
  <rect width="100%" height="100%" fill="#121214"/>

  <!-- Elemen Estetik: Kisi Geometri Ruang Semesta (Grid System) -->
  <g stroke="#ffffff" stroke-opacity="0.03" stroke-width="1">
    <circle cx="400" cy="400" r="300" fill="none"/>
    <circle cx="400" cy="400" r="200" fill="none"/>
    <line x1="100" y1="400" x2="700" y2="400" />
    <line x1="400" y1="100" x2="400" y2="700" />
  </g>

  <!-- KOMPONEN LOGO UTAMA -->
  <g filter="url(#shadow)">

    <!--
      Elemen 1: Cincin Ruang/Akasha (Hijau) - Melambangkan Ekosistem Multi-layanan
    -->
    <path d="M 280,580 A 240,200 45 1 0 540,250"
      fill="none"
      stroke="url(#orbit-grad)"
      stroke-width="24"
      stroke-linecap="round" />

    <!--
      Elemen 2: Huruf R Geometris (Merah-Jingga-Kuning)
      - Melambangkan Dinamisme & Impian
    -->
    <!-- Batang Vertikal Kiri R -->
    <path d="M 300,220 L 300,580"
    fill="none" stroke="url(#r-grad)" stroke-width="48" stroke-linecap="round" />

    <!-- Lengkungan Kepala R (Loop) -->
    <path d="M 300,220 C 450,220 480,380 300,380"
      fill="none"
      stroke="url(#r-grad)"
      stroke-width="48"
      stroke-linecap="round"
      stroke-linejoin="round" />

    <!-- Kaki Kanan R yang Melesat Keluar Melintasi Cincin -->
    <path d="M 320,380 L 520,580"
      fill="none"
      stroke="url(#r-grad)"
      stroke-width="48"
      stroke-linecap="round" />

    <!--
      Elemen 3: Bintang Impian / Polaris (Putih Bersih)
      - Simbol Manoratha (Cita-cita Tinggi)
    -->
    <path
      d="
        M 520,580
        L 525,550
        L 555,545
        L 525,540
        L 520,510
        L 515,540
        L 485,545
        L 515,550
        Z
      "
      fill="#FFFFFF" />

    <circle
      cx="520"
      cy="545"
      r="4"
      fill="#FFFFFF"
      filter="blur(1px)" />
  </g>

  <!-- Teks Brand Pendukung (Putih Elegan) -->
  <text x="400" y="700"
    font-family="'Inter', 'Segoe UI', sans-serif"
    font-size="42"
    font-weight="800"
    fill="#FFFFFF"
    letter-spacing="12"
    text-anchor="middle"
  >
    RASHA
  </text>

  <text x="400" y="740"
    font-family="'Inter', 'Segoe UI', sans-serif"
    font-size="16"
    font-weight="500"
    fill="#8E8E93"
    letter-spacing="4"
    text-anchor="middle"
  >
    RUANG IMPIAN
  </text>
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
