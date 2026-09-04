/// Phase 38: Feature Flags & A/B Testing サービス実装
///
/// フィーチャーフラグ管理、A/Bテスト、段階的ロールアウト

import 'package:project_040/models/feature_flag_models.dart';

/// フィーチャーフラグリポジトリインターフェース
abstract class FeatureFlagRepository {
  /// フラグを取得
  Future<FeatureFlag?> getFlag(String flagId);

  /// フラグを保存
  Future<void> saveFlag(FeatureFlag flag);

  /// すべてのフラグを取得
  Future<List<FeatureFlag>> getAllFlags();

  /// フラグ名で検索
  Future<FeatureFlag?> getFlagByName(String name);

  /// セグメントを保存
  Future<void> saveSegment(UserSegment segment);

  /// セグメントを取得
  Future<UserSegment?> getSegment(String segmentId);

  /// イベントを保存
  Future<void> saveEvent(FeatureFlagEvent event);

  /// メトリクスを保存
  Future<void> saveMetrics(FeatureFlagMetrics metrics);
}

/// メモリ実装のフィーチャーフラグリポジトリ
class MemoryFeatureFlagRepository implements FeatureFlagRepository {
  final Map<String, FeatureFlag> _flags = {};
  final Map<String, UserSegment> _segments = {};
  final Map<String, FeatureFlagEvent> _events = {};
  final Map<String, FeatureFlagMetrics> _metrics = {};

  @override
  Future<FeatureFlag?> getFlag(String flagId) async => _flags[flagId];

  @override
  Future<void> saveFlag(FeatureFlag flag) async {
    _flags[flag.flagId] = flag;
  }

  @override
  Future<List<FeatureFlag>> getAllFlags() async => _flags.values.toList();

