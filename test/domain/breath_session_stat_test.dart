import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/game/domain/breath_session_stat.dart';

void main() {
  group('BreathSessionStat', () {
    test('membuat instance dengan semua parameter', () {
      final stat = BreathSessionStat(
        averageBreathPower: 45.5,
        peakBreathPower: 88.0,
        stableBreathDurationSec: 30,
        totalExhaleCount: 12,
        usedMicrophone: true,
      );

      expect(stat.averageBreathPower, 45.5);
      expect(stat.peakBreathPower, 88.0);
      expect(stat.stableBreathDurationSec, 30);
      expect(stat.totalExhaleCount, 12);
      expect(stat.usedMicrophone, true);
    });

    test('usedMicrophone bisa false (tap mode)', () {
      final stat = BreathSessionStat(
        averageBreathPower: 30.0,
        peakBreathPower: 80.0,
        stableBreathDurationSec: 15,
        totalExhaleCount: 5,
        usedMicrophone: false,
      );

      expect(stat.usedMicrophone, false);
    });

    test('semua field zero/nol diperbolehkan', () {
      final stat = BreathSessionStat(
        averageBreathPower: 0,
        peakBreathPower: 0,
        stableBreathDurationSec: 0,
        totalExhaleCount: 0,
        usedMicrophone: true,
      );

      expect(stat.averageBreathPower, 0);
      expect(stat.peakBreathPower, 0);
      expect(stat.stableBreathDurationSec, 0);
      expect(stat.totalExhaleCount, 0);
    });

    test('power bisa mencapai 100', () {
      final stat = BreathSessionStat(
        averageBreathPower: 100,
        peakBreathPower: 100,
        stableBreathDurationSec: 60,
        totalExhaleCount: 25,
        usedMicrophone: true,
      );

      expect(stat.averageBreathPower, 100);
      expect(stat.peakBreathPower, 100);
    });
  });
}