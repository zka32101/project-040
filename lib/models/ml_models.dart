/// Phase 88: Advanced Machine Learning & AI Integration
/// Core domain models for ML and AI systems
library ml_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum ModelType {
  regression('回帰'),
  classification('分類'),
  clustering('クラスタリング'),
  timeSeries('時系列'),
  nlp('自然言語処理'),
  customModel('カスタム');

  const ModelType(this.displayName);
  final String displayName;
}

enum ModelStatus {
  draft('下書き'),
  training('トレーニング中'),
  evaluating('評価中'),
  deployed('デプロイ済み'),
  archived('アーカイブ'),
  failed('失敗');

  const ModelStatus(this.displayName);
  final String displayName;
}

enum FeatureType {
  numeric('数値'),
  categorical('カテゴリ'),
  text('テキスト'),
  datetime('日時'),
  embedding('エンベディング'),
  image('画像');

  const FeatureType(this.displayName);
  final String displayName;
}

enum TrainingStatus {
  pending('保留中'),
  running('実行中'),
  completed('完了'),
  failed('失敗'),
  paused('一時停止'),
  cancelled('キャンセル');

  const TrainingStatus(this.displayName);
  final String displayName;
}

enum PredictionType {
  batch('バッチ'),
  realtime('リアルタイム'),
  scheduled('スケジュール済み'),
  streaming('ストリーミング'),
  interactive('対話型'),
  api('API');

  const PredictionType(this.displayName);
  final String displayName;
}

enum ModelEvaluationMetric {
  accuracy('精度'),
  precision('適合率'),
  recall('再現率'),
  f1Score('F1スコア'),
  rocAuc('ROC AUC'),
  rmse('RMSE');

