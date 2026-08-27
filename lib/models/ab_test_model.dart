import 'package:cloud_firestore/cloud_firestore.dart';

/// A/B Test variant
enum ABTestVariant { control, variant }

/// A/B Test status
enum ABTestStatus { active, completed, paused }

/// Represents an A/B test
class ABTest {
  final String id;
  final String name;
  final String description;
  final ABTestStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int minSampleSize;
  final double requiredConfidence; // 0.0 to 1.0

  ABTest({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.minSampleSize,
    required this.requiredConfidence,
  });

  bool get isActive => status == ABTestStatus.active;
  bool get isCompleted => status == ABTestStatus.completed;

  factory ABTest.fromMap(Map<String, dynamic> map) {
    return ABTest(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: ABTestStatus.values[(map['status'] as int?) ?? 0],
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      minSampleSize: map['minSampleSize'] as int? ?? 100,
      requiredConfidence: (map['requiredConfidence'] as num?)?.toDouble() ?? 0.95,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.index,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'minSampleSize': minSampleSize,
      'requiredConfidence': requiredConfidence,
    };
  }
}

/// Represents results for an A/B test variant
class ABTestVariantResults {
  final ABTestVariant variant;
  final int sampleSize;
  final double conversionRate; // 0.0 to 1.0
  final double averageSessionDuration;
  final double averageAccuracy;
  final double engagementScore; // Custom metric

  ABTestVariantResults({
    required this.variant,
    required this.sampleSize,
    required this.conversionRate,
    required this.averageSessionDuration,
    required this.averageAccuracy,
    required this.engagementScore,
  });

  factory ABTestVariantResults.empty(ABTestVariant variant) {
    return ABTestVariantResults(
      variant: variant,
      sampleSize: 0,
      conversionRate: 0.0,
      averageSessionDuration: 0.0,
      averageAccuracy: 0.0,
      engagementScore: 0.0,
    );
  }

  factory ABTestVariantResults.fromMap(Map<String, dynamic> map) {
    return ABTestVariantResults(
      variant: (map['variant'] as String?) == 'variant'
          ? ABTestVariant.variant
          : ABTestVariant.control,
      sampleSize: map['sampleSize'] as int? ?? 0,
      conversionRate: (map['conversionRate'] as num?)?.toDouble() ?? 0.0,
      averageSessionDuration:
          (map['averageSessionDuration'] as num?)?.toDouble() ?? 0.0,
      averageAccuracy: (map['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      engagementScore: (map['engagementScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variant': variant == ABTestVariant.control ? 'control' : 'variant',
      'sampleSize': sampleSize,
      'conversionRate': conversionRate,
      'averageSessionDuration': averageSessionDuration,
      'averageAccuracy': averageAccuracy,
      'engagementScore': engagementScore,
    };
  }
}

/// Statistical significance result
class SignificanceResult {
  final bool isSignificant;
  final double pValue; // p-value from statistical test
  final double confidenceLevel; // Confidence that variant is better
  final String recommendation; // 'control_wins', 'variant_wins', 'inconclusive'

  SignificanceResult({
    required this.isSignificant,
    required this.pValue,
    required this.confidenceLevel,
    required this.recommendation,
  });

  bool get variantWins => recommendation == 'variant_wins';
  bool get controlWins => recommendation == 'control_wins';
  bool get isInconclusive => recommendation == 'inconclusive';
}

/// User's A/B test assignment
class UserABTestAssignment {
  final String userId;
  final String testId;
  final ABTestVariant assignedVariant;
  final DateTime assignedAt;
  final Map<String, dynamic> metadata;

  UserABTestAssignment({
    required this.userId,
    required this.testId,
    required this.assignedVariant,
    required this.assignedAt,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  bool get isControl => assignedVariant == ABTestVariant.control;
  bool get isVariant => assignedVariant == ABTestVariant.variant;

  factory UserABTestAssignment.fromMap(Map<String, dynamic> map) {
    return UserABTestAssignment(
      userId: map['userId'] as String? ?? '',
      testId: map['testId'] as String? ?? '',
      assignedVariant: (map['assignedVariant'] as String?) == 'variant'
          ? ABTestVariant.variant
          : ABTestVariant.control,
      assignedAt:
          (map['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testId': testId,
      'assignedVariant':
          assignedVariant == ABTestVariant.control ? 'control' : 'variant',
      'assignedAt': Timestamp.fromDate(assignedAt),
      'metadata': metadata,
    };
  }
}
