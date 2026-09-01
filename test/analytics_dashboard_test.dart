import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/community_model.dart';
import 'package:bike_license_kore/services/community_service.dart';

void main() {
  late CommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('StudentAnalyticsDashboard', () {
    test('creates dashboard with all metrics', () {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_001',
        studentId: 'student_001',
        overallScore: 85.5,
        learningVelocity: 2.5,
        totalQuestionsAttempted: 150,
        correctAnswers: 128,
        currentAccuracy: 85.33,
        totalStudyTimeMinutes: 450,
        consistencyDaysStreak: 15,
        totalSessionsCompleted: 25,
        categoryPerformances: [
          CategoryPerformance(
            category: 'road-signs',
            accuracy: 90.0,
            questionsAttempted: 30,
            correctAnswers: 27,
            timeSpentMinutes: 90,
            trend: TrendDirection.improving,
            trendPercentage: 5.0,
          ),
        ],
        weakAreas: [],
        strengths: [
          StrengthArea(
            category: 'road-signs',
            accuracy: 90.0,
            questionsMastered: 27,
            achievedAt: DateTime.now(),
            consistencyScore: 0.95,
          ),
        ],
        daysActive: 20,
        materialsCompleted: 12,
        engagementScore: 88.5,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dashboard.id, 'dash_001');
      expect(dashboard.studentId, 'student_001');
      expect(dashboard.overallScore, 85.5);
      expect(dashboard.isHighPerformer, true);
      expect(dashboard.needsSupport, false);
    });

    test('identifies high performers (score >= 85)', () {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_001',
        studentId: 'student_001',
        overallScore: 85.0,
        learningVelocity: 2.5,
        totalQuestionsAttempted: 150,
        correctAnswers: 128,
        currentAccuracy: 85.33,
        totalStudyTimeMinutes: 450,
        consistencyDaysStreak: 15,
        totalSessionsCompleted: 25,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 20,
        materialsCompleted: 12,
        engagementScore: 88.5,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dashboard.isHighPerformer, true);
    });

    test('identifies students needing support (score < 60)', () {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_002',
        studentId: 'student_002',
        overallScore: 55.0,
        learningVelocity: 1.0,
        totalQuestionsAttempted: 100,
        correctAnswers: 55,
        currentAccuracy: 55.0,
        totalStudyTimeMinutes: 300,
        consistencyDaysStreak: 5,
        totalSessionsCompleted: 10,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 10,
        materialsCompleted: 3,
        engagementScore: 45.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dashboard.needsSupport, true);
    });

    test('identifies consistent learners (streak >= 10 days)', () {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_003',
        studentId: 'student_003',
        overallScore: 75.0,
        learningVelocity: 2.0,
        totalQuestionsAttempted: 120,
        correctAnswers: 90,
        currentAccuracy: 75.0,
        totalStudyTimeMinutes: 400,
        consistencyDaysStreak: 10,
        totalSessionsCompleted: 20,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 15,
        materialsCompleted: 8,
        engagementScore: 80.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dashboard.isConsistent, true);
    });

    test('serializes and deserializes correctly', () {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_001',
        studentId: 'student_001',
        overallScore: 85.5,
        learningVelocity: 2.5,
        totalQuestionsAttempted: 150,
        correctAnswers: 128,
        currentAccuracy: 85.33,
        totalStudyTimeMinutes: 450,
        consistencyDaysStreak: 15,
        totalSessionsCompleted: 25,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 20,
        materialsCompleted: 12,
        engagementScore: 88.5,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = dashboard.toMap();
      final reconstructed = StudentAnalyticsDashboard.fromMap(map);

      expect(reconstructed.id, dashboard.id);
      expect(reconstructed.studentId, dashboard.studentId);
      expect(reconstructed.overallScore, dashboard.overallScore);
      expect(reconstructed.currentAccuracy, dashboard.currentAccuracy);
    });
  });

  group('CategoryPerformance', () {
    test('tracks accuracy and trends by category', () {
      final performance = CategoryPerformance(
        category: 'road-signs',
        accuracy: 90.0,
        questionsAttempted: 30,
        correctAnswers: 27,
        timeSpentMinutes: 90,
        trend: TrendDirection.improving,
        trendPercentage: 5.0,
      );

      expect(performance.category, 'road-signs');
      expect(performance.accuracy, 90.0);
      expect(performance.questionsAttempted, 30);
      expect(performance.trend, TrendDirection.improving);
    });

    test('detects stable performance', () {
      final performance = CategoryPerformance(
        category: 'traffic-rules',
        accuracy: 75.0,
        questionsAttempted: 20,
        correctAnswers: 15,
        timeSpentMinutes: 60,
        trend: TrendDirection.stable,
        trendPercentage: 0.0,
      );

      expect(performance.trend, TrendDirection.stable);
    });
  });

  group('WeakAreaMetric', () {
    test('tracks weak area with improvement metrics', () {
      final weakArea = WeakAreaMetric(
        category: 'vehicle-handling',
        currentAccuracy: 45.0,
        attemptCount: 20,
        improvementRate: 2.5,
        firstIdentifiedAt: DateTime.now().subtract(const Duration(days: 10)),
        lastAttemptAt: DateTime.now(),
        recommendedReviewCount: 5,
        suggestedTopics: ['tire-pressure', 'braking', 'cornering'],
      );

      expect(weakArea.category, 'vehicle-handling');
      expect(weakArea.currentAccuracy, 45.0);
      expect(weakArea.needsImmediate, true);
      expect(weakArea.improving, true);
    });

    test('identifies severe weak areas (< 40% accuracy)', () {
      final weakArea = WeakAreaMetric(
        category: 'emergency-procedures',
        currentAccuracy: 35.0,
        attemptCount: 15,
        improvementRate: 1.0,
        firstIdentifiedAt: DateTime.now().subtract(const Duration(days: 14)),
        lastAttemptAt: DateTime.now(),
        recommendedReviewCount: 8,
        suggestedTopics: ['accident-response', 'first-aid'],
      );

      expect(weakArea.needsImmediate, true);
    });
  });

  group('PerformanceTrendAnalysis', () {
    test('creates trend analysis with time-series data', () async {
      final trend = PerformanceTrendAnalysis(
        id: 'trend_001',
        studentId: 'student_001',
        metricType: 'accuracy',
        dataPoints: [
          TrendDataPoint(date: DateTime.now().subtract(const Duration(days: 7)), value: 70.0, sampleSize: 10),
          TrendDataPoint(date: DateTime.now().subtract(const Duration(days: 6)), value: 72.0, sampleSize: 12),
          TrendDataPoint(date: DateTime.now().subtract(const Duration(days: 5)), value: 75.0, sampleSize: 15),
          TrendDataPoint(date: DateTime.now(), value: 78.0, sampleSize: 18),
        ],
        overallTrend: TrendDirection.improving,
        percentageChange: 11.4,
        daysPeriod: 7,
        createdAt: DateTime.now(),
      );

      expect(trend.dataPoints.length, 4);
      expect(trend.isImproving, true);
      expect(trend.percentageChange, 11.4);
      expect(trend.overallTrend, TrendDirection.improving);
    });

    test('tracks declining trends', () {
      final trend = PerformanceTrendAnalysis(
        id: 'trend_002',
        studentId: 'student_002',
        metricType: 'engagement',
        dataPoints: [
          TrendDataPoint(date: DateTime.now().subtract(const Duration(days: 3)), value: 85.0, sampleSize: 20),
          TrendDataPoint(date: DateTime.now(), value: 78.0, sampleSize: 15),
        ],
        overallTrend: TrendDirection.declining,
        percentageChange: -8.2,
        daysPeriod: 3,
        createdAt: DateTime.now(),
      );

      expect(trend.isImproving, false);
      expect(trend.percentageChange, -8.2);
    });
  });

  group('StudentInsights', () {
    test('generates personalized insights', () {
      final insights = StudentInsights(
        id: 'insights_001',
        studentId: 'student_001',
        insights: [
          Insight(
            title: 'Strong Road Signs Knowledge',
            description: 'You consistently perform well on road signs questions',
            type: InsightType.strength,
            confidence: 0.95,
            relatedCategories: ['road-signs'],
            createdAt: DateTime.now(),
          ),
          Insight(
            title: 'Vehicle Handling Needs Practice',
            description: 'Focus on tire pressure and braking techniques',
            type: InsightType.weakness,
            confidence: 0.85,
            relatedCategories: ['vehicle-handling'],
            createdAt: DateTime.now(),
          ),
        ],
        actionItems: [
          'Practice vehicle handling questions daily',
          'Review tire pressure management concepts',
          'Take more timed practice tests',
        ],
        overallAssessment: 'Good foundation with room for improvement',
        generatedAt: DateTime.now(),
        nextReviewAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(insights.insights.length, 2);
      expect(insights.actionItems.length, 3);
      expect(insights.insights[0].type, InsightType.strength);
      expect(insights.insights[1].type, InsightType.weakness);
    });

    test('serializes insights correctly', () {
      final insights = StudentInsights(
        id: 'insights_001',
        studentId: 'student_001',
        insights: [
          Insight(
            title: 'Improvement Notice',
            description: 'Your accuracy has improved 5%',
            type: InsightType.trend,
            confidence: 0.8,
            relatedCategories: ['all'],
            createdAt: DateTime.now(),
          ),
        ],
        actionItems: ['Continue current study pace'],
        overallAssessment: 'On track',
        generatedAt: DateTime.now(),
      );

      final map = insights.toMap();
      final reconstructed = StudentInsights.fromMap(map);

      expect(reconstructed.insights.length, 1);
      expect(reconstructed.actionItems.length, 1);
    });
  });

  group('LearningPathRecommendation', () {
    test('creates personalized learning recommendations', () {
      final recommendation = LearningPathRecommendation(
        id: 'rec_001',
        studentId: 'student_001',
        type: RecommendationType.focusArea,
        title: 'Master Vehicle Handling',
        description: 'You need to improve your vehicle handling skills',
        suggestedMaterials: ['material_012', 'material_013', 'material_014'],
        suggestedQuestions: ['q_vh_001', 'q_vh_002', 'q_vh_003'],
        estimatedMinutes: 120,
        priority: 0.8,
        accepted: false,
        createdAt: DateTime.now(),
      );

      expect(recommendation.type, RecommendationType.focusArea);
      expect(recommendation.isPending, true);
      expect(recommendation.isHighPriority, true);
      expect(recommendation.suggestedMaterials.length, 3);
    });

    test('tracks recommendation completion', () {
      final recommendation = LearningPathRecommendation(
        id: 'rec_002',
        studentId: 'student_002',
        type: RecommendationType.reviewConcept,
        title: 'Review Traffic Rules',
        description: 'Quick review session',
        suggestedMaterials: ['material_004'],
        suggestedQuestions: ['q_tr_001', 'q_tr_002'],
        estimatedMinutes: 45,
        priority: 0.6,
        accepted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now(),
      );

      expect(recommendation.accepted, true);
      expect(recommendation.completedAt, isNotNull);
      expect(recommendation.isPending, false);
    });
  });

  group('ProgressMilestone', () {
    test('records achievement milestones', () {
      final milestone = ProgressMilestone(
        id: 'mile_001',
        studentId: 'student_001',
        title: 'Road Signs Mastery',
        description: 'Achieved 90% accuracy on all road signs questions',
        accuracyThreshold: 90.0,
        questionsRequired: 30,
        achievedAt: DateTime.now(),
        category: 'road-signs',
        isCertified: true,
      );

      expect(milestone.title, 'Road Signs Mastery');
      expect(milestone.accuracyThreshold, 90.0);
      expect(milestone.isCertified, true);
    });

    test('tracks uncertified progress', () {
      final milestone = ProgressMilestone(
        id: 'mile_002',
        studentId: 'student_002',
        title: 'Foundation Complete',
        description: 'Completed basic vehicle handling course',
        accuracyThreshold: 70.0,
        questionsRequired: 50,
        achievedAt: DateTime.now(),
        category: 'vehicle-handling',
        isCertified: false,
      );

      expect(milestone.isCertified, false);
    });
  });

  group('PeerBenchmark', () {
    test('calculates peer comparison metrics', () {
      final benchmark = PeerBenchmark(
        id: 'bench_001',
        studentId: 'student_001',
        metricType: 'accuracy',
        studentValue: 85.0,
        cohortMedian: 72.0,
        cohortMean: 70.5,
        percentile: 78.0,
        cohortSize: 150,
        calculatedAt: DateTime.now(),
      );

      expect(benchmark.isAboveAverage, true);
      expect(benchmark.isAboveMedian, true);
      expect(benchmark.percentile, 78.0);
    });

    test('identifies below-average performance', () {
      final benchmark = PeerBenchmark(
        id: 'bench_002',
        studentId: 'student_002',
        metricType: 'speed',
        studentValue: 65.0,
        cohortMedian: 75.0,
        cohortMean: 76.5,
        percentile: 25.0,
        cohortSize: 200,
        calculatedAt: DateTime.now(),
      );

      expect(benchmark.isAboveAverage, false);
      expect(benchmark.isAboveMedian, false);
    });
  });

  group('CommunityService Analytics Operations', () {
    test('creates and retrieves analytics dashboard', () async {
      final dashboard = StudentAnalyticsDashboard(
        id: 'dash_001',
        studentId: 'student_001',
        overallScore: 80.0,
        learningVelocity: 2.0,
        totalQuestionsAttempted: 100,
        correctAnswers: 80,
        currentAccuracy: 80.0,
        totalStudyTimeMinutes: 300,
        consistencyDaysStreak: 10,
        totalSessionsCompleted: 15,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 15,
        materialsCompleted: 5,
        engagementScore: 80.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await service.upsertStudentAnalyticsDashboard(dashboard);
      final retrieved = await service.getStudentAnalyticsDashboard('student_001');

      expect(id, 'dash_001');
      expect(retrieved, isNotNull);
      expect(retrieved?.studentId, 'student_001');
      expect(retrieved?.overallScore, 80.0);
    });

    test('creates performance trends', () async {
      final trend = PerformanceTrendAnalysis(
        id: 'trend_001',
        studentId: 'student_001',
        metricType: 'accuracy',
        dataPoints: [
          TrendDataPoint(date: DateTime.now(), value: 75.0, sampleSize: 10),
        ],
        overallTrend: TrendDirection.improving,
        percentageChange: 5.0,
        daysPeriod: 7,
        createdAt: DateTime.now(),
      );

      final id = await service.createPerformanceTrend(trend);
      final retrieved = await service.getPerformanceTrend(
        studentId: 'student_001',
        metricType: 'accuracy',
        daysPeriod: 7,
      );

      expect(id, 'trend_001');
      expect(retrieved, isNotNull);
      expect(retrieved?.overallTrend, TrendDirection.improving);
    });

    test('generates student insights', () async {
      final insightsId = await service.generateStudentInsights('student_001');
      final insights = await service.getStudentInsights('student_001');

      expect(insightsId, isNotEmpty);
      expect(insights, isNotNull);
      expect(insights?.studentId, 'student_001');
      expect(insights?.insights.isNotEmpty, true);
    });

    test('creates and manages learning recommendations', () async {
      final recommendation = LearningPathRecommendation(
        id: 'rec_001',
        studentId: 'student_001',
        type: RecommendationType.focusArea,
        title: 'Focus on Weak Areas',
        description: 'Review vehicle handling concepts',
        suggestedMaterials: ['material_012'],
        suggestedQuestions: ['q_vh_001'],
        estimatedMinutes: 60,
        priority: 0.7,
        accepted: false,
        createdAt: DateTime.now(),
      );

      final id = await service.createLearningPathRecommendation(recommendation);
      final pending = await service.getPendingRecommendations('student_001');

      expect(id, 'rec_001');
      expect(pending.length, 1);
      expect(pending[0].accepted, false);

      await service.acceptLearningRecommendation('rec_001');
      final afterAccept = await service.getPendingRecommendations('student_001');

      expect(afterAccept.isEmpty, false);
    });

    test('records and retrieves progress milestones', () async {
      final milestone = ProgressMilestone(
        id: 'mile_001',
        studentId: 'student_001',
        title: 'First Milestone',
        description: 'Completed first course',
        accuracyThreshold: 70.0,
        questionsRequired: 30,
        achievedAt: DateTime.now(),
        category: 'road-signs',
        isCertified: true,
      );

      final id = await service.recordProgressMilestone(milestone);
      final milestones = await service.getStudentMilestones('student_001');

      expect(id, 'mile_001');
      expect(milestones.length, 1);
      expect(milestones[0].title, 'First Milestone');
    });

    test('calculates peer benchmarks', () async {
      final id = await service.calculatePeerBenchmark(
        studentId: 'student_001',
        metricType: 'accuracy',
        cohortSize: 150,
      );

      final benchmark = await service.getPeerBenchmark(
        studentId: 'student_001',
        metricType: 'accuracy',
      );

      expect(id, isNotEmpty);
      expect(benchmark, isNotNull);
      expect(benchmark?.cohortSize, 150);
    });

    test('identifies students needing intervention', () async {
      final lowDashboard = StudentAnalyticsDashboard(
        id: 'dash_low',
        studentId: 'student_low',
        overallScore: 45.0,
        learningVelocity: 0.5,
        totalQuestionsAttempted: 50,
        correctAnswers: 22,
        currentAccuracy: 44.0,
        totalStudyTimeMinutes: 100,
        consistencyDaysStreak: 2,
        totalSessionsCompleted: 5,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 5,
        materialsCompleted: 1,
        engagementScore: 30.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.upsertStudentAnalyticsDashboard(lowDashboard);

      final needingIntervention = await service.getStudentsNeedingIntervention(
        institutionId: 'inst_001',
        accuracyThreshold: 60.0,
      );

      expect(needingIntervention.length, greaterThan(0));
      expect(needingIntervention[0].currentAccuracy, lessThan(60.0));
    });

    test('calculates cohort statistics', () async {
      final dashboard1 = StudentAnalyticsDashboard(
        id: 'dash_1',
        studentId: 'student_1',
        overallScore: 80.0,
        learningVelocity: 2.0,
        totalQuestionsAttempted: 100,
        correctAnswers: 80,
        currentAccuracy: 80.0,
        totalStudyTimeMinutes: 300,
        consistencyDaysStreak: 10,
        totalSessionsCompleted: 15,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 15,
        materialsCompleted: 5,
        engagementScore: 80.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dashboard2 = StudentAnalyticsDashboard(
        id: 'dash_2',
        studentId: 'student_2',
        overallScore: 70.0,
        learningVelocity: 1.5,
        totalQuestionsAttempted: 80,
        correctAnswers: 56,
        currentAccuracy: 70.0,
        totalStudyTimeMinutes: 250,
        consistencyDaysStreak: 8,
        totalSessionsCompleted: 12,
        categoryPerformances: [],
        weakAreas: [],
        strengths: [],
        daysActive: 12,
        materialsCompleted: 4,
        engagementScore: 70.0,
        lastActivityAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.upsertStudentAnalyticsDashboard(dashboard1);
      await service.upsertStudentAnalyticsDashboard(dashboard2);

      final stats = await service.calculateCohortStatistics(['student_1', 'student_2']);

      expect(stats['totalStudents'], 2);
      expect(stats['averageAccuracy'], 75.0);
      expect(stats['medianScore'], greaterThan(0));
    });
  });

  group('Enum Parsing', () {
    test('parses TrendDirection correctly', () {
      expect(_parseTrendDirection('improving'), TrendDirection.improving);
      expect(_parseTrendDirection('declining'), TrendDirection.declining);
      expect(_parseTrendDirection('stable'), TrendDirection.stable);
      expect(_parseTrendDirection('invalid'), TrendDirection.stable); // default
    });

    test('parses InsightType correctly', () {
      expect(_parseInsightType('strength'), InsightType.strength);
      expect(_parseInsightType('weakness'), InsightType.weakness);
      expect(_parseInsightType('recommendation'), InsightType.recommendation);
      expect(_parseInsightType('invalid'), InsightType.recommendation); // default
    });

    test('parses RecommendationType correctly', () {
      expect(_parseRecommendationType('focusArea'), RecommendationType.focusArea);
      expect(_parseRecommendationType('practiceMore'), RecommendationType.practiceMore);
      expect(_parseRecommendationType('invalid'), RecommendationType.focusArea); // default
    });
  });
}
