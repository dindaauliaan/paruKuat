/// Fase siklus pernapasan guided breathing.
///
/// Urutan: [inhale] → [hold] → [exhale] → [rest] → repeat
enum BreathingPhase {
  inhale,
  hold,
  exhale,
  rest;

  /// Label untuk ditampilkan di UI.
  String get label {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.rest:
        return 'Rest';
    }
  }

  /// Instruksi dalam Bahasa Indonesia.
  String get instruction {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Tarik napas perlahan melalui hidung';
      case BreathingPhase.hold:
        return 'Tahan napas Anda';
      case BreathingPhase.exhale:
        return 'Buang napas perlahan melalui mulut';
      case BreathingPhase.rest:
        return 'Istirahat sejenak';
    }
  }

  /// Durasi fase default (dipakai sebelum pace dari exercise type diterapkan).
  int get durationSeconds {
    switch (this) {
      case BreathingPhase.inhale:
        return 4;
      case BreathingPhase.hold:
        return 2;
      case BreathingPhase.exhale:
        return 6;
      case BreathingPhase.rest:
        return 2;
    }
  }
}
