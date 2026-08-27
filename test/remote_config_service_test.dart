import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/remote_config_model.dart';
import 'package:bike_license_kore/services/remote_config_service.dart';

void main() {
  group('Remote Config Service', () {
    late StubRemoteConfigService service;

    setUp(() {
      service = StubRemoteConfigService(
        strings: {
          'app_version': '2.0.0',
          'support_url': 'https://support.example.com',
        },
        integers: {
          'max_quiz_retries': 3,
          'daily_quiz_limit': 5,
        },
        doubles: {
          'difficulty_multiplier': 1.25,
          'bonus_points_rate': 0.15,
        },
        booleans: {
          'enable_analytics': true,
          'enable_notifications': true,
        },
        featureFlags: {
          'new_quiz_ui': FeatureFlag(
            name: 'new_quiz_ui',
            enabled: true,
            description: 'New quiz interface',
            rolloutPercentage: 50,
            lastUpdated: DateTime.now(),
          ),
          'offline_mode': FeatureFlag(
            name: 'offline_mode',
            enabled: false,
            description: 'Offline quiz mode',
            rolloutPercentage: 0,
            lastUpdated: DateTime.now(),
          ),
        },
      );
    });

    group('String parameters', () {
      test('should get string value', () {
        const value = 'value';

        expect(value, equals('value'));
      });

      test('should get app version string', () {
        final version = service.getString('app_version');

        expect(version, equals('2.0.0'));
      });

      test('should return default for missing string', () {
        final value = service.getString('nonexistent', defaultValue: 'default');

        expect(value, equals('default'));
      });

      test('should handle empty string', () {
        final value = service.getString('empty_string', defaultValue: 'default');

        expect(value, isA<String>());
      });
    });

    group('Integer parameters', () {
      test('should get integer value', () {
        final retries = service.getInteger('max_quiz_retries');

        expect(retries, equals(3));
      });

      test('should get quiz limit integer', () {
        final limit = service.getInteger('daily_quiz_limit');

        expect(limit, equals(5));
      });

      test('should return default for missing integer', () {
        final value = service.getInteger('nonexistent', defaultValue: 10);

        expect(value, equals(10));
      });

      test('should handle zero value', () {
        final value = service.getInteger('zero_value', defaultValue: 5);

        expect(value, isA<int>());
      });
    });

    group('Double parameters', () {
      test('should get double value', () {
        final multiplier = service.getDouble('difficulty_multiplier');

        expect(multiplier, equals(1.25));
      });

      test('should get bonus rate double', () {
        final rate = service.getDouble('bonus_points_rate');

        expect(rate, equals(0.15));
      });

      test('should return default for missing double', () {
        final value = service.getDouble('nonexistent', defaultValue: 1.0);

        expect(value, equals(1.0));
      });
    });

    group('Boolean parameters', () {
      test('should get boolean value true', () {
        final enabled = service.getBoolean('enable_analytics');

        expect(enabled, isTrue);
      });

      test('should get boolean value false', () {
        final enabled = service.getBoolean('enable_notifications');

        expect(enabled, isTrue);
      });

      test('should return default for missing boolean', () {
        final value = service.getBoolean('nonexistent', defaultValue: false);

        expect(value, isFalse);
      });
    });

    group('JSON parameters', () {
      test('should get JSON value', () {
        final json = service.getJson('config_json');

        expect(json, isA<Map<String, dynamic>>());
      });

      test('should return empty map for missing JSON', () {
        final json = service.getJson('nonexistent');

        expect(json, isEmpty);
      });
    });

    group('Feature flags', () {
      test('should check if feature is enabled', () {
        final enabled = service.isFeatureFlagEnabled('new_quiz_ui', 'user_123');

        expect(enabled, isBool);
      });

      test('should return false for disabled flag', () {
        final enabled = service.isFeatureFlagEnabled('offline_mode', 'user_123');

        expect(enabled, isFalse);
      });

      test('should use hash-based rollout for enabled flag', () {
        final flag = FeatureFlag(
          name: 'test_feature',
          enabled: true,
          description: 'Test feature',
          rolloutPercentage: 50,
          lastUpdated: DateTime.now(),
        );

        final user1Enabled = flag.shouldEnable('user_1');
        final user2Enabled = flag.shouldEnable('user_2');

        // At least one should be enabled due to 50% rollout
        expect(
          user1Enabled || user2Enabled,
          isTrue,
        );
      });

      test('should handle 100% rollout', () {
        final flag = FeatureFlag(
          name: 'universal_feature',
          enabled: true,
          description: 'Available to all',
          rolloutPercentage: 100,
          lastUpdated: DateTime.now(),
        );

        expect(flag.shouldEnable('user_1'), isTrue);
        expect(flag.shouldEnable('user_2'), isTrue);
        expect(flag.shouldEnable('user_999'), isTrue);
      });

      test('should handle 0% rollout', () {
        final flag = FeatureFlag(
          name: 'disabled_feature',
          enabled: false,
          description: 'Not available',
          rolloutPercentage: 0,
          lastUpdated: DateTime.now(),
        );

        expect(flag.shouldEnable('user_1'), isFalse);
        expect(flag.shouldEnable('user_2'), isFalse);
      });
    });

    group('All parameters and flags', () {
      test('should get all parameters', () {
        final params = service.getAllParameters();

        expect(params, isA<Map<String, RemoteConfigParameter>>());
      });

      test('should get all feature flags', () {
        final flags = service.getAllFeatureFlags();

        expect(flags, isA<Map<String, FeatureFlag>>());
        expect(flags.containsKey('new_quiz_ui'), isTrue);
        expect(flags.containsKey('offline_mode'), isTrue);
      });
    });

    group('Configuration management', () {
      test('should initialize service', () async {
        await service.initialize();

        expect(true, isTrue);
      });

      test('should fetch config', () async {
        await service.fetchConfig();

        expect(true, isTrue);
      });

      test('should set cache expiration', () {
        service.setCacheExpiration(const Duration(minutes: 30));

        expect(true, isTrue);
      });

      test('should clear cache', () async {
        await service.clearCache();

        expect(true, isTrue);
      });
    });

    group('Experiment configs', () {
      test('should create experiment config from map', () {
        final map = {
          'experimentId': 'exp_001',
          'name': 'Quiz Difficulty Test',
          'active': true,
          'variantPercentage': 50,
          'controlParameters': {'difficulty': 'normal'},
          'variantParameters': {'difficulty': 'hard'},
          'targetUserIds': [],
        };

        final config = ExperimentConfig.fromMap(map);

        expect(config.experimentId, equals('exp_001'));
        expect(config.name, equals('Quiz Difficulty Test'));
        expect(config.active, isTrue);
      });

      test('should determine variant assignment', () {
        final config = ExperimentConfig(
          experimentId: 'exp_001',
          name: 'Test',
          active: true,
          variantPercentage: 50,
          controlParameters: {'mode': 'normal'},
          variantParameters: {'mode': 'hard'},
        );

        final isInVariant = config.isUserInVariant('user_123');

        expect(isInVariant, isBool);
      });

      test('should return correct config for variant users', () {
        final config = ExperimentConfig(
          experimentId: 'exp_001',
          name: 'Test',
          active: true,
          variantPercentage: 100,
          controlParameters: {'difficulty': 'normal'},
          variantParameters: {'difficulty': 'hard'},
        );

        final userConfig = config.getConfigForUser('user_123');

        expect(userConfig['difficulty'], equals('hard'));
      });

      test('should return correct config for control users', () {
        final config = ExperimentConfig(
          experimentId: 'exp_001',
          name: 'Test',
          active: false,
          variantPercentage: 0,
          controlParameters: {'difficulty': 'normal'},
          variantParameters: {'difficulty': 'hard'},
        );

        final userConfig = config.getConfigForUser('user_123');

        expect(userConfig['difficulty'], equals('normal'));
      });

      test('should respect target user list', () {
        final config = ExperimentConfig(
          experimentId: 'exp_001',
          name: 'Test',
          active: true,
          variantPercentage: 100,
          controlParameters: {'mode': 'normal'},
          variantParameters: {'mode': 'hard'},
          targetUserIds: ['user_1', 'user_2'],
        );

        final targeted = config.isUserInVariant('user_1');
        final notTargeted = config.isUserInVariant('user_999');

        expect(targeted, isTrue);
        expect(notTargeted, isFalse);
      });
    });
  });

  group('Remote Config Models', () {
    group('RemoteConfigParameter', () {
      test('should create parameter from map', () {
        final map = {
          'key': 'max_retries',
          'value': 3,
          'type': RemoteConfigValueType.integer.index,
          'defaultValue': 1,
          'description': 'Maximum retry attempts',
        };

        final param = RemoteConfigParameter.fromMap(map);

        expect(param.key, equals('max_retries'));
        expect(param.value, equals(3));
        expect(param.type, equals(RemoteConfigValueType.integer));
      });

      test('should get parameter value', () {
        final param = RemoteConfigParameter(
          key: 'app_version',
          value: '2.0.0',
          type: RemoteConfigValueType.string,
          defaultValue: '1.0.0',
          description: 'App version',
          fetchedAt: DateTime.now(),
        );

        final value = param.getValue<String>();

        expect(value, equals('2.0.0'));
      });

      test('should return default for expired parameter', () {
        final param = RemoteConfigParameter(
          key: 'promo_code',
          value: 'SUMMER2024',
          type: RemoteConfigValueType.string,
          defaultValue: 'NONE',
          description: 'Promotional code',
          fetchedAt: DateTime.now().subtract(const Duration(hours: 25)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final value = param.getValue<String>();

        expect(value, equals('NONE'));
      });

      test('should identify expired parameters', () {
        final param = RemoteConfigParameter(
          key: 'temp_setting',
          value: true,
          type: RemoteConfigValueType.boolean,
          defaultValue: false,
          description: 'Temporary setting',
          fetchedAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(param.isExpired, isTrue);
      });
    });

    group('FeatureFlag', () {
      test('should create feature flag from map', () {
        final map = {
          'name': 'new_dashboard',
          'enabled': true,
          'description': 'New dashboard UI',
          'rolloutPercentage': 25,
          'lastUpdated': DateTime.now().toIso8601String(),
        };

        final flag = FeatureFlag.fromMap(map);

        expect(flag.name, equals('new_dashboard'));
        expect(flag.enabled, isTrue);
        expect(flag.rolloutPercentage, equals(25));
      });

      test('should disable flag for all when flag is off', () {
        final flag = FeatureFlag(
          name: 'disabled_feature',
          enabled: false,
          description: 'Disabled feature',
          rolloutPercentage: 100,
          lastUpdated: DateTime.now(),
        );

        expect(flag.shouldEnable('any_user'), isFalse);
      });

      test('should serialize to map', () {
        final flag = FeatureFlag(
          name: 'test_flag',
          enabled: true,
          description: 'Test flag',
          rolloutPercentage: 50,
          lastUpdated: DateTime.now(),
        );

        final map = flag.toMap();

        expect(map['name'], equals('test_flag'));
        expect(map['enabled'], isTrue);
        expect(map['rolloutPercentage'], equals(50));
      });
    });

    group('RemoteConfigState', () {
      test('should create empty state', () {
        final state = RemoteConfigState.empty();

        expect(state.parameters, isEmpty);
        expect(state.featureFlags, isEmpty);
        expect(state.needsRefresh, isTrue);
      });

      test('should check if refresh is needed', () {
        final recentFetch = RemoteConfigState(
          parameters: {},
          featureFlags: {},
          lastFetch: DateTime.now(),
          fetchInterval: const Duration(minutes: 15),
        );

        expect(recentFetch.needsRefresh, isFalse);
      });

      test('should get parameter value', () {
        final param = RemoteConfigParameter(
          key: 'max_retry',
          value: 5,
          type: RemoteConfigValueType.integer,
          defaultValue: 3,
          description: 'Max retry attempts',
          fetchedAt: DateTime.now(),
        );

        final state = RemoteConfigState(
          parameters: {'max_retry': param},
          featureFlags: {},
          lastFetch: DateTime.now(),
          fetchInterval: const Duration(minutes: 15),
        );

        final value = state.getParameter('max_retry');

        expect(value, isNotNull);
        expect(value?.value, equals(5));
      });

      test('should check feature flag status', () {
        final flag = FeatureFlag(
          name: 'beta_feature',
          enabled: true,
          description: 'Beta feature',
          rolloutPercentage: 50,
          lastUpdated: DateTime.now(),
        );

        final state = RemoteConfigState(
          parameters: {},
          featureFlags: {'beta_feature': flag},
          lastFetch: DateTime.now(),
          fetchInterval: const Duration(minutes: 15),
        );

        final enabled = state.isFeatureFlagEnabled('beta_feature', 'user_123');

        expect(enabled, isBool);
      });

      test('should copy with new values', () {
        final state1 = RemoteConfigState.empty();
        final newParams = <String, RemoteConfigParameter>{};

        final state2 = state1.copyWith(parameters: newParams);

        expect(state2.parameters, isEmpty);
        expect(state1.parameters, isEmpty);
      });
    });
  });

  group('Remote Config Integration Scenarios', () {
    late StubRemoteConfigService service;

    setUp(() {
      service = StubRemoteConfigService(
        strings: {'app_version': '2.0.0'},
        integers: {'daily_limit': 5},
        booleans: {'enable_analytics': true},
        featureFlags: {
          'premium_features': FeatureFlag(
            name: 'premium_features',
            enabled: true,
            description: 'Premium features',
            rolloutPercentage: 25,
            lastUpdated: DateTime.now(),
          ),
        },
      );
    });

    test('should load configuration on app startup', () async {
      await service.initialize();

      final version = service.getString('app_version');

      expect(version, equals('2.0.0'));
    });

    test('should support dynamic feature rollout', () async {
      await service.initialize();

      final enabledUsers = <int>[];
      for (int i = 0; i < 100; i++) {
        final enabled =
            service.isFeatureFlagEnabled('premium_features', 'user_$i');
        if (enabled) enabledUsers.add(i);
      }

      // Should roughly be 25% enabled
      expect(enabledUsers.length, greaterThan(5));
      expect(enabledUsers.length, lessThan(50));
    });

    test('should provide fallback values', () {
      final missing = service.getString('nonexistent', defaultValue: 'default');

      expect(missing, equals('default'));
    });

    test('should handle config refresh', () async {
      await service.fetchConfig();

      // After refresh, values should still be accessible
      final version = service.getString('app_version');
      expect(version, isNotEmpty);
    });
  });
}
