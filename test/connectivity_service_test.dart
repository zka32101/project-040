import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/services/connectivity_service.dart';

void main() {
  group('StubConnectivityService', () {
    late StubConnectivityService service;

    setUp(() {
      service = StubConnectivityService();
    });

    test('should return connected status by default', () async {
      // Act
      final status = await service.getStatus();

      // Assert
      expect(status, equals(ConnectivityStatus.connected));
    });

    test('should emit connected status in stream', (widgetTester) async {
      // Act
      final stream = service.statusStream();
      final firstStatus = await stream.first;

      // Assert
      expect(firstStatus, equals(ConnectivityStatus.connected));
    });

    test('should support manual status change for testing', () async {
      // Act
      service.setStatus(ConnectivityStatus.disconnected);
      final status = await service.getStatus();

      // Assert
      expect(status, equals(ConnectivityStatus.disconnected));
    });

    test('should emit status changes in stream', (widgetTester) async {
      // Act
      final stream = service.statusStream();
      service.setStatus(ConnectivityStatus.disconnected);
      final statuses = await stream.take(2).toList();

      // Assert
      expect(statuses, contains(ConnectivityStatus.disconnected));
    });

    test('should emit all status types', (widgetTester) async {
      // Act & Assert
      for (final status in ConnectivityStatus.values) {
        service.setStatus(status);
        final currentStatus = await service.getStatus();
        expect(currentStatus, equals(status));
      }
    });
  });

  group('ConnectivityStatus', () {
    test('should have expected status values', () {
      // Verify all statuses exist
      expect(ConnectivityStatus.connected, isNotNull);
      expect(ConnectivityStatus.disconnected, isNotNull);
      expect(ConnectivityStatus.values.length, greaterThan(0));
    });
  });
}
