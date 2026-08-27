import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ab_test_model.dart';

/// Abstract A/B testing service interface
abstract class ABTestingService {
  /// Get active A/B tests
  Future<List<ABTest>> getActiveTests();

  /// Get user's variant assignment for a test
  Future<ABTestVariant> getUserVariant(String userId, String testId);

  /// Record user event for A/B test
  Future<void> recordTestEvent(
    String userId,
    String testId,
    String eventName,
    Map<String, dynamic> metadata,
  );

  /// Get results for a specific test
  Future<ABTestVariantResults> getTestResults(String testId);

  /// Get statistical significance results
  Future<SignificanceResult> analyzeTestResults(String testId);

  /// Check if user is in variant group
  Future<bool> isUserInVariant(String userId, String testId);

  /// Record conversion event
  Future<void> recordConversion(String userId, String testId);

  /// Get all test assignments for user
  Future<Map<String, ABTestVariant>> getUserAssignments(String userId);
}

/// Firebase implementation of A/B testing service
class FirebaseABTestingService implements ABTestingService {
  final FirebaseFirestore _firestore;

  FirebaseABTestingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ABTest>> getActiveTests() async {
    try {
      final snapshot = await _firestore
          .collection('experiments')
          .where('status', isEqualTo: ABTestStatus.active.index)
          .get();

      return snapshot.docs
          .map((doc) => ABTest.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting active tests: $e');
      return [];
    }
  }

  @override
  Future<ABTestVariant> getUserVariant(String userId, String testId) async {
    try {
      final docRef = _firestore
          .collection('experiments')
          .doc(testId)
          .collection('assignments')
          .doc(userId);

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserABTestAssignment.fromMap(data).assignedVariant;
      }

      // Assign user to variant based on hash
      final variant = _assignVariant(userId, testId);

      // Store assignment
      await docRef.set({
        'userId': userId,
        'testId': testId,
        'assignedVariant':
            variant == ABTestVariant.control ? 'control' : 'variant',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      return variant;
    } catch (e) {
      debugPrint('Error getting user variant: $e');
      return ABTestVariant.control;
    }
  }

  @override
  Future<void> recordTestEvent(
    String userId,
    String testId,
    String eventName,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final variant = await getUserVariant(userId, testId);

      await _firestore
          .collection('experiments')
          .doc(testId)
          .collection('events')
          .add({
            'userId': userId,
            'variant': variant == ABTestVariant.control ? 'control' : 'variant',
            'eventName': eventName,
            'metadata': metadata,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error recording test event: $e');
    }
  }

  @override
  Future<ABTestVariantResults> getTestResults(String testId) async {
    try {
      final eventsSnapshot = await _firestore
          .collection('experiments')
          .doc(testId)
          .collection('events')
          .get();

      final events = eventsSnapshot.docs;

      if (events.isEmpty) {
        return ABTestVariantResults.empty(ABTestVariant.control);
      }

      // Group events by variant
      final controlEvents = events
          .where((doc) =>
              (doc['variant'] as String?) == 'control')
          .toList();
      final variantEvents = events
          .where((doc) =>
              (doc['variant'] as String?) == 'variant')
          .toList();

      // Calculate metrics
      final controlResults = _calculateMetrics(
        controlEvents,
        ABTestVariant.control,
      );
      final variantResults = _calculateMetrics(
        variantEvents,
        ABTestVariant.variant,
      );

      // Return variant results (user comparison)
      return variantResults;
    } catch (e) {
      debugPrint('Error getting test results: $e');
      return ABTestVariantResults.empty(ABTestVariant.variant);
    }
  }

  @override
  Future<SignificanceResult> analyzeTestResults(String testId) async {
    try {
      final results = await getTestResults(testId);

      // Calculate p-value using simplified chi-square test
      final pValue = _calculatePValue(results);
      final isSignificant = pValue < 0.05; // Standard significance level

      String recommendation;
      if (!isSignificant) {
        recommendation = 'inconclusive';
      } else if (results.conversionRate > 0.5) {
        recommendation = 'variant_wins';
      } else {
        recommendation = 'control_wins';
      }

      return SignificanceResult(
        isSignificant: isSignificant,
        pValue: pValue,
        confidenceLevel: 1.0 - pValue,
        recommendation: recommendation,
      );
    } catch (e) {
      debugPrint('Error analyzing test results: $e');
      return SignificanceResult(
        isSignificant: false,
        pValue: 1.0,
        confidenceLevel: 0.0,
        recommendation: 'inconclusive',
      );
    }
  }

  @override
  Future<bool> isUserInVariant(String userId, String testId) async {
    try {
      final variant = await getUserVariant(userId, testId);
      return variant == ABTestVariant.variant;
    } catch (e) {
      debugPrint('Error checking if user in variant: $e');
      return false;
    }
  }

  @override
  Future<void> recordConversion(String userId, String testId) async {
    try {
      await recordTestEvent(userId, testId, 'conversion', {
        'converted': true,
      });
    } catch (e) {
      debugPrint('Error recording conversion: $e');
    }
  }

  @override
  Future<Map<String, ABTestVariant>> getUserAssignments(String userId) async {
    try {
      final assignments = <String, ABTestVariant>{};

      final tests = await getActiveTests();
      for (final test in tests) {
        final variant = await getUserVariant(userId, test.id);
        assignments[test.id] = variant;
      }

      return assignments;
    } catch (e) {
      debugPrint('Error getting user assignments: $e');
      return {};
    }
  }

  // Helper methods

  ABTestVariant _assignVariant(String userId, String testId) {
    // Deterministic assignment based on hash
    final combinedString = '$userId-$testId';
    final hashValue = combinedString.hashCode.abs();

    // 50-50 split by default
    return (hashValue % 2 == 0) ? ABTestVariant.control : ABTestVariant.variant;
  }

  ABTestVariantResults _calculateMetrics(
    List<QueryDocumentSnapshot> events,
    ABTestVariant variant,
  ) {
    if (events.isEmpty) {
      return ABTestVariantResults.empty(variant);
    }

    int conversions = 0;
    double totalDuration = 0.0;
    double totalAccuracy = 0.0;
    double totalEngagement = 0.0;

    for (final event in events) {
      if ((event['eventName'] as String?) == 'conversion') {
        conversions++;
      }

      final metadata = event['metadata'] as Map<String, dynamic>? ?? {};
      totalDuration +=
          (metadata['sessionDuration'] as num?)?.toDouble() ?? 0.0;
      totalAccuracy += (metadata['accuracy'] as num?)?.toDouble() ?? 0.0;
      totalEngagement +=
          (metadata['engagementScore'] as num?)?.toDouble() ?? 0.0;
    }

    return ABTestVariantResults(
      variant: variant,
      sampleSize: events.length,
      conversionRate: conversions / events.length,
      averageSessionDuration:
          events.isNotEmpty ? totalDuration / events.length : 0.0,
      averageAccuracy:
          events.isNotEmpty ? totalAccuracy / events.length : 0.0,
      engagementScore:
          events.isNotEmpty ? totalEngagement / events.length : 0.0,
    );
  }

  double _calculatePValue(ABTestVariantResults results) {
    // Simplified p-value calculation
    // In production, use proper statistical library
    if (results.sampleSize < 30) {
      return 1.0; // Not enough samples
    }

    // Simple effect size calculation
    const controlConversionRate = 0.5; // Baseline
    final effectSize =
        (results.conversionRate - controlConversionRate).abs();

    // Rough p-value approximation
    const stdError = 0.1;
    final zScore = effectSize / stdError;

    // Approximate p-value from z-score
    return 2.0 * (1.0 - _normalCDF(zScore.abs()));
  }

  // Cumulative normal distribution function (approximation)
  double _normalCDF(double x) {
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;

    final sign = x < 0 ? -1 : 1;
    x = x.abs() / 1.41421356;

    final t = 1.0 / (1.0 + p * x);
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;
    final t5 = t4 * t;

    final y =
        1.0 - (((((a5 * t5 + a4 * t4) + a3 * t3) + a2 * t2) + a1 * t) * t) *
            (-x * x).exp();

    return 0.5 * (1.0 + sign * y);
  }
}

/// Stub implementation for testing
class StubABTestingService implements ABTestingService {
  final Map<String, ABTest> _tests = {};
  final Map<String, Map<String, ABTestVariant>> _assignments = {};

  StubABTestingService({
    Map<String, ABTest>? tests,
    Map<String, Map<String, ABTestVariant>>? assignments,
  }) {
    if (tests != null) _tests.addAll(tests);
    if (assignments != null) _assignments.addAll(assignments);
  }

  @override
  Future<List<ABTest>> getActiveTests() async {
    return _tests.values
        .where((test) => test.isActive)
        .toList();
  }

  @override
  Future<ABTestVariant> getUserVariant(String userId, String testId) async {
    return _assignments[userId]?[testId] ?? ABTestVariant.control;
  }

  @override
  Future<void> recordTestEvent(
    String userId,
    String testId,
    String eventName,
    Map<String, dynamic> metadata,
  ) async {
    // Stub: do nothing
  }

  @override
  Future<ABTestVariantResults> getTestResults(String testId) async {
    return ABTestVariantResults.empty(ABTestVariant.control);
  }

  @override
  Future<SignificanceResult> analyzeTestResults(String testId) async {
    return SignificanceResult(
      isSignificant: false,
      pValue: 1.0,
      confidenceLevel: 0.0,
      recommendation: 'inconclusive',
    );
  }

  @override
  Future<bool> isUserInVariant(String userId, String testId) async {
    return (await getUserVariant(userId, testId)) == ABTestVariant.variant;
  }

  @override
  Future<void> recordConversion(String userId, String testId) async {
    // Stub: do nothing
  }

  @override
  Future<Map<String, ABTestVariant>> getUserAssignments(String userId) async {
    return _assignments[userId] ?? {};
  }
}
