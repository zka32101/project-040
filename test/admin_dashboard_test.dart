import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('DashboardWidget', () {
    test('should initialize dashboard widget', () {
      final widget = DashboardWidget(
        widgetId: 'widget_1',
        title: 'Revenue',
        description: 'Monthly revenue metrics',
        metricType: DashboardMetricType.revenue,
        currentValue: '¥500,000',
        previousValue: '¥450,000',
        percentChange: 11.1,
        trend: 'up',
      );

      expect(widget.title, 'Revenue');
      expect(widget.metricType, DashboardMetricType.revenue);
      expect(widget.isPositiveChange, true);
    });

    test('should detect negative change', () {
      final widget = DashboardWidget(
        widgetId: 'widget_1',
        title: 'Engagement',
        description: 'Student engagement',
        metricType: DashboardMetricType.engagement,
        currentValue: 75,
        previousValue: 80,
        percentChange: -6.25,
      );

      expect(widget.isPositiveChange, false);
    });
  });

  group('StudentProgressWidget', () {
    test('should initialize student progress widget', () {
      final widget = StudentProgressWidget(
        studentId: 'student_1',
        studentName: 'Taro Yamada',
        overallAccuracy: 0.85,
        status: StudentPerformanceStatus.good,
        currentStreak: 5,
        longestStreak: 10,
        readinessProbability: 0.78,
        questionsAnsweredThisWeek: 45,
        averageTimePerQuestion: 42.5,
        lastActivityAt: DateTime.now(),
      );

      expect(widget.studentName, 'Taro Yamada');
      expect(widget.status, StudentPerformanceStatus.good);
      expect(widget.isActive, true);
    });

    test('should detect inactive student', () {
      final inactiveDate = DateTime.now().subtract(Duration(days: 10));
      final widget = StudentProgressWidget(
        studentId: 'student_1',
        studentName: 'Inactive Student',
        overallAccuracy: 0.65,
        status: StudentPerformanceStatus.atRisk,
        currentStreak: 0,
        longestStreak: 3,
        readinessProbability: 0.55,
        questionsAnsweredThisWeek: 0,
        averageTimePerQuestion: 50.0,
        lastActivityAt: inactiveDate,
      );

      expect(widget.isActive, false);
    });
  });

  group('StudentEngagementMetrics', () {
    test('should initialize engagement metrics', () {
      final metrics = StudentEngagementMetrics(
        studentId: 'student_1',
        minutesStudiedThisWeek: 240,
        minutesStudiedThisMonth: 900,
        sessionsThisWeek: 12,
        currentConsecutiveDays: 7,
        weeklyConsistencyScore: 95.0,
        averageSessionDuration: 20,
        recentBadgesEarned: ['sevenStreak', 'eightyPercent'],
        totalXPEarnedThisMonth: 2500,
      );

      expect(metrics.minutesStudiedThisWeek, 240);
      expect(metrics.weeklyConsistencyScore, 95.0);
      expect(metrics.recentBadgesEarned.length, 2);
    });

    test('should track session frequency', () {
      final metrics = StudentEngagementMetrics(
        studentId: 'student_1',
        minutesStudiedThisWeek: 100,
        minutesStudiedThisMonth: 400,
        sessionsThisWeek: 5,
        currentConsecutiveDays: 3,
        weeklyConsistencyScore: 60.0,
        averageSessionDuration: 20,
        recentBadgesEarned: [],
        totalXPEarnedThisMonth: 800,
      );

      expect(metrics.sessionsThisWeek, 5);
      expect(metrics.averageSessionDuration, 20);
    });
  });

  group('CategoryPerformanceChart', () {
    test('should initialize category performance', () {
      final chart = CategoryPerformanceChart(
        category: '交通規則',
        accuracy: 0.88,
        questionsAnswered: 250,
        trend: 0.08,
        averageTimePerQuestion: 42.0,
        weakestTopic: '信号機の見方',
      );

      expect(chart.category, '交通規則');
      expect(chart.accuracy, 0.88);
      expect(chart.trend, greaterThan(0));
    });

    test('should track declining performance', () {
      final chart = CategoryPerformanceChart(
        category: '危機回避',
        accuracy: 0.65,
        questionsAnswered: 180,
        trend: -0.10,
        averageTimePerQuestion: 55.0,
      );

      expect(chart.trend, lessThan(0));
    });
  });

  group('InstructorDashboard', () {
    test('should initialize empty instructor dashboard', () {
      final dashboard = InstructorDashboard.empty(
        dashboardId: 'dash_1',
        instructorId: 'instr_1',
        partnershipId: 'p_1',
        instructorName: 'Hanako Tanaka',
      );

      expect(dashboard.instructorName, 'Hanako Tanaka');
      expect(dashboard.assignedStudentIds.isEmpty, true);
      expect(dashboard.totalStudentsAssigned, 0);
    });

    test('should calculate at-risk student count', () {
      final dashboard = InstructorDashboard(
        dashboardId: 'dash_1',
        instructorId: 'instr_1',
        partnershipId: 'p_1',
        instructorName: 'Test Instructor',
        assignedStudentIds: ['s1', 's2', 's3'],
        widgets: [],
        studentSnapshots: [
          StudentProgressWidget(
            studentId: 's1',
            studentName: 'Student 1',
            overallAccuracy: 0.85,
            status: StudentPerformanceStatus.excellent,
            currentStreak: 10,
            longestStreak: 10,
            readinessProbability: 0.90,
            questionsAnsweredThisWeek: 50,
            averageTimePerQuestion: 40.0,
          ),
          StudentProgressWidget(
            studentId: 's2',
            studentName: 'Student 2',
            overallAccuracy: 0.50,
            status: StudentPerformanceStatus.atRisk,
            currentStreak: 0,
            longestStreak: 3,
            readinessProbability: 0.45,
            questionsAnsweredThisWeek: 10,
            averageTimePerQuestion: 60.0,
          ),
          StudentProgressWidget(
            studentId: 's3',
            studentName: 'Student 3',
            overallAccuracy: 0.35,
            status: StudentPerformanceStatus.critical,
            currentStreak: 0,
            longestStreak: 1,
            readinessProbability: 0.20,
            questionsAnsweredThisWeek: 0,
            averageTimePerQuestion: 70.0,
          ),
        ],
        categoryBreakdown: {},
        totalStudentsAssigned: 3,
        activeStudentsThisWeek: 1,
        classAverageAccuracy: 0.57,
        classAverageReadiness: 0.52,
      );

      expect(dashboard.atRiskStudentCount, 2);
      expect(dashboard.engagementRate, closeTo(33.33, 0.1));
    });
  });

  group('AdminDashboard', () {
    test('should initialize empty admin dashboard', () {
      final dashboard = AdminDashboard.empty(
        dashboardId: 'admin_dash_1',
        partnershipId: 'p_1',
        schoolName: 'Test Driving School',
      );

      expect(dashboard.schoolName, 'Test Driving School');
      expect(dashboard.totalEnrolledStudents, 0);
      expect(dashboard.widgets.isEmpty, true);
    });

    test('should calculate student retention rate', () {
      final dashboard = AdminDashboard(
        dashboardId: 'admin_dash_1',
        partnershipId: 'p_1',
        schoolName: 'Test School',
        widgets: [],
        financialMetrics: {},
        topPerformers: [],
        atRiskStudents: [],
        schoolWideCategoryPerformance: {},
        totalEnrolledStudents: 100,
        activeStudentsThisMonth: 85,
        overallCompletionRate: 0.82,
        overallReadinessProbability: 0.78,
        monthlyRevenueJPY: 25000.0,
        seatUtilizationPercent: 85.0,
        recentInstructorActivity: [],
      );

      expect(dashboard.studentRetentionRate, 85.0);
      expect(dashboard.criticalAtRiskCount, 0);
    });

    test('should count critical at-risk students', () {
      final dashboard = AdminDashboard(
        dashboardId: 'admin_dash_1',
        partnershipId: 'p_1',
        schoolName: 'Test School',
        widgets: [],
        financialMetrics: {},
        topPerformers: [],
        atRiskStudents: [
          StudentProgressWidget(
            studentId: 's1',
            studentName: 'Critical Student',
            overallAccuracy: 0.25,
            status: StudentPerformanceStatus.critical,
            currentStreak: 0,
            longestStreak: 0,
            readinessProbability: 0.10,
            questionsAnsweredThisWeek: 0,
            averageTimePerQuestion: 80.0,
          ),
          StudentProgressWidget(
            studentId: 's2',
            studentName: 'At Risk Student',
            overallAccuracy: 0.50,
            status: StudentPerformanceStatus.atRisk,
            currentStreak: 0,
            longestStreak: 2,
            readinessProbability: 0.40,
            questionsAnsweredThisWeek: 5,
            averageTimePerQuestion: 65.0,
          ),
        ],
        schoolWideCategoryPerformance: {},
        totalEnrolledStudents: 50,
        activeStudentsThisMonth: 40,
        overallCompletionRate: 0.70,
        overallReadinessProbability: 0.65,
        monthlyRevenueJPY: 25000.0,
        seatUtilizationPercent: 80.0,
        recentInstructorActivity: [],
      );

      expect(dashboard.criticalAtRiskCount, 1);
    });
  });

  group('CustomReport', () {
    test('should create performance report', () {
      final report = CustomReport(
        reportId: 'report_1',
        partnershipId: 'p_1',
        reportName: 'Monthly Performance Report',
        reportType: ReportType.performance,
        generatedAt: DateTime.now(),
        reportData: {
          'totalStudents': 50,
          'averageAccuracy': 0.78,
          'passRate': 0.85,
        },
        generatedByUserName: 'Admin User',
        fileFormat: 'pdf',
      );

      expect(report.reportName, 'Monthly Performance Report');
      expect(report.reportType, ReportType.performance);
      expect(report.fileFormat, 'pdf');
    });

    test('should track report sharing', () {
      final report = CustomReport(
        reportId: 'report_1',
        partnershipId: 'p_1',
        reportName: 'Engagement Report',
        reportType: ReportType.engagement,
        generatedAt: DateTime.now(),
        reportData: {},
        isPubliclyShared: false,
        sharedWithEmails: ['instructor@school.jp', 'admin@school.jp'],
      );

      expect(report.sharedWithEmails, isNotNull);
      expect(report.sharedWithEmails!.length, 2);
    });
  });

  group('InstructorDashboardGeneration', () {
    test('should generate instructor dashboard', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      final dashboard = await service.generateInstructorDashboard(
        instructorId: 'instr_1',
        partnershipId: 'school_1',
      );

      expect(dashboard, isNotNull);
      expect(dashboard!.instructorId, 'instr_1');
      expect(dashboard.widgets.isNotEmpty, true);
    });

    test('should retrieve generated instructor dashboard', () async {
      await service.generateInstructorDashboard(
        instructorId: 'instr_1',
        partnershipId: 'p_1',
      );

      final retrieved = await service.getInstructorDashboard('instr_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.instructorId, 'instr_1');
    });
  });

  group('AdminDashboardGeneration', () {
    test('should generate admin dashboard', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test Driving School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      final dashboard = await service.generateAdminDashboard(
        partnershipId: 'school_1',
      );

      expect(dashboard, isNotNull);
      expect(dashboard!.partnershipId, 'school_1');
      expect(dashboard.widgets.isNotEmpty, true);
    });

    test('should retrieve admin dashboard', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.generateAdminDashboard(partnershipId: 'school_1');
      final retrieved = await service.getAdminDashboard('school_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.schoolName, 'Test School');
    });

    test('should calculate financial metrics', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Professional School',
        contactEmail: 'pro@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      final dashboard = await service.generateAdminDashboard(
        partnershipId: 'school_1',
      );

      expect(dashboard!.financialMetrics, isNotEmpty);
      expect(dashboard.financialMetrics['annualCostJPY'], 800000);
      expect(dashboard.financialMetrics['monthlyCost'], 800000 / 12);
    });
  });

  group('StudentProgressTracking', () {
    test('should get student progress widget', () async {
      final widget = await service.getStudentProgressWidget(
        studentId: 'student_1',
        partnershipId: 'p_1',
      );

      // May be null if not created yet
      expect(widget == null || widget is StudentProgressWidget, true);
    });

    test('should get class student progress', () async {
      final progress = await service.getClassStudentProgress(
        instructorId: 'instr_1',
        partnershipId: 'p_1',
      );

      expect(progress, isList);
    });

    test('should get student engagement metrics', () async {
      final metrics = await service.getStudentEngagementMetrics('student_1');

      // May be null if not created yet
      expect(metrics == null || metrics is StudentEngagementMetrics, true);
    });
  });

  group('AtRiskStudentDetection', () {
    test('should identify at-risk students', () async {
      final atRiskStudents = await service.getAtRiskStudents(
        partnershipId: 'p_1',
      );

      expect(atRiskStudents, isList);
    });

    test('should get top performers', () async {
      final topPerformers = await service.getTopPerformers(
        partnershipId: 'p_1',
        limit: 10,
      );

      expect(topPerformers, isList);
      expect(topPerformers.length, lessThanOrEqualTo(10));
    });
  });

  group('CategoryPerformanceAnalytics', () {
    test('should get category performance', () async {
      final performance = await service.getCategoryPerformance(
        partnershipId: 'p_1',
      );

      expect(performance, isNotEmpty);
      expect(performance.containsKey('交通規則'), true);
      expect(performance.containsKey('危機回避'), true);
    });

    test('should track category-specific trends', () async {
      final performance = await service.getCategoryPerformance(
        partnershipId: 'p_1',
      );

      final trafficRules = performance['交通規則'];
      expect(trafficRules!.accuracy, greaterThan(0.7));
      expect(trafficRules.trend, isNotNull);
    });
  });

  group('CustomReportGeneration', () {
    test('should generate performance report', () async {
      final reportId = await service.generateCustomReport(
        partnershipId: 'p_1',
        reportName: 'Q1 Performance Report',
        reportType: ReportType.performance,
        filters: {
          'startDate': '2026-01-01',
          'endDate': '2026-03-31',
        },
      );

      expect(reportId, isNotNull);
      expect(reportId.isNotEmpty, true);
    });

    test('should retrieve generated report', () async {
      final reportId = await service.generateCustomReport(
        partnershipId: 'p_1',
        reportName: 'Test Report',
        reportType: ReportType.completion,
        filters: {},
      );

      final report = await service.getCustomReport(reportId);

      expect(report, isNotNull);
      expect(report!.reportName, 'Test Report');
    });

    test('should get partnership reports', () async {
      await service.generateCustomReport(
        partnershipId: 'p_1',
        reportName: 'Report 1',
        reportType: ReportType.performance,
        filters: {},
      );

      await service.generateCustomReport(
        partnershipId: 'p_1',
        reportName: 'Report 2',
        reportType: ReportType.engagement,
        filters: {},
      );

      final reports = await service.getPartnershipReports(
        partnershipId: 'p_1',
      );

      expect(reports.length, greaterThanOrEqualTo(2));
    });

    test('should export report in multiple formats', () async {
      final reportId = await service.generateCustomReport(
        partnershipId: 'p_1',
        reportName: 'Export Test',
        reportType: ReportType.performance,
        filters: {},
      );

      final pdfUrl = await service.exportReport(
        reportId: reportId,
        format: 'pdf',
      );

      final csvUrl = await service.exportReport(
        reportId: reportId,
        format: 'csv',
      );

      expect(pdfUrl, isNotNull);
      expect(csvUrl, isNotNull);
      expect(pdfUrl!.contains('pdf'), true);
      expect(csvUrl!.contains('csv'), true);
    });
  });

  group('InstructorAssignments', () {
    test('should get assigned students for instructor', () async {
      final assignedStudents = await service.getAssignedStudents('instr_1');

      expect(assignedStudents, isList);
    });

    test('should handle unassigned instructors', () async {
      final assignedStudents = await service.getAssignedStudents('unknown_instr');

      expect(assignedStudents.isEmpty, true);
    });
  });

  group('DashboardRefresh', () {
    test('should update dashboard widget', () async {
      await service.updateDashboardWidget(
        dashboardId: 'dash_1',
        widget: DashboardWidget(
          widgetId: 'w_1',
          title: 'Updated Widget',
          description: 'Widget description',
          metricType: DashboardMetricType.engagement,
          currentValue: 100,
        ),
      );

      expect(true, true); // No error thrown
    });

    test('should refresh institutional metrics', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.refreshInstitutionalMetrics('school_1');

      expect(true, true); // No error thrown
    });
  });

  group('PerformanceStatusDetection', () {
    test('should classify excellent performance', () {
      final widget = StudentProgressWidget(
        studentId: 'student_1',
        studentName: 'Excellent Student',
        overallAccuracy: 0.95,
        status: StudentPerformanceStatus.excellent,
        currentStreak: 15,
        longestStreak: 20,
        readinessProbability: 0.92,
        questionsAnsweredThisWeek: 100,
        averageTimePerQuestion: 35.0,
      );

      expect(widget.status, StudentPerformanceStatus.excellent);
      expect(widget.overallAccuracy, greaterThan(0.9));
    });

    test('should classify average performance', () {
      final widget = StudentProgressWidget(
        studentId: 'student_2',
        studentName: 'Average Student',
        overallAccuracy: 0.70,
        status: StudentPerformanceStatus.average,
        currentStreak: 3,
        longestStreak: 5,
        readinessProbability: 0.65,
        questionsAnsweredThisWeek: 30,
        averageTimePerQuestion: 50.0,
      );

      expect(widget.status, StudentPerformanceStatus.average);
      expect(widget.overallAccuracy, closeTo(0.7, 0.05));
    });

    test('should classify critical performance', () {
      final widget = StudentProgressWidget(
        studentId: 'student_3',
        studentName: 'Critical Student',
        overallAccuracy: 0.30,
        status: StudentPerformanceStatus.critical,
        currentStreak: 0,
        longestStreak: 1,
        readinessProbability: 0.15,
        questionsAnsweredThisWeek: 0,
        averageTimePerQuestion: 75.0,
      );

      expect(widget.status, StudentPerformanceStatus.critical);
      expect(widget.readinessProbability, lessThan(0.5));
    });
  });

  group('DashboardIntegration', () {
    test('should provide complete admin workflow', () async {
      // Create partnership
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Integrated Test School',
        contactEmail: 'integrated@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      // Generate admin dashboard
      final adminDash = await service.generateAdminDashboard(
        partnershipId: 'school_1',
      );

      expect(adminDash, isNotNull);
      expect(adminDash!.schoolName, 'Integrated Test School');

      // Generate instructor dashboard
      final instrDash = await service.generateInstructorDashboard(
        instructorId: 'instr_1',
        partnershipId: 'school_1',
      );

      expect(instrDash, isNotNull);
      expect(instrDash!.instructorId, 'instr_1');

      // Generate custom report
      final reportId = await service.generateCustomReport(
        partnershipId: 'school_1',
        reportName: 'Integration Test Report',
        reportType: ReportType.performance,
        filters: {},
      );

      expect(reportId, isNotEmpty);

      // Get category performance
      final performance = await service.getCategoryPerformance(
        partnershipId: 'school_1',
      );

      expect(performance.isNotEmpty, true);
    });
  });
}
