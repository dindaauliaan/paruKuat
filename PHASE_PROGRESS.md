# 🚀 ParuKuat — Phase Progress

> **Catatan:** Fase mengacu pada `FEATURE_INTEGRATION_PLAN.md`.
> - Fase 1 = Foundation, Fase 2 = Home Dashboard, Fase 3 = Guided Breathing,
>   Fase 4 = Balloon Game, Fase 5 = Progress & Gamification

---

# Current Status

## UI/UX Mockup
✅ selesai

## Database Schema
✅ selesai

## Basic CRUD
✅ selesai

## Clean Architecture (feature-based)
✅ Selesai (core + all 6 features — domain entities terpisah dari data layer)

## Riverpod Integration
✅ Selesai (StateNotifier, FutureProvider.family, Provider)

## GoRouter Integration
✅ Selesai (auth guard, redirect logic, all routes, welcome page migrated)

## Authentication Flow
✅ Selesai (login, register, session persistence, logout)

## Home Dashboard (Data Real)
✅ Selesai (vital capacity, oxygen, streak, 7-day trend)

## Guided Breathing (Interaktif)
✅ Selesai (timer, animasi lingkaran, save ke Supabase)

## Balloon Game Logic
✅ selesai (state notifier, tap & hold mechanic, balloon physics, save ke Supabase)

## Progress & Gamification
✅ Selesai (progress screen, fl_chart 7/30 hari, XP & level system, achievement badges, streak)

## Notification System
✅ Selesai (repository + provider + screen dengan data real, mark read/unread, badge count, pull-to-refresh)

## Testing
✅ Selesai (56 unit & widget tests — domain entities, bottom nav)

## Lint
✅ 0 issues (flutter analyze clean)

## Unused Dependencies
✅ Dibersihkan (10 paket dihapus, 42 transitive deps otomatis turun)

## Orphaned Files
✅ Dibersihkan (5 page files, 1 service file, 6 model files — total ~3.300 baris kode mati)

## Models → Domain Entities
✅ Selesai (ExerciseType, ExerciseLog, GameStat pindah ke feature domain)

---

# Phase Progress

## Fase 1 — Foundation
Status: ✅ Done

### Goals
- setup architecture foundation
- setup Riverpod
- setup GoRouter
- setup Supabase service layer

### Tasks
- [v] setup dependencies
- [v] setup ProviderScope
- [v] setup router
- [v] setup app theme
- [v] setup Supabase client
- [v] base repository structure
- [v] base error handling

---

## Fase 2 — Home Dashboard (Data Real)
Status: ✅ Done

### Goals
- dashboard dengan data real dari Supabase
- greeting dinamis dengan streak & nama user
- rekomendasi harian
- tren pernapasan 7 hari

### Tasks
- [v] home_data entity (domain)
- [v] home_repository interface
- [v] supabase_home_repository (queries, kalkulasi delta, streak, trend)
- [v] home_provider (FutureProvider.family)
- [v] home_screen dengan AuthState aware & all cards
- [v] chart bar tren pernapasan 7 hari

---

## Fase 3 — Guided Breathing (Interaktif)
Status: ✅ Done

### Goals
- timer real-time siklus inhale → hold → exhale → rest
- animasi lingkaran mengembang/mengempis
- perubahan warna smooth per fase
- pemilih jenis latihan dari Supabase
- simpan ExerciseLog setelah sesi selesai

### Tasks
- [v] breathing_phase enum (inhale, hold, exhale, rest) + label & instruksi
- [v] breathing_state immutable (timer, cycles, scale, warna, sessionSaved)
- [v] breathing_repository interface
- [v] supabase_breathing_repository (fetch types, insert log, fallback)
- [v] breathing_notifier (Timer.periodic, state transitions, auto-save)
- [v] breathing_screen UI (AnimatedScale, phase indicator, stat cards, completion view)
- [v] update router (breathing_page.dart → breathing_screen.dart)

---

## Fase 4 — Balloon Game
Status: ✅ Done

### Goals
- breathing game interaction (tap & hold)
- real-time microphone breath detection
- balloon animation (inflate, float, pop)
- breathing power tracking & visualization
- save game_stats + breath session stats
- fallback to tap & hold mode jika mic tidak tersedia

