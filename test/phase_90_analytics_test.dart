import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/analytics_models.dart';
import 'package:project_040/services/analytics_service.dart';

void main() {
  group('Phase 90: Advanced AI-Powered Analytics & Insights', () {
    late AnalyticsFacade facade;
    late AnalyticsManager manager;
    late InMemoryAnalyticsRepository repository;

    setUp(() {
      repository = InMemoryAnalyticsRepository();
      manager = AnalyticsManager(repository);
      facade = AnalyticsFacade(manager);
    });

    // ============================================================================
    // ENUM TESTS
    // ============================================================================

    group('Enum Tests', () {
      test('PredictionType enum has all values', () {
        expect(PredictionType.values.length, equals(6));
        expect(PredictionType.values, contains(PredictionType.realtime));
        expect(PredictionType.values, contains(PredictionType.batch));
        expect(PredictionType.values, contains(PredictionType.streaming));
        expect(PredictionType.values, contains(PredictionType.scheduled));
        expect(PredictionType.values, contains(PredictionType.interactive));
        expect(PredictionType.values, contains(PredictionType.api));
      });

      test('AnomalyType enum has all values', () {
        expect(AnomalyType.values.length, equals(6));
        expect(AnomalyType.values, contains(AnomalyType.statistical));
        expect(AnomalyType.values, contains(AnomalyType.isolation));
        expect(AnomalyType.values, contains(AnomalyType.clustering));
      });

      test('AlertSeverity enum has all values', () {
        expect(AlertSeverity.values.length, equals(5));
        expect(AlertSeverity.values, contains(AlertSeverity.low));
        expect(AlertSeverity.values, contains(AlertSeverity.high));
        expect(AlertSeverity.values, contains(AlertSeverity.critical));
      });

      test('PatternType enum has all values', () {
        expect(PatternType.values.length, equals(6));
        expect(PatternType.values, contains(PatternType.sequential));
      });

      test('CorrelationType enum has all values', () {
        expect(CorrelationType.values.length, equals(4));
      });

      test('FraudRiskLevel enum has all values', () {
        expect(FraudRiskLevel.values.length, equals(5));
        expect(FraudRiskLevel.values, contains(FraudRiskLevel.low));
      });
    });

    // ============================================================================
    // MODEL TESTS - Computed Properties and copyWith
    // ============================================================================

    group('PredictiveModel Model Tests', () {
      test('PredictiveModel creation and properties', () {
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Sales Predictor',
          type: PredictionType.batch,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        expect(model.id, equals('model_1'));
        expect(model.name, equals('Sales Predictor'));
        expect(model.type, equals(PredictionType.batch));
        expect(model.accuracy, equals(0.92));
        expect(model.isActive, true);
        expect(model.isAccurate, true);
      });

      test('PredictiveModel copyWith', () {
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Sales Predictor',
          type: PredictionType.batch,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        final updated = model.copyWith(accuracy: 0.95, isActive: false);
        expect(updated.accuracy, equals(0.95));
        expect(updated.isActive, false);
        expect(updated.name, equals('Sales Predictor'));
      });
    });

    group('Prediction Model Tests', () {
      test('Prediction creation with success', () {
        final prediction = Prediction(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'value': 100},
          prediction: 'High',
          confidence: 0.87,
          timestamp: DateTime.now(),
          isSuccessful: true,
          processingTimeMs: 45,
        );

        expect(prediction.isSuccessful, true);
        expect(prediction.confidence, equals(0.87));
      });

      test('Prediction copyWith', () {
        final prediction = Prediction(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'value': 100},
          prediction: 'High',
          confidence: 0.87,
          timestamp: DateTime.now(),
          isSuccessful: true,
          processingTimeMs: 45,
        );

        final updated = prediction.copyWith(confidence: 0.92);
        expect(updated.confidence, equals(0.92));
      });
    });

    group('AnomalyDetection Model Tests', () {
      test('AnomalyDetection critical detection', () {
        final anomaly = AnomalyDetection(
          id: 'anom_1',
          dataPointId: 'dp_1',
          type: AnomalyType.statistical,
          anomalyScore: 0.95,
          threshold: 0.80,
          detectedAt: DateTime.now(),
          description: 'Unusual spike',
          severity: AlertSeverity.critical,
        );

        expect(anomaly.isCritical, true);
        expect(anomaly.severity, equals(AlertSeverity.critical));
      });

      test('AnomalyDetection copyWith', () {
        final anomaly = AnomalyDetection(
          id: 'anom_1',
          dataPointId: 'dp_1',
          type: AnomalyType.statistical,
          anomalyScore: 0.95,
          threshold: 0.80,
          detectedAt: DateTime.now(),
          description: 'Unusual spike',
          severity: AlertSeverity.critical,
        );

        final updated = anomaly.copyWith(severity: AlertSeverity.low);
        expect(updated.severity, equals(AlertSeverity.low));
      });
    });

    group('PatternAnalysis Model Tests', () {
      test('PatternAnalysis strong pattern', () {
        final pattern = PatternAnalysis(
          id: 'pat_1',
          type: PatternType.sequential,
          confidence: 0.88,
          frequency: 42,
          lastOccurrence: DateTime.now(),
          nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
          description: 'Weekly spike pattern',
        );

        expect(pattern.isStrong, true);
        expect(pattern.confidence, equals(0.88));
      });

      test('PatternAnalysis copyWith', () {
        final pattern = PatternAnalysis(
          id: 'pat_1',
          type: PatternType.sequential,
          confidence: 0.88,
          frequency: 42,
          lastOccurrence: DateTime.now(),
          nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
          description: 'Weekly spike pattern',
        );

        final updated = pattern.copyWith(confidence: 0.92);
        expect(updated.confidence, equals(0.92));
      });
    });

    group('CorrelationAnalysis Model Tests', () {
      test('CorrelationAnalysis significant correlation', () {
        final correlation = CorrelationAnalysis(
          id: 'corr_1',
          variable1: 'sales',
          variable2: 'marketing_spend',
          type: CorrelationType.positive,
          strength: 0.87,
          pValue: 0.001,
          analysisDate: DateTime.now(),
        );

        expect(correlation.isSignificant, true);
        expect(correlation.type, equals(CorrelationType.positive));
      });

      test('CorrelationAnalysis copyWith', () {
        final correlation = CorrelationAnalysis(
          id: 'corr_1',
          variable1: 'sales',
          variable2: 'marketing_spend',
          type: CorrelationType.positive,
          strength: 0.87,
          pValue: 0.001,
          analysisDate: DateTime.now(),
        );

        final updated = correlation.copyWith(strength: 0.92);
        expect(updated.strength, equals(0.92));
      });
    });

    group('IntelligentAlert Model Tests', () {
      test('IntelligentAlert creation', () {
        final alert = IntelligentAlert(
          id: 'alert_1',
          severity: AlertSeverity.high,
          message: 'High anomaly detected',
          triggerType: 'anomaly_detection',
          triggeredAt: DateTime.now(),
          isResolved: false,
          relatedMetrics: ['metric_1', 'metric_2'],
        );

        expect(alert.severity, equals(AlertSeverity.high));
        expect(alert.isResolved, false);
      });

      test('IntelligentAlert copyWith', () {
        final alert = IntelligentAlert(
          id: 'alert_1',
          severity: AlertSeverity.high,
          message: 'High anomaly detected',
          triggerType: 'anomaly_detection',
          triggeredAt: DateTime.now(),
          isResolved: false,
          relatedMetrics: ['metric_1', 'metric_2'],
        );

        final updated = alert.copyWith(isResolved: true);
        expect(updated.isResolved, true);
      });
    });

    group('BehavioralAnalysis Model Tests', () {
      test('BehavioralAnalysis creation', () {
        final behavior = BehavioralAnalysis(
          id: 'behav_1',
          userId: 'user_123',
          behaviorType: 'login_pattern',
          frequency: 15,
          lastObserved: DateTime.now(),
          riskScore: 0.65,
          description: 'Unusual login times',
        );

        expect(behavior.userId, equals('user_123'));
        expect(behavior.frequency, equals(15));
      });

      test('BehavioralAnalysis copyWith', () {
        final behavior = BehavioralAnalysis(
          id: 'behav_1',
          userId: 'user_123',
          behaviorType: 'login_pattern',
          frequency: 15,
          lastObserved: DateTime.now(),
          riskScore: 0.65,
          description: 'Unusual login times',
        );

        final updated = behavior.copyWith(riskScore: 0.80);
        expect(updated.riskScore, equals(0.80));
      });
    });

    group('FraudDetection Model Tests', () {
      test('FraudDetection suspicious transaction', () {
        final fraud = FraudDetection(
          id: 'fraud_1',
          transactionId: 'txn_123',
          riskLevel: FraudRiskLevel.high,
          riskScore: 0.85,
          indicators: ['velocity', 'location_mismatch'],
          analysisTime: DateTime.now(),
          recommendation: 'block',
        );

        expect(fraud.isSuspicious, true);
        expect(fraud.riskLevel, equals(FraudRiskLevel.high));
      });

      test('FraudDetection copyWith', () {
        final fraud = FraudDetection(
          id: 'fraud_1',
          transactionId: 'txn_123',
          riskLevel: FraudRiskLevel.high,
          riskScore: 0.85,
          indicators: ['velocity', 'location_mismatch'],
          analysisTime: DateTime.now(),
          recommendation: 'block',
        );

        final updated = fraud.copyWith(riskLevel: FraudRiskLevel.low);
        expect(updated.riskLevel, equals(FraudRiskLevel.low));
      });
    });

    group('Recommendation Model Tests', () {
      test('Recommendation creation', () {
        final rec = Recommendation(
          id: 'rec_1',
          userId: 'user_123',
          itemId: 'item_456',
          score: 0.89,
          reason: 'Similar to your purchases',
          generatedAt: DateTime.now(),
          isActedUpon: false,
        );

        expect(rec.userId, equals('user_123'));
        expect(rec.score, equals(0.89));
      });

      test('Recommendation copyWith', () {
        final rec = Recommendation(
          id: 'rec_1',
          userId: 'user_123',
          itemId: 'item_456',
          score: 0.89,
          reason: 'Similar to your purchases',
          generatedAt: DateTime.now(),
          isActedUpon: false,
        );

        final updated = rec.copyWith(isActedUpon: true);
        expect(updated.isActedUpon, true);
      });
    });

    group('InsightGeneration Model Tests', () {
      test('InsightGeneration creation', () {
        final insight = InsightGeneration(
          id: 'insight_1',
          title: 'Revenue Growth Trend',
          description: 'Sales increasing by 5% MoM',
          category: 'business',
          generatedAt: DateTime.now(),
          confidence: 0.87,
          actionableItems: ['increase_inventory', 'hire_staff'],
        );

        expect(insight.title, equals('Revenue Growth Trend'));
        expect(insight.confidence, equals(0.87));
      });

      test('InsightGeneration copyWith', () {
        final insight = InsightGeneration(
          id: 'insight_1',
          title: 'Revenue Growth Trend',
          description: 'Sales increasing by 5% MoM',
          category: 'business',
          generatedAt: DateTime.now(),
          confidence: 0.87,
          actionableItems: ['increase_inventory', 'hire_staff'],
        );

        final updated = insight.copyWith(confidence: 0.92);
        expect(updated.confidence, equals(0.92));
      });
    });

    // ============================================================================
    // REPOSITORY TESTS - All 98+ Methods
    // ============================================================================

    group('Predictive Model Repository Tests', () {
      test('createPredictiveModel and retrieve', () async {
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Sales Model',
          type: PredictionType.batch,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        await repository.createPredictiveModel(model);
        final retrieved = await repository.getPredictiveModel('model_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Sales Model'));
      });

      test('getAllPredictiveModels returns all models', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.80 + (i * 0.02),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: i % 2 == 0,
            trainingDataPoints: 5000,
          ));
        }

        final models = await repository.getAllPredictiveModels();
        expect(models.length, equals(5));
      });

      test('updatePredictiveModel', () async {
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Sales Model',
          type: PredictionType.batch,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        await repository.createPredictiveModel(model);
        final updated = model.copyWith(accuracy: 0.95);
        await repository.updatePredictiveModel(updated);

        final retrieved = await repository.getPredictiveModel('model_1');
        expect(retrieved!.accuracy, equals(0.95));
      });

      test('deletePredictiveModel', () async {
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Sales Model',
          type: PredictionType.batch,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        await repository.createPredictiveModel(model);
        await repository.deletePredictiveModel('model_1');

        final retrieved = await repository.getPredictiveModel('model_1');
        expect(retrieved, isNull);
      });

      test('getActiveModels', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.80 + (i * 0.02),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: i < 3,
            trainingDataPoints: 5000,
          ));
        }

        final active = await repository.getActiveModels();
        expect(active.length, equals(3));
      });

      test('getModelsWithMinimumAccuracy', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.80 + (i * 0.02),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            trainingDataPoints: 5000,
          ));
        }

        final highAccuracy = await repository.getModelsWithMinimumAccuracy(0.90);
        expect(highAccuracy.length, equals(3));
      });

      test('getModelsByType', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: i < 3 ? PredictionType.batch : PredictionType.realtime,
            accuracy: 0.85,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            trainingDataPoints: 5000,
          ));
        }

        final batchModels = await repository.getModelsByType(PredictionType.batch);
        expect(batchModels.length, equals(3));
      });

      test('getAverageModelAccuracy', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.80 + (i * 0.05),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            trainingDataPoints: 5000,
          ));
        }

        final avg = await repository.getAverageModelAccuracy();
        expect(avg, greaterThan(0.8));
      });

      test('countPredictiveModels', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.85,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            trainingDataPoints: 5000,
          ));
        }

        final count = await repository.countPredictiveModels();
        expect(count, equals(5));
      });

      test('deleteAllPredictiveModels', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPredictiveModel(PredictiveModel(
            id: 'model_$i',
            name: 'Model $i',
            type: PredictionType.batch,
            accuracy: 0.85,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            trainingDataPoints: 5000,
          ));
        }

        await repository.deleteAllPredictiveModels();
        final count = await repository.countPredictiveModels();
        expect(count, equals(0));
      });
    });

    group('Prediction Repository Tests', () {
      test('createPrediction and retrieve', () async {
        final prediction = Prediction(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'value': 100},
          prediction: 'High',
          confidence: 0.87,
          timestamp: DateTime.now(),
          isSuccessful: true,
          processingTimeMs: 45,
        );

        await repository.createPrediction(prediction);
        final retrieved = await repository.getPrediction('pred_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.prediction, equals('High'));
      });

      test('getAllPredictions returns all predictions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100 + i},
            prediction: 'Result_$i',
            confidence: 0.80 + (i * 0.02),
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        final predictions = await repository.getAllPredictions();
        expect(predictions.length, equals(5));
      });

      test('getSuccessfulPredictions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100 + i},
            prediction: 'Result_$i',
            confidence: 0.85,
            timestamp: DateTime.now(),
            isSuccessful: i < 3,
            processingTimeMs: 45,
          ));
        }

        final successful = await repository.getSuccessfulPredictions();
        expect(successful.length, equals(3));
      });

      test('getPredictionsByModel', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: i < 3 ? 'model_1' : 'model_2',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.85,
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        final modelPreds = await repository.getPredictionsByModel('model_1');
        expect(modelPreds.length, equals(3));
      });

      test('getHighConfidencePredictions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.70 + (i * 0.04),
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        final highConf = await repository.getHighConfidencePredictions(0.85);
        expect(highConf.length, equals(2));
      });

      test('getAveragePredictionConfidence', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.80 + (i * 0.05),
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        final avg = await repository.getAveragePredictionConfidence();
        expect(avg, greaterThan(0.8));
      });

      test('countPredictions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.85,
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        final count = await repository.countPredictions();
        expect(count, equals(5));
      });

      test('getAveragePredictionTime', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.85,
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 30 + (i * 10),
          ));
        }

        final avgTime = await repository.getAveragePredictionTime();
        expect(avgTime, greaterThan(30));
      });

      test('deletePrediction', () async {
        final prediction = Prediction(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'value': 100},
          prediction: 'High',
          confidence: 0.87,
          timestamp: DateTime.now(),
          isSuccessful: true,
          processingTimeMs: 45,
        );

        await repository.createPrediction(prediction);
        await repository.deletePrediction('pred_1');

        final retrieved = await repository.getPrediction('pred_1');
        expect(retrieved, isNull);
      });

      test('deleteAllPredictions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPrediction(Prediction(
            id: 'pred_$i',
            modelId: 'model_1',
            inputData: {'value': 100},
            prediction: 'Result',
            confidence: 0.85,
            timestamp: DateTime.now(),
            isSuccessful: true,
            processingTimeMs: 45,
          ));
        }

        await repository.deleteAllPredictions();
        final count = await repository.countPredictions();
        expect(count, equals(0));
      });
    });

    group('Anomaly Detection Repository Tests', () {
      test('createAnomalyDetection and retrieve', () async {
        final anomaly = AnomalyDetection(
          id: 'anom_1',
          dataPointId: 'dp_1',
          type: AnomalyType.statistical,
          anomalyScore: 0.95,
          threshold: 0.80,
          detectedAt: DateTime.now(),
          description: 'Unusual spike',
          severity: AlertSeverity.critical,
        );

        await repository.createAnomalyDetection(anomaly);
        final retrieved = await repository.getAnomalyDetection('anom_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.description, equals('Unusual spike'));
      });

      test('getCriticalAnomalies', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: AnomalyType.statistical,
            anomalyScore: 0.80 + (i * 0.03),
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly $i',
            severity: i < 2 ? AlertSeverity.critical : AlertSeverity.low,
          ));
        }

        final critical = await repository.getCriticalAnomalies();
        expect(critical.length, equals(2));
      });

      test('getAnomaliesByType', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: i < 3 ? AnomalyType.statistical : AnomalyType.isolation,
            anomalyScore: 0.85,
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly',
            severity: AlertSeverity.medium,
          ));
        }

        final statistical = await repository.getAnomaliesByType(AnomalyType.statistical);
        expect(statistical.length, equals(3));
      });

      test('getHighScoreAnomalies', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: AnomalyType.statistical,
            anomalyScore: 0.70 + (i * 0.04),
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly',
            severity: AlertSeverity.medium,
          ));
        }

        final highScore = await repository.getHighScoreAnomalies(0.85);
        expect(highScore.length, equals(2));
      });

      test('countAnomalies', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: AnomalyType.statistical,
            anomalyScore: 0.85,
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly',
            severity: AlertSeverity.medium,
          ));
        }

        final count = await repository.countAnomalies();
        expect(count, equals(5));
      });

      test('deleteAnomalyDetection', () async {
        final anomaly = AnomalyDetection(
          id: 'anom_1',
          dataPointId: 'dp_1',
          type: AnomalyType.statistical,
          anomalyScore: 0.95,
          threshold: 0.80,
          detectedAt: DateTime.now(),
          description: 'Unusual spike',
          severity: AlertSeverity.critical,
        );

        await repository.createAnomalyDetection(anomaly);
        await repository.deleteAnomalyDetection('anom_1');

        final retrieved = await repository.getAnomalyDetection('anom_1');
        expect(retrieved, isNull);
      });

      test('deleteAllAnomalies', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: AnomalyType.statistical,
            anomalyScore: 0.85,
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly',
            severity: AlertSeverity.medium,
          ));
        }

        await repository.deleteAllAnomalies();
        final count = await repository.countAnomalies();
        expect(count, equals(0));
      });

      test('getAverageAnomalyScore', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createAnomalyDetection(AnomalyDetection(
            id: 'anom_$i',
            dataPointId: 'dp_$i',
            type: AnomalyType.statistical,
            anomalyScore: 0.80 + (i * 0.04),
            threshold: 0.80,
            detectedAt: DateTime.now(),
            description: 'Anomaly',
            severity: AlertSeverity.medium,
          ));
        }

        final avg = await repository.getAverageAnomalyScore();
        expect(avg, greaterThan(0.8));
      });
    });

    group('Pattern Analysis Repository Tests', () {
      test('createPatternAnalysis and retrieve', () async {
        final pattern = PatternAnalysis(
          id: 'pat_1',
          type: PatternType.sequential,
          confidence: 0.88,
          frequency: 42,
          lastOccurrence: DateTime.now(),
          nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
          description: 'Weekly spike pattern',
        );

        await repository.createPatternAnalysis(pattern);
        final retrieved = await repository.getPatternAnalysis('pat_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.description, equals('Weekly spike pattern'));
      });

      test('getHighConfidencePatterns', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: PatternType.sequential,
            confidence: 0.70 + (i * 0.04),
            frequency: 42,
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern $i',
          ));
        }

        final highConf = await repository.getHighConfidencePatterns(0.85);
        expect(highConf.length, equals(2));
      });

      test('getPatternsByType', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: i < 3 ? PatternType.sequential : PatternType.cyclic,
            confidence: 0.85,
            frequency: 42,
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern',
          ));
        }

        final sequential = await repository.getPatternsByType(PatternType.sequential);
        expect(sequential.length, equals(3));
      });

      test('getFrequentPatterns', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: PatternType.sequential,
            confidence: 0.85,
            frequency: 10 + (i * 5),
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern',
          ));
        }

        final frequent = await repository.getFrequentPatterns(30);
        expect(frequent.length, equals(2));
      });

      test('countPatterns', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: PatternType.sequential,
            confidence: 0.85,
            frequency: 42,
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern',
          ));
        }

        final count = await repository.countPatterns();
        expect(count, equals(5));
      });

      test('deletePatternAnalysis', () async {
        final pattern = PatternAnalysis(
          id: 'pat_1',
          type: PatternType.sequential,
          confidence: 0.88,
          frequency: 42,
          lastOccurrence: DateTime.now(),
          nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
          description: 'Weekly spike pattern',
        );

        await repository.createPatternAnalysis(pattern);
        await repository.deletePatternAnalysis('pat_1');

        final retrieved = await repository.getPatternAnalysis('pat_1');
        expect(retrieved, isNull);
      });

      test('deleteAllPatterns', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: PatternType.sequential,
            confidence: 0.85,
            frequency: 42,
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern',
          ));
        }

        await repository.deleteAllPatterns();
        final count = await repository.countPatterns();
        expect(count, equals(0));
      });

      test('getAveragePatternConfidence', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createPatternAnalysis(PatternAnalysis(
            id: 'pat_$i',
            type: PatternType.sequential,
            confidence: 0.80 + (i * 0.04),
            frequency: 42,
            lastOccurrence: DateTime.now(),
            nextPredictedOccurrence: DateTime.now().add(Duration(days: 1)),
            description: 'Pattern',
          ));
        }

        final avg = await repository.getAveragePatternConfidence();
        expect(avg, greaterThan(0.8));
      });
    });

    group('Correlation Analysis Repository Tests', () {
      test('createCorrelationAnalysis and retrieve', () async {
        final correlation = CorrelationAnalysis(
          id: 'corr_1',
          variable1: 'sales',
          variable2: 'marketing_spend',
          type: CorrelationType.positive,
          strength: 0.87,
          pValue: 0.001,
          analysisDate: DateTime.now(),
        );

        await repository.createCorrelationAnalysis(correlation);
        final retrieved = await repository.getCorrelationAnalysis('corr_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.variable1, equals('sales'));
      });

      test('getSignificantCorrelations', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createCorrelationAnalysis(CorrelationAnalysis(
            id: 'corr_$i',
            variable1: 'var1',
            variable2: 'var2',
            type: CorrelationType.positive,
            strength: 0.70 + (i * 0.04),
            pValue: 0.001 + (i * 0.001),
            analysisDate: DateTime.now(),
          ));
        }

        final significant = await repository.getSignificantCorrelations(0.05);
        expect(significant.isNotEmpty, true);
      });

      test('getCorrelationsByType', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createCorrelationAnalysis(CorrelationAnalysis(
            id: 'corr_$i',
            variable1: 'var1',
            variable2: 'var2',
            type: i < 3 ? CorrelationType.positive : CorrelationType.negative,
            strength: 0.85,
            pValue: 0.001,
            analysisDate: DateTime.now(),
          ));
        }

        final positive = await repository.getCorrelationsByType(CorrelationType.positive);
        expect(positive.length, equals(3));
      });

      test('countCorrelations', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createCorrelationAnalysis(CorrelationAnalysis(
            id: 'corr_$i',
            variable1: 'var1',
            variable2: 'var2',
            type: CorrelationType.positive,
            strength: 0.85,
            pValue: 0.001,
            analysisDate: DateTime.now(),
          ));
        }

        final count = await repository.countCorrelations();
        expect(count, equals(5));
      });

      test('deleteCorrelationAnalysis', () async {
        final correlation = CorrelationAnalysis(
          id: 'corr_1',
          variable1: 'sales',
          variable2: 'marketing_spend',
          type: CorrelationType.positive,
          strength: 0.87,
          pValue: 0.001,
          analysisDate: DateTime.now(),
        );

        await repository.createCorrelationAnalysis(correlation);
        await repository.deleteCorrelationAnalysis('corr_1');

        final retrieved = await repository.getCorrelationAnalysis('corr_1');
        expect(retrieved, isNull);
      });

      test('deleteAllCorrelations', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createCorrelationAnalysis(CorrelationAnalysis(
            id: 'corr_$i',
            variable1: 'var1',
            variable2: 'var2',
            type: CorrelationType.positive,
            strength: 0.85,
            pValue: 0.001,
            analysisDate: DateTime.now(),
          ));
        }

        await repository.deleteAllCorrelations();
        final count = await repository.countCorrelations();
        expect(count, equals(0));
      });

      test('getAverageCorrelationStrength', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createCorrelationAnalysis(CorrelationAnalysis(
            id: 'corr_$i',
            variable1: 'var1',
            variable2: 'var2',
            type: CorrelationType.positive,
            strength: 0.80 + (i * 0.04),
            pValue: 0.001,
            analysisDate: DateTime.now(),
          ));
        }

        final avg = await repository.getAverageCorrelationStrength();
        expect(avg, greaterThan(0.8));
      });
    });

    group('Intelligent Alert Repository Tests', () {
      test('createIntelligentAlert and retrieve', () async {
        final alert = IntelligentAlert(
          id: 'alert_1',
          severity: AlertSeverity.high,
          message: 'High anomaly detected',
          triggerType: 'anomaly_detection',
          triggeredAt: DateTime.now(),
          isResolved: false,
          relatedMetrics: ['metric_1', 'metric_2'],
        );

        await repository.createIntelligentAlert(alert);
        final retrieved = await repository.getIntelligentAlert('alert_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.severity, equals(AlertSeverity.high));
      });

      test('getUnresolvedAlerts', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIntelligentAlert(IntelligentAlert(
            id: 'alert_$i',
            severity: AlertSeverity.medium,
            message: 'Alert $i',
            triggerType: 'test',
            triggeredAt: DateTime.now(),
            isResolved: i >= 2,
            relatedMetrics: [],
          ));
        }

        final unresolved = await repository.getUnresolvedAlerts();
        expect(unresolved.length, equals(2));
      });

      test('getAlertsBySeverity', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIntelligentAlert(IntelligentAlert(
            id: 'alert_$i',
            severity: i < 2 ? AlertSeverity.critical : AlertSeverity.low,
            message: 'Alert',
            triggerType: 'test',
            triggeredAt: DateTime.now(),
            isResolved: false,
            relatedMetrics: [],
          ));
        }

        final critical = await repository.getAlertsBySeverity(AlertSeverity.critical);
        expect(critical.length, equals(2));
      });

      test('countAlerts', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIntelligentAlert(IntelligentAlert(
            id: 'alert_$i',
            severity: AlertSeverity.medium,
            message: 'Alert',
            triggerType: 'test',
            triggeredAt: DateTime.now(),
            isResolved: false,
            relatedMetrics: [],
          ));
        }

        final count = await repository.countAlerts();
        expect(count, equals(5));
      });

      test('deleteIntelligentAlert', () async {
        final alert = IntelligentAlert(
          id: 'alert_1',
          severity: AlertSeverity.high,
          message: 'High anomaly detected',
          triggerType: 'anomaly_detection',
          triggeredAt: DateTime.now(),
          isResolved: false,
          relatedMetrics: ['metric_1', 'metric_2'],
        );

        await repository.createIntelligentAlert(alert);
        await repository.deleteIntelligentAlert('alert_1');

        final retrieved = await repository.getIntelligentAlert('alert_1');
        expect(retrieved, isNull);
      });

      test('deleteAllAlerts', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIntelligentAlert(IntelligentAlert(
            id: 'alert_$i',
            severity: AlertSeverity.medium,
            message: 'Alert',
            triggerType: 'test',
            triggeredAt: DateTime.now(),
            isResolved: false,
            relatedMetrics: [],
          ));
        }

        await repository.deleteAllAlerts();
        final count = await repository.countAlerts();
        expect(count, equals(0));
      });
    });

    group('Behavioral Analysis Repository Tests', () {
      test('createBehavioralAnalysis and retrieve', () async {
        final behavior = BehavioralAnalysis(
          id: 'behav_1',
          userId: 'user_123',
          behaviorType: 'login_pattern',
          frequency: 15,
          lastObserved: DateTime.now(),
          riskScore: 0.65,
          description: 'Unusual login times',
        );

        await repository.createBehavioralAnalysis(behavior);
        final retrieved = await repository.getBehavioralAnalysis('behav_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.userId, equals('user_123'));
      });

      test('getBehaviorsByUser', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createBehavioralAnalysis(BehavioralAnalysis(
            id: 'behav_$i',
            userId: i < 3 ? 'user_123' : 'user_456',
            behaviorType: 'login_pattern',
            frequency: 15,
            lastObserved: DateTime.now(),
            riskScore: 0.65,
            description: 'Behavior',
          ));
        }

        final behaviors = await repository.getBehaviorsByUser('user_123');
        expect(behaviors.length, equals(3));
      });

      test('countBehaviors', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createBehavioralAnalysis(BehavioralAnalysis(
            id: 'behav_$i',
            userId: 'user_123',
            behaviorType: 'login_pattern',
            frequency: 15,
            lastObserved: DateTime.now(),
            riskScore: 0.65,
            description: 'Behavior',
          ));
        }

        final count = await repository.countBehaviors();
        expect(count, equals(5));
      });

      test('deleteBehavioralAnalysis', () async {
        final behavior = BehavioralAnalysis(
          id: 'behav_1',
          userId: 'user_123',
          behaviorType: 'login_pattern',
          frequency: 15,
          lastObserved: DateTime.now(),
          riskScore: 0.65,
          description: 'Unusual login times',
        );

        await repository.createBehavioralAnalysis(behavior);
        await repository.deleteBehavioralAnalysis('behav_1');

        final retrieved = await repository.getBehavioralAnalysis('behav_1');
        expect(retrieved, isNull);
      });

      test('deleteAllBehaviors', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createBehavioralAnalysis(BehavioralAnalysis(
            id: 'behav_$i',
            userId: 'user_123',
            behaviorType: 'login_pattern',
            frequency: 15,
            lastObserved: DateTime.now(),
            riskScore: 0.65,
            description: 'Behavior',
          ));
        }

        await repository.deleteAllBehaviors();
        final count = await repository.countBehaviors();
        expect(count, equals(0));
      });
    });

    group('Fraud Detection Repository Tests', () {
      test('createFraudDetection and retrieve', () async {
        final fraud = FraudDetection(
          id: 'fraud_1',
          transactionId: 'txn_123',
          riskLevel: FraudRiskLevel.high,
          riskScore: 0.85,
          indicators: ['velocity', 'location_mismatch'],
          analysisTime: DateTime.now(),
          recommendation: 'block',
        );

        await repository.createFraudDetection(fraud);
        final retrieved = await repository.getFraudDetection('fraud_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.riskLevel, equals(FraudRiskLevel.high));
      });

      test('getHighRiskFrauds', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createFraudDetection(FraudDetection(
            id: 'fraud_$i',
            transactionId: 'txn_$i',
            riskLevel: i < 2 ? FraudRiskLevel.high : FraudRiskLevel.low,
            riskScore: 0.80 + (i * 0.02),
            indicators: [],
            analysisTime: DateTime.now(),
            recommendation: 'block',
          ));
        }

        final highRisk = await repository.getHighRiskFrauds();
        expect(highRisk.length, equals(2));
      });

      test('countFrauds', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createFraudDetection(FraudDetection(
            id: 'fraud_$i',
            transactionId: 'txn_$i',
            riskLevel: FraudRiskLevel.medium,
            riskScore: 0.65,
            indicators: [],
            analysisTime: DateTime.now(),
            recommendation: 'review',
          ));
        }

        final count = await repository.countFrauds();
        expect(count, equals(5));
      });

      test('deleteFraudDetection', () async {
        final fraud = FraudDetection(
          id: 'fraud_1',
          transactionId: 'txn_123',
          riskLevel: FraudRiskLevel.high,
          riskScore: 0.85,
          indicators: ['velocity', 'location_mismatch'],
          analysisTime: DateTime.now(),
          recommendation: 'block',
        );

        await repository.createFraudDetection(fraud);
        await repository.deleteFraudDetection('fraud_1');

        final retrieved = await repository.getFraudDetection('fraud_1');
        expect(retrieved, isNull);
      });

      test('deleteAllFrauds', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createFraudDetection(FraudDetection(
            id: 'fraud_$i',
            transactionId: 'txn_$i',
            riskLevel: FraudRiskLevel.medium,
            riskScore: 0.65,
            indicators: [],
            analysisTime: DateTime.now(),
            recommendation: 'review',
          ));
        }

        await repository.deleteAllFrauds();
        final count = await repository.countFrauds();
        expect(count, equals(0));
      });

      test('getAverageFraudRiskScore', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createFraudDetection(FraudDetection(
            id: 'fraud_$i',
            transactionId: 'txn_$i',
            riskLevel: FraudRiskLevel.medium,
            riskScore: 0.60 + (i * 0.05),
            indicators: [],
            analysisTime: DateTime.now(),
            recommendation: 'review',
          ));
        }

        final avg = await repository.getAverageFraudRiskScore();
        expect(avg, greaterThan(0.6));
      });
    });

    group('Recommendation Repository Tests', () {
      test('createRecommendation and retrieve', () async {
        final rec = Recommendation(
          id: 'rec_1',
          userId: 'user_123',
          itemId: 'item_456',
          score: 0.89,
          reason: 'Similar to your purchases',
          generatedAt: DateTime.now(),
          isActedUpon: false,
        );

        await repository.createRecommendation(rec);
        final retrieved = await repository.getRecommendation('rec_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.itemId, equals('item_456'));
      });

      test('getRecommendationsByUser', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createRecommendation(Recommendation(
            id: 'rec_$i',
            userId: i < 3 ? 'user_123' : 'user_456',
            itemId: 'item_$i',
            score: 0.85,
            reason: 'Recommendation',
            generatedAt: DateTime.now(),
            isActedUpon: false,
          ));
        }

        final userRecs = await repository.getRecommendationsByUser('user_123');
        expect(userRecs.length, equals(3));
      });

      test('countRecommendations', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createRecommendation(Recommendation(
            id: 'rec_$i',
            userId: 'user_123',
            itemId: 'item_$i',
            score: 0.85,
            reason: 'Recommendation',
            generatedAt: DateTime.now(),
            isActedUpon: false,
          ));
        }

        final count = await repository.countRecommendations();
        expect(count, equals(5));
      });

      test('deleteRecommendation', () async {
        final rec = Recommendation(
          id: 'rec_1',
          userId: 'user_123',
          itemId: 'item_456',
          score: 0.89,
          reason: 'Similar to your purchases',
          generatedAt: DateTime.now(),
          isActedUpon: false,
        );

        await repository.createRecommendation(rec);
        await repository.deleteRecommendation('rec_1');

        final retrieved = await repository.getRecommendation('rec_1');
        expect(retrieved, isNull);
      });

      test('deleteAllRecommendations', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createRecommendation(Recommendation(
            id: 'rec_$i',
            userId: 'user_123',
            itemId: 'item_$i',
            score: 0.85,
            reason: 'Recommendation',
            generatedAt: DateTime.now(),
            isActedUpon: false,
          ));
        }

        await repository.deleteAllRecommendations();
        final count = await repository.countRecommendations();
        expect(count, equals(0));
      });
    });

    group('Insight Generation Repository Tests', () {
      test('createInsightGeneration and retrieve', () async {
        final insight = InsightGeneration(
          id: 'insight_1',
          title: 'Revenue Growth Trend',
          description: 'Sales increasing by 5% MoM',
          category: 'business',
          generatedAt: DateTime.now(),
          confidence: 0.87,
          actionableItems: ['increase_inventory', 'hire_staff'],
        );

        await repository.createInsightGeneration(insight);
        final retrieved = await repository.getInsightGeneration('insight_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Revenue Growth Trend'));
      });

      test('getHighConfidenceInsights', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createInsightGeneration(InsightGeneration(
            id: 'insight_$i',
            title: 'Insight $i',
            description: 'Description',
            category: 'business',
            generatedAt: DateTime.now(),
            confidence: 0.70 + (i * 0.04),
            actionableItems: [],
          ));
        }

        final highConf = await repository.getHighConfidenceInsights(0.85);
        expect(highConf.length, equals(2));
      });

      test('countInsights', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createInsightGeneration(InsightGeneration(
            id: 'insight_$i',
            title: 'Insight $i',
            description: 'Description',
            category: 'business',
            generatedAt: DateTime.now(),
            confidence: 0.85,
            actionableItems: [],
          ));
        }

        final count = await repository.countInsights();
        expect(count, equals(5));
      });

      test('deleteInsightGeneration', () async {
        final insight = InsightGeneration(
          id: 'insight_1',
          title: 'Revenue Growth Trend',
          description: 'Sales increasing by 5% MoM',
          category: 'business',
          generatedAt: DateTime.now(),
          confidence: 0.87,
          actionableItems: ['increase_inventory', 'hire_staff'],
        );

        await repository.createInsightGeneration(insight);
        await repository.deleteInsightGeneration('insight_1');

        final retrieved = await repository.getInsightGeneration('insight_1');
        expect(retrieved, isNull);
      });

      test('deleteAllInsights', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createInsightGeneration(InsightGeneration(
            id: 'insight_$i',
            title: 'Insight $i',
            description: 'Description',
            category: 'business',
            generatedAt: DateTime.now(),
            confidence: 0.85,
            actionableItems: [],
          ));
        }

        await repository.deleteAllInsights();
        final count = await repository.countInsights();
        expect(count, equals(0));
      });
    });

    // ============================================================================
    // ENGINE TESTS
    // ============================================================================

    group('Engine Tests', () {
      test('PredictionEngine makes prediction', () async {
        final engine = PredictionEngine();
        final model = PredictiveModel(
          id: 'model_1',
          name: 'Test Model',
          type: PredictionType.realtime,
          accuracy: 0.92,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          trainingDataPoints: 5000,
        );

        final result = await engine.makePrediction(model, {'value': 100});
        expect(result, isNotNull);
      });

      test('AnomalyEngine detects anomaly', () async {
        final engine = AnomalyEngine();
        final scores = [10.0, 12.0, 11.0, 9.0, 50.0];
        
        final anomalies = await engine.detectAnomalies(scores, 0.90);
        expect(anomalies.isNotEmpty, true);
      });

      test('PatternEngine identifies pattern', () async {
        final engine = PatternEngine();
        final sequence = [1, 2, 3, 1, 2, 3, 1, 2, 3];
        
        final pattern = await engine.identifyPattern(sequence);
        expect(pattern, isNotNull);
      });

      test('AlertEngine generates alert', () async {
        final engine = AlertEngine();
        final alert = await engine.generateAlert(
          'High anomaly',
          AlertSeverity.critical,
          'anomaly_detection',
        );
        
        expect(alert.severity, equals(AlertSeverity.critical));
      });

      test('FraudEngine assesses fraud risk', () async {
        final engine = FraudEngine();
        final indicators = ['velocity', 'location_mismatch', 'device_change'];
        
        final riskScore = await engine.assessFraudRisk(indicators);
        expect(riskScore, greaterThan(0.0));
        expect(riskScore, lessThanOrEqualTo(1.0));
      });
    });

    // ============================================================================
    // FACADE TESTS
    // ============================================================================

    group('Facade API Tests', () {
      test('createPredictiveModel via facade', () async {
        final model = await facade.createPredictiveModel(
          'Sales Predictor',
          PredictionType.batch,
        );

        expect(model, isNotNull);
        expect(model.name, equals('Sales Predictor'));
        expect(model.type, equals(PredictionType.batch));
      });

      test('makePrediction via facade', () async {
        final model = await facade.createPredictiveModel(
          'Test Model',
          PredictionType.realtime,
        );

        final prediction = await facade.makePrediction(
          model.id,
          {'value': 100},
        );

        expect(prediction, isNotNull);
        expect(prediction.modelId, equals(model.id));
      });

      test('detectAnomalies via facade', () async {
        final anomalies = await facade.detectAnomalies(
          [1.0, 2.0, 3.0, 50.0, 2.0],
          0.90,
        );

        expect(anomalies.isNotEmpty, true);
      });

      test('analyzePatterns via facade', () async {
        final patterns = await facade.analyzePatterns([1, 2, 3, 1, 2, 3]);
        expect(patterns, isNotNull);
      });

      test('detectFraud via facade', () async {
        final fraud = await facade.detectFraud(
          'txn_123',
          ['velocity'],
        );

        expect(fraud, isNotNull);
        expect(fraud.transactionId, equals('txn_123'));
      });

      test('generateRecommendation via facade', () async {
        final rec = await facade.generateRecommendation(
          'user_123',
          'item_456',
        );

        expect(rec, isNotNull);
        expect(rec.userId, equals('user_123'));
      });

      test('generateInsight via facade', () async {
        final insight = await facade.generateInsight(
          'Revenue Analysis',
          'Sales trending up',
          'business',
        );

        expect(insight, isNotNull);
        expect(insight.title, equals('Revenue Analysis'));
      });

      test('getAnalyticsDashboard', () async {
        // Create some test data
        final model = await facade.createPredictiveModel(
          'Dashboard Model',
          PredictionType.batch,
        );

        final prediction = await facade.makePrediction(model.id, {'value': 100});
        final anomalies = await facade.detectAnomalies([1.0, 50.0], 0.80);

        final dashboard = await facade.getAnalyticsDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.containsKey('totalModels'), true);
        expect(dashboard.containsKey('totalPredictions'), true);
      });
    });

    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================

    group('Integration Tests', () {
      test('Complete analytics workflow', () async {
        // Create model
        final model = await facade.createPredictiveModel(
          'Customer Churn Model',
          PredictionType.batch,
        );
        expect(model.isActive, true);

        // Make predictions
        for (int i = 0; i < 5; i++) {
          await facade.makePrediction(
            model.id,
            {'age': 30 + i, 'income': 50000 + (i * 5000)},
          );
        }

        // Detect anomalies
        final anomalies = await facade.detectAnomalies(
          [100.0, 105.0, 103.0, 500.0, 102.0],
          0.85,
        );
        expect(anomalies.isNotEmpty, true);

        // Analyze patterns
        final patterns = await facade.analyzePatterns([1, 2, 1, 2, 1, 2]);
        expect(patterns, isNotNull);

        // Detect fraud
        final fraud = await facade.detectFraud(
          'txn_12345',
          ['velocity', 'location_mismatch'],
        );
        expect(fraud.isSuspicious, true);

        // Generate recommendations
        final rec = await facade.generateRecommendation('user_1', 'product_1');
        expect(rec, isNotNull);

        // Generate insights
        final insight = await facade.generateInsight(
          'Churn Risk Analysis',
          'High churn risk detected for segment A',
          'business',
        );
        expect(insight.confidence, greaterThan(0.0));
      });

      test('Multi-model analytics scenario', () async {
        // Create multiple models
        final models = <PredictiveModel>[];
        for (int i = 0; i < 3; i++) {
          final model = await facade.createPredictiveModel(
            'Model_$i',
            i == 0 ? PredictionType.batch : PredictionType.realtime,
          );
          models.add(model);
        }

        expect(models.length, equals(3));

        // Make predictions with each model
        for (final model in models) {
          for (int i = 0; i < 3; i++) {
            await facade.makePrediction(model.id, {'data': i});
          }
        }

        // Get analytics
        final dashboard = await facade.getAnalyticsDashboard();
        expect(dashboard['totalModels'], equals(3));
      });
    });

    // ============================================================================
    // PERFORMANCE TESTS
    // ============================================================================

    group('Performance Tests', () {
      test('Bulk model creation performance', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.createPredictiveModel(
            'Model_$i',
            PredictionType.batch,
          );
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        expect(elapsedMs, lessThan(5000));
        print('Bulk model creation: $elapsedMs ms for 100 models');
      });

      test('Bulk prediction generation', () async {
        final model = await facade.createPredictiveModel(
          'Perf Model',
          PredictionType.batch,
        );

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.makePrediction(model.id, {'value': i});
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        expect(elapsedMs, lessThan(3000));
        print('Bulk predictions: $elapsedMs ms for 100 predictions');
      });

      test('Bulk anomaly detection', () async {
        final data = List<double>.generate(1000, (i) => (i % 100).toDouble());

        final stopwatch = Stopwatch()..start();
        await facade.detectAnomalies(data, 0.80);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        expect(elapsedMs, lessThan(1000));
        print('Anomaly detection: $elapsedMs ms for 1000 points');
      });
    });

    // ============================================================================
    // EDGE CASE TESTS
    // ============================================================================

    group('Edge Case Tests', () {
      test('Handle null model retrieval', () async {
        final result = await repository.getPredictiveModel('non_existent');
        expect(result, isNull);
      });

      test('Handle empty predictions list', () async {
        final predictions = await repository.getAllPredictions();
        expect(predictions, isEmpty);
      });

      test('Handle zero confidence predictions', () async {
        final prediction = Prediction(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {},
          prediction: 'Unknown',
          confidence: 0.0,
          timestamp: DateTime.now(),
          isSuccessful: false,
          processingTimeMs: 0,
        );

        await repository.createPrediction(prediction);
        final retrieved = await repository.getPrediction('pred_1');

        expect(retrieved!.confidence, equals(0.0));
      });

      test('Handle very high anomaly scores', () async {
        final anomaly = AnomalyDetection(
          id: 'anom_1',
          dataPointId: 'dp_1',
          type: AnomalyType.statistical,
          anomalyScore: 1.0,
          threshold: 0.80,
          detectedAt: DateTime.now(),
          description: 'Max anomaly',
          severity: AlertSeverity.critical,
        );

        await repository.createAnomalyDetection(anomaly);
        final retrieved = await repository.getAnomalyDetection('anom_1');

        expect(retrieved!.isCritical, true);
      });

      test('Handle empty actionable items', () async {
        final insight = InsightGeneration(
          id: 'insight_1',
          title: 'Empty Insight',
          description: 'No actions',
          category: 'test',
          generatedAt: DateTime.now(),
          confidence: 0.50,
          actionableItems: [],
        );

        await repository.createInsightGeneration(insight);
        final retrieved = await repository.getInsightGeneration('insight_1');

        expect(retrieved!.actionableItems, isEmpty);
      });

      test('Handle concurrent operations', () async {
        final futures = <Future<void>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(
            facade.createPredictiveModel(
              'Concurrent_$i',
              PredictionType.batch,
            ),
          );
        }

        await Future.wait(futures);
        final count = await repository.countPredictiveModels();

        expect(count, equals(10));
      });
    });
  });
}
