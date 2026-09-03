import 'package:test/test.dart';
import 'package:project_040/models/feature_flag_models.dart';
import 'package:project_040/services/feature_flag_service.dart';

void main() {
  group('Phase 38: Feature Flags & A/B Testing', () {
    late FeatureFlagManager manager;

    setUp(() {
      manager = FeatureFlagManager();
    });

    // Feature Flag Status Enum Tests
    group('FeatureFlagStatus Enum', () {
      test('should have disabled status', () {
        expect(FeatureFlagStatus.disabled.value, equals('disabled'));
      });

      test('should have all statuses', () {
        expect(FeatureFlagStatus.values.length, equals(4));
      });
    });

    // Rollout Strategy Enum Tests
    group('RolloutStrategy Enum', () {
      test('should have immediate strategy', () {
        expect(RolloutStrategy.immediate.value, equals('immediate'));
      });

      test('should have gradual strategy', () {
        expect(RolloutStrategy.gradual.value, equals('gradual'));
      });

      test('should have all strategies', () {
        expect(RolloutStrategy.values.length, equals(5));
      });
    });

    // User Segment Tests
    group('UserSegment', () {
      test('should create user segment', () {
        final segment = UserSegment(
          segmentId: 'seg_1',
          name: 'Premium Users',
          description: 'Users with premium subscription',
          rules: {'subscription': 'premium'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(segment.name, equals('Premium Users'));
      });

      test('should track estimated user count', () {
        final segment = UserSegment(
          segmentId: 'seg_2',
          name: 'Beta Testers',
          description: 'Beta testing users',
          rules: {'beta': true},
          estimatedUserCount: 500,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(segment.estimatedUserCount, equals(500));
      });
    });

    // Feature Flag Variant Tests
    group('FeatureFlagVariant', () {
      test('should create variant', () {
        final variant = FeatureFlagVariant(
          variantId: 'var_1',
          name: 'Control',
          description: 'Control variant',
          config: {'type': 'control'},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );
        expect(variant.name, equals('Control'));
      });

      test('should define traffic percentage', () {
        final variant = FeatureFlagVariant(
          variantId: 'var_2',
          name: 'Treatment',
          description: 'Treatment variant',
          config: {'type': 'treatment', 'new_ui': true},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );
        expect(variant.trafficPercentage, equals(50.0));
      });
    });

    // Feature Flag Tests
    group('FeatureFlag', () {
      test('should create feature flag', () {
        final flag = FeatureFlag(
          flagId: 'flag_1',
          name: 'new_ui',
          description: 'New user interface',
          status: FeatureFlagStatus.disabled,
          strategy: RolloutStrategy.gradual,
          config: {'enabled': false},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(flag.name, equals('new_ui'));
        expect(flag.isEnabled, isFalse);
      });

      test('should check if flag is fully rolled out', () {
        final flag = FeatureFlag(
          flagId: 'flag_2',
          name: 'feature_x',
          description: 'Feature X',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(flag.isFullyRolledOut, isTrue);
      });

      test('should track rollout percentage', () {
        final flag = FeatureFlag(
          flagId: 'flag_3',
          name: 'gradual_rollout',
          description: 'Gradual rollout feature',
          status: FeatureFlagStatus.rolling,
          strategy: RolloutStrategy.gradual,
          config: {},
          rolloutPercentage: 25.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(flag.rolloutPercentage, equals(25.0));
        expect(flag.isRolling, isTrue);
      });

      test('should track variants for A/B testing', () {
        final variant1 = FeatureFlagVariant(
          variantId: 'var_a',
          name: 'Control',
          description: 'Control',
          config: {'version': 'v1'},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );
        final variant2 = FeatureFlagVariant(
          variantId: 'var_b',
          name: 'Treatment',
          description: 'Treatment',
          config: {'version': 'v2'},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );

        final flag = FeatureFlag(
          flagId: 'flag_ab_test',
          name: 'ab_test_feature',
          description: 'A/B test feature',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          variants: [variant1, variant2],
          config: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(flag.variants.length, equals(2));
        expect(flag.variants[0].name, equals('Control'));
      });
    });

    // Experiment Config Tests
    group('ExperimentConfig', () {
      test('should create experiment config', () {
        final variant1 = FeatureFlagVariant(
          variantId: 'exp_var_1',
          name: 'Control',
          description: 'Control',
          config: {},
          createdAt: DateTime.now(),
        );

        final config = ExperimentConfig(
          experimentId: 'exp_1',
          flagId: 'flag_exp',
          name: 'Conversion Rate Test',
          description: 'Test new feature impact on conversion',
          variants: [variant1],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 7)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(config.name, equals('Conversion Rate Test'));
        expect(config.isCompleted, isFalse);
      });

      test('should track if experiment is running', () {
        final variant = FeatureFlagVariant(
          variantId: 'var',
          name: 'V1',
          description: 'V1',
          config: {},
          createdAt: DateTime.now(),
        );

        final config = ExperimentConfig(
          experimentId: 'exp_running',
          flagId: 'flag',
          name: 'Running Experiment',
          description: 'Currently running',
          variants: [variant],
          startDate: DateTime.now().subtract(Duration(hours: 1)),
          endDate: DateTime.now().add(Duration(days: 7)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(config.isRunning, isTrue);
      });
    });

    // Experiment Result Tests
    group('ExperimentResult', () {
      test('should track experiment results', () {
        final result = ExperimentResult(
          resultId: 'exp_res_1',
          experimentId: 'exp_1',
          variantId: 'var_1',
          sampleSize: 1000,
          conversions: 150,
          conversionRate: 0.15,
          createdAt: DateTime.now(),
          measuredAt: DateTime.now(),
        );

        expect(result.sampleSize, equals(1000));
        expect(result.conversions, equals(150));
        expect(result.conversionRate, equals(0.15));
      });

      test('should check statistical significance', () {
        final result = ExperimentResult(
          resultId: 'exp_res_2',
          experimentId: 'exp_2',
          variantId: 'var_2',
          sampleSize: 500,
          conversions: 75,
          conversionRate: 0.15,
          confidenceInterval: 0.96,
          createdAt: DateTime.now(),
          measuredAt: DateTime.now(),
        );

        expect(result.isSignificant, isTrue);
      });
    });

    // Feature Flag Event Tests
    group('FeatureFlagEvent', () {
      test('should create event', () {
        final event = FeatureFlagEvent(
          eventId: 'event_1',
          flagId: 'flag_1',
          eventType: 'enabled',
          userId: 'user_1',
          reason: 'Scheduled rollout',
          createdAt: DateTime.now(),
        );

        expect(event.eventType, equals('enabled'));
        expect(event.reason, equals('Scheduled rollout'));
      });
    });

    // Flag Evaluation Tests
    group('FlagEvaluation', () {
      test('should evaluate flag for user', () async {
        final flag = FeatureFlag(
          flagId: 'flag_eval',
          name: 'test_flag',
          description: 'Test flag',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {'enabled': true},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);

        final context = EvaluationContext(
          userId: 'user_eval_1',
          userAttributes: {'plan': 'premium'},
        );

        final result = await manager.evaluateFlag('flag_eval', context);

        expect(result.flagId, equals('flag_eval'));
        expect(result.userId, equals('user_eval_1'));
      });

      test('should evaluate multiple flags', () async {
        final flag1 = FeatureFlag(
          flagId: 'flag_multi_1',
          name: 'feature_1',
          description: 'Feature 1',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final flag2 = FeatureFlag(
          flagId: 'flag_multi_2',
          name: 'feature_2',
          description: 'Feature 2',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag1);
        await manager.createFlag(flag2);

        final context = EvaluationContext(userId: 'user_multi');
        final results = await manager.evaluateFlags(
          ['flag_multi_1', 'flag_multi_2'],
          context,
        );

        expect(results.length, equals(2));
      });
    });

    // Variant Assignment Tests
    group('VariantAssignment', () {
      test('should assign variant consistently', () async {
        final variant1 = FeatureFlagVariant(
          variantId: 'var_consistent_1',
          name: 'Control',
          description: 'Control',
          config: {'version': '1'},
          createdAt: DateTime.now(),
        );

        final flag = FeatureFlag(
          flagId: 'flag_variant_test',
          name: 'variant_test',
          description: 'Variant test',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          variants: [variant1],
          config: {},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);

        final variant1_assigned =
            await manager.assignVariant('flag_variant_test', 'user_consistent');
        final variant2_assigned =
            await manager.assignVariant('flag_variant_test', 'user_consistent');

        expect(variant1_assigned, equals(variant2_assigned));
      });
    });

    // Rollout Tests
    group('Rollout', () {
      test('should start rollout', () async {
        final flag = FeatureFlag(
          flagId: 'flag_rollout',
          name: 'rollout_feature',
          description: 'Rollout feature',
          status: FeatureFlagStatus.disabled,
          strategy: RolloutStrategy.gradual,
          config: {},
          rolloutPercentage: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);
        await manager.startRollout(
          'flag_rollout',
          10.0,
          RolloutStrategy.gradual,
        );

        final updated = await manager.getFlag('flag_rollout');
        expect(updated?.rolloutPercentage, equals(10.0));
        expect(updated?.isRolling, isTrue);
      });

      test('should update rollout percentage', () async {
        final flag = FeatureFlag(
          flagId: 'flag_update_rollout',
          name: 'update_rollout',
          description: 'Update rollout',
          status: FeatureFlagStatus.rolling,
          strategy: RolloutStrategy.gradual,
          config: {},
          rolloutPercentage: 25.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);
        await manager.updateRolloutPercentage('flag_update_rollout', 50.0);

        final updated = await manager.getFlag('flag_update_rollout');
        expect(updated?.rolloutPercentage, equals(50.0));
      });

      test('should track rollout history', () async {
        final history = RolloutHistory(
          historyId: 'hist_1',
          flagId: 'flag_history',
          timestamp: DateTime.now(),
          previousPercentage: 10.0,
          newPercentage: 25.0,
          reason: 'Gradual rollout',
          executedBy: 'user_1',
          createdAt: DateTime.now(),
        );

        await manager.saveRolloutHistory(history);
        final histories = await manager.getRolloutHistory('flag_history');

        expect(histories.length, equals(1));
        expect(histories[0].newPercentage, equals(25.0));
      });
    });

    // Experiment Tests
    group('Experiment', () {
      test('should create experiment', () async {
        final variant = FeatureFlagVariant(
          variantId: 'exp_var',
          name: 'V1',
          description: 'V1',
          config: {},
          createdAt: DateTime.now(),
        );

        final config = ExperimentConfig(
          experimentId: 'exp_create',
          flagId: 'flag_exp',
          name: 'Test Experiment',
          description: 'Test',
          variants: [variant],
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createExperiment(config);
        final retrieved = await manager.getExperiment('exp_create');

        expect(retrieved?.name, equals('Test Experiment'));
      });

      test('should save experiment result', () async {
        final result = ExperimentResult(
          resultId: 'exp_res_save',
          experimentId: 'exp_save',
          variantId: 'var_save',
          sampleSize: 1000,
          conversions: 100,
          conversionRate: 0.10,
          createdAt: DateTime.now(),
          measuredAt: DateTime.now(),
        );

        await manager.saveExperimentResult(result);
        final retrieved = await manager.saveExperimentResult(result);

        expect(result.sampleSize, equals(1000));
      });
    });

    // Metrics Tests
    group('FeatureFlagMetrics', () {
      test('should track flag metrics', () {
        final metrics = FeatureFlagMetrics(
          metricsId: 'metrics_1',
          flagId: 'flag_1',
          totalUsers: 10000,
          enabledUsers: 2500,
          disabledUsers: 7500,
          enabledPercentage: 25.0,
          evaluationCount: 50000,
          measuredAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(metrics.enabledRatePercent, equals(25.0));
      });
    });

    // Evaluation Context Tests
    group('EvaluationContext', () {
      test('should create evaluation context', () {
        final context = EvaluationContext(
          userId: 'user_ctx',
          userAttributes: {'plan': 'premium', 'country': 'US'},
          environment: {'version': '1.0.0'},
        );

        expect(context.userId, equals('user_ctx'));
        expect(context.userAttributes?['plan'], equals('premium'));
      });

      test('should support forced variant', () {
        final context = EvaluationContext(
          userId: 'user_forced',
          forcedVariantId: 'var_forced',
        );

        expect(context.forcedVariantId, equals('var_forced'));
      });
    });

    // Report Tests
    group('FeatureFlagReport', () {
      test('should generate report', () {
        final flag = FeatureFlag(
          flagId: 'flag_report',
          name: 'report_flag',
          description: 'Report flag',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final report = FeatureFlagReport(
          reportId: 'report_1',
          generatedAt: DateTime.now(),
          flags: [flag],
          summary: '# Feature Flag Report',
        );

        expect(report.flags.length, equals(1));
        expect(report.flags[0].name, equals('report_flag'));
      });

      test('should export report to markdown', () {
        final flag = FeatureFlag(
          flagId: 'flag_md',
          name: 'markdown_flag',
          description: 'Markdown flag',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          config: {},
          rolloutPercentage: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final report = FeatureFlagReport(
          reportId: 'report_md',
          generatedAt: DateTime.now(),
          flags: [flag],
          summary: 'Test report',
        );

        final markdown = report.toMarkdown();
        expect(markdown, contains('Feature Flag Report'));
        expect(markdown, contains('Total Flags: 1'));
      });
    });

    // Segment Tests
    group('UserSegment', () {
      test('should create and retrieve segment', () async {
        final segment = UserSegment(
          segmentId: 'seg_create',
          name: 'Test Segment',
          description: 'Test',
          rules: {'test': true},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createSegment(segment);
        final retrieved = await manager.getSegment('seg_create');

        expect(retrieved?.name, equals('Test Segment'));
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('should complete full feature flag workflow', () async {
        // Create flag
        final flag = FeatureFlag(
          flagId: 'flag_workflow',
          name: 'new_feature',
          description: 'New feature',
          status: FeatureFlagStatus.disabled,
          strategy: RolloutStrategy.gradual,
          config: {'enabled': false},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);

        // Start rollout
        await manager.startRollout('flag_workflow', 10.0, RolloutStrategy.gradual);

        // Evaluate flag
        final context = EvaluationContext(userId: 'user_workflow');
        final result = await manager.evaluateFlag('flag_workflow', context);

        expect(result.flagId, equals('flag_workflow'));
        expect(result.userId, equals('user_workflow'));
      });

      test('should complete A/B testing workflow', () async {
        final control = FeatureFlagVariant(
          variantId: 'var_control',
          name: 'Control',
          description: 'Control',
          config: {'ui': 'old'},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );

        final treatment = FeatureFlagVariant(
          variantId: 'var_treatment',
          name: 'Treatment',
          description: 'Treatment',
          config: {'ui': 'new'},
          trafficPercentage: 50.0,
          createdAt: DateTime.now(),
        );

        final flag = FeatureFlag(
          flagId: 'flag_ab',
          name: 'ab_test',
          description: 'A/B test',
          status: FeatureFlagStatus.enabled,
          strategy: RolloutStrategy.immediate,
          variants: [control, treatment],
          config: {},
          rolloutPercentage: 100.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.createFlag(flag);

        final result = ExperimentResult(
          resultId: 'result_ab',
          experimentId: 'exp_ab',
          variantId: 'var_control',
          sampleSize: 500,
          conversions: 75,
          conversionRate: 0.15,
          createdAt: DateTime.now(),
          measuredAt: DateTime.now(),
        );

        await manager.saveExperimentResult(result);

        expect(result.sampleSize, equals(500));
        expect(result.conversionRate, equals(0.15));
      });
    });
  });
}