  @override
  Future<FeatureFlag?> getFlagByName(String name) async {
    try {
      return _flags.values.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSegment(UserSegment segment) async {
    _segments[segment.segmentId] = segment;
  }

  @override
  Future<UserSegment?> getSegment(String segmentId) async => _segments[segmentId];

  @override
  Future<void> saveEvent(FeatureFlagEvent event) async {
    _events[event.eventId] = event;
  }

  @override
  Future<void> saveMetrics(FeatureFlagMetrics metrics) async {
    _metrics[metrics.metricsId] = metrics;
  }
}

/// フィーチャーフラグ評価エンジンインターフェース
abstract class FlagEvaluationEngine {
  /// フラグを評価
  Future<FlagEvaluationResult> evaluateFlag(
    String flagId,
    EvaluationContext context,
  );

  /// 複数フラグを評価
  Future<List<FlagEvaluationResult>> evaluateFlags(
    List<String> flagIds,
    EvaluationContext context,
  );

  /// ユーザーのバリアント割り当て
  Future<String?> assignVariant(
    String flagId,
    String userId,
  );
}

/// メモリ実装のフィーチャーフラグ評価エンジン
class MemoryFlagEvaluationEngine implements FlagEvaluationEngine {
  final FeatureFlagRepository _repository;
  final Map<String, Map<String, String>> _variantAssignments = {}; // flagId -> userId -> variantId

  MemoryFlagEvaluationEngine(this._repository);

  @override
  Future<FlagEvaluationResult> evaluateFlag(
    String flagId,
    EvaluationContext context,
  ) async {
    final flag = await _repository.getFlag(flagId);
    if (flag == null) {
      return FlagEvaluationResult(
        flagId: flagId,
        userId: context.userId,
        enabled: false,
        evaluatedAt: DateTime.now(),
        reason: 'Flag not found',
      );
    }

    // 強制バリアント
    if (context.forcedVariantId != null && flag.allowForcedVariation) {
      final variant = flag.variants
          .firstWhere((v) => v.variantId == context.forcedVariantId, orElse: () => flag.variants.first);
      return FlagEvaluationResult(
        flagId: flagId,
        userId: context.userId,
        enabled: true,
        variantId: variant.variantId,
        config: variant.config,
        evaluatedAt: DateTime.now(),
        reason: 'Forced variant',
      );
    }

    // フラグが無効
    if (!flag.isEnabled) {
      return FlagEvaluationResult(
        flagId: flagId,
        userId: context.userId,
        enabled: false,
        evaluatedAt: DateTime.now(),
        reason: 'Flag disabled',
      );
    }

    // ロールアウト率チェック
    final userHash = context.userId.hashCode.abs() % 100;
    final enabled = userHash < flag.rolloutPercentage;

    // バリアント割り当て
    String? assignedVariant;
    if (enabled && flag.variants.isNotEmpty) {
      assignedVariant = await assignVariant(flagId, context.userId);
    }

    final variant = assignedVariant != null
        ? flag.variants.firstWhere((v) => v.variantId == assignedVariant, orElse: () => flag.variants.first)
        : null;

    return FlagEvaluationResult(
      flagId: flagId,
      userId: context.userId,
      enabled: enabled,
      variantId: variant?.variantId,
      config: variant?.config ?? flag.config,
      evaluatedAt: DateTime.now(),
      reason: 'Evaluated',
    );
  }

  @override
  Future<List<FlagEvaluationResult>> evaluateFlags(
    List<String> flagIds,
    EvaluationContext context,
  ) async {
    final results = <FlagEvaluationResult>[];
    for (final flagId in flagIds) {
      final result = await evaluateFlag(flagId, context);
      results.add(result);
    }
    return results;
  }

  @override
  Future<String?> assignVariant(String flagId, String userId) async {
    if (!_variantAssignments.containsKey(flagId)) {
      _variantAssignments[flagId] = {};
    }

    if (!_variantAssignments[flagId]!.containsKey(userId)) {
      final flag = await _repository.getFlag(flagId);
      if (flag?.variants.isNotEmpty ?? false) {
        // 簡易的なバリアント割り当て
        final variantIndex = userId.hashCode.abs() % flag!.variants.length;
        _variantAssignments[flagId]![userId] = flag.variants[variantIndex].variantId;
      }
    }

    return _variantAssignments[flagId]![userId];
  }
}

/// A/Bテスト管理インターフェース
abstract class ExperimentManager {
  /// 実験を作成
  Future<void> createExperiment(ExperimentConfig config);

  /// 実験を取得
  Future<ExperimentConfig?> getExperiment(String experimentId);

  /// 実験結果を保存
  Future<void> saveExperimentResult(ExperimentResult result);

  /// 実験結果を取得
  Future<ExperimentResult?> getExperimentResult(String resultId);

  /// 実験を終了
  Future<void> endExperiment(String experimentId);
}

/// メモリ実装のA/Bテスト管理
class MemoryExperimentManager implements ExperimentManager {
  final Map<String, ExperimentConfig> _experiments = {};
  final Map<String, ExperimentResult> _results = {};

  @override
  Future<void> createExperiment(ExperimentConfig config) async {
    _experiments[config.experimentId] = config;
  }

  @override
  Future<ExperimentConfig?> getExperiment(String experimentId) async =>
      _experiments[experimentId];

  @override
  Future<void> saveExperimentResult(ExperimentResult result) async {
    _results[result.resultId] = result;
  }

  @override
  Future<ExperimentResult?> getExperimentResult(String resultId) async =>
      _results[resultId];

  @override
  Future<void> endExperiment(String experimentId) async {
    final experiment = _experiments[experimentId];
    if (experiment != null) {
      _experiments[experimentId] = ExperimentConfig(
        experimentId: experiment.experimentId,
        flagId: experiment.flagId,
        name: experiment.name,
        description: experiment.description,
        variants: experiment.variants,
        startDate: experiment.startDate,
        endDate: DateTime.now(),
        confidenceLevel: experiment.confidenceLevel,
        minSampleSize: experiment.minSampleSize,
        primaryMetric: experiment.primaryMetric,
        secondaryMetrics: experiment.secondaryMetrics,
        isActive: false,
        createdAt: experiment.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

/// ロールアウト管理インターフェース
abstract class RolloutManager {
  /// ロールアウトを開始
  Future<void> startRollout(
    String flagId,
    double initialPercentage,
    RolloutStrategy strategy,
  );

  /// ロールアウト率を更新
  Future<void> updateRolloutPercentage(String flagId, double percentage);

  /// ロールアウト履歴を保存
  Future<void> saveRolloutHistory(RolloutHistory history);

  /// ロールアウト履歴を取得
  Future<List<RolloutHistory>> getRolloutHistory(String flagId);
}

/// メモリ実装のロールアウト管理
class MemoryRolloutManager implements RolloutManager {
  final FeatureFlagRepository _repository;
  final Map<String, List<RolloutHistory>> _histories = {};

  MemoryRolloutManager(this._repository);

  @override
  Future<void> startRollout(
    String flagId,
    double initialPercentage,
    RolloutStrategy strategy,
  ) async {
    final flag = await _repository.getFlag(flagId);
    if (flag != null) {
      final updatedFlag = FeatureFlag(
        flagId: flag.flagId,
        name: flag.name,
        description: flag.description,
        status: FeatureFlagStatus.rolling,
        strategy: strategy,
        variants: flag.variants,
        config: flag.config,
        targetSegments: flag.targetSegments,
        rolloutPercentage: initialPercentage,
        enabledAt: DateTime.now(),
        disabledAt: flag.disabledAt,
        scheduledAt: flag.scheduledAt,
        ownerTeam: flag.ownerTeam,
        tags: flag.tags,
        allowForcedVariation: flag.allowForcedVariation,
        createdAt: flag.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.saveFlag(updatedFlag);
    }
  }

  @override
  Future<void> updateRolloutPercentage(String flagId, double percentage) async {
    final flag = await _repository.getFlag(flagId);
    if (flag != null) {
      final updatedFlag = FeatureFlag(
        flagId: flag.flagId,
        name: flag.name,
        description: flag.description,
        status: percentage >= 100.0 ? FeatureFlagStatus.enabled : flag.status,
        strategy: flag.strategy,
        variants: flag.variants,
        config: flag.config,
        targetSegments: flag.targetSegments,
        rolloutPercentage: percentage,
        enabledAt: flag.enabledAt,
        disabledAt: flag.disabledAt,
        scheduledAt: flag.scheduledAt,
        ownerTeam: flag.ownerTeam,
        tags: flag.tags,
        allowForcedVariation: flag.allowForcedVariation,
        createdAt: flag.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.saveFlag(updatedFlag);
    }
  }

  @override
  Future<void> saveRolloutHistory(RolloutHistory history) async {
    if (!_histories.containsKey(history.flagId)) {
      _histories[history.flagId] = [];
    }
    _histories[history.flagId]!.add(history);
  }

  @override
  Future<List<RolloutHistory>> getRolloutHistory(String flagId) async =>
      _histories[flagId] ?? [];
}

/// フィーチャーフラグ マネージャー (ファサードパターン)
class FeatureFlagManager {
  late FeatureFlagRepository _repository;
  late FlagEvaluationEngine _evaluationEngine;
  late ExperimentManager _experimentManager;
  late RolloutManager _rolloutManager;

  FeatureFlagManager({
    FeatureFlagRepository? repository,
    FlagEvaluationEngine? evaluationEngine,
    ExperimentManager? experimentManager,
    RolloutManager? rolloutManager,
  }) {
    _repository = repository ?? MemoryFeatureFlagRepository();
    _evaluationEngine = evaluationEngine ?? MemoryFlagEvaluationEngine(_repository);
    _experimentManager = experimentManager ?? MemoryExperimentManager();
    _rolloutManager = rolloutManager ?? MemoryRolloutManager(_repository);
  }

  /// フラグを作成
  Future<void> createFlag(FeatureFlag flag) => _repository.saveFlag(flag);

  /// フラグを取得
  Future<FeatureFlag?> getFlag(String flagId) => _repository.getFlag(flagId);

  /// すべてのフラグを取得
  Future<List<FeatureFlag>> getAllFlags() => _repository.getAllFlags();

  /// フラグを評価
  Future<FlagEvaluationResult> evaluateFlag(
    String flagId,
    EvaluationContext context,
  ) =>
      _evaluationEngine.evaluateFlag(flagId, context);

  /// 複数フラグを評価
  Future<List<FlagEvaluationResult>> evaluateFlags(
    List<String> flagIds,
    EvaluationContext context,
  ) =>
      _evaluationEngine.evaluateFlags(flagIds, context);

  /// バリアント割り当て
  Future<String?> assignVariant(String flagId, String userId) =>
      _evaluationEngine.assignVariant(flagId, userId);

  /// 実験を作成
  Future<void> createExperiment(ExperimentConfig config) =>
      _experimentManager.createExperiment(config);

  /// 実験を取得
  Future<ExperimentConfig?> getExperiment(String experimentId) =>
      _experimentManager.getExperiment(experimentId);

  /// 実験結果を保存
  Future<void> saveExperimentResult(ExperimentResult result) =>
      _experimentManager.saveExperimentResult(result);

  /// ロールアウトを開始
  Future<void> startRollout(
    String flagId,
    double initialPercentage,
    RolloutStrategy strategy,
  ) =>
      _rolloutManager.startRollout(flagId, initialPercentage, strategy);

  /// ロールアウト率を更新
  Future<void> updateRolloutPercentage(String flagId, double percentage) =>
      _rolloutManager.updateRolloutPercentage(flagId, percentage);

  /// ロールアウト履歴を保存
  Future<void> saveRolloutHistory(RolloutHistory history) =>
      _rolloutManager.saveRolloutHistory(history);

  /// ロールアウト履歴を取得
  Future<List<RolloutHistory>> getRolloutHistory(String flagId) =>
      _rolloutManager.getRolloutHistory(flagId);

  /// セグメントを作成
  Future<void> createSegment(UserSegment segment) =>
      _repository.saveSegment(segment);

  /// セグメントを取得
  Future<UserSegment?> getSegment(String segmentId) =>
      _repository.getSegment(segmentId);
}
