# 🫁 Laporan Tahapan Pembuatan Aplikasi ParuKuat

Laporan ini mendokumentasikan langkah-langkah pembuatan aplikasi **ParuKuat**, sebuah aplikasi rehabilitasi fungsi paru mandiri berbasis gamifikasi untuk pasien pasca Tuberkulosis (TBC). Aplikasi ini dibangun menggunakan **Flutter** dengan pendekatan **Clean Architecture (Feature-First)**, state management **Riverpod**, routing **GoRouter**, dan **Supabase** sebagai backend server.

---

## 🛠️ Tahapan Pengembangan Aplikasi

### 1. Buat Struktur Folder
Struktur folder dirancang dengan pola **Feature-First Clean Architecture** untuk memudahkan pemeliharaan dan modularitas kode. Buat struktur direktori di bawah folder `lib` seperti berikut:

```text
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   ├── app_text_styles.dart
│   │   └── session_keys.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   └── services/
│       └── local_notification_service.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── supabase_auth_repository.dart
│   │   ├── domain/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_user.dart
│   │   └── presentation/
│   │       ├── auth_notifier.dart
│   │       └── auth_widgets.dart
│   ├── breathing/
│   │   ├── data/
│   │   │   └── supabase_breathing_repository.dart
│   │   ├── domain/
│   │   │   ├── breathing_phase.dart
│   │   │   ├── breathing_repository.dart
│   │   │   ├── breathing_state.dart
│   │   │   └── exercise_type.dart
│   │   └── presentation/
│   │       ├── breathing_provider.dart
│   │       └── breathing_screen.dart
│   ├── game/
│   │   ├── data/
│   │   │   ├── services/
│   │   │   │   └── breath_detector_service.dart
│   │   │   └── supabase_game_repository.dart
│   │   ├── domain/
│   │   │   ├── balloon_game_state.dart
│   │   │   ├── breath_session_stat.dart
│   │   │   ├── game_repository.dart
│   │   │   └── game_stat.dart
│   │   └── presentation/
│   │       ├── game_provider.dart
│   │       └── game_screen.dart
│   ├── home/
│   │   ├── data/
│   │   │   └── supabase_home_repository.dart
│   │   ├── domain/
│   │   │   ├── home_data.dart
│   │   │   └── home_repository.dart
│   │   └── presentation/
│   │       ├── home_provider.dart
│   │       └── home_screen.dart
│   ├── notification/
│   │   ├── data/
│   │   │   └── supabase_notification_repository.dart
│   │   ├── domain/
│   │   │   ├── notification_item.dart
│   │   │   └── notification_repository.dart
│   │   └── presentation/
│   │       ├── notification_provider.dart
│   │       └── notification_screen.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── profile_screen.dart
│   └── progress/
│       ├── data/
│       │   └── supabase_progress_repository.dart
│       ├── domain/
│       │   ├── exercise_log.dart
│       │   ├── progress_data.dart
│       │   └── progress_repository.dart
│       └── presentation/
│           ├── progress_provider.dart
│           └── progress_screen.dart
├── pages/
│   ├── login_page.dart
│   ├── register_page.dart
│   └── welcome_page.dart
├── widgets/
│   └── bottom_nav.dart
└── main.dart
```

### 2. Buat file main.dart dan tambahkan source code berikut
File `main.dart` merupakan entry point aplikasi yang menginisialisasi Flutter framework bindings, layanan notifikasi lokal, error reporting, Supabase client, local cache (SharedPreferences), serta menjalankan widget aplikasi utama `ParuKuatApp` yang dibungkus dengan `ProviderScope` untuk Riverpod.

*   Source Code: [main.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/main.dart)

### 3. Lakukan konfigurasi supabase pada file supabase_config.dart
Buatlah kelas konfigurasi Supabase untuk memisahkan detail koneksi database (URL dan Anon Key) dari file `main.dart`. Kelas ini menyediakan static method `init()` untuk memulai koneksi SDK.

*   Source Code: [supabase_config.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/config/supabase_config.dart)

### 4. Konfigurasi pubspec.yaml untuk Dependensi Proyek
Tambahkan dependensi library yang dibutuhkan ke dalam file konfigurasi pubspec untuk mengaktifkan fitur state management, routing, database, grafik, perekaman audio, perizinan, dan notifikasi lokal.

*   Source Code: [pubspec.yaml](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/pubspec.yaml)

### 5. Buat Konstanta Gaya Desain (Themes & Constants)
Tentukan palet warna soft pastel khas terapi, ukuran tata letak, gaya tipografi Manrope, serta kunci penyimpanan lokal (Shared Preferences) pada folder constants agar konsisten di semua komponen UI.

