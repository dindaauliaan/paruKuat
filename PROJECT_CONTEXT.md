# 🫁 ParuKuat — Project Context

## Overview

ParuKuat adalah aplikasi terapi pernapasan mandiri berbasis gamifikasi
untuk membantu pasien pasca Tuberkulosis (TBC) melakukan rehabilitasi
fungsi paru secara lebih interaktif, nyaman, dan konsisten.

Aplikasi menggabungkan:
- guided breathing therapy
- light gamification
- breathing progress tracking
- calming therapeutic UI

ParuKuat bukan aplikasi diagnosis medis,
melainkan companion app untuk latihan pernapasan harian.

---

# Background

Tuberkulosis (TBC) merupakan salah satu masalah kesehatan utama di Surabaya.

Banyak pasien yang telah dinyatakan sembuh secara klinis
tetap mengalami penurunan fungsi paru akibat kerusakan jaringan paru.

Latihan pernapasan mandiri sering terkendala:
- kurangnya motivasi
- latihan terasa monoton
- keterbatasan pendampingan tenaga kesehatan

ParuKuat hadir untuk membuat proses rehabilitasi
lebih menarik melalui gamifikasi ringan dan visualisasi progres kesehatan paru.

---

# Product Goals

## Primary Goals
- membantu latihan pernapasan mandiri
- meningkatkan konsistensi terapi
- mengurangi rasa bosan saat rehabilitasi
- memberikan feedback progres yang mudah dipahami

## Measured Metrics
- breath hold duration
- breathing consistency
- breathing session frequency
- breathing strength simulation
- streak consistency

---

# UX Direction

## Core Experience
Aplikasi harus terasa:
- calming
- lightweight
- therapeutic
- supportive
- encouraging

## Avoid
- competitive game feeling
- cluttered medical dashboard
- flashy animation
- aggressive sound effect

---

# Gamification Philosophy

Gamification bersifat:
- supportive
- non-competitive
- subtle
- motivational

Tidak ada:
- leaderboard global
- PvP
- ranking antar user
- competitive scoring

---

# Target Users

## Primary Users
- pasien pasca TBC
- rehabilitasi paru ringan

## User Characteristics
- non technical users
- membutuhkan UI sederhana
- sebagian pengguna dewasa/lansia

---

# Platform Scope

## Current Target
- Android first

## Future Possibility
- iOS support

---

# Constraints

## Technical Constraints
- menggunakan Supabase sebagai backend utama
- fokus lightweight animation
- optimized untuk Android mid-range
- maintainable architecture

## Product Constraints
- bukan alat diagnosis medis
- semua indikator hanya untuk latihan mandiri
- fokus MVP terlebih dahulu

---

# MVP Features

- authentication
- guided breathing
- breathing timer
- balloon breathing game
- streak & XP
- progress tracking
- dashboard summary

---

# Current Architecture

- Clean Architecture
- Riverpod
- GoRouter
- Supabase SDK
- Feature-based structure
- Repository Pattern

---

# UI Identity

## Visual Style
- soft pastel
- rounded cards
- smooth shadow
- glassmorphism ringan

## Main Colors
- pink pastel
- soft coral
- cream white
- light magenta

## Animation Style
- smooth
- slow easing
- relaxing
- non aggressive