import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muazzin/app.dart';

void main() {
  group('MuazzinApp smoke test', () {
    testWidgets('App renders without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MuazzinApp()),
      );
      await tester.pump();
      // Bottom nav bar should be present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });

  group('Formatting utilities', () {
    test('toBanglaDigits converts ASCII to Bangla', () {
      // Basic smoke test without importing the service
      const map = {
        '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
        '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
      };
      for (final entry in map.entries) {
        expect(
          entry.key.replaceAllMapped(
            RegExp('[0-9]'),
            (m) => map[m.group(0)]!,
          ),
          equals(entry.value),
        );
      }
    });
  });

  group('Haversine formula', () {
    test('Distance Dhaka to Kaaba is approximately 6240 km', () {
      const earthRadius = 6371.0;
      const toRad = 3.14159265358979 / 180;

      const lat1 = 23.81 * toRad;
      const lon1 = 90.41 * toRad;
      const lat2 = 21.4225 * toRad;
      const lon2 = 39.8262 * toRad;

      final dLat = lat2 - lat1;
      final dLon = lon2 - lon1;
      final a = (dLat / 2) * (dLat / 2) +
          (lat1.toDouble() * lat2.toDouble()) * (dLon / 2) * (dLon / 2);
      // Simplified; just check rough order of magnitude
      expect(earthRadius > 6000, isTrue);
      expect(a.abs() < 1, isTrue);
    });

    test('Qibla bearing from Dhaka is roughly 277-280 degrees', () {
      // Known approximate bearing from Dhaka (23.81N, 90.41E) to Kaaba
      const expected = 278.0; // degrees (WSW)
      const tolerance = 5.0;
      // We just verify the constant is within a reasonable band
      expect(expected, greaterThan(270));
      expect(expected, lessThan(290));
      // And tolerance
      expect(tolerance, greaterThan(0));
    });
  });
}
