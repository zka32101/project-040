/// Remote config parameter types
enum RemoteConfigValueType { string, integer, double, boolean, json }

/// Represents a remote configuration parameter
class RemoteConfigParameter {
  final String key;
  final dynamic value;
  final RemoteConfigValueType type;
  final dynamic defaultValue;
  final String description;
  final DateTime fetchedAt;
  final DateTime? expiresAt;

  RemoteConfigParameter({
    required this.key,
    required this.value,
    required this.type,
    required this.defaultValue,
    required this.description,
    required this.fetchedAt,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  T getValue<T>() {
    if (isExpired) return defaultValue as T;
    return value as T;
  }

  factory RemoteConfigParameter.fromMap(Map<String, dynamic> map) {
    return RemoteConfigParameter(
      key: map['key'] as String? ?? '',
      value: map['value'],
      type: RemoteConfigValueType
          .values[(map['type'] as int?) ?? RemoteConfigValueType.string.index],
      defaultValue: map['defaultValue'],
      description: map['description'] as String? ?? '',
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'type': type.index,
      'defaultValue': defaultValue,
      'description': description,
      'fetchedAt': fetchedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

/// Feature flag configuration
class FeatureFlag {
  final String name;
  final bool enabled;
  final String description;
  final int rolloutPercentage; // 0-100
  final DateTime lastUpdated;
  final Map<String, dynamic> targetingRules;

  FeatureFlag({
    required this.name,
    required this.enabled,
    required this.description,
    required this.rolloutPercentage,
    required this.lastUpdated,
    Map<String, dynamic>? targetingRules,
  }) : targetingRules = targetingRules ?? {};

  bool shouldEnable(String userId) {
    if (!enabled) return false;

    // Simple hash-based rollout for consistent user assignment
    final hashValue = userId.hashCode.abs();
    final userPercentage = (hashValue % 100);

    return userPercentage < rolloutPercentage;
  }

  factory FeatureFlag.fromMap(Map<String, dynamic> map) {
    return FeatureFlag(
      name: map['name'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? false,
      description: map['description'] as String? ?? '',
      rolloutPercentage: map['rolloutPercentage'] as int? ?? 0,
      lastUpdated: DateTime.parse(
          (map['lastUpdated'] as String?) ?? DateTime.now().toIso8601String()),
      targetingRules: map['targetingRules'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'enabled': enabled,
      'description': description,
      'rolloutPercentage': rolloutPercentage,
      'lastUpdated': lastUpdated.toIso8601String(),
      'targetingRules': targetingRules,
    };
  }
}

/// Remote configuration state
class RemoteConfigState {
  final Map<String, RemoteConfigParameter> parameters;
  final Map<String, FeatureFlag> featureFlags;
  final DateTime lastFetch;
  final Duration fetchInterval;

  RemoteConfigState({
    required this.parameters,
    required this.featureFlags,
    required this.lastFetch,
    required this.fetchInterval,
  });

  bool get needsRefresh =>
      DateTime.now().difference(lastFetch) > fetchInterval;

  RemoteConfigParameter? getParameter(String key) {
    return parameters[key];
  }

  T? getParameterValue<T>(String key) {
    final param = parameters[key];
    if (param == null || param.isExpired) return null;
    return param.value as T?;
  }

  bool isFeatureFlagEnabled(String featureName, String userId) {
    final flag = featureFlags[featureName];
    if (flag == null) return false;
    return flag.shouldEnable(userId);
  }

  factory RemoteConfigState.empty() {
    return RemoteConfigState(
      parameters: {},
      featureFlags: {},
      lastFetch: DateTime.now(),
      fetchInterval: const Duration(minutes: 15),
    );
  }

  RemoteConfigState copyWith({
    Map<String, RemoteConfigParameter>? parameters,
    Map<String, FeatureFlag>? featureFlags,
    DateTime? lastFetch,
    Duration? fetchInterval,
  }) {
    return RemoteConfigState(
      parameters: parameters ?? this.parameters,
      featureFlags: featureFlags ?? this.featureFlags,
      lastFetch: lastFetch ?? this.lastFetch,
      fetchInterval: fetchInterval ?? this.fetchInterval,
    );
  }
}

/// Experiment configuration (for A/B testing via Remote Config)
class ExperimentConfig {
  final String experimentId;
  final String name;
  final bool active;
  final int variantPercentage; // Percentage assigned to variant (rest get control)
  final Map<String, dynamic> controlParameters;
  final Map<String, dynamic> variantParameters;
  final List<String> targetUserIds; // Empty means all users

  ExperimentConfig({
    required this.experimentId,
    required this.name,
    required this.active,
    required this.variantPercentage,
    required this.controlParameters,
    required this.variantParameters,
    List<String>? targetUserIds,
  }) : targetUserIds = targetUserIds ?? [];

  bool isUserInVariant(String userId) {
    if (!active) return false;

    // Check if user is targeted
    if (targetUserIds.isNotEmpty && !targetUserIds.contains(userId)) {
      return false;
    }

    // Hash-based assignment for consistency
    final hashValue = userId.hashCode.abs();
    final userPercentage = (hashValue % 100);

    return userPercentage < variantPercentage;
  }

  Map<String, dynamic> getConfigForUser(String userId) {
    return isUserInVariant(userId) ? variantParameters : controlParameters;
  }

  factory ExperimentConfig.fromMap(Map<String, dynamic> map) {
    return ExperimentConfig(
      experimentId: map['experimentId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      active: map['active'] as bool? ?? false,
      variantPercentage: map['variantPercentage'] as int? ?? 50,
      controlParameters:
          map['controlParameters'] as Map<String, dynamic>? ?? {},
      variantParameters:
          map['variantParameters'] as Map<String, dynamic>? ?? {},
      targetUserIds:
          (map['targetUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'experimentId': experimentId,
      'name': name,
      'active': active,
      'variantPercentage': variantPercentage,
      'controlParameters': controlParameters,
      'variantParameters': variantParameters,
      'targetUserIds': targetUserIds,
    };
  }
}
