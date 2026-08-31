import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('PartnershipAgreement', () {
    test('should initialize partnership with starter tier', () {
      final partnership = PartnershipAgreement(
        partnershipId: 'p_1',
        schoolId: 'school_1',
        schoolName: 'Tokyo Driving School',
        contactEmail: 'contact@tokyodriving.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.starter,
        maxStudents: 50,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 300000,
        isCustomBrandingAllowed: false,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(partnership.tier, PartnershipTier.starter);
      expect(partnership.maxStudents, 50);
      expect(partnership.annualCostJPY, 300000);
      expect(partnership.isCustomBrandingAllowed, false);
    });

    test('should initialize partnership with professional tier', () {
      final partnership = PartnershipAgreement(
        partnershipId: 'p_2',
        schoolId: 'school_2',
        schoolName: 'Osaka Driving Academy',
        contactEmail: 'contact@osakaacademy.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.professional,
        maxStudents: 200,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 800000,
        isCustomBrandingAllowed: true,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(partnership.tier, PartnershipTier.professional);
      expect(partnership.maxStudents, 200);
      expect(partnership.annualCostJPY, 800000);
      expect(partnership.isCustomBrandingAllowed, true);
    });

    test('should initialize partnership with enterprise tier', () {
      final partnership = PartnershipAgreement(
        partnershipId: 'p_3',
        schoolId: 'school_3',
        schoolName: 'National Training Center',
        contactEmail: 'contact@national.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.enterprise,
        maxStudents: 1000,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 2000000,
        isCustomBrandingAllowed: true,
        isPrivateContentAllowed: true,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(partnership.tier, PartnershipTier.enterprise);
      expect(partnership.maxStudents, 1000);
      expect(partnership.annualCostJPY, 2000000);
      expect(partnership.isPrivateContentAllowed, true);
    });

    test('should calculate remaining seats', () {
      final partnership = PartnershipAgreement(
        partnershipId: 'p_1',
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.starter,
        maxStudents: 50,
        currentStudents: 35,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 300000,
        isCustomBrandingAllowed: false,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(partnership.remainingSeats, 15);
      expect(partnership.utilizationPercent, 70);
    });

    test('should calculate days until expiry', () {
      final expiryDate = DateTime.now().add(Duration(days: 30));
      final partnership = PartnershipAgreement(
        partnershipId: 'p_1',
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.starter,
        maxStudents: 50,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: expiryDate,
        annualCostJPY: 300000,
        isCustomBrandingAllowed: false,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(partnership.daysUntilExpiry, closeTo(30, 1));
    });

    test('should detect active status correctly', () {
      final activePartnership = PartnershipAgreement(
        partnershipId: 'p_1',
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        status: PartnershipStatus.active,
        tier: PartnershipTier.starter,
        maxStudents: 50,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 300000,
        isCustomBrandingAllowed: false,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(activePartnership.isActive, true);

      final suspendedPartnership = PartnershipAgreement(
        partnershipId: 'p_2',
        schoolId: 'school_2',
        schoolName: 'Test School 2',
        contactEmail: 'test2@school.jp',
        status: PartnershipStatus.suspended,
        tier: PartnershipTier.starter,
        maxStudents: 50,
        currentStudents: 0,
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        annualCostJPY: 300000,
        isCustomBrandingAllowed: false,
        isPrivateContentAllowed: false,
        authorizedInstructors: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(suspendedPartnership.isActive, false);
    });
  });

  group('InstitutionalLicense', () {
    test('should initialize student license', () {
      final license = InstitutionalLicense(
        licenseId: 'lic_1',
        partnershipId: 'p_1',
        userId: 'user_1',
        userName: 'Taro Yamada',
        type: LicenseType.studentAccess,
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: 365)),
        isActive: true,
        loginCount: 0,
        lastLoginAt: null,
        permissions: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(license.type, LicenseType.studentAccess);
      expect(license.isLicenseValid, true);
    });

    test('should initialize instructor license with permissions', () {
      final license = InstitutionalLicense(
        licenseId: 'lic_2',
        partnershipId: 'p_1',
        userId: 'user_2',
        userName: 'Hanako Tanaka',
        type: LicenseType.instructorAccess,
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: 365)),
        isActive: true,
        loginCount: 5,
        lastLoginAt: DateTime.now().subtract(Duration(hours: 2)),
        permissions: {
          'canViewAnalytics': true,
          'canCreateCustomContent': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(license.type, LicenseType.instructorAccess);
      expect(license.permissions['canViewAnalytics'], true);
      expect(license.loginCount, 5);
    });

    test('should initialize admin license with full permissions', () {
      final license = InstitutionalLicense(
        licenseId: 'lic_3',
        partnershipId: 'p_1',
        userId: 'user_3',
        userName: 'Jiro Suzuki',
        type: LicenseType.administratorAccess,
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: 365)),
        isActive: true,
        loginCount: 50,
        lastLoginAt: DateTime.now(),
        permissions: {
          'canManageLicenses': true,
          'canViewBilling': true,
          'canManageInstructors': true,
          'canAccessAllReports': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(license.type, LicenseType.administratorAccess);
      expect(license.permissions['canManageLicenses'], true);
      expect(license.permissions['canViewBilling'], true);
    });

    test('should calculate days until license expiry', () {
      final expiryDate = DateTime.now().add(Duration(days: 180));
      final license = InstitutionalLicense(
        licenseId: 'lic_1',
        partnershipId: 'p_1',
        userId: 'user_1',
        userName: 'Test User',
        type: LicenseType.studentAccess,
        issuedAt: DateTime.now(),
        expiresAt: expiryDate,
        isActive: true,
        loginCount: 0,
        lastLoginAt: null,
        permissions: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(license.daysUntilExpiry, closeTo(180, 1));
    });

    test('should detect expired license', () {
      final expiredDate = DateTime.now().subtract(Duration(days: 1));
      final license = InstitutionalLicense(
        licenseId: 'lic_1',
        partnershipId: 'p_1',
        userId: 'user_1',
        userName: 'Test User',
        type: LicenseType.studentAccess,
        issuedAt: DateTime.now().subtract(Duration(days: 366)),
        expiresAt: expiredDate,
        isActive: false,
        loginCount: 0,
        lastLoginAt: null,
        permissions: {},
        createdAt: DateTime.now().subtract(Duration(days: 366)),
        updatedAt: DateTime.now(),
      );

      expect(license.isLicenseValid, false);
    });
  });

  group('InstitutionalAnalytics', () {
    test('should initialize analytics with enrollment data', () {
      final analytics = InstitutionalAnalytics(
        analyticsId: 'an_1',
        partnershipId: 'p_1',
        totalStudentsEnrolled: 100,
        activeStudents: 75,
        averageCompletionRate: 0.82,
        averageExamReadiness: 0.78,
        totalQuestionsAnswered: 15000,
        averageHoursPerStudent: 25.5,
        topPerformingStudents: ['user_5', 'user_12', 'user_8'],
        categoryPerformance: {
          '交通規則': 0.85,
          '危機回避': 0.72,
          '機械知識': 0.79,
        },
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        generatedAt: DateTime.now(),
      );

      expect(analytics.totalStudentsEnrolled, 100);
      expect(analytics.activeStudents, 75);
      expect(analytics.averageCompletionRate, 0.82);
      expect(analytics.studentActivityPercentage, 75);
    });

    test('should calculate average pass probability', () {
      final analytics = InstitutionalAnalytics(
        analyticsId: 'an_1',
        partnershipId: 'p_1',
        totalStudentsEnrolled: 50,
        activeStudents: 40,
        averageCompletionRate: 0.90,
        averageExamReadiness: 0.85,
        totalQuestionsAnswered: 10000,
        averageHoursPerStudent: 30.0,
        topPerformingStudents: ['user_1', 'user_2'],
        categoryPerformance: {
          '交通規則': 0.88,
          '危機回避': 0.83,
          '機械知識': 0.85,
        },
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        generatedAt: DateTime.now(),
      );

      expect(analytics.averagePassProbability, greaterThan(0.8));
    });

    test('should track category performance variations', () {
      final analytics = InstitutionalAnalytics(
        analyticsId: 'an_1',
        partnershipId: 'p_1',
        totalStudentsEnrolled: 50,
        activeStudents: 40,
        averageCompletionRate: 0.75,
        averageExamReadiness: 0.70,
        totalQuestionsAnswered: 8000,
        averageHoursPerStudent: 20.0,
        topPerformingStudents: ['user_1'],
        categoryPerformance: {
          '交通規則': 0.90,
          '危機回避': 0.60,
          '機械知識': 0.75,
        },
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        generatedAt: DateTime.now(),
      );

      expect(analytics.categoryPerformance['交通規則'], 0.90);
      expect(analytics.categoryPerformance['危機回避'], 0.60);
    });
  });

  group('PartnershipBilling', () {
    test('should initialize billing record', () {
      final billing = PartnershipBilling(
        billingId: 'bill_1',
        partnershipId: 'p_1',
        basePlanCostJPY: 300000,
        additionalSeatsJPY: 0,
        totalStudentsInBillingPeriod: 50,
        totalCostJPY: 300000,
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 12, 31),
        isPaid: false,
        paidAt: null,
        invoiceUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(billing.basePlanCostJPY, 300000);
      expect(billing.totalCostJPY, 300000);
      expect(billing.isPaid, false);
    });

    test('should calculate billing with additional seats', () {
      final billing = PartnershipBilling(
        billingId: 'bill_1',
        partnershipId: 'p_1',
        basePlanCostJPY: 300000,
        additionalSeatsJPY: 120000, // 2 additional seats × 60k
        totalStudentsInBillingPeriod: 60,
        totalCostJPY: 420000,
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 12, 31),
        isPaid: false,
        paidAt: null,
        invoiceUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(billing.basePlanCostJPY, 300000);
      expect(billing.additionalSeatsJPY, 120000);
      expect(billing.totalCostJPY, 420000);
    });

    test('should mark billing as paid', () {
      final billing = PartnershipBilling(
        billingId: 'bill_1',
        partnershipId: 'p_1',
        basePlanCostJPY: 800000,
        additionalSeatsJPY: 0,
        totalStudentsInBillingPeriod: 200,
        totalCostJPY: 800000,
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 12, 31),
        isPaid: true,
        paidAt: DateTime.now(),
        invoiceUrl: 'https://invoices.example.com/bill_1.pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(billing.isPaid, true);
      expect(billing.paidAt, isNotNull);
      expect(billing.invoiceUrl, isNotNull);
    });
  });

  group('PartnershipManagement', () {
    test('should create partnership', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test Driving School',
        contactEmail: 'contact@testschool.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      final partnership = await service.getPartnership('school_1');

      expect(partnership, isNotNull);
      expect(partnership!.schoolId, 'school_1');
      expect(partnership.status, PartnershipStatus.active);
      expect(partnership.tier, PartnershipTier.starter);
    });

    test('should get active partnerships', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Active School',
        contactEmail: 'active@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.createPartnership(
        schoolId: 'school_2',
        schoolName: 'Another School',
        contactEmail: 'another@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_academy,
      );

      final active = await service.getActivePartnerships();

      expect(active.length, greaterThanOrEqualTo(2));
    });

    test('should suspend partnership', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.suspendPartnership('school_1');
      final partnership = await service.getPartnership('school_1');

      expect(partnership!.status, PartnershipStatus.suspended);
      expect(partnership.isActive, false);
    });

    test('should resume suspended partnership', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.suspendPartnership('school_1');
      await service.resumePartnership('school_1');
      final partnership = await service.getPartnership('school_1');

      expect(partnership!.status, PartnershipStatus.active);
      expect(partnership.isActive, true);
    });
  });

  group('LicenseManagement', () {
    test('should issue student license', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_1',
        userName: 'Test Student',
        type: LicenseType.studentAccess,
      );

      final license = await service.getLicense(partnershipId: 'school_1', userId: 'user_1');

      expect(license, isNotNull);
      expect(license!.type, LicenseType.studentAccess);
      expect(license.isActive, true);
    });

    test('should issue instructor license', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_1',
        userName: 'Test Instructor',
        type: LicenseType.instructorAccess,
      );

      final license = await service.getLicense(partnershipId: 'school_1', userId: 'user_1');

      expect(license!.type, LicenseType.instructorAccess);
    });

    test('should get all partnership licenses', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_1',
        userName: 'User 1',
        type: LicenseType.studentAccess,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_2',
        userName: 'User 2',
        type: LicenseType.studentAccess,
      );

      final licenses = await service.getPartnershipLicenses('school_1');

      expect(licenses.length, 2);
    });

    test('should revoke license', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_1',
        userName: 'Test User',
        type: LicenseType.studentAccess,
      );

      await service.revokeLicense(partnershipId: 'school_1', userId: 'user_1');
      final license = await service.getLicense(partnershipId: 'school_1', userId: 'user_1');

      expect(license!.isActive, false);
    });
  });

  group('SeatManagement', () {
    test('should consume seat when adding student', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.consumeSeat('school_1');
      final partnership = await service.getPartnership('school_1');

      expect(partnership!.currentStudents, 1);
      expect(partnership.remainingSeats, 49);
    });

    test('should release seat when removing student', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.consumeSeat('school_1');
      await service.consumeSeat('school_1');
      await service.releaseSeat('school_1');

      final partnership = await service.getPartnership('school_1');

      expect(partnership!.currentStudents, 1);
      expect(partnership.remainingSeats, 49);
    });

    test('should get seat usage', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      for (int i = 0; i < 150; i++) {
        await service.consumeSeat('school_1');
      }

      final usage = await service.getSeatUsage('school_1');

      expect(usage, isNotNull);
      expect(usage!['currentStudents'], 150);
      expect(usage!['remainingSeats'], 50);
    });

    test('should not exceed maximum seats', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      for (int i = 0; i < 60; i++) {
        await service.consumeSeat('school_1');
      }

      final partnership = await service.getPartnership('school_1');

      expect(partnership!.currentStudents, lessThanOrEqualTo(50));
    });
  });

  group('AnalyticsGeneration', () {
    test('should generate institutional analytics', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.generateInstitutionalAnalytics('school_1');
      final analytics = await service.getInstitutionalAnalytics('school_1');

      expect(analytics, isNotNull);
      expect(analytics!.partnershipId, 'school_1');
    });

    test('should get student performance summary', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.issueLicense(
        partnershipId: 'school_1',
        userId: 'user_1',
        userName: 'Test Student',
        type: LicenseType.studentAccess,
      );

      // Add progress data
      await service.updateProgressTracker(
        userId: 'user_1',
        category: '交通規則',
        isCorrect: true,
        timeSpentSeconds: 30,
      );

      final summary = await service.getStudentPerformanceSummary(
        partnershipId: 'school_1',
        userId: 'user_1',
      );

      expect(summary, isNotNull);
    });
  });

  group('BillingOperations', () {
    test('should generate billing record', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.generateBilling(
        partnershipId: 'school_1',
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 1, 31),
      );

      final billing = await service.getBilling('school_1');

      expect(billing, isNotNull);
      expect(billing!.basePlanCostJPY, 300000);
    });

    test('should get billing history', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.generateBilling(
        partnershipId: 'school_1',
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 1, 31),
      );

      final history = await service.getPartnershipBillingHistory('school_1');

      expect(history.length, greaterThan(0));
    });

    test('should confirm billing payment', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.generateBilling(
        partnershipId: 'school_1',
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 1, 31),
      );

      await service.confirmPayment('school_1');
      final billing = await service.getBilling('school_1');

      expect(billing!.isPaid, true);
      expect(billing.paidAt, isNotNull);
    });
  });

  group('PartnershipPlanUpgrade', () {
    test('should upgrade from starter to professional', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.updatePartnership(
        partnershipId: 'school_1',
        updates: {
          'tier': PartnershipTier.professional,
          'maxStudents': 200,
          'annualCostJPY': 800000,
          'isCustomBrandingAllowed': true,
        },
      );

      final partnership = await service.getPartnership('school_1');

      expect(partnership!.tier, PartnershipTier.professional);
      expect(partnership.maxStudents, 200);
    });

    test('should purchase additional seats', () async {
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Test School',
        contactEmail: 'test@school.jp',
        tier: PartnershipTier.starter,
        schoolCategory: SchoolCategory.driving_school,
      );

      await service.purchaseAdditionalSeats('school_1', numberOfSeats: 10);
      final partnership = await service.getPartnership('school_1');

      expect(partnership!.maxStudents, 60);
    });
  });

  group('PartnershipIntegration', () {
    test('should manage complete partnership lifecycle', () async {
      // Create partnership
      await service.createPartnership(
        schoolId: 'school_1',
        schoolName: 'Integration Test School',
        contactEmail: 'integration@school.jp',
        tier: PartnershipTier.professional,
        schoolCategory: SchoolCategory.driving_academy,
      );

      // Issue licenses for students
      for (int i = 1; i <= 3; i++) {
        await service.issueLicense(
          partnershipId: 'school_1',
          userId: 'user_$i',
          userName: 'Test User $i',
          type: LicenseType.studentAccess,
        );
      }

      // Check seat consumption
      var partnership = await service.getPartnership('school_1');
      expect(partnership!.currentStudents, 3);

      // Generate analytics
      await service.generateInstitutionalAnalytics('school_1');
      final analytics = await service.getInstitutionalAnalytics('school_1');
      expect(analytics, isNotNull);

      // Create billing
      await service.generateBilling(
        partnershipId: 'school_1',
        billingPeriodStart: DateTime(2026, 1, 1),
        billingPeriodEnd: DateTime(2026, 12, 31),
      );

      final billing = await service.getBilling('school_1');
      expect(billing!.basePlanCostJPY, 800000);

      // Confirm payment
      await service.confirmPayment('school_1');
      final paidBilling = await service.getBilling('school_1');
      expect(paidBilling!.isPaid, true);
    });
  });
}
