import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/breathing/domain/breathing_phase.dart';

void main() {
  group('BreathingPhase', () {
    test('memiliki 4 fase dalam urutan yang benar', () {
      expect(BreathingPhase.values, hasLength(4));
      expect(BreathingPhase.values[0], BreathingPhase.inhale);
      expect(BreathingPhase.values[1], BreathingPhase.hold);
      expect(BreathingPhase.values[2], BreathingPhase.exhale);
      expect(BreathingPhase.values[3], BreathingPhase.rest);
    });

    group('label', () {
      test('inhale → Inhale', () {
        expect(BreathingPhase.inhale.label, 'Inhale');
      });
      test('hold → Hold', () {
        expect(BreathingPhase.hold.label, 'Hold');
      });
      test('exhale → Exhale', () {
        expect(BreathingPhase.exhale.label, 'Exhale');
      });
      test('rest → Rest', () {
        expect(BreathingPhase.rest.label, 'Rest');
      });
    });

    group('instruction (Bahasa Indonesia)', () {
      test('inhale → Tarik napas perlahan melalui hidung', () {
        expect(
          BreathingPhase.inhale.instruction,
          'Tarik napas perlahan melalui hidung',
        );
      });
      test('hold → Tahan napas Anda', () {
        expect(BreathingPhase.hold.instruction, 'Tahan napas Anda');
      });
      test('exhale → Buang napas perlahan melalui mulut', () {
        expect(
          BreathingPhase.exhale.instruction,
          'Buang napas perlahan melalui mulut',
        );
      });
      test('rest → Istirahat sejenak', () {
        expect(BreathingPhase.rest.instruction, 'Istirahat sejenak');
      });
    });

    group('durationSeconds', () {
      test('inhale → 4 detik', () {
        expect(BreathingPhase.inhale.durationSeconds, 4);
      });
      test('hold → 2 detik', () {
        expect(BreathingPhase.hold.durationSeconds, 2);
      });
      test('exhale → 6 detik', () {
        expect(BreathingPhase.exhale.durationSeconds, 6);
      });
      test('rest → 2 detik', () {
        expect(BreathingPhase.rest.durationSeconds, 2);
      });
    });

    test('total durasi satu siklus adalah 14 detik', () {
      int total = 0;
      for (final phase in BreathingPhase.values) {
        total += phase.durationSeconds;
      }
      expect(total, 14);
    });
  });
}
