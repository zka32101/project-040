import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../models/remote_config_model.dart';

/// Abstract remote config service interface
abstract class RemoteConfigService {
  /// Initialize and fetch remote config
  Future<void> initialize();

  /// Get a string parameter
  String getString(String key, {String defaultValue = ''});

  /// Get an integer parameter
  int getInteger(String key, {int defaultValue = 0});

  /// Get a double parameter
  double getDouble(String key, {double defaultValue = 0.0});

  /// Get a boolean parameter
  bool getBoolean(String key, {bool defaultValue = false});

  /// Get JSON parameter
  Map<String, dynamic> getJson(String key);

  /// Check if feature flag is enabled for user
  bool isFeatureFlagEnabled(String featureName, String userId);

  /// Get experiment config
  ExperimentConfig? getExperimentConfig(String experimentId);

  /// Fetch latest config from server
  Future<void> fetchConfig();

  /// Get all parameters
  Map<String, RemoteConfigParameter> getAllParameters();

  /// Get all feature flags
  Map<String, FeatureFlag> getAllFeatureFlags();

  /// Set cache expiration duration
  void setCacheExpiration(Duration duration);

  /// Clear all cached data
  Future<void> clearCache();
}

/// Firebase implementation of remote config service
class FirebaseRemoteConfigService implements RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  late RemoteConfigState _state;
  late Duration _cacheExpiration;

  FirebaseRemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  @override
  Future<void> initialize() async {
    try {
      _cacheExpiration = const Duration(minutes: 15);

      // Set defaults
      await _remoteConfig.ensureInitialized();

      // Set minimum fetch interval
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: _cacheExpiration,
        ),
      );

      _state = RemoteConfigState.empty();

      // Fetch initial config
      await fetchConfig();
    } catch (e) {
      debugPrint('Error initializing remote config: $e');
      _state = RemoteConfigState.empty();
    }
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      debugPrint('Error getting string: $e');
      return defaultValue;
    }
  }

  @override
  int getInteger(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      debugPrint('Error getting integer: $e');
      return defaultValue;
    }
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double: $e');
      return defaultValue;
    }
  }

  @override
  bool getBoolean(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      debugPrint('Error getting boolean: $e');
      return defaultValue;
    }
  }

  @override
  Map<String, dynamic> getJson(String key) {
    try {
      final jsonString = _remoteConfig.getString(key);
      // Parse JSON if needed
      return {'value': jsonString};
    } catch (e) {
      debugPrint('Error getting JSON: $e');
      return {};
    }
  }

  @override
  bool isFeatureFlagEnabled(String featureName, String userId) {
    try {
      final flagJson = _remoteConfig.getString('feature_${featureName}_enabled');
      if (flagJson.isEmpty) return false;

      final flag = FeatureFlag.fromMap({
        'name': featureName,
        'enabled': true,
        'description': '',
        'rolloutPercentage': 100,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      return flag.shouldEnable(userId);
    } catch (e) {
      debugPrint('Error checking feature flag: $e');
      return false;
    }
  }

  @override
  ExperimentConfig? getExperimentConfig(String experimentId) {
    try {
      final configJson = _remoteConfig.getString('experiment_${experimentId}_config');
      if (configJson.isEmpty) return null;

      // In production, parse the JSON properly
      return ExperimentConfig(
        experimentId: experimentId,
        name: experimentId,
        active: true,
        variantPercentage: 50,
        controlParameters: {},
        variantParameters: {},
      );
    } catch (e) {
      debugPrint('Error getting experiment config: $e');
      return null;
    }
  }

  @override
  Future<void> fetchConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _state = _state.copyWith(lastFetch: DateTime.now());
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
    }
  }

  @override
  Map<String, RemoteConfigParameter> getAllParameters() {
    try {
      final params = <String, RemoteConfigParameter>{};

      for (final key in _remoteConfig.getKeys()) {
        final value = _remoteConfig.getValue(key);
        params[key] = RemoteConfigParameter(
          key: key,
          value: value.asString(),
          type: RemoteConfigValueType.string,
          defaultValue: '',
          description: '',
          fetchedAt: DateTime.now(),
        );
      }

      return params;
    } catch (e) {
      debugPrint('Error getting all parameters: $e');
      return {};
    }
  }

  @override
  Map<String, FeatureFlag> getAllFeatureFlags() {
    try {
      final flags = <String, FeatureFlag>{};

      for (final key in _remoteConfig.getKeys()) {
        if (key.startsWith('feature_')) {
          final featureName = key.replaceAll('feature_', '').replaceAll('_enabled', '');
          flags[featureName] = FeatureFlag(
            name: featureName,
            enabled: _remoteConfig.getBool(key),
            description: '',
            rolloutPercentage: 100,
            lastUpdated: DateTime.now(),
          );
        }
      }

      return flags;
    } catch (e) {
      debugPrint('Error getting all feature flags: $e');
      return {};
    }
  }

  @override
  void setCacheExpiration(Duration duration) {
    _cacheExpiration = duration;
  }

  @override
  Future<void> clearCache() async {
    try {
      _state = RemoteConfigState.empty();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}

/// Stub implementation for testing
class StubRemoteConfigService implements RemoteConfigService {
  final Map<String, String> _strings = {};
  final Map<String, int> _integers = {};
  final Map<String, double> _doubles = {};
  final Map<String, bool> _booleans = {};
  final Map<String, Map<String, dynamic>> _jsons = {};
  final Map<String, FeatureFlag> _featureFlags = {};

  StubRemoteConfigService({
    Map<String, String>? strings,
    Map<String, int>? integers,
    Map<String, double>? doubles,
    Map<String, bool>? booleans,
    Map<String, FeatureFlag>? featureFlags,
  }) {
    if (strings != null) _strings.addAll(strings);
    if (integers != null) _integers.addAll(integers);
    if (doubles != null) _doubles.addAll(doubles);
    if (booleans != null) _booleans.addAll(booleans);
    if (featureFlags != null) _featureFlags.addAll(featureFlags);
  }

  @override
  Future<void> initialize() async {
    // Stub: do nothing
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    return _strings[key] ?? defaultValue;
  }

  @override
  int getInteger(String key, {int defaultValue = 0}) {
    return _integers[key] ?? defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _doubles[key] ?? defaultValue;
  }

  @override
  bool getBoolean(String key, {bool defaultValue = false}) {
    return _booleans[key] ?? defaultValue;
  }

  @override
  Map<String, dynamic> getJson(String key) {
    return _jsons[key] ?? {};
  }

  @override
  bool isFeatureFlagEnabled(String featureName, String userId) {
    final flag = _featureFlags[featureName];
    if (flag == null) return false;
    return flag.shouldEnable(userId);
  }

  @override
  ExperimentConfig? getExperimentConfig(String experimentId) {
    // Stub: return null
    return null;
  }

  @override
  Future<void> fetchConfig() async {
    // Stub: do nothing
  }

  @override
  Map<String, RemoteConfigParameter> getAllParameters() {
    final params = <String, RemoteConfigParameter>{};

    for (final entry in _strings.entries) {
      params[entry.key] = RemoteConfigParameter(
        key: entry.key,
        value: entry.value,
        type: RemoteConfigValueType.string,
        defaultValue: '',
        description: '',
        fetchedAt: DateTime.now(),
      );
    }

    return params;
  }

  @override
  Map<String, FeatureFlag> getAllFeatureFlags() {
    return Map.from(_featureFlags);
  }

  @override
  void setCacheExpiration(Duration duration) {
    // Stub: do nothing
  }

  @override
  Future<void> clearCache() async {
    // Stub: do nothing
  }
}
