# 🫁 ParuKuat — Feature Integration Plan
`branch: feat/feature-integration`

## Kondisi Saat Ini

| Aspek | Status |
|---|---|
| UI Pages | ✅ Selesai (home, breathing, games, profile, login, register, notification, welcome) |
| Models | ✅ Selesai (User, ExerciseLog, ExerciseType, GameStat, DailyJournal, Notification) |
| SupabaseApi service | ✅ CRUD dasar via REST HTTP |
| State management | ❌ Belum ada (semua StatelessWidget) |
| Routing | ❌ Masih MaterialApp routes manual |
| Auth flow | ❌ Login/register belum terhubung ke Supabase |
| Breathing animation | ❌ Masih statis (StatelessWidget) |
| Balloon game | ❌ Masih statis (tidak ada logika game) |
| Progress tracking | ❌ Data masih hardcoded |
| Streak & XP | ❌ Belum ada sama sekali |

---

## Arsitektur Target (Clean Architecture)

```
lib/
├── core/
│   ├── constants/         # AppColors, AppStrings, AppSizes
│   ├── router/            # GoRouter config
│   ├── providers/         # Global providers (supabase, auth)
│   └── utils/             # date helpers, formatters
├── features/
│   ├── auth/
│   │   ├── data/          # AuthRepository impl
│   │   ├── domain/        # AuthRepository interface, User entity
│   │   └── presentation/  # login_screen, register_screen + providers
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # home_screen + home_provider
│   ├── breathing/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # breathing_screen + breathing_provider
│   ├── game/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # game_screen + game_provider
│   ├── progress/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # progress_screen + progress_provider
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/  # profile_screen + profile_provider
├── models/                # (tetap, shared data models)
├── services/              # SupabaseApi (diperluas)
└── widgets/               # Shared widgets (BottomNav, AppHeader, etc.)
```

---

## Dependencies Baru yang Dibutuhkan

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.7
  supabase_flutter: ^2.8.4   # ganti HTTP manual
  shared_preferences: ^2.3.3 # local cache (streak, session)
  lottie: ^3.1.3             # animasi breathing
  percent_indicator: ^4.2.3  # progress bar breathing
  fl_chart: ^0.70.2          # chart di home/progress
  audioplayers: ^6.1.0       # sound feedback (opsional)

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.4.3
  custom_lint: ^0.7.5
  riverpod_lint: ^2.3.13
```

---

## Fase Implementasi

### Fase 1 — Foundation (Core + Router + Auth) 🔴 PRIORITAS TINGGI

**Tujuan:** App bisa login/register nyata ke Supabase, navigate dengan GoRouter.

#### 1.1 Setup Dependencies
- Update `pubspec.yaml` dengan semua dependency baru
- Inisialisasi Supabase di `main.dart` dengan `SupabaseFlutter.initialize()`
- Wrap app dengan `ProviderScope`

#### 1.2 Core Constants
- `lib/core/constants/app_colors.dart` — semua color token dari UI existing
- `lib/core/constants/app_text_styles.dart` — semua text style
- `lib/core/constants/app_sizes.dart` — spacing, radius

#### 1.3 GoRouter Setup
- `lib/core/router/app_router.dart`
- Routes: `/` (welcome), `/login`, `/register`, `/home`, `/breathing`, `/games`, `/progress`, `/profile`, `/notifications`
- `redirect` logic: jika tidak ada session → ke `/login`

#### 1.4 Auth Feature
- `AuthRepository` interface + `SupabaseAuthRepository` implementation
- `AuthNotifier` (Riverpod StateNotifier) — state: loading, authenticated, unauthenticated, error
- Update `LoginParukuat` → `LoginScreen` (StatefulWidget) dengan form validation + real Supabase auth
- Update `RegisterParukuat` → `RegisterScreen` dengan register flow
- `AuthGuard` di router

---

### Fase 2 — Home Dashboard dengan Data Real 🟠 PRIORITAS TINGGI

**Tujuan:** Dashboard menampilkan data nyata dari Supabase (vital capacity, oxygen, streak, XP).

#### 2.1 Home Provider
- `HomeNotifier` — fetch exercise logs milik user hari ini
- `UserStatsProvider` — total latihan, vital capacity terakhir, streak count, XP total
- Kalkulasi 7-hari trend dari `exercise_logs`

#### 2.2 Update HomeParukuat → HomeScreen
- Ganti hardcoded `'Syauqy'` dengan nama user dari auth provider
- Ganti hardcoded `4.2 Liters` dengan data `ExerciseLog` terakhir
- Ganti bar chart statis dengan data 7 hari nyata
- Tambah XP progress indicator (subtle, non-competitive)
- Tambah `streak_count` di greeting ("Streak 7 hari! 🔥")

---

### Fase 3 — Breathing Therapy Interaktif 🟠 PRIORITAS TINGGI

**Tujuan:** Breathing page menjadi fully interactive dengan animasi, timer, dan save ke Supabase.

#### 3.1 Breathing State Management
```dart
enum BreathingPhase { inhale, hold, exhale, rest }

