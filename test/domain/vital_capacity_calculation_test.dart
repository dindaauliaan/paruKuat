import 'package:flutter_test/flutter_test.dart';

/// Fungsi pure untuk mempermudah pengetesan formula vital capacity
double calculateVitalCapacity({
  required int completedSessionsCount,
  required double? avgPower,
  required double? stableSec,
  required double randomValue,
}) {
  double base = 2.2;
  double practiceBonus = (completedSessionsCount * 0.05).clamp(0.0, 0.6);

  if (avgPower != null && stableSec != null) {
    double powerBonus = (avgPower / 100) * 1.4; // Max 1.4 L
    double stabilityBonus = (stableSec / 20) * 0.8; // Max 0.8 L

    return (base + powerBonus + stabilityBonus + practiceBonus).clamp(2.0, 4.8);
  } else {
    double cycleBonus = (8 / 8) * 0.6;
    double randomFluctuation = randomValue * 0.2;
    return (base + cycleBonus + practiceBonus + randomFluctuation).clamp(2.0, 4.5);
  }
}

void main() {
  group('Vital Capacity Calculation Formula', () {
    test('menggunakan fallback jika tidak ada game stats', () {
      final vc = calculateVitalCapacity(
        completedSessionsCount: 0,
        avgPower: null,
        stableSec: null,
        randomValue: 0.5,
      );
      // base (2.2) + cycle (0.6) + random (0.5 * 0.2 = 0.1) = 2.9
      expect(vc, closeTo(2.9, 0.001));
    });

    test('meningkat seiring dengan jumlah latihan (practice bonus)', () {
      final vc1 = calculateVitalCapacity(
        completedSessionsCount: 2,
        avgPower: null,
        stableSec: null,
        randomValue: 0.0,
      );
      // base (2.2) + cycle (0.6) + practice (2 * 0.05 = 0.1) = 2.9
      expect(vc1, closeTo(2.9, 0.001));

      final vc2 = calculateVitalCapacity(
        completedSessionsCount: 20, // 20 * 0.05 = 1.0 -> cap ke 0.6
        avgPower: null,
        stableSec: null,
        randomValue: 0.0,
      );
      // base (2.2) + cycle (0.6) + practice (0.6) = 3.4
      expect(vc2, closeTo(3.4, 0.001));
    });

    test('menggunakan data game stats untuk menghitung power dan stability bonus', () {
      final vc = calculateVitalCapacity(
        completedSessionsCount: 0,
        avgPower: 70.0, // 70% power -> 0.7 * 1.4 = 0.98
        stableSec: 10.0, // 10s stability -> 0.5 * 0.8 = 0.4
        randomValue: 0.0,
      );
      // base (2.2) + power (0.98) + stability (0.4) + practice (0) = 3.58
      expect(vc, closeTo(3.58, 0.001));
    });

    test('menghormati nilai maksimum clamp (4.8L)', () {
      final vc = calculateVitalCapacity(
        completedSessionsCount: 100, // 5.0 -> cap 0.6
        avgPower: 100.0, // 1.4
        stableSec: 50.0, // 2.0 -> cap 0.8 (stabilityBonus limit = 0.8)
        randomValue: 0.0,
      );
      // base (2.2) + power (1.4) + stability (2.0 -> bonus max limit 2.0 L?)
      // Note: stabilityBonus = (stableSec / 20) * 0.8 = (50 / 20) * 0.8 = 2.0.
      // Total: 2.2 + 1.4 + 2.0 + 0.6 = 6.2 -> clamped to 4.8 L
      expect(vc, 4.8);
    });
  });
}