  const ModelEvaluationMetric(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// MLModel: 機械学習モデル
class MLModel {
  MLModel({
    required this.id,
    required this.name,
    required this.modelType,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.owner,
    this.version = '1.0',
    this.status = ModelStatus.draft,
    this.accuracy = 0.0,
    this.deployedAt,
  });

  final String id;
  final String name;
  final ModelType modelType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? owner;
  final String version;
  final ModelStatus status;
  final double accuracy;
  final DateTime? deployedAt;

  bool get isDeployed => status == ModelStatus.deployed;
  bool get isTraining => status == ModelStatus.training;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysSinceDeployment => deployedAt != null
      ? DateTime.now().difference(deployedAt!).inDays
      : -1;

  MLModel copyWith({
    String? id,
    String? name,
    ModelType? modelType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? owner,
    String? version,
    ModelStatus? status,
    double? accuracy,
    DateTime? deployedAt,
  }) {
    return MLModel(
      id: id ?? this.id,
      name: name ?? this.name,
      modelType: modelType ?? this.modelType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      version: version ?? this.version,
      status: status ?? this.status,
      accuracy: accuracy ?? this.accuracy,
      deployedAt: deployedAt ?? this.deployedAt,
    );
  }
}

/// TrainingJob: トレーニングジョブ
class TrainingJob {
  TrainingJob({
    required this.id,
    required this.modelId,
    required this.datasetId,
    required this.startedAt,
    required this.createdAt,
    this.completedAt,
    this.status = TrainingStatus.pending,
    this.epochsCompleted = 0,
    this.totalEpochs = 100,
    this.currentLoss = 0.0,
    this.bestLoss = double.infinity,
  });

  final String id;
  final String modelId;
  final String datasetId;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final TrainingStatus status;
  final int epochsCompleted;
  final int totalEpochs;
  final double currentLoss;
  final double bestLoss;

  bool get isRunning => status == TrainingStatus.running;
  bool get isCompleted => status == TrainingStatus.completed;
  int get durationSeconds => completedAt != null
      ? completedAt!.difference(startedAt).inSeconds
      : DateTime.now().difference(startedAt).inSeconds;
  double get progressPercent =>
      totalEpochs > 0 ? (epochsCompleted / totalEpochs) * 100 : 0.0;
  bool get isConverging => currentLoss < bestLoss;
}

/// FeatureDefinition: 特徴定義
class FeatureDefinition {
  FeatureDefinition({
    required this.id,
    required this.name,
    required this.featureType,
    required this.sourceField,
    required this.createdAt,
    this.description,
    this.datasetId,
    this.isNormalized = false,
    this.min = 0.0,
    this.max = 1.0,
  });

  final String id;
  final String name;
  final FeatureType featureType;
  final String sourceField;
  final DateTime createdAt;
  final String? description;
  final String? datasetId;
  final bool isNormalized;
  final double min;
  final double max;

  bool get isNumeric => featureType == FeatureType.numeric;
  double get range => max - min;
  int get ageInHours => DateTime.now().difference(createdAt).inHours;
}

/// ModelEvaluation: モデル評価
class ModelEvaluation {
  ModelEvaluation({
    required this.id,
    required this.modelId,
    required this.evaluatedAt,
    required this.createdAt,
    this.accuracy = 0.0,
    this.precision = 0.0,
    this.recall = 0.0,
    this.f1Score = 0.0,
    this.rocAuc = 0.0,
    this.rmse = 0.0,
    this.sampleSize = 0,
  });

  final String id;
  final String modelId;
  final DateTime evaluatedAt;
  final DateTime createdAt;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double rocAuc;
  final double rmse;
  final int sampleSize;

  bool get isHighAccuracy => accuracy > 0.9;
  bool get isHighPrecision => precision > 0.9;
  int get ageInMinutes => DateTime.now().difference(evaluatedAt).inMinutes;
  double get overallScore => (accuracy + precision + recall + f1Score) / 4;
}

/// PredictionRequest: 予測リクエスト
class PredictionRequest {
  PredictionRequest({
    required this.id,
    required this.modelId,
    required this.inputData,
    required this.createdAt,
    required this.predictionType,
    this.processedAt,
    this.confidence = 0.0,
    this.prediction,
    this.error,
  });

  final String id;
  final String modelId;
  final Map<String, dynamic> inputData;
  final DateTime createdAt;
  final PredictionType predictionType;
  final DateTime? processedAt;
  final double confidence;
  final dynamic prediction;
  final String? error;

  bool get isProcessed => processedAt != null;
  bool get isSuccessful => prediction != null && error == null;
  int get processingTimeMs => processedAt != null
      ? processedAt!.difference(createdAt).inMilliseconds
      : -1;
  bool get isHighConfidence => confidence > 0.9;
}

/// Dataset: データセット
class Dataset {
  Dataset({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description,
    this.dataFormat = 'csv',
    this.rowCount = 0,
    this.columnCount = 0,
    this.sizeBytes = 0,
    this.isProcessed = false,
    this.lastAccessedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? description;
  final String dataFormat;
  final int rowCount;
  final int columnCount;
  final int sizeBytes;
  final bool isProcessed;
  final DateTime? lastAccessedAt;

  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysSinceAccess => lastAccessedAt != null
      ? DateTime.now().difference(lastAccessedAt!).inDays
      : -1;
  bool get isLarge => sizeBytes > 1000000;
}

/// HyperParameter: ハイパーパラメータ
class HyperParameter {
  HyperParameter({
    required this.id,
    required this.trainingJobId,
    required this.parameterName,
    required this.parameterValue,
    required this.createdAt,
    this.description,
    this.parameterType = 'numeric',
    this.min = 0.0,
    this.max = 1.0,
  });

  final String id;
  final String trainingJobId;
  final String parameterName;
  final dynamic parameterValue;
  final DateTime createdAt;
  final String? description;
  final String parameterType;
  final double min;
  final double max;

  bool get isNumeric => parameterType == 'numeric';
  bool get isInRange =>
      isNumeric ? parameterValue >= min && parameterValue <= max : true;
}

/// ModelArtifact: モデルアーティファクト
class ModelArtifact {
  ModelArtifact({
    required this.id,
    required this.modelId,
    required this.artifactType,
    required this.storageLocation,
    required this.createdAt,
    this.description,
    this.fileSize = 0,
    this.checksum,
    this.isCompressed = false,
  });

  final String id;
  final String modelId;
  final String artifactType;
  final String storageLocation;
  final DateTime createdAt;
  final String? description;
  final int fileSize;
  final String? checksum;
  final bool isCompressed;

  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isLarge => fileSize > 1000000;
}

/// FeatureImportance: 特徴重要度
class FeatureImportance {
  FeatureImportance({
    required this.id,
    required this.modelId,
    required this.featureName,
    required this.importanceScore,
    required this.createdAt,
    this.rank = 0,
    this.percentageContribution = 0.0,
  });

  final String id;
  final String modelId;
  final String featureName;
  final double importanceScore;
  final DateTime createdAt;
  final int rank;
  final double percentageContribution;

  bool get isHighImportance => importanceScore > 0.5;
  int get ageInHours => DateTime.now().difference(createdAt).inHours;
}

/// RecommendationEngine: レコメンデーションエンジン
class RecommendationEngine {
  RecommendationEngine({
    required this.id,
    required this.name,
    required this.modelId,
    required this.createdAt,
    this.description,
    this.algorithmType = 'collaborative',
    this.isActive = true,
    this.recommendationCount = 10,
    this.lastUpdatedAt,
  });

  final String id;
  final String name;
  final String modelId;
  final DateTime createdAt;
  final String? description;
  final String algorithmType;
  final bool isActive;
  final int recommendationCount;
  final DateTime? lastUpdatedAt;

  bool get isCollaborative => algorithmType == 'collaborative';
  bool get needsUpdate => lastUpdatedAt == null ||
      DateTime.now().difference(lastUpdatedAt!).inDays > 7;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

/// ModelVersionControl: モデルバージョン管理
class ModelVersionControl {
  ModelVersionControl({
    required this.id,
    required this.modelId,
    required this.version,
    required this.createdAt,
    this.description,
    this.changesSummary,
    this.parentVersion,
    this.accuracy = 0.0,
    this.isActive = false,
  });

  final String id;
  final String modelId;
  final String version;
  final DateTime createdAt;
  final String? description;
  final String? changesSummary;
  final String? parentVersion;
  final double accuracy;
  final bool isActive;

  bool get isProduction => isActive;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isHighQuality => accuracy > 0.85;
}