class BreathingState {
  final BreathingPhase phase;
  final int secondsRemaining;
  final int currentCycle;
  final int totalCycles;
  final bool isRunning;
  final double circleScale; // 0.6 - 1.0 untuk animasi
}
```

#### 3.2 BreathingNotifier
- Timer berbasis `Timer.periodic` yang berjalan di background
- State transition: inhale (4s) → hold (2s) → exhale (6s) → rest (2s) → repeat
- `dispose()` otomatis cancel timer
- Setelah sesi selesai → save `ExerciseLog` ke Supabase

#### 3.3 Animasi Breathing Circle
- `AnimatedContainer` dengan scale berdasarkan `BreathingPhase`
- Ripple effect saat inhale (concentric circles expanding)
- Warna berubah smooth: pink (inhale) → lavender (hold) → teal (exhale)
- Text "Inhale" / "Hold" / "Exhale" dengan fade transition

#### 3.4 Breathing Exercise Selector
- Cards untuk memilih tipe latihan (Deep Lung Recovery, Pursed Lip, Diaphragmatic)
- Data dari `exercise_types` table

---

### Fase 4 — Balloon Game dengan Input Nafas Real 🎤🟡 PRIORITAS SEDANG

**Tujuan:** Game balloon bereaksi terhadap kekuatan hembusan napas user melalui microphone secara real-time, lalu menyimpan hasil latihan ke Supabase.

> Input balloon tidak lagi hanya simulasi button hold, tetapi membaca intensitas audio dari hembusan user.

#### Dependencies Tambahan

```yaml
dependencies:
  record: ^6.0.0
  noise_meter: ^5.0.2
  permission_handler: ^11.3.1
```

#### 4.1 Audio Breathing Detection Layer

Tambahkan service baru:

```txt
lib/features/game/data/services/breath_detector_service.dart
```

##### Tanggung Jawab:
- Request permission microphone
- Mendengarkan amplitude audio realtime
- Mengubah amplitude → breathing power (0-100%)
- Filter noise kecil agar suara sekitar tidak dianggap hembusan

##### Flow:
```txt
Microphone Input
    ↓
Audio Amplitude (dB)
    ↓
Noise Filtering
    ↓
Normalize Value
    ↓
Breathing Power
    ↓
Update Balloon Size
```

#### 4.2 Game State

```dart
class BalloonGameState {
  final double balloonSize;
  final double altitude;
  final double breathingPower;

  final double microphoneDb;
  final bool isListeningMic;

  final int score;
  final bool isGameActive;
  final bool isBalloonPopped;
  final int timeElapsed;

  final List<double> powerHistory;
}
```

#### 4.3 Breath Detection Logic

##### Mapping Audio → Power

```dart
double normalizedPower = ((db + 45) / 45).clamp(0.0, 1.0);
```

##### Threshold Filter

```dart
if (db < -35) {
  breathingPower = 0;
}
```

##### Behavior
- Hembusan kecil → balloon naik pelan
- Hembusan stabil → balloon membesar smooth
- Hembusan terlalu kuat → risiko balloon pop lebih cepat
- Diam terlalu lama → balloon mengempis perlahan

#### 4.4 GameNotifier

##### Tambahan Responsibility
- Start microphone stream saat game dimulai
- Listen realtime audio amplitude
- Convert amplitude menjadi breathing power
- Stop stream saat game selesai/dispose

##### Pseudocode

```dart
startGame() {
  startMicListening();

  gameTimer = Timer.periodic(...);
}

