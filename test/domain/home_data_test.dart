import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/home/domain/home_data.dart';

void main() {
  group('HomeData', () {
    final weeklyTrend = [
      const TrendDataPoint(
        dayLabel: 'SEN', normalizedValue: 0.5, actualValue: 2.5, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'SEL', normalizedValue: 0.6, actualValue: 3.0, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'RAB', normalizedValue: 0.7, actualValue: 3.5, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'KAM', normalizedValue: 0.8, actualValue: 4.0, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'JUM', normalizedValue: 0.4, actualValue: 2.0, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'SAB', normalizedValue: 0.9, actualValue: 4.5, isToday: false,
      ),
      const TrendDataPoint(
        dayLabel: 'MIN', normalizedValue: 0.75, actualValue: 3.75, isToday: true,
      ),
    ];

    final homeData = HomeData(
      userName: 'Budi',
      profilePictureUrl: null,
      recommendationTitle: 'Latihan Pagi',
      recommendationDescription: 'Coba latihan pernapasan 5 menit',
      latestVitalCapacity: 3.5,
      latestOxygenLevel: 97.0,
      vitalCapacityDelta: '+5% vs Kemarin',
      oxygenStatus: 'Optimal',
      totalSessions: 12,
      currentStreak: 3,
      weeklyTrend: weeklyTrend,
    );

    test('menyimpan userName dengan benar', () {
      expect(homeData.userName, 'Budi');
    });

    test('menyimpan data rekomendasi', () {
      expect(homeData.recommendationTitle, 'Latihan Pagi');
      expect(homeData.recommendationDescription, 'Coba latihan pernapasan 5 menit');
    });

    test('menyimpan metrik vital capacity dan oksigen', () {
      expect(homeData.latestVitalCapacity, 3.5);
      expect(homeData.latestOxygenLevel, 97.0);
    });

    test('menyimpan delta dan status', () {
      expect(homeData.vitalCapacityDelta, '+5% vs Kemarin');
      expect(homeData.oxygenStatus, 'Optimal');
    });

    test('menyimpan totalSessions dan currentStreak', () {
      expect(homeData.totalSessions, 12);
      expect(homeData.currentStreak, 3);
    });

    test('weeklyTrend memiliki 7 data point', () {
      expect(homeData.weeklyTrend, hasLength(7));
    });

    test('weeklyTrend data point yang terakhir adalah hari ini', () {
      expect(homeData.weeklyTrend.last.isToday, true);
      expect(homeData.weeklyTrend.last.dayLabel, 'MIN');
    });

    test('profilePictureUrl bisa null', () {
      expect(homeData.profilePictureUrl, isNull);
    });
  });

  group('TrendDataPoint', () {
    test('membuat instance dengan nilai yang benar', () {
      const point = TrendDataPoint(
        dayLabel: 'SEN',
        normalizedValue: 0.5,
        actualValue: 2.5,
        isToday: false,
      );
      expect(point.dayLabel, 'SEN');
      expect(point.normalizedValue, 0.5);
      expect(point.actualValue, 2.5);
      expect(point.isToday, false);
    });

    test('isToday bisa true', () {
      const point = TrendDataPoint(
        dayLabel: 'MIN',
        normalizedValue: 0.8,
        actualValue: 4.0,
        isToday: true,
      );
      expect(point.isToday, true);
    });
  });
}