### Tasks
- [v] game state (BalloonGameState — immutable, 17 fields + mic fields)
- [v] game notifier (GameNotifier — Timer.periodic 200ms, dual mode: mic/tap)
- [v] balloon movement (animated container + float animation dengan AnimationController)
- [v] breathing simulation (tap & hold inflasi, release deflasi, hint system)
- [v] real-time mic detection (BreathDetectorService — NoiseMeter + permission_handler)
- [v] mic sensitivity bar & breath wave visualization
- [v] breathing feedback label ("Tiup lebih kuat", "Bagus!", "Mantap!", dll)
- [v] mode badge (Mic / Tap & Hold) di idle state
- [v] fallback otomatis ke tap mode jika mic denied/unavailable
- [v] save game_stats (SupabaseGameRepository — insert ke game_stats)
- [v] save breath session stats (average power, peak, stable duration, exhale count)
- [v] game_screen (menggantikan GamesParukuat, 4 states: idle, playing, over, complete)
- [v] CustomPainter wave visualization (_BreathWavePainter)
- [v] Android RECORD_AUDIO permission + iOS NSMicrophoneUsageDescription
- [v] router update (app_router.dart → import GameScreen)
- [v] clean architecture (domain/data/presentation)
- [v] unit tests (95 total — +31 mic fields + breath session stat tests)

---

## Fase 5 — Progress & Gamification
Status: ✅ Done

### Goals
- progress screen dengan chart (fl_chart)
- XP & streak system
- achievement badges
- profile connect ke data real + logout

### Tasks
- [v] progress domain entities (ProgressData, DailyTrend, Achievement)
- [v] progress repository (abstract + Supabase impl)
- [v] progress provider (FutureProvider.family)
- [v] progress screen (fl_chart BarChart, filter 7/30 hari)
- [v] XP & level calculation (per session + streak bonus)
- [v] achievement system (5 badges: Napas Pertama, Balon Terbang, 3 Hari, Seminggu Kuat, Konsisten)
- [v] profile screen (data real dari auth + progress providers)
- [v] logout fungsional dengan konfirmasi dialog
- [v] router update (progress + profile routes)

---

## Fase 6 — Notifications
Status: ✅ Done

### Goals
- notification system dengan data real dari Supabase
- notification screen dengan mark as read & mark all
- notification badge di home screen bell icon
- pull-to-refresh, loading & error states

### Tasks
- [v] notification domain entity (NotificationItem)
- [v] notification repository interface
- [v] supabase_notification_repository (queries, mark as read, mark all)
- [v] notification provider (FutureProvider.family, unreadCountProvider)
- [v] notification screen (ConsumerStatefulWidget, data dari Supabase)
- [v] badge count di home_screen bell icon
- [v] pull-to-refresh, loading states, empty state, error state
- [v] router update (notification_page.dart → notification_screen.dart)

---

# Current Priority

## Active Focus
✅ Semua Fase MVP (1–6) selesai. ✅ Stabilisasi & polish selesai.
**Siap untuk rilis atau pengembangan lanjutan.**

---

# Current Branch

```bash
feat/feature-integration
```

---

# Development Notes

## Current MVP Focus
- stable architecture ✅
- smooth UX ✅ (animasi 60fps dengan AnimatedScale/TweenAnimationBuilder)
- lightweight performance ✅
- breathing interaction ✅ (real timer + animasi)
- balloon game ✅ (real-time mic detection + tap & hold fallback, inflasi/deflasi, altitude, pop mechanic)
- progress tracking ✅ (fl_chart, XP, level, achievements, streak)
- maintainable codebase ✅ (Clean Architecture + Repository Pattern)

## Completed Features
- Auth (login/register/logout + session persist) ✅
- Home Dashboard (data real + streak + trend chart) ✅
- Guided Breathing (timer + animation + save to Supabase) ✅
- Balloon Game ✅
  - Real-time microphone breath detection via NoiseMeter
  - dB → breathing power mapping (0-100%) dengan noise filtering
  - Mic sensitivity bar + wave visualization (_BreathWavePainter)
  - Breathing feedback labels (progressif dari "Tiup lebih kuat" → "Mantap! 🔥")
  - Dual mode: mic & tap & hold (auto fallback jika mic tidak tersedia)
  - Mic permission handling (granted/denied/permanentlyDenied + settings redirect)
  - Breath session stats (average power, peak, stable duration, exhale count)
  - Balloon physics (inflasi proporsional sesuai power, deflasi, float, altitude, pop mechanic)
  - Android RECORD_AUDIO + iOS NSMicrophoneUsageDescription
- Progress & Gamification (chart 7/30 hari, XP, level, achievements, streak) ✅
- Profile (data real, stats, fungsional logout) ✅
- Notifications (data real dari Supabase, mark read, badge count) ✅

## Important Reminder
Semua Fase MVP (1–6) telah selesai.
**Fitur real-time microphone detection untuk Balloon Game telah diimplementasikan sesuai FEATURE_INTEGRATION_PLAN.md.**

## Catatan Kalibrasi Mikrofon
BreathDetectorService menggunakan threshold default 45 dB dan max 80 dB.
Jika deteksi kurang akurat di perangkat tertentu, sesuaikan konstanta:
- `_dbThreshold` (default 45.0) — tingkat kebisingan ambient
- `_dbMax` (default 80.0) — level untuk mapping 100% power

Fokus selanjutnya: stabilisasi, testing, dan polish.