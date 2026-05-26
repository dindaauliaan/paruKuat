# ⚙️ ParuKuat — Technical Decisions

# Architecture

## Main Architecture
Clean Architecture

## Structure
Feature-based structure

## Pattern
Repository Pattern

---

# State Management

## Chosen Solution
Riverpod

## Reason
- scalable
- reactive
- maintainable
- cocok untuk async Supabase flow

---

# Navigation

## Chosen Solution
GoRouter

## Reason
- modern Flutter routing
- scalable route management
- clean auth redirect handling

---

# Backend

## Backend Service
Supabase PostgreSQL

## Current Authentication Strategy
Custom authentication menggunakan table users.

## Notes
Belum menggunakan Supabase Auth native.

---

# Database Strategy

## Philosophy
- lightweight MVP
- relational structure sederhana
- maintainable CRUD flow

## Priorities
- easy development
- easy debugging
- scalable incrementally

## Avoid
- overengineering schema
- complex realtime structure
- unnecessary optimization

---

# Animation Strategy

## Preferred Widgets
- AnimatedContainer
- TweenAnimationBuilder
- AnimatedOpacity

## Reason
- lightweight
- smooth
- maintainable
- cocok untuk Android mid-range

---

# Balloon Game Strategy

## Current Interaction
Tap & hold breathing simulation.

## Reason
Realtime microphone detection:
- lebih kompleks
- membutuhkan audio processing
- berpotensi meningkatkan bug MVP

## Future Possibility
Microphone breathing detection dapat ditambahkan setelah MVP stabil.

---

# Local Storage

## Chosen Solution
shared_preferences

## Usage
- local session
- onboarding state
- lightweight cache

---

# Chart Library

## Chosen Solution
fl_chart

## Usage
- breathing trend
- dashboard statistics
- exercise visualization

---

# Audio

## Chosen Solution
audioplayers

## Usage
- calming breathing sound
- breathing cue
- interaction feedback

---

# Product Constraints

## Important Rules
- bukan aplikasi diagnosis medis
- gamification non-competitive
- calming therapeutic UX
- Android focused MVP

---

# Coding Style

## Preferred
- readable code
- reusable widgets
- separation of concerns
- small focused files

## Avoid
- giant widgets
- business logic di UI
- unnecessary abstraction

---

# Current MVP Priorities

## Prioritized
- auth flow
- dashboard
- breathing exercise
- breathing tracking
- balloon game
- notification system

## Deferred
- achievement system
- XP progression
- streak tracking
- realtime sync
- social feature