onAudioLevelChanged(db) {
  final power = mapDbToPower(db);

  state = state.copyWith(
    breathingPower: power,
    balloonSize: calculateBalloonSize(power),
  );
}
```

#### 4.5 Animasi Balloon
- `TweenAnimationBuilder` untuk smooth size transition
- Balloon floating animation (subtle up-down)
- Cloud particles di background
- Altitude gauge animated
- Glow effect mengikuti kekuatan napas
- Wave animation realtime dari audio input

#### 4.6 Visual Feedback Tambahan
- Mic sensitivity bar
- Indicator teks:
  - “Tiup lebih kuat”
  - “Bagus!”
  - “Terlalu kuat!”

#### 4.7 Stability & UX Constraint

| Topik | Keputusan |
|---|---|
| Noise filtering | Ignore amplitude rendah |
| Permission handling | Wajib graceful fallback |
| Battery usage | Mic aktif hanya saat game |
| Performance | Hindari heavy FFT/audio processing |
| Privacy | Audio tidak direkam/disimpan |
| Accessibility | Tetap sediakan mode simulasi button |

#### 4.8 Fallback Mode

Jika:
- permission microphone ditolak
- device tidak support
- emulator tanpa mic

Maka otomatis fallback ke:

```txt
Tap & Hold Simulation Mode
```

#### 4.9 Data Tracking Tambahan

```dart
class BreathSessionStat {
  final double averageBreathPower;
  final double peakBreathPower;
  final int stableBreathDuration;
  final int totalExhaleCount;
}
```

Data ini bisa dipakai untuk:
- progress chart
- breathing consistency
- adaptive difficulty
- XP bonus untuk napas stabil

---

### Fase 5 — Progress Tracking & Gamification 🟡 PRIORITAS SEDANG

**Tujuan:** Halaman progress dengan data nyata, streak system, XP system.

#### 5.1 Progress Screen (baru)
- Chart 7/30 hari menggunakan `fl_chart`
- Filter: mingguan / bulanan
- Cards: total sesi, rata-rata vital capacity, rata-rata oxygen level
- Achievement badges (unlocked jika milestone tercapai)

#### 5.2 Streak & XP System
```dart
// Di GameStat atau UserStats
class UserGamification {
  final int currentStreak;   // hari berturut-turut
  final int longestStreak;
  final int totalXP;
  final int currentLevel;    // 1-10, berdasarkan XP
  final List<Achievement> unlockedAchievements;
}
```

**XP Rules (supportive, non-competitive):**
- Selesai sesi breathing: +10 XP
- Selesai game balloon: +15 XP  
- Streak 3 hari: +20 XP bonus
- Streak 7 hari: +50 XP bonus
- First session of the day: +5 XP

**Achievements (encouraging, bukan competitive):**
- 🌬️ "Napas Pertama" — selesaikan sesi pertama
- 🔥 "3 Hari Berturut" — streak 3 hari
- 💪 "Seminggu Kuat" — streak 7 hari
- 🎈 "Balon Terbang" — selesaikan balloon game pertama
- ⭐ "Konsisten" — 10 sesi total

#### 5.3 Profile Update
- Sambungkan ke data nyata dari Supabase (nama, email, foto)
- Stats card: total latihan, vital capacity avg, XP score
- Logout dengan konfirmasi → clear session → redirect ke login

---

## Urutan Implementasi (yang Disarankan)

```
1. pubspec.yaml update → flutter pub get
2. main.dart → ProviderScope + Supabase init
3. core/constants/ (colors, text styles, sizes)
4. core/router/app_router.dart
5. features/auth/ (repository + notifier + screens)
6. features/home/ (provider + update HomeScreen)
7. features/breathing/ (notifier + animasi + save)
8. features/game/ (notifier + animasi + save)
9. features/progress/ (screen baru + chart)
10. Gamification (XP/streak update di provider)
11. features/profile/ (connect ke real data + logout)
```

---

## Keputusan Teknis Penting

| Topik | Keputusan | Alasan |
|---|---|---|
| State Management | Riverpod (StateNotifier) | Sesuai spec, testable, reactive |
| Auth | Supabase Flutter SDK (ganti HTTP manual) | Built-in session, realtime, lebih aman |
| Navigation | GoRouter | Sesuai spec, deep linking support |
| Animasi | AnimatedContainer + TweenAnimationBuilder | Lightweight, no heavy deps |
| Microphone | Simulasi dulu (button hold) | Avoid kompleksitas permission + platform |
| Chart | fl_chart | Ringan, customizable, sesuai desain |
| Local State | shared_preferences | Cache session, streak harian |

---

## Catatan UX & Constraint

> [!IMPORTANT]
> - **Bukan alat diagnosis medis** — semua angka adalah indikator latihan, bukan klinis
> - **Gamification supportive** — tidak ada leaderboard, tidak ada perbandingan antar user
> - **Animasi smooth** — semua animasi harus 60fps di mid-range Android (avoid expensive ops di build())
> - **UI calming** — pertahankan color palette pink/cream, font Manrope, glassmorphism cards