*   [app_colors.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/constants/app_colors.dart) — Konfigurasi warna HSL pastel (Pink, Coral, Cream White).
*   [app_sizes.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/constants/app_sizes.dart) — Konstanta padding, margin, dan radius border.
*   [app_text_styles.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/constants/app_text_styles.dart) — Pengaturan gaya teks (Title, Body, Label).
*   [session_keys.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/constants/session_keys.dart) — Kunci penyimpanan cache sesi pengguna.

### 6. Implementasikan Sistem Navigasi & Routing (GoRouter)
Konfigurasikan sistem routing dengan middleware (Auth Guard) untuk memeriksa status login pengguna secara reaktif. Pengguna yang belum terautentikasi otomatis diarahkan ke halaman login, sedangkan pengguna terautentikasi diarahkan ke halaman dashboard.

*   [app_routes.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/router/app_routes.dart) — Daftar konstanta path rute layar.
*   [app_router.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/router/app_router.dart) — Implementasi GoRouter beserta adapter listener Riverpod.

### 7. Buat Layanan Notifikasi Lokal (Local Notification Service)
Buat modul service yang bertugas mendaftarkan channel notifikasi Android/iOS, meminta izin push notification, serta menampilkan pengingat latihan harian secara instan maupun terjadwal.

*   Source Code: [local_notification_service.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/core/services/local_notification_service.dart)

### 8. Bangun Modul Autentikasi Pengguna (Auth Module)
Buatlah model data user, abstraksi repository, implementasi query manual ke tabel `users` Supabase (tidak menggunakan native auth karena menggunakan custom schema tabel users bawaan kuliah), serta StateNotifier untuk mengelola status login & registrasi.

*   [auth_user.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/auth/domain/auth_user.dart) — Model data akun pengguna.
*   [auth_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/auth/domain/auth_repository.dart) — Interface untuk modul autentikasi.
*   [supabase_auth_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/auth/data/supabase_auth_repository.dart) — Implementasi query login, register, dan hapus session.
*   [auth_notifier.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/auth/presentation/auth_notifier.dart) — State Management status autentikasi.
*   [auth_widgets.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/auth/presentation/auth_widgets.dart) — Komponen input field & tombol kustom bernuansa pastel.

### 9. Desain Halaman Publik Utama (Welcome, Login, & Register)
Buat antarmuka visual pendaftaran akun baru, login menggunakan email dan password, serta welcome page dengan ilustrasi menarik dan tombol navigasi responsif.

*   [welcome_page.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/pages/welcome_page.dart) — Layar pembuka aplikasi dengan logo ParuKuat.
*   [login_page.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/pages/login_page.dart) — Halaman login dengan validasi input form.
*   [register_page.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/pages/register_page.dart) — Halaman pendaftaran detail profil dan tanggal lahir pengguna.

### 10. Buat Kerangka Navigasi Bawah (Bottom Navigation Bar)
Implementasikan layout navigasi utama yang persisten di bagian bawah layar untuk berpindah antara menu Dashboard Home, Latihan Pernapasan, Game Balon, Progress Latihan, dan Halaman Profile.

*   Source Code: [bottom_nav.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/widgets/bottom_nav.dart)

### 11. Implementasikan Modul Dashboard Beranda (Home Module)
Halaman utama yang menampilkan ringkasan data kesehatan pengguna hari ini, jumlah latihan harian, streak konsistensi latihan, serta teks rekomendasi latihan dinamis berdasarkan log aktivitas terakhir yang diambil dari tabel database Supabase.

*   [home_data.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/home/domain/home_data.dart) — Model data ringkasan dashboard.
*   [home_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/home/domain/home_repository.dart) — Abstraksi data dashboard.
*   [supabase_home_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/home/data/supabase_home_repository.dart) — Pengambilan statistik ringkasan dari Supabase.
*   [home_provider.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/home/presentation/home_provider.dart) — State notifier penyedia data dashboard.
*   [home_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/home/presentation/home_screen.dart) — Tampilan UI dashboard beranda.

### 12. Kembangkan Modul Terapi Guided Breathing (Breathing Module)
Modul panduan terapi pernapasan yang menuntun pengguna melakukan pola latihan napas dalam 3 fase (Tarik Napas/Inhale, Tahan Napas/Hold, Hembuskan Napas/Exhale) secara visual dengan animasi melingkar yang menenangkan. Hasil latihan kemudian disimpan ke dalam tabel `exercise_logs`.

*   [exercise_type.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/domain/exercise_type.dart) — Model tipe latihan pernapasan.
*   [breathing_phase.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/domain/breathing_phase.dart) — Enum fase pernapasan (inhale, hold, exhale, completed).
*   [breathing_state.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/domain/breathing_state.dart) — Status data state pernapasan saat ini.
*   [breathing_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/domain/breathing_repository.dart) — Interface log & list jenis latihan.
*   [supabase_breathing_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/data/supabase_breathing_repository.dart) — Implementasi database fetching jenis latihan & insert log latihan.
*   [breathing_provider.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/presentation/breathing_provider.dart) — State Management timer fase pernapasan.
*   [breathing_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/breathing/presentation/breathing_screen.dart) — Tampilan visual petunjuk pernapasan terapetik.

