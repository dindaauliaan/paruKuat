# 🗄️ ParuKuat — Database Schema

# Database Provider
Supabase PostgreSQL

---

# Database Philosophy

Database dirancang untuk:
- lightweight MVP
- sederhana dan mudah maintain
- fokus rehabilitasi pernapasan
- minim kompleksitas relasi
- scalable untuk pengembangan berikutnya

Database saat ini berfokus pada:
- authentication
- breathing exercise tracking
- breathing game tracking
- notification system

---

# Tables

## users

Menyimpan data utama pengguna aplikasi.

| Field | Type |
|---|---|
| id | integer |
| full_name | varchar |
| email | varchar |
| password | varchar |
| phone_number | varchar |
| birth_date | date |
| is_premium | boolean |
| profile_picture | text |
| created_at | timestamp |

---

## exercise_types

Master data jenis latihan pernapasan.

| Field | Type |
|---|---|
| id | integer |
| name | varchar |
| description | text |
| recommendation_text | text |
| duration_seconds | integer |

---

## exercise_logs

Riwayat latihan pernapasan pengguna.

| Field | Type |
|---|---|
| id | integer |
| user_id | integer |
| exercise_type_id | integer |
| vital_capacity_value | numeric |
| oxygen_level | numeric |
| breathing_rate | numeric |
| completed_at | timestamp |

---

## game_stats

Data hasil mini game balloon breathing.

| Field | Type |
|---|---|
| id | integer |
| user_id | integer |
| current_altitude | integer |
| breathing_power | numeric |
| last_played_at | timestamp |

---

## notifications

Data notifikasi pengguna.

| Field | Type |
|---|---|
| id | integer |
| user_id | integer |
| title | varchar |
| message | text |
| is_read | boolean |
| sent_at | timestamp |

---

# Relationships

## users → exercise_logs
One-to-many

## users → game_stats
One-to-many

## users → notifications
One-to-many

## exercise_types → exercise_logs
One-to-many

---

# Breathing Metrics

## Current Measured Metrics
Sistem saat ini mencatat:
- vital_capacity_value
- oxygen_level
- breathing_rate
- breathing_power

## Notes
Semua data bersifat indikator latihan
dan bukan alat diagnosis medis resmi.

---

# Authentication Notes

## Current Auth Strategy
Authentication masih menggunakan:
- custom users table
- email & password login
- manual session handling

## Not Using Yet
- Supabase Auth native
- OAuth provider
- biometric login

---

# MVP Scope

## Current Included Scope
- login & register
- breathing exercise tracking
- balloon game tracking
- notification system

## Not Included Yet
- achievement system
- XP system
- streak system
- journaling
- realtime multiplayer
- wearable integration

---

# Future Expansion Possibility

Kemungkinan pengembangan:
- achievement table
- XP progression
- streak tracking
- breathing analytics
- AI recommendation
- wearable sync