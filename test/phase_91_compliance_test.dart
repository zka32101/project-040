import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/compliance_models.dart';
import 'package:project_040/services/compliance_service.dart';

void main() {
  group('Phase 91: Advanced Compliance & Risk Management', () {
    late ComplianceFacade facade;
    late ComplianceManager manager;
    late InMemoryComplianceRepository repository;

    setUp(() {
      repository = InMemoryComplianceRepository();
      manager = ComplianceManager(repository);
      facade = ComplianceFacade(manager);
    });

    // ============================================================================
    // ENUM TESTS
    // ============================================================================

    group('Enum Tests', () {
      test('ComplianceFramework enum has all values', () {
        expect(ComplianceFramework.values.length, equals(6));
        expect(ComplianceFramework.values, contains(ComplianceFramework.gdpr));
        expect(ComplianceFramework.values, contains(ComplianceFramework.ccpa));
        expect(ComplianceFramework.values, contains(ComplianceFramework.hipaa));
      });

      test('RiskLevel enum has all values', () {
        expect(RiskLevel.values.length, equals(5));
        expect(RiskLevel.values, contains(RiskLevel.low));
        expect(RiskLevel.values, contains(RiskLevel.critical));
      });

      test('ComplianceStatus enum has all values', () {
        expect(ComplianceStatus.values.length, equals(5));
        expect(ComplianceStatus.values, contains(ComplianceStatus.compliant));
        expect(ComplianceStatus.values, contains(ComplianceStatus.nonCompliant));
      });

      test('RiskCategory enum has all values', () {
        expect(RiskCategory.values.length, equals(5));
      });

      test('MitigationStrategy enum has all values', () {
        expect(MitigationStrategy.values.length, equals(5));
      });

      test('ControlType enum has all values', () {
        expect(ControlType.values.length, equals(5));
      });
    });

    // ============================================================================
    // MODEL TESTS
    // ============================================================================

    group('ComplianceRequirement Model Tests', () {
      test('ComplianceRequirement creation', () {
        final req = ComplianceRequirement(
          id: 'req_1',
          framework: ComplianceFramework.gdpr,
          title: 'Data Protection',
          description: 'Implement GDPR controls',
          impactLevel: RiskLevel.critical,
          createdAt: DateTime.now(),
          deadline: DateTime.now().add(Duration(days: 30)),
          isActive: true,
          relatedControls: ['ctrl_1', 'ctrl_2'],
        );

        expect(req.title, equals('Data Protection'));
        expect(req.framework, equals(ComplianceFramework.gdpr));
        expect(req.isActive, true);
      });

      test('ComplianceRequirement copyWith', () {
        final req = ComplianceRequirement(
          id: 'req_1',
          framework: ComplianceFramework.gdpr,
          title: 'Data Protection',
          description: 'Implement GDPR controls',
          impactLevel: RiskLevel.critical,
          createdAt: DateTime.now(),
          deadline: DateTime.now().add(Duration(days: 30)),
          isActive: true,
          relatedControls: [],
        );

        final updated = req.copyWith(isActive: false);
        expect(updated.isActive, false);
        expect(updated.title, equals('Data Protection'));
      });
    });

    group('RiskAssessment Model Tests', () {
      test('RiskAssessment creation and critical detection', () {
        final assessment = RiskAssessment(
          id: 'risk_1',
          assetId: 'asset_1',
          category: RiskCategory.operational,
          likelihood: RiskLevel.high,
          impact: RiskLevel.critical,
          riskScore: 0.85,
          assessmentDate: DateTime.now(),
          description: 'Critical risk',
          threats: ['threat_1'],
        );

        expect(assessment.isCritical, true);
        expect(assessment.riskScore, equals(0.85));
      });

      test('RiskAssessment copyWith', () {
        final assessment = RiskAssessment(
          id: 'risk_1',
          assetId: 'asset_1',
          category: RiskCategory.operational,
          likelihood: RiskLevel.high,
          impact: RiskLevel.critical,
          riskScore: 0.85,
          assessmentDate: DateTime.now(),
          description: 'Critical risk',
          threats: [],
        );

        final updated = assessment.copyWith(riskScore: 0.50);
        expect(updated.riskScore, equals(0.50));
      });
    });

    group('ControlActivity Model Tests', () {
      test('ControlActivity creation', () {
        final control = ControlActivity(
          id: 'ctrl_1',
          controlId: 'ctrl_id',
          type: ControlType.preventive,
          title: 'Access Control',
          description: 'MFA for all users',
          implementedDate: DateTime.now(),
          nextReviewDate: DateTime.now().add(Duration(days: 180)),
          effectiveness: 0.95,
          isActive: true,
        );

        expect(control.isEffective, true);
        expect(control.type, equals(ControlType.preventive));
      });

      test('ControlActivity copyWith', () {
        final control = ControlActivity(
          id: 'ctrl_1',
          controlId: 'ctrl_id',
          type: ControlType.preventive,
          title: 'Access Control',
          description: 'MFA for all users',
          implementedDate: DateTime.now(),
          nextReviewDate: DateTime.now().add(Duration(days: 180)),
          effectiveness: 0.95,
          isActive: true,
        );

        final updated = control.copyWith(effectiveness: 0.75);
        expect(updated.effectiveness, equals(0.75));
      });
    });

    group('AuditFinding Model Tests', () {
      test('AuditFinding creation', () {
        final finding = AuditFinding(
          id: 'find_1',
          auditId: 'audit_1',
          title: 'Missing Control',
          description: 'Control not implemented',
          severity: RiskLevel.high,
          status: ComplianceStatus.nonCompliant,
          foundDate: DateTime.now(),
          targetRemediationDate: DateTime.now().add(Duration(days: 30)),
          foundBy: 'Auditor',
        );

        expect(finding.title, equals('Missing Control'));
        expect(finding.isResolved, false);
      });

      test('AuditFinding copyWith', () {
        final finding = AuditFinding(
          id: 'find_1',
          auditId: 'audit_1',
          title: 'Missing Control',
          description: 'Control not implemented',
          severity: RiskLevel.high,
          status: ComplianceStatus.nonCompliant,
          foundDate: DateTime.now(),
          targetRemediationDate: DateTime.now().add(Duration(days: 30)),
          foundBy: 'Auditor',
        );

        final updated = finding.copyWith(status: ComplianceStatus.compliant);
        expect(updated.isResolved, true);
      });
    });

    group('MitigationAction Model Tests', () {
      test('MitigationAction creation', () {
        final action = MitigationAction(
          id: 'mit_1',
          riskId: 'risk_1',
          strategy: MitigationStrategy.mitigate,
          title: 'Implement Control',
          description: 'Add new control',
          plannedDate: DateTime.now().add(Duration(days: 30)),
          progressPercent: 50.0,
          owner: 'Risk Owner',
          dependencies: [],
        );

        expect(action.isCompleted, false);
        expect(action.progressPercent, equals(50.0));
      });

      test('MitigationAction copyWith', () {
        final action = MitigationAction(
          id: 'mit_1',
          riskId: 'risk_1',
          strategy: MitigationStrategy.mitigate,
          title: 'Implement Control',
          description: 'Add new control',
          plannedDate: DateTime.now().add(Duration(days: 30)),
          progressPercent: 50.0,
          owner: 'Risk Owner',
          dependencies: [],
        );

        final updated = action.copyWith(progressPercent: 100.0);
        expect(updated.isCompleted, true);
      });
    });

    group('ComplianceAsset Model Tests', () {
      test('ComplianceAsset creation', () {
        final asset = ComplianceAsset(
          id: 'asset_1',
          name: 'Database System',
          description: 'Production database',
          applicableFrameworks: [ComplianceFramework.gdpr, ComplianceFramework.hipaa],
          complianceStatus: ComplianceStatus.compliant,
          lastAssessmentDate: DateTime.now(),
          nextAssessmentDate: DateTime.now().add(Duration(days: 180)),
          complianceScore: 0.95,
          openFindings: [],
        );

        expect(asset.isFullyCompliant, true);
        expect(asset.complianceScore, equals(0.95));
      });

      test('ComplianceAsset copyWith', () {
        final asset = ComplianceAsset(
          id: 'asset_1',
          name: 'Database System',
          description: 'Production database',
          applicableFrameworks: [ComplianceFramework.gdpr],
          complianceStatus: ComplianceStatus.compliant,
          lastAssessmentDate: DateTime.now(),
          complianceScore: 0.95,
          openFindings: [],
        );

        final updated = asset.copyWith(complianceStatus: ComplianceStatus.nonCompliant);
        expect(updated.isFullyCompliant, false);
      });
    });

    group('RegulatoryEvent Model Tests', () {
      test('RegulatoryEvent creation', () {
        final event = RegulatoryEvent(
          id: 'event_1',
          title: 'GDPR Audit',
          description: 'Annual compliance audit',
          framework: ComplianceFramework.gdpr,
          eventDate: DateTime.now(),
          deadline: DateTime.now().add(Duration(days: 90)),
          category: 'audit',
          isCompleted: false,
          affectedSystems: ['system_1'],
        );

        expect(event.title, equals('GDPR Audit'));
        expect(event.isCompleted, false);
      });

      test('RegulatoryEvent copyWith', () {
        final event = RegulatoryEvent(
          id: 'event_1',
          title: 'GDPR Audit',
          description: 'Annual compliance audit',
          framework: ComplianceFramework.gdpr,
          eventDate: DateTime.now(),
          deadline: DateTime.now().add(Duration(days: 90)),
          category: 'audit',
          isCompleted: false,
          affectedSystems: [],
        );

        final updated = event.copyWith(isCompleted: true);
        expect(updated.isCompleted, true);
      });
    });

    group('CompliancePolicy Model Tests', () {
      test('CompliancePolicy creation', () {
        final policy = CompliancePolicy(
          id: 'policy_1',
          policyName: 'Data Protection Policy',
          purpose: 'Protect personal data',
          relatedFrameworks: [ComplianceFramework.gdpr],
          createdDate: DateTime.now().subtract(Duration(days: 200)),
          lastUpdatedDate: DateTime.now().subtract(Duration(days: 200)),
          version: 1,
          isActive: true,
          stakeholders: [],
        );

        expect(policy.needsReview, true);
        expect(policy.isActive, true);
      });

      test('CompliancePolicy copyWith', () {
        final policy = CompliancePolicy(
          id: 'policy_1',
          policyName: 'Data Protection Policy',
          purpose: 'Protect personal data',
          relatedFrameworks: [ComplianceFramework.gdpr],
          createdDate: DateTime.now(),
          lastUpdatedDate: DateTime.now(),
          version: 1,
          isActive: true,
          stakeholders: [],
        );

        final updated = policy.copyWith(version: 2);
        expect(updated.version, equals(2));
      });
    });

    group('RiskRegister Model Tests', () {
      test('RiskRegister creation', () {
        final register = RiskRegister(
          id: 'reg_1',
          riskId: 'risk_1',
          title: 'Data Breach Risk',
          description: 'Unauthorized data access',
          category: RiskCategory.operational,
          inherentRisk: RiskLevel.high,
          residualRisk: RiskLevel.medium,
          identifiedDate: DateTime.now(),
          owner: 'CISO',
          mitigations: ['mit_1'],
        );

        expect(register.riskReduced, true);
        expect(register.title, equals('Data Breach Risk'));
      });

      test('RiskRegister copyWith', () {
        final register = RiskRegister(
          id: 'reg_1',
          riskId: 'risk_1',
          title: 'Data Breach Risk',
          description: 'Unauthorized data access',
          category: RiskCategory.operational,
          inherentRisk: RiskLevel.high,
          residualRisk: RiskLevel.medium,
          identifiedDate: DateTime.now(),
          owner: 'CISO',
          mitigations: [],
        );

        final updated = register.copyWith(residualRisk: RiskLevel.low);
        expect(updated.residualRisk, equals(RiskLevel.low));
      });
    });

    // ============================================================================
    // REPOSITORY TESTS
    // ============================================================================

    group('Repository Tests', () {
      test('Create and retrieve ComplianceRequirement', () async {
        final req = ComplianceRequirement(
          id: 'req_1',
          framework: ComplianceFramework.gdpr,
          title: 'GDPR Compliance',
          description: 'Implement GDPR',
          impactLevel: RiskLevel.critical,
          createdAt: DateTime.now(),
          isActive: true,
          relatedControls: [],
        );

        await repository.createComplianceRequirement(req);
        final retrieved = await repository.getComplianceRequirement('req_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('GDPR Compliance'));
      });

      test('Get requirements by framework', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createComplianceRequirement(ComplianceRequirement(
            id: 'req_$i',
            framework: i < 3 ? ComplianceFramework.gdpr : ComplianceFramework.ccpa,
            title: 'Requirement $i',
            description: 'Description',
            impactLevel: RiskLevel.high,
            createdAt: DateTime.now(),
            isActive: true,
            relatedControls: [],
          ));
        }

        final gdprReqs = await repository.getRequirementsByFramework(ComplianceFramework.gdpr);
        expect(gdprReqs.length, equals(3));
      });

      test('Create and retrieve RiskAssessment', () async {
        final assessment = RiskAssessment(
          id: 'risk_1',
          assetId: 'asset_1',
          category: RiskCategory.operational,
          likelihood: RiskLevel.high,
          impact: RiskLevel.critical,
          riskScore: 0.85,
          assessmentDate: DateTime.now(),
          description: 'Risk assessment',
          threats: [],
        );

        await repository.createRiskAssessment(assessment);
        final retrieved = await repository.getRiskAssessment('risk_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.riskScore, equals(0.85));
      });

      test('Get critical risks', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createRiskAssessment(RiskAssessment(
            id: 'risk_$i',
            assetId: 'asset_1',
            category: RiskCategory.operational,
            likelihood: RiskLevel.high,
            impact: RiskLevel.critical,
            riskScore: 0.70 + (i * 0.04),
            assessmentDate: DateTime.now(),
            description: 'Risk',
            threats: [],
          ));
        }

        final critical = await repository.getCriticalRisks();
        expect(critical.length, equals(2));
      });

      test('Create and retrieve ControlActivity', () async {
        final control = ControlActivity(
          id: 'ctrl_1',
          controlId: 'ctrl_id',
          type: ControlType.preventive,
          title: 'Access Control',
          description: 'MFA implementation',
          implementedDate: DateTime.now(),
          effectiveness: 0.95,
          isActive: true,
        );

        await repository.createControlActivity(control);
        final retrieved = await repository.getControlActivity('ctrl_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isEffective, true);
      });

      test('Get ineffective controls', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createControlActivity(ControlActivity(
            id: 'ctrl_$i',
            controlId: 'ctrl_id',
            type: ControlType.preventive,
            title: 'Control $i',
            description: 'Control description',
            implementedDate: DateTime.now(),
            effectiveness: 0.70 + (i * 0.04),
            isActive: true,
          ));
        }

        final ineffective = await repository.getIneffectiveControls();
        expect(ineffective.length, equals(2));
      });

      test('Create and retrieve AuditFinding', () async {
        final finding = AuditFinding(
          id: 'find_1',
          auditId: 'audit_1',
          title: 'Missing Control',
          description: 'Control not found',
          severity: RiskLevel.high,
          status: ComplianceStatus.nonCompliant,
          foundDate: DateTime.now(),
          foundBy: 'Auditor',
        );

        await repository.createAuditFinding(finding);
        final retrieved = await repository.getAuditFinding('find_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.severity, equals(RiskLevel.high));
      });

      test('Get open findings', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createAuditFinding(AuditFinding(
            id: 'find_$i',
            auditId: 'audit_1',
            title: 'Finding $i',
            description: 'Description',
            severity: RiskLevel.medium,
            status: i < 3 ? ComplianceStatus.nonCompliant : ComplianceStatus.compliant,
            foundDate: DateTime.now(),
            foundBy: 'Auditor',
          ));
        }

        final open = await repository.getOpenFindings();
        expect(open.length, equals(3));
      });

      test('Create and retrieve MitigationAction', () async {
        final action = MitigationAction(
          id: 'mit_1',
          riskId: 'risk_1',
          strategy: MitigationStrategy.mitigate,
          title: 'Implement Control',
          description: 'Action description',
          plannedDate: DateTime.now().add(Duration(days: 30)),
          progressPercent: 50.0,
          owner: 'Owner',
          dependencies: [],
        );

        await repository.createMitigationAction(action);
        final retrieved = await repository.getMitigationAction('mit_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.progressPercent, equals(50.0));
      });

      test('Get completed actions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createMitigationAction(MitigationAction(
            id: 'mit_$i',
            riskId: 'risk_1',
            strategy: MitigationStrategy.mitigate,
            title: 'Action $i',
            description: 'Description',
            plannedDate: DateTime.now(),
            progressPercent: i < 2 ? 100.0 : 50.0,
            owner: 'Owner',
            dependencies: [],
          ));
        }

        final completed = await repository.getCompletedActions();
        expect(completed.length, equals(2));
      });

      test('Create and retrieve ComplianceAsset', () async {
        final asset = ComplianceAsset(
          id: 'asset_1',
          name: 'Database',
          description: 'Production DB',
          applicableFrameworks: [ComplianceFramework.gdpr],
          complianceStatus: ComplianceStatus.compliant,
          lastAssessmentDate: DateTime.now(),
          complianceScore: 0.95,
          openFindings: [],
        );

        await repository.createComplianceAsset(asset);
        final retrieved = await repository.getComplianceAsset('asset_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isFullyCompliant, true);
      });

      test('Get non-compliant assets', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createComplianceAsset(ComplianceAsset(
            id: 'asset_$i',
            name: 'Asset $i',
            description: 'Description',
            applicableFrameworks: [ComplianceFramework.gdpr],
            complianceStatus: i < 2 ? ComplianceStatus.nonCompliant : ComplianceStatus.compliant,
            lastAssessmentDate: DateTime.now(),
            complianceScore: 0.70 + (i * 0.05),
            openFindings: [],
          ));
        }

        final nonCompliant = await repository.getNonCompliantAssets();
        expect(nonCompliant.length, equals(2));
      });

      test('Create and retrieve RegulatoryEvent', () async {
        final event = RegulatoryEvent(
          id: 'event_1',
          title: 'GDPR Audit',
          description: 'Annual audit',
          framework: ComplianceFramework.gdpr,
          eventDate: DateTime.now(),
          category: 'audit',
          isCompleted: false,
          affectedSystems: [],
        );

        await repository.createRegulatoryEvent(event);
        final retrieved = await repository.getRegulatoryEvent('event_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.framework, equals(ComplianceFramework.gdpr));
      });

      test('Create and retrieve CompliancePolicy', () async {
        final policy = CompliancePolicy(
          id: 'policy_1',
          policyName: 'Data Protection',
          purpose: 'Protect data',
          relatedFrameworks: [ComplianceFramework.gdpr],
          createdDate: DateTime.now(),
          lastUpdatedDate: DateTime.now(),
          version: 1,
          isActive: true,
          stakeholders: [],
        );

        await repository.createCompliancePolicy(policy);
        final retrieved = await repository.getCompliancePolicy('policy_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isActive, true);
      });

      test('Create and retrieve RiskRegister', () async {
        final register = RiskRegister(
          id: 'reg_1',
          riskId: 'risk_1',
          title: 'Data Breach',
          description: 'Unauthorized access',
          category: RiskCategory.operational,
          inherentRisk: RiskLevel.high,
          residualRisk: RiskLevel.medium,
          identifiedDate: DateTime.now(),
          owner: 'CISO',
          mitigations: [],
        );

        await repository.createRiskRegister(register);
        final retrieved = await repository.getRiskRegister('reg_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.riskReduced, true);
      });

      test('Count all entities', () async {
        for (int i = 0; i < 3; i++) {
          await repository.createComplianceRequirement(ComplianceRequirement(
            id: 'req_$i',
            framework: ComplianceFramework.gdpr,
            title: 'Req $i',
            description: 'Description',
            impactLevel: RiskLevel.high,
            createdAt: DateTime.now(),
            isActive: true,
            relatedControls: [],
          ));
        }

        final count = await repository.countActiveRequirements();
        expect(count, equals(3));
      });

      test('Delete operations', () async {
        final req = ComplianceRequirement(
          id: 'req_1',
          framework: ComplianceFramework.gdpr,
          title: 'Test Requirement',
          description: 'Description',
          impactLevel: RiskLevel.high,
          createdAt: DateTime.now(),
          isActive: true,
          relatedControls: [],
        );

        await repository.createComplianceRequirement(req);
        await repository.deleteComplianceRequirement('req_1');

        final retrieved = await repository.getComplianceRequirement('req_1');
        expect(retrieved, isNull);
      });

      test('Average score calculations', () async {
        for (int i = 0; i < 4; i++) {
          await repository.createRiskAssessment(RiskAssessment(
            id: 'risk_$i',
            assetId: 'asset_1',
            category: RiskCategory.operational,
            likelihood: RiskLevel.high,
            impact: RiskLevel.critical,
            riskScore: 0.50 + (i * 0.10),
            assessmentDate: DateTime.now(),
            description: 'Risk',
            threats: [],
          ));
        }

        final avg = await repository.getAverageRiskScore();
        expect(avg, greaterThan(0.5));
      });
    });

    // ============================================================================
    // ENGINE TESTS
    // ============================================================================

    group('Engine Tests', () {
      test('ComplianceCheckEngine checks compliance', () async {
        final engine = ComplianceCheckEngine();
        final asset = ComplianceAsset(
          id: 'asset_1',
          name: 'Database',
          description: 'DB',
          applicableFrameworks: [ComplianceFramework.gdpr],
          complianceStatus: ComplianceStatus.compliant,
          lastAssessmentDate: DateTime.now(),
          complianceScore: 0.97,
          openFindings: [],
        );

        final status = await engine.checkCompliance(asset);
        expect(status, equals(ComplianceStatus.compliant));
      });

      test('RiskScoringEngine calculates risk', () async {
        final engine = RiskScoringEngine();
        final assessment = RiskAssessment(
          id: 'risk_1',
          assetId: 'asset_1',
          category: RiskCategory.operational,
          likelihood: RiskLevel.high,
          impact: RiskLevel.critical,
          riskScore: 0.0,
          assessmentDate: DateTime.now(),
          description: 'Risk',
          threats: [],
        );

        final score = await engine.calculateRiskScore(assessment);
        expect(score, greaterThan(0.0));
      });

      test('MitigationPlanningEngine recommends strategy', () async {
        final engine = MitigationPlanningEngine();
        final strategy = await engine.recommendStrategy(0.85);
        expect(strategy, equals(MitigationStrategy.avoid));
      });

      test('AuditTrailEngine generates trail', () async {
        final engine = AuditTrailEngine();
        final req = ComplianceRequirement(
          id: 'req_1',
          framework: ComplianceFramework.gdpr,
          title: 'GDPR',
          description: 'Compliance',
          impactLevel: RiskLevel.high,
          createdAt: DateTime.now(),
          isActive: true,
          relatedControls: [],
        );

        final trail = await engine.generateAuditTrail(req);
        expect(trail, isNotEmpty);
      });

      test('ControlEffectivenessEngine evaluates control', () async {
        final engine = ControlEffectivenessEngine();
        final control = ControlActivity(
          id: 'ctrl_1',
          controlId: 'ctrl_id',
          type: ControlType.preventive,
          title: 'Control',
          description: 'Description',
          implementedDate: DateTime.now(),
          effectiveness: 0.95,
          isActive: true,
        );

        final isEffective = await engine.evaluateControl(control);
        expect(isEffective, true);
      });
    });

    // ============================================================================
    // FACADE TESTS
    // ============================================================================

    group('Facade Tests', () {
      test('Create requirement via facade', () async {
        final req = await facade.createRequirement(
          'GDPR Requirement',
          'Implement controls',
          ComplianceFramework.gdpr,
        );

        expect(req, isNotNull);
        expect(req.framework, equals(ComplianceFramework.gdpr));
      });

      test('Assess risk via facade', () async {
        final assessment = await facade.assessRisk(
          'asset_1',
          RiskCategory.operational,
          RiskLevel.high,
          RiskLevel.critical,
        );

        expect(assessment, isNotNull);
        expect(assessment.isCritical, true);
      });

      test('Implement control via facade', () async {
        final control = await facade.implementControl(
          'Access Control',
          ControlType.preventive,
          0.95,
        );

        expect(control, isNotNull);
        expect(control.isEffective, true);
      });

      test('Log finding via facade', () async {
        final finding = await facade.logFinding(
          'audit_1',
          'Missing Control',
          RiskLevel.high,
        );

        expect(finding, isNotNull);
        expect(finding.severity, equals(RiskLevel.high));
      });

      test('Create mitigation via facade', () async {
        final action = await facade.createMitigation(
          'risk_1',
          MitigationStrategy.mitigate,
          'Implement Control',
        );

        expect(action, isNotNull);
        expect(action.strategy, equals(MitigationStrategy.mitigate));
      });

      test('Register asset via facade', () async {
        final asset = await facade.registerAsset(
          'Database System',
          [ComplianceFramework.gdpr, ComplianceFramework.hipaa],
        );

        expect(asset, isNotNull);
        expect(asset.applicableFrameworks.length, equals(2));
      });

      test('Create policy via facade', () async {
        final policy = await facade.createPolicy(
          'Data Protection Policy',
          [ComplianceFramework.gdpr],
        );

        expect(policy, isNotNull);
        expect(policy.isActive, true);
      });

      test('Get compliance dashboard', () async {
        await facade.registerAsset('Asset 1', [ComplianceFramework.gdpr]);
        await facade.assessRisk('asset_1', RiskCategory.operational, RiskLevel.high, RiskLevel.critical);

        final dashboard = await facade.getComplianceDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.containsKey('totalAssets'), true);
        expect(dashboard.containsKey('totalRisks'), true);
      });
    });

    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================

    group('Integration Tests', () {
      test('Complete compliance workflow', () async {
        // Create requirements
        final req = await facade.createRequirement(
          'GDPR Compliance',
          'Implement GDPR controls',
          ComplianceFramework.gdpr,
        );
        expect(req, isNotNull);

        // Register asset
        final asset = await facade.registerAsset(
          'Customer Database',
          [ComplianceFramework.gdpr],
        );
        expect(asset, isNotNull);

        // Assess risk
        final risk = await facade.assessRisk(
          asset.id,
          RiskCategory.operational,
          RiskLevel.medium,
          RiskLevel.high,
        );
        expect(risk.isCritical, false);

        // Implement controls
        final control = await facade.implementControl(
          'Data Encryption',
          ControlType.preventive,
          0.92,
        );
        expect(control.isEffective, true);

        // Create mitigation
        final mitigation = await facade.createMitigation(
          risk.id,
          MitigationStrategy.mitigate,
          'Implement encryption',
        );
        expect(mitigation, isNotNull);

        // Get dashboard
        final dashboard = await facade.getComplianceDashboard();
        expect(dashboard['totalAssets'], equals(1));
      });

      test('Multi-asset compliance scenario', () async {
        for (int i = 0; i < 3; i++) {
          await facade.registerAsset(
            'Asset_$i',
            [ComplianceFramework.gdpr, ComplianceFramework.hipaa],
          );
        }

        final dashboard = await facade.getComplianceDashboard();
        expect(dashboard['totalAssets'], equals(3));
      });
    });

    // ============================================================================
    // PERFORMANCE TESTS
    // ============================================================================

    group('Performance Tests', () {
      test('Bulk requirement creation', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.createRequirement(
            'Requirement_$i',
            'Description',
            ComplianceFramework.gdpr,
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Bulk risk assessment', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.assessRisk(
            'asset_$i',
            RiskCategory.operational,
            RiskLevel.high,
            RiskLevel.medium,
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      test('Dashboard generation performance', () async {
        for (int i = 0; i < 50; i++) {
          await facade.registerAsset('Asset_$i', [ComplianceFramework.gdpr]);
        }

        final stopwatch = Stopwatch()..start();
        await facade.getComplianceDashboard();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    // ============================================================================
    // EDGE CASE TESTS
    // ============================================================================

    group('Edge Case Tests', () {
      test('Handle null requirement retrieval', () async {
        final result = await repository.getComplianceRequirement('non_existent');
        expect(result, isNull);
      });

      test('Handle empty lists', () async {
        final requirements = await repository.getAllRequirements();
        expect(requirements, isEmpty);
      });

      test('Handle zero risk score', () async {
        final assessment = RiskAssessment(
          id: 'risk_1',
          assetId: 'asset_1',
          category: RiskCategory.operational,
          likelihood: RiskLevel.minimal,
          impact: RiskLevel.minimal,
          riskScore: 0.0,
          assessmentDate: DateTime.now(),
          description: 'Zero risk',
          threats: [],
        );

        await repository.createRiskAssessment(assessment);
        final retrieved = await repository.getRiskAssessment('risk_1');

        expect(retrieved!.riskScore, equals(0.0));
      });

      test('Handle maximum compliance score', () async {
        final asset = ComplianceAsset(
          id: 'asset_1',
          name: 'Perfect Asset',
          description: 'Fully compliant',
          applicableFrameworks: [ComplianceFramework.gdpr],
          complianceStatus: ComplianceStatus.compliant,
          lastAssessmentDate: DateTime.now(),
          complianceScore: 1.0,
          openFindings: [],
        );

        await repository.createComplianceAsset(asset);
        final retrieved = await repository.getComplianceAsset('asset_1');

        expect(retrieved!.isFullyCompliant, true);
      });

      test('Handle concurrent operations', () async {
        final futures = <Future<void>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(
            facade.createRequirement(
              'Concurrent_$i',
              'Description',
              ComplianceFramework.gdpr,
            ),
          );
        }

        await Future.wait(futures);
        final count = await repository.countActiveRequirements();
        expect(count, equals(10));
      });
    });
  });
}