### 13. Kembangkan Modul Mini Game Tiup Balon (Game Module)
Mini game interaktif di mana pengguna meniup mikrofon perangkat mereka untuk menerbangkan balon udara virtual. Modul ini menggunakan mikrofon melalui `noise_meter` untuk mendeteksi intensitas suara hembusan napas (desibel), mengukur kapasitas tiupan (`breathing_power`), melacak ketinggian balon, serta menyimpan hasilnya ke tabel `game_stats`.

*   [breath_detector_service.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/data/services/breath_detector_service.dart) — Layanan deteksi desibel tiupan mikrofon perangkat.
*   [game_stat.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/domain/game_stat.dart) — Model data skor mini game balon udara.
*   [balloon_game_state.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/domain/balloon_game_state.dart) — State internal game (skor, tinggi balon, status game).
*   [breath_session_stat.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/domain/breath_session_stat.dart) — Statistik sesi hembusan napas.
*   [game_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/domain/game_repository.dart) — Abstraksi data log mini game.
*   [supabase_game_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/data/supabase_game_repository.dart) — Penyimpanan log skor game ke Supabase.
*   [game_provider.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/presentation/game_provider.dart) — Pengatur timer game dan listening ke detector service.
*   [game_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/game/presentation/game_screen.dart) — Layar interaktif game balon udara dengan visualisasi tiupan real-time.

### 14. Buat Modul Progres & Grafis Riwayat Latihan (Progress Module)
Modul untuk melihat riwayat latihan lengkap, riwayat mini game tiup balon, dan visualisasi grafik perubahan vitalitas paru-paru, kapasitas oksigen darah, serta kekuatan napas dari hari ke hari menggunakan library `fl_chart`.

*   [exercise_log.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/domain/exercise_log.dart) — Model data log latihan pernapasan.
*   [progress_data.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/domain/progress_data.dart) — Model agregasi data grafik progress.
*   [progress_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/domain/progress_repository.dart) — Abstraksi data history.
*   [supabase_progress_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/data/supabase_progress_repository.dart) — Pengambilan seluruh log latihan dan game stats milik pengguna.
*   [progress_provider.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/presentation/progress_provider.dart) — State management penyedia data grafik dan list history.
*   [progress_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/progress/presentation/progress_screen.dart) — Layar grafik fl_chart (Kapasitas Vital, Kadar Oksigen, Laju Napas).

### 15. Buat Modul Riwayat Notifikasi Aplikasi (Notification Module)
Layar daftar riwayat notifikasi yang dikirimkan oleh sistem (misal pengingat harian atau info latihan baru). Halaman ini mengambil data secara real-time dari tabel `notifications` Supabase dan memungkinkan pengguna menandai notifikasi sebagai "sudah dibaca".

*   [notification_item.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/notification/domain/notification_item.dart) — Model data entitas notifikasi.
*   [notification_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/notification/domain/notification_repository.dart) — Abstraksi aksi pada notifikasi.
*   [supabase_notification_repository.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/notification/data/supabase_notification_repository.dart) — Aksi update status baca & fetch notifikasi di database.
*   [notification_provider.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/notification/presentation/notification_provider.dart) — State provider daftar notifikasi aktif.
*   [notification_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/notification/presentation/notification_screen.dart) — UI daftar pesan notifikasi dengan swipe to read.

### 16. Kembangkan Modul Pengaturan Profil Pengguna (Profile Module)
Halaman pengelolaan data profil yang memuat data pengguna secara langsung dari Supabase. Menyediakan fitur mengubah foto profil dengan mengambil gambar dari Galeri/Kamera (menggunakan `image_picker`) lalu mengunggahnya ke bucket Storage Supabase, memperbarui detail profil, serta tombol Log Out untuk menghapus sesi pengguna dan mengembalikannya ke layar login.

*   Source Code: [profile_screen.dart](file:///d:/SEMESTER_4/WORKSHOP%20PEMROGRAMAN%20PERANGKAT%20BERGERAK/Flutter/paru_kuat/lib/features/profile/presentation/profile_screen.dart)

---

## 🚀 Cara Menjalankan Proyek

1.  **Clone Repositori dan Masuk ke Direktori Proyek**
    ```bash
    cd paru_kuat
    ```
2.  **Instal Seluruh Library Dependensi Flutter**
    ```bash
    flutter pub get
    ```
3.  **Jalankan Flutter Analyzer untuk Memastikan Tidak Ada Error**
    ```bash
    flutter analyze
    ```
4.  **Jalankan Aplikasi pada Emulator atau Perangkat Fisik (Android)**
    ```bash
    flutter run
    ```
