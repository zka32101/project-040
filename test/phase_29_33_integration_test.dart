/// Phases 29-33: セキュリティ・パフォーマンス・リアルタイム・認証・監視テスト

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/services/security_service.dart';
import 'package:project_040/services/cache_service.dart';
import 'package:project_040/services/websocket_service.dart';
import 'package:project_040/services/advanced_auth_service.dart';
import 'package:project_040/services/monitoring_service.dart';

void main() {
  group('Phases 29-33: Integrated Security, Performance, Real-time, Auth, Monitoring', () {
    // ==================== Phase 29: Security ====================

    test('29.1: Rate limit - allows requests under limit', () async {
      final limiter = MemoryRateLimiter();
      final rule = RateLimitRule(
        identifier: 'user_1',
        maxRequests: 5,
        window: Duration(minutes: 1),
      );

      final result1 = await limiter.checkLimit(rule);
      expect(result1.allowed, true);
      expect(result1.remainingRequests, 4);
    });

    test('29.2: Rate limit - blocks after exceeded', () async {
      final limiter = MemoryRateLimiter();
      final rule = RateLimitRule(
        identifier: 'user_2',
        maxRequests: 2,
        window: Duration(minutes: 1),
      );

      await limiter.checkLimit(rule);
      await limiter.checkLimit(rule);
      final result3 = await limiter.checkLimit(rule);

      expect(result3.allowed, false);
    });

    test('29.3: Token blacklist - revoke token', () async {
      final blacklist = MemoryTokenBlacklist();
      await blacklist.revoke('token_123', 'User logout', DateTime.now().add(Duration(hours: 1)));

      final isRevoked = await blacklist.isRevoked('token_123');
      expect(isRevoked, true);
    });

    test('29.4: CSRF protection - generate and validate token', () async {
      final csrf = MemoryCsrfProtection();
      final token = await csrf.generateToken('session_1');

      expect(token.token, isNotNull);
      final valid = await csrf.validateToken(token.token, 'session_1');
      expect(valid, true);
    });

    test('29.5: IP whitelist - allow whitelisted IP', () async {
      final whitelist = MemoryIpWhitelist();
      await whitelist.addIp('192.168.1.1', 'Office');

      final allowed = await whitelist.isAllowed('192.168.1.1');
      expect(allowed, true);
    });

    test('29.6: Security manager - integrated check passes', () async {
      final manager = SecurityManager(
        rateLimiter: MemoryRateLimiter(),
        tokenBlacklist: MemoryTokenBlacklist(),
        csrfProtection: MemoryCsrfProtection(),
        ipWhitelist: MemoryIpWhitelist(),
      );

      await manager.ipWhitelist.addIp('192.168.1.1', 'Test');

      final result = await manager.performSecurityCheck(
        userId: 'user_1',
        ipAddress: '192.168.1.1',
        authToken: null,
      );

      expect(result.ipAllowed, true);
      expect(result.rateLimitOk, true);
    });

    // ==================== Phase 30: Caching ====================

    test('30.1: Cache - store and retrieve value', () async {
      final cache = MemoryCacheService<String, String>();
      await cache.put('key1', 'value1', Duration(minutes: 5));

      final value = await cache.get('key1');
      expect(value, 'value1');
    });

    test('30.2: Cache - expired entry returns null', () async {
      final cache = MemoryCacheService<String, String>();
      await cache.put('key2', 'value2', Duration(milliseconds: 10));

      await Future.delayed(Duration(milliseconds: 20));
      final value = await cache.get('key2');
      expect(value, null);
    });

    test('30.3: Cache - invalidate key', () async {
      final cache = MemoryCacheService<String, String>();
      await cache.put('key3', 'value3', Duration(minutes: 5));
      await cache.invalidate('key3');

      final value = await cache.get('key3');
      expect(value, null);
    });

    test('30.4: Cache - clear all entries', () async {
      final cache = MemoryCacheService<String, String>();
      await cache.put('key1', 'value1', Duration(minutes: 5));
      await cache.put('key2', 'value2', Duration(minutes: 5));
      await cache.clear();

      final size = await cache.size();
      expect(size, 0);
    });

    // ==================== Phase 31: Real-time ====================

    test('31.1: WebSocket - connect and disconnect', () async {
      final ws = MemoryWebSocketService();
      await ws.connect('ws://example.com');

      expect(ws.state, ConnectionState.connected);

      await ws.disconnect();
      expect(ws.state, ConnectionState.disconnected);
    });

    test('31.2: WebSocket - send message', () async {
      final ws = MemoryWebSocketService();
      await ws.connect('ws://example.com');

      ws.send('Hello');

      final message = await ws.messageStream.first;
      expect(message, 'Hello');
    });

    test('31.3: Event broadcaster - subscribe and broadcast', () async {
      final broadcaster = MemoryEventBroadcaster();

      String? receivedData;
      broadcaster.subscribe('chat', (data) {
        receivedData = data['message'];
      });

      broadcaster.broadcast('chat', {'message': 'Hello, World!'});

      await Future.delayed(Duration(milliseconds: 100));
      expect(receivedData, 'Hello, World!');
    });

    // ==================== Phase 32: Advanced Auth ====================

    test('32.1: MFA - setup and verify', () async {
      final mfa = MemoryMfaService();
      await mfa.setupMfa('user_1', MfaMethod.sms);

      final verified = await mfa.verifyMfa('user_1', '123456');
      expect(verified, true);
    });

    test('32.2: MFA - generate backup codes', () async {
      final mfa = MemoryMfaService();
      final codes = await mfa.generateBackupCodes('user_2');

      expect(codes, isNotEmpty);
      expect(codes.split(',').length, 10);
    });

    test('32.3: Biometric - check availability', () async {
      final biometric = MemoryBiometricAuthService();
      final available = await biometric.isAvailable();

      expect(available, true);
    });

    test('32.4: Biometric - authenticate', () async {
      final biometric = MemoryBiometricAuthService();
      final authenticated = await biometric.authenticate('Login to app');

      expect(authenticated, true);
    });

    // ==================== Phase 33: Monitoring ====================

    test('33.1: Logger - log at different levels', () async {
      final logger = MemoryLogger();

      logger.info('Info message');
      logger.warn('Warning message');
      logger.debug('Debug message', context: {'key': 'value'});

      final logs = await logger.logStream.take(3).toList();
      expect(logs.length, 3);
      expect(logs[0].level, LogLevel.info);
    });

    test('33.2: Metrics collector - record and retrieve', () async {
      final metrics = MemoryMetricsCollector();

      metrics.recordMetric('requests', 100);
      metrics.recordMetric('latency_ms', 45.5);

      final requests = await metrics.getMetrics('requests');
      expect(requests.length, 1);
      expect(requests.first.value, 100);
    });

    test('33.3: Metrics - get summary', () async {
      final metrics = MemoryMetricsCollector();

      metrics.recordMetric('cpu_usage', 50);
      metrics.recordMetric('cpu_usage', 60);
      metrics.recordMetric('memory_usage', 80);

      final summary = await metrics.getSummary();
      expect(summary['cpu_usage'], isNotNull);
      expect(summary['memory_usage'], isNotNull);
    });

    test('33.4: Error tracking - capture exception', () async {
      final errorTracker = MemoryErrorTracker();

      try {
        throw Exception('Test error');
      } catch (e, stack) {
        await errorTracker.captureException(e, stack);
      }

      final errors = await errorTracker.getErrors();
      expect(errors.isNotEmpty, true);
    });
  });
}

// Mock implementations for testing
class MemoryErrorTracker implements ErrorTracker {
  final List<dynamic> _errors = [];

  @override
  Future<void> captureException(Object error, StackTrace stackTrace, {Map<String, dynamic>? context}) async {
    _errors.add({'error': error, 'stackTrace': stackTrace, 'context': context});
  }

  @override
  Future<List<dynamic>> getErrors({DateTime? since}) async {
    return _errors;
  }

  @override
  Future<void> clearErrors() async {
    _errors.clear();
  }
}
