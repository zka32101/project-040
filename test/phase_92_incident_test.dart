import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/incident_models.dart';
import 'package:project_040/services/incident_service.dart';

void main() {
  group('Phase 92: Advanced Incident Response & Crisis Management', () {
    late IncidentFacade facade;
    late IncidentManager manager;
    late InMemoryIncidentRepository repository;

    setUp(() {
      repository = InMemoryIncidentRepository();
      manager = IncidentManager(repository);
      facade = IncidentFacade(manager);
    });

    // ============================================================================
    // ENUM TESTS
    // ============================================================================

    group('Enum Tests', () {
      test('IncidentSeverity enum has all values', () {
        expect(IncidentSeverity.values.length, equals(5));
        expect(IncidentSeverity.values, contains(IncidentSeverity.low));
        expect(IncidentSeverity.values, contains(IncidentSeverity.critical));
      });

      test('IncidentStatus enum has all values', () {
        expect(IncidentStatus.values.length, equals(6));
        expect(IncidentStatus.values, contains(IncidentStatus.reported));
        expect(IncidentStatus.values, contains(IncidentStatus.closed));
      });

      test('IncidentType enum has all values', () {
        expect(IncidentType.values.length, equals(6));
      });

      test('ResponsePhase enum has all values', () {
        expect(ResponsePhase.values.length, equals(6));
      });

      test('CommunicationChannel enum has all values', () {
        expect(CommunicationChannel.values.length, equals(6));
      });

      test('RecoveryStrategy enum has all values', () {
        expect(RecoveryStrategy.values.length, equals(5));
      });
    });

    // ============================================================================
    // MODEL TESTS
    // ============================================================================

    group('Incident Model Tests', () {
      test('Incident creation and critical detection', () {
        final incident = Incident(
          id: 'inc_1',
          title: 'Database Outage',
          description: 'Critical database down',
          type: IncidentType.infrastructure,
          severity: IncidentSeverity.critical,
          reportedAt: DateTime.now(),
          reportedBy: 'Monitoring',
          status: IncidentStatus.investigating,
          affectedSystems: ['database', 'api'],
        );

        expect(incident.isCritical, true);
        expect(incident.isActive, true);
      });

      test('Incident copyWith', () {
        final incident = Incident(
          id: 'inc_1',
          title: 'Database Outage',
          description: 'Critical database down',
          type: IncidentType.infrastructure,
          severity: IncidentSeverity.critical,
          reportedAt: DateTime.now(),
          reportedBy: 'Monitoring',
          status: IncidentStatus.investigating,
          affectedSystems: [],
        );

        final updated = incident.copyWith(status: IncidentStatus.resolved);
        expect(updated.isActive, false);
      });
    });

    group('IncidentTimeline Model Tests', () {
      test('IncidentTimeline creation', () {
        final timeline = IncidentTimeline(
          id: 'time_1',
          incidentId: 'inc_1',
          eventTime: DateTime.now(),
          phase: ResponsePhase.detection,
          description: 'Incident detected',
          actor: 'Monitoring System',
          notes: [],
        );

        expect(timeline.phase, equals(ResponsePhase.detection));
        expect(timeline.ageInMinutes, equals(0));
      });

      test('IncidentTimeline copyWith', () {
        final timeline = IncidentTimeline(
          id: 'time_1',
          incidentId: 'inc_1',
          eventTime: DateTime.now(),
          phase: ResponsePhase.detection,
          description: 'Incident detected',
          actor: 'Monitoring System',
          notes: [],
        );

        final updated = timeline.copyWith(phase: ResponsePhase.containment);
        expect(updated.phase, equals(ResponsePhase.containment));
      });
    });

    group('ImpactAssessment Model Tests', () {
      test('ImpactAssessment creation', () {
        final assessment = ImpactAssessment(
          id: 'imp_1',
          incidentId: 'inc_1',
          usersAffected: 5000,
          systemsAffected: 3,
          estimatedDataLossPercent: 5.0,
          estimatedRecoveryTime: Duration(hours: 4),
          financialImpactDollars: 500000,
          assessmentTime: DateTime.now(),
          assessedBy: 'Assessment Team',
        );

        expect(assessment.isHighImpact, true);
        expect(assessment.hasDataLoss, true);
      });

      test('ImpactAssessment copyWith', () {
        final assessment = ImpactAssessment(
          id: 'imp_1',
          incidentId: 'inc_1',
          usersAffected: 5000,
          systemsAffected: 3,
          estimatedDataLossPercent: 5.0,
          estimatedRecoveryTime: Duration(hours: 4),
          financialImpactDollars: 500000,
          assessmentTime: DateTime.now(),
          assessedBy: 'Assessment Team',
        );

        final updated = assessment.copyWith(usersAffected: 100);
        expect(updated.isHighImpact, false);
      });
    });

    group('ResponseAction Model Tests', () {
      test('ResponseAction creation', () {
        final action = ResponseAction(
          id: 'act_1',
          incidentId: 'inc_1',
          title: 'Failover Database',
          description: 'Switch to replica',
          initiatedAt: DateTime.now(),
          assignedTo: 'DBA Team',
          progressPercent: 50.0,
          outcomes: [],
        );

        expect(action.isCompleted, false);
        expect(action.durationMinutes, equals(0));
      });

      test('ResponseAction copyWith', () {
        final action = ResponseAction(
          id: 'act_1',
          incidentId: 'inc_1',
          title: 'Failover Database',
          description: 'Switch to replica',
          initiatedAt: DateTime.now(),
          assignedTo: 'DBA Team',
          progressPercent: 50.0,
          outcomes: [],
        );

        final updated = action.copyWith(progressPercent: 100.0);
        expect(updated.isCompleted, true);
      });
    });

    group('CrisisCommunication Model Tests', () {
      test('CrisisCommunication creation', () {
        final communication = CrisisCommunication(
          id: 'com_1',
          incidentId: 'inc_1',
          channel: CommunicationChannel.slack,
          recipient: 'engineering-team',
          message: 'Database outage - investigating',
          sentAt: DateTime.now(),
          acknowledged: false,
          sentBy: 'Incident Commander',
        );

        expect(communication.isPending, true);
        expect(communication.channel, equals(CommunicationChannel.slack));
      });

      test('CrisisCommunication copyWith', () {
        final communication = CrisisCommunication(
          id: 'com_1',
          incidentId: 'inc_1',
          channel: CommunicationChannel.slack,
          recipient: 'engineering-team',
          message: 'Database outage',
          sentAt: DateTime.now(),
          acknowledged: false,
          sentBy: 'Incident Commander',
        );

        final updated = communication.copyWith(
          acknowledged: true,
          acknowledgedAt: DateTime.now(),
        );
        expect(updated.isPending, false);
      });
    });

    group('RecoveryPlan Model Tests', () {
      test('RecoveryPlan creation', () {
        final plan = RecoveryPlan(
          id: 'rec_1',
          incidentId: 'inc_1',
          strategy: RecoveryStrategy.failover,
          description: 'Failover to standby',
          plannedStartTime: DateTime.now().add(Duration(minutes: 30)),
          estimatedDuration: Duration(hours: 2),
          steps: ['Verify replica', 'Update DNS', 'Resume traffic'],
          dependencies: [],
          owner: 'Recovery Lead',
        );

        expect(plan.isDue, false);
        expect(plan.strategy, equals(RecoveryStrategy.failover));
      });

      test('RecoveryPlan copyWith', () {
        final plan = RecoveryPlan(
          id: 'rec_1',
          incidentId: 'inc_1',
          strategy: RecoveryStrategy.failover,
          description: 'Failover to standby',
          plannedStartTime: DateTime.now(),
          estimatedDuration: Duration(hours: 2),
          steps: [],
          dependencies: [],
          owner: 'Recovery Lead',
        );

        final updated = plan.copyWith(strategy: RecoveryStrategy.restoration);
        expect(updated.strategy, equals(RecoveryStrategy.restoration));
      });
    });

    group('PostIncidentReview Model Tests', () {
      test('PostIncidentReview creation', () {
        final review = PostIncidentReview(
          id: 'pir_1',
          incidentId: 'inc_1',
          reviewDate: DateTime.now(),
          reviewedBy: 'Team Lead',
          rootCause: 'Hardware failure',
          contributingFactors: ['No monitoring alert', 'No backup'],
          lessons: ['Add monitoring', 'Test backups'],
          actionItems: ['Set up alerts', 'Schedule backup tests'],
          completed: false,
        );

        expect(review.completed, false);
        expect(review.pendingActionItems, equals(2));
      });

      test('PostIncidentReview copyWith', () {
        final review = PostIncidentReview(
          id: 'pir_1',
          incidentId: 'inc_1',
          reviewDate: DateTime.now(),
          reviewedBy: 'Team Lead',
          rootCause: 'Hardware failure',
          contributingFactors: [],
          lessons: [],
          actionItems: [],
          completed: false,
        );

        final updated = review.copyWith(completed: true);
        expect(updated.completed, true);
      });
    });

    group('EscalationPath Model Tests', () {
      test('EscalationPath creation', () {
        final path = EscalationPath(
          id: 'esc_1',
          incidentId: 'inc_1',
          escalationOrder: ['Manager', 'VP', 'CTO'],
          escalatedAt: DateTime.now(),
          escalationReason: IncidentSeverity.critical,
          escalatedBy: 'Incident Commander',
          currentEscalationLevel: 'Manager',
        );

        expect(path.escalationCount, equals(3));
        expect(path.minutesElapsedSinceEscalation, equals(0));
      });

      test('EscalationPath copyWith', () {
        final path = EscalationPath(
          id: 'esc_1',
          incidentId: 'inc_1',
          escalationOrder: ['Manager', 'VP', 'CTO'],
          escalatedAt: DateTime.now(),
          escalationReason: IncidentSeverity.critical,
          escalatedBy: 'Incident Commander',
        );

        final updated = path.copyWith(currentEscalationLevel: 'VP');
        expect(updated.currentEscalationLevel, equals('VP'));
      });
    });

    group('ResourceAllocation Model Tests', () {
      test('ResourceAllocation creation', () {
        final allocation = ResourceAllocation(
          id: 'res_1',
          incidentId: 'inc_1',
          resourceType: 'Engineers',
          quantityAllocated: 10,
          allocationTime: DateTime.now(),
          allocatedBy: 'Manager',
          assignments: ['Eng1', 'Eng2', 'Eng3'],
          isActive: true,
        );

        expect(allocation.isActive, true);
        expect(allocation.quantityAllocated, equals(10));
      });

      test('ResourceAllocation copyWith', () {
        final allocation = ResourceAllocation(
          id: 'res_1',
          incidentId: 'inc_1',
          resourceType: 'Engineers',
          quantityAllocated: 10,
          allocationTime: DateTime.now(),
          allocatedBy: 'Manager',
          assignments: [],
          isActive: true,
        );

        final updated = allocation.copyWith(isActive: false);
        expect(updated.needsReallocation, true);
      });
    });

    group('IncidentMetrics Model Tests', () {
      test('IncidentMetrics creation', () {
        final metrics = IncidentMetrics(
          id: 'met_1',
          incidentId: 'inc_1',
          timeToDetection: Duration(minutes: 5),
          timeToContainment: Duration(minutes: 30),
          timeToResolution: Duration(hours: 2),
          personalInvolved: 15,
          meetingsHeld: 3,
          costPerMinute: 100.0,
          metricsComputedAt: DateTime.now(),
        );

        expect(metrics.totalCost, equals(12000.0));
        expect(metrics.personalInvolved, equals(15));
      });

      test('IncidentMetrics copyWith', () {
        final metrics = IncidentMetrics(
          id: 'met_1',
          incidentId: 'inc_1',
          timeToDetection: Duration(minutes: 5),
          timeToContainment: Duration(minutes: 30),
          timeToResolution: Duration(hours: 2),
          personalInvolved: 15,
          meetingsHeld: 3,
          costPerMinute: 100.0,
          metricsComputedAt: DateTime.now(),
        );

        final updated = metrics.copyWith(personalInvolved: 20);
        expect(updated.personalInvolved, equals(20));
      });
    });

    // ============================================================================
    // REPOSITORY TESTS
    // ============================================================================

    group('Repository Tests', () {
      test('Create and retrieve Incident', () async {
        final incident = Incident(
          id: 'inc_1',
          title: 'Database Outage',
          description: 'Critical database down',
          type: IncidentType.infrastructure,
          severity: IncidentSeverity.critical,
          reportedAt: DateTime.now(),
          reportedBy: 'Monitoring',
          status: IncidentStatus.investigating,
          affectedSystems: [],
        );

        await repository.createIncident(incident);
        final retrieved = await repository.getIncident('inc_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Database Outage'));
      });

      test('Get active incidents', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIncident(Incident(
            id: 'inc_$i',
            title: 'Incident $i',
            description: 'Description',
            type: IncidentType.operational,
            severity: IncidentSeverity.medium,
            reportedAt: DateTime.now(),
            reportedBy: 'System',
            status: i < 3 ? IncidentStatus.investigating : IncidentStatus.closed,
            affectedSystems: [],
          ));
        }

        final active = await repository.getActiveIncidents();
        expect(active.length, equals(3));
      });

      test('Get critical incidents', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIncident(Incident(
            id: 'inc_$i',
            title: 'Incident $i',
            description: 'Description',
            type: IncidentType.operational,
            severity: i < 2 ? IncidentSeverity.critical : IncidentSeverity.low,
            reportedAt: DateTime.now(),
            reportedBy: 'System',
            status: IncidentStatus.investigating,
            affectedSystems: [],
          ));
        }

        final critical = await repository.getCriticalIncidents();
        expect(critical.length, equals(2));
      });

      test('Create and retrieve IncidentTimeline', () async {
        final timeline = IncidentTimeline(
          id: 'time_1',
          incidentId: 'inc_1',
          eventTime: DateTime.now(),
          phase: ResponsePhase.detection,
          description: 'Detected',
          actor: 'Monitoring',
          notes: [],
        );

        await repository.createIncidentTimeline(timeline);
        final retrieved = await repository.getIncidentTimeline('time_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.phase, equals(ResponsePhase.detection));
      });

      test('Create and retrieve ImpactAssessment', () async {
        final assessment = ImpactAssessment(
          id: 'imp_1',
          incidentId: 'inc_1',
          usersAffected: 5000,
          systemsAffected: 3,
          estimatedDataLossPercent: 5.0,
          estimatedRecoveryTime: Duration(hours: 4),
          financialImpactDollars: 500000,
          assessmentTime: DateTime.now(),
          assessedBy: 'Team',
        );

        await repository.createImpactAssessment(assessment);
        final retrieved = await repository.getImpactAssessment('imp_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isHighImpact, true);
      });

      test('Create and retrieve ResponseAction', () async {
        final action = ResponseAction(
          id: 'act_1',
          incidentId: 'inc_1',
          title: 'Failover',
          description: 'Switch',
          initiatedAt: DateTime.now(),
          assignedTo: 'DBA',
          progressPercent: 50.0,
          outcomes: [],
        );

        await repository.createResponseAction(action);
        final retrieved = await repository.getResponseAction('act_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Failover'));
      });

      test('Create and retrieve CrisisCommunication', () async {
        final communication = CrisisCommunication(
          id: 'com_1',
          incidentId: 'inc_1',
          channel: CommunicationChannel.slack,
          recipient: 'team',
          message: 'Outage',
          sentAt: DateTime.now(),
          acknowledged: false,
          sentBy: 'Commander',
        );

        await repository.createCrisisCommunication(communication);
        final retrieved = await repository.getCrisisCommunication('com_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.channel, equals(CommunicationChannel.slack));
      });

      test('Get pending acknowledgments', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createCrisisCommunication(CrisisCommunication(
            id: 'com_$i',
            incidentId: 'inc_1',
            channel: CommunicationChannel.email,
            recipient: 'user_$i',
            message: 'Message',
            sentAt: DateTime.now(),
            acknowledged: i < 2,
            sentBy: 'System',
          ));
        }

        final pending = await repository.getPendingAcknowledgments();
        expect(pending.length, equals(3));
      });

      test('Create and retrieve RecoveryPlan', () async {
        final plan = RecoveryPlan(
          id: 'rec_1',
          incidentId: 'inc_1',
          strategy: RecoveryStrategy.failover,
          description: 'Failover',
          plannedStartTime: DateTime.now(),
          estimatedDuration: Duration(hours: 2),
          steps: [],
          dependencies: [],
          owner: 'Lead',
        );

        await repository.createRecoveryPlan(plan);
        final retrieved = await repository.getRecoveryPlan('rec_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.strategy, equals(RecoveryStrategy.failover));
      });

      test('Create and retrieve PostIncidentReview', () async {
        final review = PostIncidentReview(
          id: 'pir_1',
          incidentId: 'inc_1',
          reviewDate: DateTime.now(),
          reviewedBy: 'Team',
          rootCause: 'Failure',
          contributingFactors: [],
          lessons: [],
          actionItems: [],
          completed: false,
        );

        await repository.createPostIncidentReview(review);
        final retrieved = await repository.getPostIncidentReview('pir_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.rootCause, equals('Failure'));
      });

      test('Create and retrieve EscalationPath', () async {
        final path = EscalationPath(
          id: 'esc_1',
          incidentId: 'inc_1',
          escalationOrder: ['L1', 'L2', 'L3'],
          escalatedAt: DateTime.now(),
          escalationReason: IncidentSeverity.critical,
          escalatedBy: 'System',
        );

        await repository.createEscalationPath(path);
        final retrieved = await repository.getEscalationPath('esc_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.escalationCount, equals(3));
      });

      test('Create and retrieve ResourceAllocation', () async {
        final allocation = ResourceAllocation(
          id: 'res_1',
          incidentId: 'inc_1',
          resourceType: 'Engineers',
          quantityAllocated: 10,
          allocationTime: DateTime.now(),
          allocatedBy: 'Manager',
          assignments: [],
          isActive: true,
        );

        await repository.createResourceAllocation(allocation);
        final retrieved = await repository.getResourceAllocation('res_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.quantityAllocated, equals(10));
      });

      test('Create and retrieve IncidentMetrics', () async {
        final metrics = IncidentMetrics(
          id: 'met_1',
          incidentId: 'inc_1',
          timeToDetection: Duration(minutes: 5),
          timeToContainment: Duration(minutes: 30),
          timeToResolution: Duration(hours: 2),
          personalInvolved: 15,
          meetingsHeld: 3,
          costPerMinute: 100.0,
          metricsComputedAt: DateTime.now(),
        );

        await repository.createIncidentMetrics(metrics);
        final retrieved = await repository.getIncidentMetrics('met_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.totalCost, equals(12000.0));
      });

      test('Count operations', () async {
        for (int i = 0; i < 3; i++) {
          await repository.createIncident(Incident(
            id: 'inc_$i',
            title: 'Incident $i',
            description: 'Description',
            type: IncidentType.operational,
            severity: IncidentSeverity.medium,
            reportedAt: DateTime.now(),
            reportedBy: 'System',
            status: IncidentStatus.investigating,
            affectedSystems: [],
          ));
        }

        final count = await repository.countIncidents();
        expect(count, equals(3));
      });

      test('Delete operations', () async {
        final incident = Incident(
          id: 'inc_1',
          title: 'Test',
          description: 'Test',
          type: IncidentType.operational,
          severity: IncidentSeverity.low,
          reportedAt: DateTime.now(),
          reportedBy: 'System',
          status: IncidentStatus.investigating,
          affectedSystems: [],
        );

        await repository.createIncident(incident);
        await repository.deleteIncident('inc_1');

        final retrieved = await repository.getIncident('inc_1');
        expect(retrieved, isNull);
      });
    });

    // ============================================================================
    // ENGINE TESTS
    // ============================================================================

    group('Engine Tests', () {
      test('IncidentDetectionEngine identifies critical incidents', () async {
        final engine = IncidentDetectionEngine();
        final incident = Incident(
          id: 'inc_1',
          title: 'Critical',
          description: 'Critical incident',
          type: IncidentType.infrastructure,
          severity: IncidentSeverity.critical,
          reportedAt: DateTime.now(),
          reportedBy: 'System',
          status: IncidentStatus.investigating,
          affectedSystems: [],
        );

        final isCritical = await engine.isIncidentCritical(incident);
        expect(isCritical, true);
      });

      test('CrisisCoordinationEngine suggests escalation', () async {
        final engine = CrisisCoordinationEngine();
        final escalation = await engine.generateEscalationList(IncidentSeverity.catastrophic);
        expect(escalation.isNotEmpty, true);
      });

      test('RecoveryCoordinationEngine recommends strategy', () async {
        final engine = RecoveryCoordinationEngine();
        final strategy = await engine.recommendStrategy(IncidentType.dataLoss, 15.0);
        expect(strategy, equals(RecoveryStrategy.reconstruction));
      });

      test('ImpactCalculationEngine calculates impact', () async {
        final engine = ImpactCalculationEngine();
        final assessment = ImpactAssessment(
          id: 'imp_1',
          incidentId: 'inc_1',
          usersAffected: 2000,
          systemsAffected: 2,
          estimatedDataLossPercent: 10.0,
          estimatedRecoveryTime: Duration(hours: 3),
          financialImpactDollars: 50000,
          assessmentTime: DateTime.now(),
          assessedBy: 'Team',
        );

        final totalImpact = await engine.calculateTotalImpact(assessment);
        expect(totalImpact, equals(70000.0));
      });

      test('PostIncidentLearningEngine extracts lessons', () async {
        final engine = PostIncidentLearningEngine();
        final review = PostIncidentReview(
          id: 'pir_1',
          incidentId: 'inc_1',
          reviewDate: DateTime.now(),
          reviewedBy: 'Team',
          rootCause: 'Failure',
          contributingFactors: [],
          lessons: ['Lesson 1', 'Lesson 2'],
          actionItems: [],
          completed: true,
        );

        final lessons = await engine.extractLessons(review);
        expect(lessons.length, equals(2));
      });
    });

    // ============================================================================
    // FACADE TESTS
    // ============================================================================

    group('Facade Tests', () {
      test('Report incident via facade', () async {
        final incident = await facade.reportIncident(
          'Database Outage',
          'Critical database down',
          IncidentType.infrastructure,
          IncidentSeverity.critical,
          'Monitoring System',
        );

        expect(incident, isNotNull);
        expect(incident.status, equals(IncidentStatus.reported));
      });

      test('Assess impact via facade', () async {
        final assessment = await facade.assessImpact('inc_1', 5000, 3, 5.0);

        expect(assessment, isNotNull);
        expect(assessment.isHighImpact, true);
      });

      test('Create response action via facade', () async {
        final action = await facade.createResponseAction(
          'inc_1',
          'Failover Database',
          'Execute failover',
          'DBA Team',
        );

        expect(action, isNotNull);
        expect(action.progressPercent, equals(0.0));
      });

      test('Send crisis communication via facade', () async {
        await facade.sendCrisisCommunication(
          'inc_1',
          CommunicationChannel.slack,
          'engineering-team',
          'Database outage - investigating',
        );

        final communications = await repository.getCommunicationsByIncident('inc_1');
        expect(communications.isNotEmpty, true);
      });

      test('Create recovery plan via facade', () async {
        final plan = await facade.createRecoveryPlan(
          'inc_1',
          RecoveryStrategy.failover,
          'Failover to standby',
        );

        expect(plan, isNotNull);
        expect(plan.strategy, equals(RecoveryStrategy.failover));
      });

      test('Create post-incident review via facade', () async {
        final review = await facade.createPostIncidentReview(
          'inc_1',
          'Hardware failure',
          ['Improve monitoring', 'Test backups'],
        );

        expect(review, isNotNull);
        expect(review.rootCause, equals('Hardware failure'));
      });

      test('Get incident dashboard', () async {
        await facade.reportIncident('Test', 'Test', IncidentType.operational, IncidentSeverity.medium, 'System');

        final dashboard = await facade.getIncidentDashboard();

        expect(dashboard, isNotNull);
        expect(dashboard.containsKey('totalIncidents'), true);
      });
    });

    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================

    group('Integration Tests', () {
      test('Complete incident response workflow', () async {
        // Report incident
        final incident = await facade.reportIncident(
          'Database Outage',
          'Production database offline',
          IncidentType.infrastructure,
          IncidentSeverity.critical,
          'Monitoring',
        );
        expect(incident.isCritical, true);

        // Assess impact
        final assessment = await facade.assessImpact(
          incident.id,
          5000,
          3,
          5.0,
        );
        expect(assessment.isHighImpact, true);

        // Create response actions
        await facade.createResponseAction(
          incident.id,
          'Failover',
          'Execute failover',
          'DBA',
        );

        // Send communications
        await facade.sendCrisisCommunication(
          incident.id,
          CommunicationChannel.slack,
          'team',
          'Incident investigation underway',
        );

        // Create recovery plan
        final plan = await facade.createRecoveryPlan(
          incident.id,
          RecoveryStrategy.failover,
          'Failover to standby',
        );
        expect(plan, isNotNull);

        // Update status
        await facade.updateIncidentStatus(incident.id, IncidentStatus.contained);

        // Create post-incident review
        final review = await facade.createPostIncidentReview(
          incident.id,
          'Infrastructure failure',
          ['Improve monitoring', 'Add redundancy'],
        );
        expect(review.completed, false);
      });

      test('Multi-incident scenario', () async {
        for (int i = 0; i < 3; i++) {
          await facade.reportIncident(
            'Incident_$i',
            'Description',
            IncidentType.operational,
            i == 0 ? IncidentSeverity.critical : IncidentSeverity.medium,
            'System',
          );
        }

        final dashboard = await facade.getIncidentDashboard();
        expect(dashboard['totalIncidents'], equals(3));
        expect(dashboard['criticalIncidents'], equals(1));
      });
    });

    // ============================================================================
    // PERFORMANCE TESTS
    // ============================================================================

    group('Performance Tests', () {
      test('Bulk incident creation', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.reportIncident(
            'Incident_$i',
            'Description',
            IncidentType.operational,
            IncidentSeverity.medium,
            'System',
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Bulk response action creation', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await facade.createResponseAction(
            'inc_1',
            'Action_$i',
            'Description',
            'Owner',
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      test('Dashboard generation performance', () async {
        for (int i = 0; i < 50; i++) {
          await facade.reportIncident(
            'Incident_$i',
            'Description',
            IncidentType.operational,
            IncidentSeverity.medium,
            'System',
          );
        }

        final stopwatch = Stopwatch()..start();
        await facade.getIncidentDashboard();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    // ============================================================================
    // EDGE CASE TESTS
    // ============================================================================

    group('Edge Case Tests', () {
      test('Handle null incident retrieval', () async {
        final result = await repository.getIncident('non_existent');
        expect(result, isNull);
      });

      test('Handle empty incident list', () async {
        final incidents = await repository.getAllIncidents();
        expect(incidents, isEmpty);
      });

      test('Handle zero impact users', () async {
        final assessment = ImpactAssessment(
          id: 'imp_1',
          incidentId: 'inc_1',
          usersAffected: 0,
          systemsAffected: 0,
          estimatedDataLossPercent: 0.0,
          estimatedRecoveryTime: Duration(minutes: 30),
          financialImpactDollars: 0.0,
          assessmentTime: DateTime.now(),
          assessedBy: 'Team',
        );

        await repository.createImpactAssessment(assessment);
        final retrieved = await repository.getImpactAssessment('imp_1');

        expect(retrieved!.isHighImpact, false);
      });

      test('Handle catastrophic severity', () async {
        final incident = Incident(
          id: 'inc_1',
          title: 'Catastrophic',
          description: 'Catastrophic incident',
          type: IncidentType.infrastructure,
          severity: IncidentSeverity.catastrophic,
          reportedAt: DateTime.now(),
          reportedBy: 'System',
          status: IncidentStatus.reported,
          affectedSystems: [],
        );

        await repository.createIncident(incident);
        final isCritical = await manager.assessIncidentCriticality('inc_1');

        expect(isCritical, true);
      });

      test('Handle concurrent operations', () async {
        final futures = <Future<void>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(
            facade.reportIncident(
              'Concurrent_$i',
              'Description',
              IncidentType.operational,
              IncidentSeverity.low,
              'System',
            ),
          );
        }

        await Future.wait(futures);
        final count = await repository.countIncidents();
        expect(count, equals(10));
      });
    });
  });
}
