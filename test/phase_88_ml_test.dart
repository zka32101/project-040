// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/ml_models.dart';
import 'package:project_040/services/ml_service.dart';

void main() {
  group('Phase 88: Advanced Machine Learning & AI Integration', () {
    // ========================================================================
    // ENUM TESTS (6 enums × ~5 tests each = 30+ tests)
    // ========================================================================

    group('ModelType Enum Tests', () {
      test('ModelType.regression has correct displayName', () {
        expect(ModelType.regression.displayName, '回帰');
      });

      test('ModelType.classification has correct displayName', () {
        expect(ModelType.classification.displayName, '分類');
      });

      test('ModelType.clustering has correct displayName', () {
        expect(ModelType.clustering.displayName, 'クラスタリング');
      });

      test('ModelType.timeSeries has correct displayName', () {
        expect(ModelType.timeSeries.displayName, '時系列');
      });

      test('ModelType.nlp has correct displayName', () {
        expect(ModelType.nlp.displayName, '自然言語処理');
      });

      test('ModelType.customModel has correct displayName', () {
        expect(ModelType.customModel.displayName, 'カスタム');
      });

      test('All ModelType values exist', () {
        expect(ModelType.values.length, 6);
      });
    });

    group('ModelStatus Enum Tests', () {
      test('ModelStatus.draft has correct displayName', () {
        expect(ModelStatus.draft.displayName, '下書き');
      });

      test('ModelStatus.training has correct displayName', () {
        expect(ModelStatus.training.displayName, 'トレーニング中');
      });

      test('ModelStatus.evaluating has correct displayName', () {
        expect(ModelStatus.evaluating.displayName, '評価中');
      });

      test('ModelStatus.deployed has correct displayName', () {
        expect(ModelStatus.deployed.displayName, 'デプロイ済み');
      });

      test('ModelStatus.archived has correct displayName', () {
        expect(ModelStatus.archived.displayName, 'アーカイブ');
      });

      test('ModelStatus.failed has correct displayName', () {
        expect(ModelStatus.failed.displayName, '失敗');
      });

      test('All ModelStatus values exist', () {
        expect(ModelStatus.values.length, 6);
      });
    });

    group('FeatureType Enum Tests', () {
      test('FeatureType.numeric has correct displayName', () {
        expect(FeatureType.numeric.displayName, '数値');
      });

      test('FeatureType.categorical has correct displayName', () {
        expect(FeatureType.categorical.displayName, 'カテゴリ');
      });

      test('FeatureType.text has correct displayName', () {
        expect(FeatureType.text.displayName, 'テキスト');
      });

      test('FeatureType.datetime has correct displayName', () {
        expect(FeatureType.datetime.displayName, '日時');
      });

      test('FeatureType.embedding has correct displayName', () {
        expect(FeatureType.embedding.displayName, 'エンベディング');
      });

      test('FeatureType.image has correct displayName', () {
        expect(FeatureType.image.displayName, '画像');
      });

      test('All FeatureType values exist', () {
        expect(FeatureType.values.length, 6);
      });
    });

    group('TrainingStatus Enum Tests', () {
      test('TrainingStatus.pending has correct displayName', () {
        expect(TrainingStatus.pending.displayName, '保留中');
      });

      test('TrainingStatus.running has correct displayName', () {
        expect(TrainingStatus.running.displayName, '実行中');
      });

      test('TrainingStatus.completed has correct displayName', () {
        expect(TrainingStatus.completed.displayName, '完了');
      });

      test('TrainingStatus.failed has correct displayName', () {
        expect(TrainingStatus.failed.displayName, '失敗');
      });

      test('TrainingStatus.paused has correct displayName', () {
        expect(TrainingStatus.paused.displayName, '一時停止');
      });

      test('TrainingStatus.cancelled has correct displayName', () {
        expect(TrainingStatus.cancelled.displayName, 'キャンセル');
      });

      test('All TrainingStatus values exist', () {
        expect(TrainingStatus.values.length, 6);
      });
    });

    group('PredictionType Enum Tests', () {
      test('PredictionType.batch has correct displayName', () {
        expect(PredictionType.batch.displayName, 'バッチ');
      });

      test('PredictionType.realtime has correct displayName', () {
        expect(PredictionType.realtime.displayName, 'リアルタイム');
      });

      test('PredictionType.scheduled has correct displayName', () {
        expect(PredictionType.scheduled.displayName, 'スケジュール済み');
      });

      test('PredictionType.streaming has correct displayName', () {
        expect(PredictionType.streaming.displayName, 'ストリーミング');
      });

      test('PredictionType.interactive has correct displayName', () {
        expect(PredictionType.interactive.displayName, '対話型');
      });

      test('PredictionType.api has correct displayName', () {
        expect(PredictionType.api.displayName, 'API');
      });

      test('All PredictionType values exist', () {
        expect(PredictionType.values.length, 6);
      });
    });

    group('ModelEvaluationMetric Enum Tests', () {
      test('ModelEvaluationMetric.accuracy has correct displayName', () {
        expect(ModelEvaluationMetric.accuracy.displayName, '精度');
      });

      test('ModelEvaluationMetric.precision has correct displayName', () {
        expect(ModelEvaluationMetric.precision.displayName, '適合率');
      });

      test('ModelEvaluationMetric.recall has correct displayName', () {
        expect(ModelEvaluationMetric.recall.displayName, '再現率');
      });

      test('ModelEvaluationMetric.f1Score has correct displayName', () {
        expect(ModelEvaluationMetric.f1Score.displayName, 'F1スコア');
      });

      test('ModelEvaluationMetric.rocAuc has correct displayName', () {
        expect(ModelEvaluationMetric.rocAuc.displayName, 'ROC AUC');
      });

      test('ModelEvaluationMetric.rmse has correct displayName', () {
        expect(ModelEvaluationMetric.rmse.displayName, 'RMSE');
      });

      test('All ModelEvaluationMetric values exist', () {
        expect(ModelEvaluationMetric.values.length, 6);
      });
    });

    // ========================================================================
    // MODEL TESTS (12 models × ~4 tests each = 48+ tests)
    // ========================================================================

    group('MLModel Tests', () {
      test('MLModel creation with defaults', () {
        final now = DateTime.now();
        final model = MLModel(
          id: 'model_1',
          name: 'Test Model',
          modelType: ModelType.regression,
          createdAt: now,
          updatedAt: now,
        );

        expect(model.id, 'model_1');
        expect(model.name, 'Test Model');
        expect(model.modelType, ModelType.regression);
        expect(model.status, ModelStatus.draft);
        expect(model.version, '1.0');
        expect(model.accuracy, 0.0);
      });

      test('MLModel.isDeployed getter works correctly', () {
        final now = DateTime.now();
        final model = MLModel(
          id: 'model_1',
          name: 'Test Model',
          modelType: ModelType.classification,
          createdAt: now,
          updatedAt: now,
          status: ModelStatus.deployed,
        );

        expect(model.isDeployed, true);
      });

      test('MLModel.isTraining getter works correctly', () {
        final now = DateTime.now();
        final model = MLModel(
          id: 'model_1',
          name: 'Test Model',
          modelType: ModelType.timeSeries,
          createdAt: now,
          updatedAt: now,
          status: ModelStatus.training,
        );

        expect(model.isTraining, true);
      });

      test('MLModel.ageInDays computed correctly', () {
        final now = DateTime.now();
        final model = MLModel(
          id: 'model_1',
          name: 'Test Model',
          modelType: ModelType.clustering,
          createdAt: now.subtract(Duration(days: 10)),
          updatedAt: now,
        );

        expect(model.ageInDays, greaterThanOrEqualTo(9));
      });

      test('MLModel copyWith works correctly', () {
        final now = DateTime.now();
        final model = MLModel(
          id: 'model_1',
          name: 'Original Name',
          modelType: ModelType.nlp,
          createdAt: now,
          updatedAt: now,
        );

        final updated = model.copyWith(
          name: 'Updated Name',
          status: ModelStatus.deployed,
        );

        expect(updated.name, 'Updated Name');
        expect(updated.status, ModelStatus.deployed);
        expect(updated.id, 'model_1');
      });
    });

    group('TrainingJob Tests', () {
      test('TrainingJob creation with defaults', () {
        final now = DateTime.now();
        final job = TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
        );

        expect(job.status, TrainingStatus.pending);
        expect(job.epochsCompleted, 0);
        expect(job.totalEpochs, 100);
        expect(job.currentLoss, 0.0);
      });

      test('TrainingJob.isRunning getter works correctly', () {
        final now = DateTime.now();
        final job = TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
          status: TrainingStatus.running,
        );

        expect(job.isRunning, true);
      });

      test('TrainingJob.progressPercent computed correctly', () {
        final now = DateTime.now();
        final job = TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
          epochsCompleted: 50,
          totalEpochs: 100,
        );

        expect(job.progressPercent, 50.0);
      });

      test('TrainingJob.isConverging detects improving loss', () {
        final now = DateTime.now();
        final job = TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
          currentLoss: 0.1,
          bestLoss: 0.2,
        );

        expect(job.isConverging, true);
      });
    });

    group('FeatureDefinition Tests', () {
      test('FeatureDefinition creation with defaults', () {
        final now = DateTime.now();
        final feature = FeatureDefinition(
          id: 'feature_1',
          name: 'Age',
          featureType: FeatureType.numeric,
          sourceField: 'user_age',
          createdAt: now,
        );

        expect(feature.isNormalized, false);
        expect(feature.min, 0.0);
        expect(feature.max, 1.0);
      });

      test('FeatureDefinition.isNumeric getter works', () {
        final now = DateTime.now();
        final feature = FeatureDefinition(
          id: 'feature_1',
          name: 'Age',
          featureType: FeatureType.numeric,
          sourceField: 'user_age',
          createdAt: now,
        );

        expect(feature.isNumeric, true);
      });

      test('FeatureDefinition.range computed correctly', () {
        final now = DateTime.now();
        final feature = FeatureDefinition(
          id: 'feature_1',
          name: 'Age',
          featureType: FeatureType.numeric,
          sourceField: 'user_age',
          createdAt: now,
          min: 0.0,
          max: 100.0,
        );

        expect(feature.range, 100.0);
      });
    });

    group('ModelEvaluation Tests', () {
      test('ModelEvaluation creation with defaults', () {
        final now = DateTime.now();
        final eval = ModelEvaluation(
          id: 'eval_1',
          modelId: 'model_1',
          evaluatedAt: now,
          createdAt: now,
        );

        expect(eval.accuracy, 0.0);
        expect(eval.precision, 0.0);
        expect(eval.sampleSize, 0);
      });

      test('ModelEvaluation.isHighAccuracy getter works', () {
        final now = DateTime.now();
        final eval = ModelEvaluation(
          id: 'eval_1',
          modelId: 'model_1',
          evaluatedAt: now,
          createdAt: now,
          accuracy: 0.95,
        );

        expect(eval.isHighAccuracy, true);
      });

      test('ModelEvaluation.overallScore computed correctly', () {
        final now = DateTime.now();
        final eval = ModelEvaluation(
          id: 'eval_1',
          modelId: 'model_1',
          evaluatedAt: now,
          createdAt: now,
          accuracy: 0.8,
          precision: 0.8,
          recall: 0.8,
          f1Score: 0.8,
        );

        expect(eval.overallScore, 0.8);
      });
    });

    group('PredictionRequest Tests', () {
      test('PredictionRequest creation', () {
        final now = DateTime.now();
        final prediction = PredictionRequest(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'feature1': 10.0},
          createdAt: now,
          predictionType: PredictionType.realtime,
        );

        expect(prediction.isProcessed, false);
        expect(prediction.confidence, 0.0);
      });

      test('PredictionRequest.isSuccessful checks prediction and error', () {
        final now = DateTime.now();
        final prediction = PredictionRequest(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'feature1': 10.0},
          createdAt: now,
          predictionType: PredictionType.batch,
          prediction: 0.75,
          error: null,
        );

        expect(prediction.isSuccessful, true);
      });

      test('PredictionRequest.isHighConfidence works', () {
        final now = DateTime.now();
        final prediction = PredictionRequest(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'feature1': 10.0},
          createdAt: now,
          predictionType: PredictionType.scheduled,
          confidence: 0.95,
        );

        expect(prediction.isHighConfidence, true);
      });
    });

    group('Dataset Tests', () {
      test('Dataset creation with defaults', () {
        final now = DateTime.now();
        final dataset = Dataset(
          id: 'dataset_1',
          name: 'Training Data',
          createdAt: now,
        );

        expect(dataset.dataFormat, 'csv');
        expect(dataset.rowCount, 0);
        expect(dataset.isProcessed, false);
      });

      test('Dataset.isLarge computed correctly', () {
        final now = DateTime.now();
        final dataset = Dataset(
          id: 'dataset_1',
          name: 'Large Data',
          createdAt: now,
          sizeBytes: 2000000,
        );

        expect(dataset.isLarge, true);
      });

      test('Dataset.ageInDays computed correctly', () {
        final now = DateTime.now();
        final dataset = Dataset(
          id: 'dataset_1',
          name: 'Old Data',
          createdAt: now.subtract(Duration(days: 30)),
        );

        expect(dataset.ageInDays, greaterThanOrEqualTo(29));
      });
    });

    group('HyperParameter Tests', () {
      test('HyperParameter creation', () {
        final now = DateTime.now();
        final param = HyperParameter(
          id: 'param_1',
          trainingJobId: 'job_1',
          parameterName: 'learning_rate',
          parameterValue: 0.001,
          createdAt: now,
        );

        expect(param.parameterType, 'numeric');
        expect(param.min, 0.0);
        expect(param.max, 1.0);
      });

      test('HyperParameter.isNumeric getter works', () {
        final now = DateTime.now();
        final param = HyperParameter(
          id: 'param_1',
          trainingJobId: 'job_1',
          parameterName: 'learning_rate',
          parameterValue: 0.001,
          createdAt: now,
          parameterType: 'numeric',
        );

        expect(param.isNumeric, true);
      });

      test('HyperParameter.isInRange validates bounds', () {
        final now = DateTime.now();
        final param = HyperParameter(
          id: 'param_1',
          trainingJobId: 'job_1',
          parameterName: 'learning_rate',
          parameterValue: 0.5,
          createdAt: now,
          parameterType: 'numeric',
          min: 0.0,
          max: 1.0,
        );

        expect(param.isInRange, true);
      });
    });

    group('ModelArtifact Tests', () {
      test('ModelArtifact creation', () {
        final now = DateTime.now();
        final artifact = ModelArtifact(
          id: 'artifact_1',
          modelId: 'model_1',
          artifactType: 'weights',
          storageLocation: 's3://bucket/model.pkl',
          createdAt: now,
        );

        expect(artifact.isCompressed, false);
        expect(artifact.fileSize, 0);
      });

      test('ModelArtifact.isLarge computed correctly', () {
        final now = DateTime.now();
        final artifact = ModelArtifact(
          id: 'artifact_1',
          modelId: 'model_1',
          artifactType: 'weights',
          storageLocation: 's3://bucket/model.pkl',
          createdAt: now,
          fileSize: 5000000,
        );

        expect(artifact.isLarge, true);
      });
    });

    group('FeatureImportance Tests', () {
      test('FeatureImportance creation', () {
        final now = DateTime.now();
        final importance = FeatureImportance(
          id: 'imp_1',
          modelId: 'model_1',
          featureName: 'age',
          importanceScore: 0.8,
          createdAt: now,
        );

        expect(importance.isHighImportance, true);
      });

      test('FeatureImportance.rank is tracked', () {
        final now = DateTime.now();
        final importance = FeatureImportance(
          id: 'imp_1',
          modelId: 'model_1',
          featureName: 'age',
          importanceScore: 0.8,
          createdAt: now,
          rank: 1,
          percentageContribution: 15.0,
        );

        expect(importance.rank, 1);
        expect(importance.percentageContribution, 15.0);
      });
    });

    group('RecommendationEngine Tests', () {
      test('RecommendationEngine creation with defaults', () {
        final now = DateTime.now();
        final engine = RecommendationEngine(
          id: 'rec_1',
          name: 'Collaborative Filter',
          modelId: 'model_1',
          createdAt: now,
        );

        expect(engine.algorithmType, 'collaborative');
        expect(engine.isActive, true);
        expect(engine.recommendationCount, 10);
      });

      test('RecommendationEngine.isCollaborative getter works', () {
        final now = DateTime.now();
        final engine = RecommendationEngine(
          id: 'rec_1',
          name: 'Collaborative Filter',
          modelId: 'model_1',
          createdAt: now,
          algorithmType: 'collaborative',
        );

        expect(engine.isCollaborative, true);
      });

      test('RecommendationEngine.needsUpdate checks staleness', () {
        final now = DateTime.now();
        final engine = RecommendationEngine(
          id: 'rec_1',
          name: 'Collaborative Filter',
          modelId: 'model_1',
          createdAt: now,
          lastUpdatedAt: now.subtract(Duration(days: 10)),
        );

        expect(engine.needsUpdate, true);
      });
    });

    group('ModelVersionControl Tests', () {
      test('ModelVersionControl creation', () {
        final now = DateTime.now();
        final version = ModelVersionControl(
          id: 'ver_1',
          modelId: 'model_1',
          version: '1.0.0',
          createdAt: now,
        );

        expect(version.isActive, false);
        expect(version.accuracy, 0.0);
      });

      test('ModelVersionControl.isProduction checks active state', () {
        final now = DateTime.now();
        final version = ModelVersionControl(
          id: 'ver_1',
          modelId: 'model_1',
          version: '1.0.0',
          createdAt: now,
          isActive: true,
        );

        expect(version.isProduction, true);
      });

      test('ModelVersionControl.isHighQuality checks accuracy', () {
        final now = DateTime.now();
        final version = ModelVersionControl(
          id: 'ver_1',
          modelId: 'model_1',
          version: '1.0.0',
          createdAt: now,
          accuracy: 0.9,
        );

        expect(version.isHighQuality, true);
      });
    });

    // ========================================================================
    // REPOSITORY TESTS (70+ methods across 10 categories)
    // ========================================================================

    group('InMemoryMLRepository Tests', () {
      late InMemoryMLRepository repository;

      setUp(() {
        repository = InMemoryMLRepository();
      });

      group('Model Management', () {
        test('createModel stores model correctly', () async {
          final now = DateTime.now();
          final model = MLModel(
            id: 'model_1',
            name: 'Test Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          );

          await repository.createModel(model);
          final retrieved = await repository.getModelById('model_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.name, 'Test Model');
        });

        test('getModelsByType filters correctly', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Regression Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          ));

          await repository.createModel(MLModel(
            id: 'model_2',
            name: 'Classification Model',
            modelType: ModelType.classification,
            createdAt: now,
            updatedAt: now,
          ));

          final regressionModels =
              await repository.getModelsByType(ModelType.regression);
          expect(regressionModels.length, 1);
          expect(regressionModels.first.name, 'Regression Model');
        });

        test('getModelsByStatus filters by status', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Deployed Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
            status: ModelStatus.deployed,
          ));

          final deployed =
              await repository.getModelsByStatus(ModelStatus.deployed);
          expect(deployed.length, 1);
          expect(deployed.first.status, ModelStatus.deployed);
        });

        test('getDeployedModelCount returns correct count', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Deployed Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
            status: ModelStatus.deployed,
          ));

          final count = await repository.getDeployedModelCount();
          expect(count, 1);
        });

        test('updateModel modifies existing model', () async {
          final now = DateTime.now();
          final model = MLModel(
            id: 'model_1',
            name: 'Original',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          );

          await repository.createModel(model);

          final updated = model.copyWith(name: 'Updated');
          await repository.updateModel(updated);

          final retrieved = await repository.getModelById('model_1');
          expect(retrieved!.name, 'Updated');
        });

        test('deleteModel removes model', () async {
          final now = DateTime.now();
          final model = MLModel(
            id: 'model_1',
            name: 'Temp Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          );

          await repository.createModel(model);
          await repository.deleteModel('model_1');

          final retrieved = await repository.getModelById('model_1');
          expect(retrieved, isNull);
        });

        test('listModels returns all models', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Model 1',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          ));

          await repository.createModel(MLModel(
            id: 'model_2',
            name: 'Model 2',
            modelType: ModelType.classification,
            createdAt: now,
            updatedAt: now,
          ));

          final models = await repository.listModels();
          expect(models.length, 2);
        });

        test('getModelCount returns total models', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Model 1',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          ));

          final count = await repository.getModelCount();
          expect(count, 1);
        });

        test('searchModels finds models by name', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Test Model',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          ));

          final results = await repository.searchModels('Test');
          expect(results.length, 1);
        });

        test('getModelsByOwner filters by owner', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Model 1',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
            owner: 'user1',
          ));

          final models = await repository.getModelsByOwner('user1');
          expect(models.length, 1);
        });

        test('getAverageModelAccuracy calculates average', () async {
          final now = DateTime.now();
          await repository.createModel(MLModel(
            id: 'model_1',
            name: 'Model 1',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
            accuracy: 0.8,
          ));

          await repository.createModel(MLModel(
            id: 'model_2',
            name: 'Model 2',
            modelType: ModelType.classification,
            createdAt: now,
            updatedAt: now,
            accuracy: 0.9,
          ));

          final average = await repository.getAverageModelAccuracy();
          expect(average, 0.85);
        });
      });

      group('Training Jobs', () {
        test('createTrainingJob stores job correctly', () async {
          final now = DateTime.now();
          final job = TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
          );

          await repository.createTrainingJob(job);
          final retrieved = await repository.getTrainingJobById('job_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.modelId, 'model_1');
        });

        test('getRunningTrainingJobs filters running jobs', () async {
          final now = DateTime.now();
          await repository.createTrainingJob(TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
            status: TrainingStatus.running,
          ));

          final jobs = await repository.getRunningTrainingJobs();
          expect(jobs.length, 1);
          expect(jobs.first.status, TrainingStatus.running);
        });

        test('getActiveTrainingJobCount returns correct count', () async {
          final now = DateTime.now();
          await repository.createTrainingJob(TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
            status: TrainingStatus.running,
          ));

          final count = await repository.getActiveTrainingJobCount();
          expect(count, 1);
        });

        test('updateTrainingJob modifies job', () async {
          final now = DateTime.now();
          final job = TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
            epochsCompleted: 0,
          );

          await repository.createTrainingJob(job);

          final updated = job.copyWith(
            epochsCompleted: 50,
            status: TrainingStatus.running,
          );
          await repository.updateTrainingJob(updated);

          final retrieved = await repository.getTrainingJobById('job_1');
          expect(retrieved!.epochsCompleted, 50);
          expect(retrieved.status, TrainingStatus.running);
        });

        test('listTrainingJobs returns all jobs', () async {
          final now = DateTime.now();
          await repository.createTrainingJob(TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
          ));

          final jobs = await repository.listTrainingJobs();
          expect(jobs.length, 1);
        });

        test('getTrainingJobCount returns total', () async {
          final now = DateTime.now();
          await repository.createTrainingJob(TrainingJob(
            id: 'job_1',
            modelId: 'model_1',
            datasetId: 'dataset_1',
            startedAt: now,
            createdAt: now,
          ));

          final count = await repository.getTrainingJobCount();
          expect(count, 1);
        });
      });

      group('Feature Definitions', () {
        test('createFeatureDefinition stores feature', () async {
          final now = DateTime.now();
          final feature = FeatureDefinition(
            id: 'feature_1',
            name: 'Age',
            featureType: FeatureType.numeric,
            sourceField: 'user_age',
            createdAt: now,
          );

          await repository.createFeatureDefinition(feature);
          final retrieved =
              await repository.getFeatureDefinitionById('feature_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.name, 'Age');
        });

        test('getFeaturesByType filters by type', () async {
          final now = DateTime.now();
          await repository.createFeatureDefinition(FeatureDefinition(
            id: 'feature_1',
            name: 'Age',
            featureType: FeatureType.numeric,
            sourceField: 'user_age',
            createdAt: now,
          ));

          final numeric =
              await repository.getFeaturesByType(FeatureType.numeric);
          expect(numeric.length, 1);
        });

        test('getNormalizedFeatures filters normalized features', () async {
          final now = DateTime.now();
          await repository.createFeatureDefinition(FeatureDefinition(
            id: 'feature_1',
            name: 'Normalized Age',
            featureType: FeatureType.numeric,
            sourceField: 'user_age',
            createdAt: now,
            isNormalized: true,
          ));

          final normalized = await repository.getNormalizedFeatures();
          expect(normalized.length, 1);
        });

        test('listFeatureDefinitions returns all', () async {
          final now = DateTime.now();
          await repository.createFeatureDefinition(FeatureDefinition(
            id: 'feature_1',
            name: 'Age',
            featureType: FeatureType.numeric,
            sourceField: 'user_age',
            createdAt: now,
          ));

          final features = await repository.listFeatureDefinitions();
          expect(features.length, 1);
        });
      });

      group('Model Evaluation', () {
        test('createModelEvaluation stores evaluation', () async {
          final now = DateTime.now();
          final eval = ModelEvaluation(
            id: 'eval_1',
            modelId: 'model_1',
            evaluatedAt: now,
            createdAt: now,
            accuracy: 0.95,
          );

          await repository.createModelEvaluation(eval);
          final retrieved =
              await repository.getModelEvaluationById('eval_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.accuracy, 0.95);
        });

        test('getEvaluationsByModelId retrieves all evaluations', () async {
          final now = DateTime.now();
          await repository.createModelEvaluation(ModelEvaluation(
            id: 'eval_1',
            modelId: 'model_1',
            evaluatedAt: now,
            createdAt: now,
            accuracy: 0.95,
          ));

          final evals =
              await repository.getEvaluationsByModelId('model_1');
          expect(evals.length, 1);
        });

        test('getHighAccuracyEvaluations filters high accuracy', () async {
          final now = DateTime.now();
          await repository.createModelEvaluation(ModelEvaluation(
            id: 'eval_1',
            modelId: 'model_1',
            evaluatedAt: now,
            createdAt: now,
            accuracy: 0.95,
          ));

          final high = await repository.getHighAccuracyEvaluations(0.9);
          expect(high.length, 1);
        });

        test('listModelEvaluations returns all', () async {
          final now = DateTime.now();
          await repository.createModelEvaluation(ModelEvaluation(
            id: 'eval_1',
            modelId: 'model_1',
            evaluatedAt: now,
            createdAt: now,
            accuracy: 0.95,
          ));

          final evals = await repository.listModelEvaluations();
          expect(evals.length, 1);
        });
      });

      group('Prediction Requests', () {
        test('createPredictionRequest stores prediction', () async {
          final now = DateTime.now();
          final pred = PredictionRequest(
            id: 'pred_1',
            modelId: 'model_1',
            inputData: {'feature1': 10.0},
            createdAt: now,
            predictionType: PredictionType.realtime,
          );

          await repository.createPredictionRequest(pred);
          final retrieved =
              await repository.getPredictionRequestById('pred_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.modelId, 'model_1');
        });

        test('getSuccessfulPredictions filters successful', () async {
          final now = DateTime.now();
          await repository.createPredictionRequest(PredictionRequest(
            id: 'pred_1',
            modelId: 'model_1',
            inputData: {'feature1': 10.0},
            createdAt: now,
            predictionType: PredictionType.batch,
            prediction: 0.75,
            error: null,
          ));

          final successful =
              await repository.getSuccessfulPredictions();
          expect(successful.length, 1);
        });

        test('getHighConfidencePredictions filters confidence', () async {
          final now = DateTime.now();
          await repository.createPredictionRequest(PredictionRequest(
            id: 'pred_1',
            modelId: 'model_1',
            inputData: {'feature1': 10.0},
            createdAt: now,
            predictionType: PredictionType.scheduled,
            confidence: 0.95,
          ));

          final high =
              await repository.getHighConfidencePredictions(0.9);
          expect(high.length, 1);
        });

        test('listPredictionRequests returns all', () async {
          final now = DateTime.now();
          await repository.createPredictionRequest(PredictionRequest(
            id: 'pred_1',
            modelId: 'model_1',
            inputData: {'feature1': 10.0},
            createdAt: now,
            predictionType: PredictionType.streaming,
          ));

          final preds = await repository.listPredictionRequests();
          expect(preds.length, 1);
        });
      });

      group('Datasets', () {
        test('createDataset stores dataset', () async {
          final now = DateTime.now();
          final dataset = Dataset(
            id: 'dataset_1',
            name: 'Training Data',
            createdAt: now,
            rowCount: 1000,
          );

          await repository.createDataset(dataset);
          final retrieved = await repository.getDatasetById('dataset_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.rowCount, 1000);
        });

        test('getProcessedDatasets filters processed', () async {
          final now = DateTime.now();
          await repository.createDataset(Dataset(
            id: 'dataset_1',
            name: 'Processed Data',
            createdAt: now,
            isProcessed: true,
          ));

          final processed = await repository.getProcessedDatasets();
          expect(processed.length, 1);
        });

        test('listDatasets returns all', () async {
          final now = DateTime.now();
          await repository.createDataset(Dataset(
            id: 'dataset_1',
            name: 'Training Data',
            createdAt: now,
          ));

          final datasets = await repository.listDatasets();
          expect(datasets.length, 1);
        });
      });

      group('Hyperparameters', () {
        test('createHyperParameter stores parameter', () async {
          final now = DateTime.now();
          final param = HyperParameter(
            id: 'param_1',
            trainingJobId: 'job_1',
            parameterName: 'learning_rate',
            parameterValue: 0.001,
            createdAt: now,
          );

          await repository.createHyperParameter(param);
          final retrieved =
              await repository.getHyperParameterById('param_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.parameterName, 'learning_rate');
        });

        test('getHyperParametersByJobId retrieves all for job', () async {
          final now = DateTime.now();
          await repository.createHyperParameter(HyperParameter(
            id: 'param_1',
            trainingJobId: 'job_1',
            parameterName: 'learning_rate',
            parameterValue: 0.001,
            createdAt: now,
          ));

          final params =
              await repository.getHyperParametersByJobId('job_1');
          expect(params.length, 1);
        });

        test('listHyperParameters returns all', () async {
          final now = DateTime.now();
          await repository.createHyperParameter(HyperParameter(
            id: 'param_1',
            trainingJobId: 'job_1',
            parameterName: 'learning_rate',
            parameterValue: 0.001,
            createdAt: now,
          ));

          final params = await repository.listHyperParameters();
          expect(params.length, 1);
        });
      });

      group('Model Artifacts', () {
        test('createModelArtifact stores artifact', () async {
          final now = DateTime.now();
          final artifact = ModelArtifact(
            id: 'artifact_1',
            modelId: 'model_1',
            artifactType: 'weights',
            storageLocation: 's3://bucket/model.pkl',
            createdAt: now,
          );

          await repository.createModelArtifact(artifact);
          final retrieved =
              await repository.getModelArtifactById('artifact_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.artifactType, 'weights');
        });

        test('getArtifactsByModelId retrieves all for model', () async {
          final now = DateTime.now();
          await repository.createModelArtifact(ModelArtifact(
            id: 'artifact_1',
            modelId: 'model_1',
            artifactType: 'weights',
            storageLocation: 's3://bucket/model.pkl',
            createdAt: now,
          ));

          final artifacts =
              await repository.getArtifactsByModelId('model_1');
          expect(artifacts.length, 1);
        });

        test('listModelArtifacts returns all', () async {
          final now = DateTime.now();
          await repository.createModelArtifact(ModelArtifact(
            id: 'artifact_1',
            modelId: 'model_1',
            artifactType: 'weights',
            storageLocation: 's3://bucket/model.pkl',
            createdAt: now,
          ));

          final artifacts = await repository.listModelArtifacts();
          expect(artifacts.length, 1);
        });
      });

      group('Feature Importance', () {
        test('createFeatureImportance stores importance', () async {
          final now = DateTime.now();
          final importance = FeatureImportance(
            id: 'imp_1',
            modelId: 'model_1',
            featureName: 'age',
            importanceScore: 0.8,
            createdAt: now,
          );

          await repository.createFeatureImportance(importance);
          final retrieved =
              await repository.getFeatureImportanceById('imp_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.featureName, 'age');
        });

        test('getTopFeaturesForModel retrieves top features', () async {
          final now = DateTime.now();
          await repository.createFeatureImportance(FeatureImportance(
            id: 'imp_1',
            modelId: 'model_1',
            featureName: 'age',
            importanceScore: 0.8,
            createdAt: now,
          ));

          final top = await repository.getTopFeaturesForModel(
            'model_1',
            limit: 5,
          );
          expect(top.length, 1);
        });

        test('listFeatureImportance returns all', () async {
          final now = DateTime.now();
          await repository.createFeatureImportance(FeatureImportance(
            id: 'imp_1',
            modelId: 'model_1',
            featureName: 'age',
            importanceScore: 0.8,
            createdAt: now,
          ));

          final importance = await repository.listFeatureImportance();
          expect(importance.length, 1);
        });
      });

      group('Recommendation Engines', () {
        test('createRecommendationEngine stores engine', () async {
          final now = DateTime.now();
          final engine = RecommendationEngine(
            id: 'rec_1',
            name: 'Collab Filter',
            modelId: 'model_1',
            createdAt: now,
          );

          await repository.createRecommendationEngine(engine);
          final retrieved =
              await repository.getRecommendationEngineById('rec_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.name, 'Collab Filter');
        });

        test('getActiveRecommendationEngines filters active', () async {
          final now = DateTime.now();
          await repository.createRecommendationEngine(RecommendationEngine(
            id: 'rec_1',
            name: 'Collab Filter',
            modelId: 'model_1',
            createdAt: now,
            isActive: true,
          ));

          final active = await repository.getActiveRecommendationEngines();
          expect(active.length, 1);
        });

        test('listRecommendationEngines returns all', () async {
          final now = DateTime.now();
          await repository.createRecommendationEngine(RecommendationEngine(
            id: 'rec_1',
            name: 'Collab Filter',
            modelId: 'model_1',
            createdAt: now,
          ));

          final engines = await repository.listRecommendationEngines();
          expect(engines.length, 1);
        });
      });

      group('Model Version Control', () {
        test('createModelVersion stores version', () async {
          final now = DateTime.now();
          final version = ModelVersionControl(
            id: 'ver_1',
            modelId: 'model_1',
            version: '1.0.0',
            createdAt: now,
          );

          await repository.createModelVersion(version);
          final retrieved = await repository.getModelVersionById('ver_1');

          expect(retrieved, isNotNull);
          expect(retrieved!.version, '1.0.0');
        });

        test('getProductionVersion returns active version', () async {
          final now = DateTime.now();
          await repository.createModelVersion(ModelVersionControl(
            id: 'ver_1',
            modelId: 'model_1',
            version: '1.0.0',
            createdAt: now,
            isActive: true,
          ));

          final prod =
              await repository.getProductionVersion('model_1');
          expect(prod, isNotNull);
          expect(prod!.isActive, true);
        });

        test('listModelVersions returns all versions', () async {
          final now = DateTime.now();
          await repository.createModelVersion(ModelVersionControl(
            id: 'ver_1',
            modelId: 'model_1',
            version: '1.0.0',
            createdAt: now,
          ));

          final versions = await repository.listModelVersions();
          expect(versions.length, 1);
        });
      });
    });

    // ========================================================================
    // FACADE & INTEGRATION TESTS
    // ========================================================================

    group('MLFacade Tests', () {
      late MLFacade facade;
      late InMemoryMLRepository repository;

      setUp(() {
        repository = InMemoryMLRepository();
        final manager = MLManager(repository);
        facade = MLFacade(manager);
      });

      test('createModel creates model via facade', () async {
        final model = await facade.createModel(
          'Test Model',
          ModelType.regression,
        );

        expect(model.name, 'Test Model');
        expect(model.modelType, ModelType.regression);
        expect(model.status, ModelStatus.draft);
      });

      test('startTrainingJob creates and tracks training', () async {
        final model = await facade.createModel(
          'Test Model',
          ModelType.classification,
        );

        final job = await facade.startTrainingJob(
          model.id,
          'dataset_1',
        );

        expect(job.modelId, model.id);
        expect(job.status, TrainingStatus.pending);
      });

      test('defineFeature creates feature definition', () async {
        final feature = await facade.defineFeature(
          'Age',
          FeatureType.numeric,
          'user_age',
        );

        expect(feature.name, 'Age');
        expect(feature.featureType, FeatureType.numeric);
      });

      test('evaluateModel stores evaluation', () async {
        final model = await facade.createModel(
          'Test Model',
          ModelType.regression,
        );

        final eval = await facade.evaluateModel(
          model.id,
          accuracy: 0.95,
          precision: 0.93,
        );

        expect(eval.modelId, model.id);
        expect(eval.accuracy, 0.95);
      });

      test('makePrediction creates prediction request', () async {
        final model = await facade.createModel(
          'Test Model',
          ModelType.classification,
        );

        final pred = await facade.makePrediction(
          model.id,
          {'feature1': 10.0},
          PredictionType.realtime,
        );

        expect(pred.modelId, model.id);
        expect(pred.inputData['feature1'], 10.0);
      });

      test('getDeployedModelCount returns count', () async {
        final now = DateTime.now();
        await repository.createModel(MLModel(
          id: 'model_1',
          name: 'Model 1',
          modelType: ModelType.regression,
          createdAt: now,
          updatedAt: now,
          status: ModelStatus.deployed,
        ));

        final count = await facade.getDeployedModelCount();
        expect(count, greaterThanOrEqualTo(1));
      });

      test('getAverageModelAccuracy calculates average', () async {
        final now = DateTime.now();
        await repository.createModel(MLModel(
          id: 'model_1',
          name: 'Model 1',
          modelType: ModelType.regression,
          createdAt: now,
          updatedAt: now,
          accuracy: 0.9,
        ));

        final avg = await facade.getAverageModelAccuracy();
        expect(avg, greaterThan(0.0));
      });

      test('getActiveTrainingJobCount returns count', () async {
        final now = DateTime.now();
        await repository.createTrainingJob(TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
          status: TrainingStatus.running,
        ));

        final count = await facade.getActiveTrainingJobCount();
        expect(count, greaterThanOrEqualTo(1));
      });

      test('createRecommendationEngine creates engine', () async {
        final model = await facade.createModel(
          'Test Model',
          ModelType.regression,
        );

        final engine = await facade.createRecommendationEngine(
          'Collab Filter',
          model.id,
        );

        expect(engine.name, 'Collab Filter');
        expect(engine.modelId, model.id);
      });
    });

    // ========================================================================
    // EDGE CASE & ERROR HANDLING TESTS
    // ========================================================================

    group('Edge Cases & Error Handling', () {
      late InMemoryMLRepository repository;

      setUp(() {
        repository = InMemoryMLRepository();
      });

      test('getModelById returns null for missing model', () async {
        final model = await repository.getModelById('nonexistent');
        expect(model, isNull);
      });

      test('deleteModel handles missing model gracefully', () async {
        expect(
          () => repository.deleteModel('nonexistent'),
          returnsNormally,
        );
      });

      test('listModels returns empty list when no models', () async {
        final models = await repository.listModels();
        expect(models, isEmpty);
      });

      test('getAverageModelAccuracy handles zero models', () async {
        final avg = await repository.getAverageModelAccuracy();
        expect(avg, 0.0);
      });

      test('TrainingJob with zero total epochs returns 0% progress', () {
        final now = DateTime.now();
        final job = TrainingJob(
          id: 'job_1',
          modelId: 'model_1',
          datasetId: 'dataset_1',
          startedAt: now,
          createdAt: now,
          totalEpochs: 0,
        );

        expect(job.progressPercent, 0.0);
      });

      test('FeatureDefinition with min=max returns zero range', () {
        final now = DateTime.now();
        final feature = FeatureDefinition(
          id: 'feature_1',
          name: 'Constant',
          featureType: FeatureType.numeric,
          sourceField: 'const',
          createdAt: now,
          min: 5.0,
          max: 5.0,
        );

        expect(feature.range, 0.0);
      });

      test('PredictionRequest with error is not successful', () {
        final now = DateTime.now();
        final pred = PredictionRequest(
          id: 'pred_1',
          modelId: 'model_1',
          inputData: {'feature1': 10.0},
          createdAt: now,
          predictionType: PredictionType.batch,
          error: 'Model not found',
        );

        expect(pred.isSuccessful, false);
      });

      test('ModelEvaluation with no metrics returns 0.0 score', () {
        final now = DateTime.now();
        final eval = ModelEvaluation(
          id: 'eval_1',
          modelId: 'model_1',
          evaluatedAt: now,
          createdAt: now,
          accuracy: 0.0,
          precision: 0.0,
          recall: 0.0,
          f1Score: 0.0,
        );

        expect(eval.overallScore, 0.0);
      });
    });

    // ========================================================================
    // PERFORMANCE & STRESS TESTS
    // ========================================================================

    group('Performance Tests', () {
      late InMemoryMLRepository repository;

      setUp(() {
        repository = InMemoryMLRepository();
      });

      test('Bulk model creation performance', () async {
        final stopwatch = Stopwatch()..start();
        final now = DateTime.now();

        for (int i = 0; i < 100; i++) {
          await repository.createModel(MLModel(
            id: 'model_$i',
            name: 'Model $i',
            modelType: ModelType.regression,
            createdAt: now,
            updatedAt: now,
          ));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Bulk training job creation performance', () async {
        final stopwatch = Stopwatch()..start();
        final now = DateTime.now();

        for (int i = 0; i < 50; i++) {
          await repository.createTrainingJob(TrainingJob(
            id: 'job_$i',
            modelId: 'model_$i',
            datasetId: 'dataset_$i',
            startedAt: now,
            createdAt: now,
          ));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Query performance on large dataset', () async {
        final now = DateTime.now();

        for (int i = 0; i < 100; i++) {
          await repository.createModel(MLModel(
            id: 'model_$i',
            name: 'Model $i',
            modelType: i % 2 == 0
                ? ModelType.regression
                : ModelType.classification,
            createdAt: now,
            updatedAt: now,
          ));
        }

        final stopwatch = Stopwatch()..start();
        final regressions =
            await repository.getModelsByType(ModelType.regression);
        stopwatch.stop();

        expect(regressions.length, 50);
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
