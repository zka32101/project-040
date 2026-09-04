import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/incident_models.dart';
import 'package:project_040/services/incident_management_service.dart';

void main() {
  group('Phase 74: Incident Management & Response', () {
    late IncidentRepository repository;
    late IncidentDetectionEngine detectionEngine;
    late IncidentEscalationEngine escalationEngine;
    late ImpactAnalysisEngine impactEngine;
    late IncidentResolutionEngine resolutionEngine;
    late PostmortemGenerationEngine postmortemEngine;
    late IncidentManager manager;
    late IncidentFacade facade;

    setUp(() {
      repository = IncidentRepositoryImpl();
      detectionEngine = IncidentDetectionEngine();
      escalationEngine = IncidentEscalationEngine();
      impactEngine = ImpactAnalysisEngine();
      resolutionEngine = IncidentResolutionEngine();
      postmortemEngine = PostmortemGenerationEngine();
      manager = IncidentManager(
        repository: repository,
        detectionEngine: detectionEngine,
        escalationEngine: escalationEngine,
        impactEngine: impactEngine,
        resolutionEngine: resolutionEngine,
        postmortemEngine: postmortemEngine,
      );
      facade = IncidentFacade(repository: repository, manager: manager);
    });

    // ========== ENUM TESTS ==========
    group('Enums', () {
      test('IncidentSeverity enum has all values', () {
        expect(IncidentSeverity.values.length, equals(5));
        expect(IncidentSeverity.values, contains(IncidentSeverity.critical));
        expect(IncidentSeverity.values, contains(IncidentSeverity.info));
      });

      test('IncidentStatus enum has all values', () {
        expect(IncidentStatus.values.length, equals(6));
        expect(IncidentStatus.values, contains(IncidentStatus.open));
        expect(IncidentStatus.values, contains(IncidentStatus.closed));
      });

      test('IncidentPriority enum has all values', () {
        expect(IncidentPriority.values.length, equals(5));
      });

      test('ImpactScope enum has all values', () {
        expect(ImpactScope.values.length, equals(5));
      });

      test('ResolutionType enum has all values', () {
        expect(ResolutionType.values.length, equals(6));
      });

      test('PostmortemStatus enum has all values', () {
        expect(PostmortemStatus.values.length, equals(5));
      });
    });

    // ========== MODEL TESTS ==========
    group('Incident Model', () {
      test('creates incident with required fields', () {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Database Connection Timeout',
          description: 'Database is timing out',
          severity: IncidentSeverity.critical,
          status: IncidentStatus.open,
          priority: IncidentPriority.p0,
          createdAt: DateTime.now(),
          assignedTo: 'team_a',
          affectedServices: ['api', 'auth'],
          affectedUsers: ['user1', 'user2'],
        );
        expect(incident.incidentId, equals('inc_123'));
        expect(incident.isCritical, isTrue);
        expect(incident.isOpen, isTrue);
        expect(incident.isResolved, isFalse);
      });

      test('calculates impactScore correctly', () {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Test',
          description: 'Test',
          severity: IncidentSeverity.critical,
          status: IncidentStatus.open,
          priority: IncidentPriority.p0,
          createdAt: DateTime.now(),
          assignedTo: 'team',
          affectedServices: ['svc1', 'svc2'],
          affectedUsers: ['u1', 'u2', 'u3'],
        );
        expect(incident.impactScore, greaterThan(0));
      });
    });

    group('IncidentTimeline Model', () {
      test('creates timeline event', () {
        final timeline = IncidentTimeline(
          timelineId: 'tl_123',
          incidentId: 'inc_123',
          timestamp: DateTime.now(),
          eventType: 'detection',
          description: 'Incident detected',
          triggeredBy: 'monitoring',
          metadata: {'source': 'prometheus'},
        );
        expect(timeline.timelineId, equals('tl_123'));
        expect(timeline.eventType, equals('detection'));
      });

      test('isRecent property works correctly', () {
        final recent = IncidentTimeline(
          timelineId: 'tl_1',
          incidentId: 'inc_1',
          timestamp: DateTime.now().subtract(Duration(hours: 12)),
          eventType: 'update',
          description: 'Updated',
          triggeredBy: 'user',
          metadata: {},
        );
        expect(recent.isRecent, isTrue);
      });
    });

    group('IncidentImpactAnalysis Model', () {
      test('determines impact scope correctly', () {
        final analysis = IncidentImpactAnalysis(
          analysisId: 'ana_123',
          incidentId: 'inc_123',
          scope: ImpactScope.global,
          estimatedAffectedUsers: 50000,
          affectedServices: List.generate(10, (i) => 'svc$i'),
          dependentServices: [],
          estimatedRevenueLoss: 100000.0,
          analyzedAt: DateTime.now(),
        );
        expect(analysis.isGlobal, isTrue);
        expect(analysis.hasHighImpact, isTrue);
      });
    });

    group('IncidentEscalation Model', () {
      test('tracks escalation state', () {
        final escalation = IncidentEscalation(
          escalationId: 'esc_123',
          incidentId: 'inc_123',
          escalationLevel: 2,
          escalatedTo: 'manager',
          reason: 'Critical incident',
          escalatedAt: DateTime.now(),
        );
        expect(escalation.isAcknowledged, isFalse);
        expect(escalation.isPending, isTrue);
      });
    });

    group('IncidentCommunication Model', () {
      test('tracks communication delivery', () {
        final comm = IncidentCommunication(
          communicationId: 'com_123',
          incidentId: 'inc_123',
          channelType: 'email',
          recipient: 'team@example.com',
          message: 'Incident alert',
          sentAt: DateTime.now(),
          sentBy: 'system',
        );
        expect(comm.isPending, isTrue);
        expect(comm.hasResponse, isFalse);
      });
    });

    group('IncidentResolution Model', () {
      test('tracks resolution verification', () {
        final resolution = IncidentResolution(
          resolutionId: 'res_123',
          incidentId: 'inc_123',
          resolutionType: ResolutionType.rollback,
          description: 'Rolled back to previous version',
          implementedAt: DateTime.now(),
          implementedBy: 'automation',
        );
        expect(resolution.isPending, isTrue);
      });
    });

    group('IncidentPostmortem Model', () {
      test('tracks postmortem lifecycle', () {
        final postmortem = IncidentPostmortem(
          postmortemId: 'pm_123',
          incidentId: 'inc_123',
          title: 'Database Outage Postmortem',
          rootCauseAnalysis: 'Connection pool exhaustion',
          contributingFactors: ['High traffic', 'Slow queries'],
          actionItems: ['Optimize queries', 'Increase pool size'],
          preventionMeasures: ['Add monitoring', 'Load testing'],
          status: PostmortemStatus.draft,
          createdAt: DateTime.now(),
          createdBy: 'team_lead',
        );
        expect(postmortem.isPublished, isFalse);
        expect(postmortem.actionItemCount, equals(2));
      });
    });

    group('IncidentNotification Model', () {
      test('tracks notification delivery status', () {
        final notification = IncidentNotification(
          notificationId: 'notif_123',
          incidentId: 'inc_123',
          notificationType: 'email',
          recipients: ['eng@example.com', 'ops@example.com'],
          subject: 'Critical Incident Alert',
          body: 'API service is down',
          createdAt: DateTime.now(),
          sentCount: 2,
          failedCount: 0,
        );
        expect(notification.isSent, isFalse);
        expect(notification.hasFailed, isFalse);
      });
    });

    group('IncidentTrendAnalysis Model', () {
      test('calculates trend metrics', () {
        final analysis = IncidentTrendAnalysis(
          analysisId: 'trend_123',
          analyzedAt: DateTime.now(),
          incidentsInPeriod: 10,
          averageDuration: 120.0,
          averageTimeToResolution: 95.0,
          severityDistribution: {
            IncidentSeverity.critical: 2,
            IncidentSeverity.high: 3,
            IncidentSeverity.medium: 5,
          },
          topAffectedServices: ['api', 'database'],
          mtbf: 7200.0,
          mttr: 95.0,
          mtrc: 120.0,
        );
        expect(analysis.hasIncidents, isTrue);
        expect(analysis.criticalIncidents, equals(2));
      });
    });

    // ========== REPOSITORY TESTS ==========
    group('Repository: Incident Management', () {
      test('creates incident', () async {
        final incident = await repository.createIncident(
          'API Server Down',
          'API is not responding',
          IncidentSeverity.critical,
          'on-call',
        );
        expect(incident.incidentId, isNotEmpty);
        expect(incident.title, equals('API Server Down'));
      });

      test('retrieves incident', () async {
        final created = await repository.createIncident(
          'Test',
          'Description',
          IncidentSeverity.high,
          'team',
        );
        final retrieved = await repository.getIncident(created.incidentId);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Test'));
      });

      test('updates incident status', () async {
        final incident = await repository.createIncident(
          'Test',
          'Test',
          IncidentSeverity.medium,
          'team',
        );
        final updated = await repository.updateIncident(
          incident.incidentId,
          status: IncidentStatus.resolved,
        );
        expect(updated.status, equals(IncidentStatus.resolved));
        expect(updated.isResolved, isTrue);
      });

      test('lists incidents with limit', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createIncident(
            'Incident $i',
            'Desc',
            IncidentSeverity.low,
            'team',
          );
        }
        final list = await repository.listIncidents(limit: 3);
        expect(list.length, lessThanOrEqualTo(3));
      });

      test('gets open incidents', () async {
        await repository.createIncident('Open1', 'Desc', IncidentSeverity.high, 'team');
        await repository.createIncident('Closed1', 'Desc', IncidentSeverity.low, 'team');
        final openList = await repository.getOpenIncidents();
        expect(openList.isNotEmpty, isTrue);
        expect(openList.every((i) => i.isOpen), isTrue);
      });

      test('gets critical incidents', () async {
        await repository.createIncident('Critical1', 'Desc', IncidentSeverity.critical, 'team');
        await repository.createIncident('Normal1', 'Desc', IncidentSeverity.low, 'team');
        final criticalList = await repository.getCriticalIncidents();
        expect(criticalList.isNotEmpty, isTrue);
        expect(criticalList.every((i) => i.isCritical), isTrue);
      });
    });

    group('Repository: Timeline Events', () {
      test('creates timeline event', () async {
        final event = await repository.createTimelineEvent(
          'inc_123',
          'detection',
          'Incident detected by monitoring',
          'prometheus',
        );
        expect(event.timelineId, isNotEmpty);
        expect(event.eventType, equals('detection'));
      });

      test('retrieves timeline for incident', () async {
        final event = await repository.createTimelineEvent(
          'inc_456',
          'update',
          'Status updated',
          'user',
        );
        final timeline = await repository.getIncidentTimeline('inc_456');
        expect(timeline.isNotEmpty, isTrue);
        expect(timeline.first.eventType, equals('update'));
      });

      test('gets timeline event count', () async {
        for (int i = 0; i < 3; i++) {
          await repository.createTimelineEvent('inc_789', 'update', 'Update $i', 'user');
        }
        final count = await repository.getTimelineEventCount('inc_789');
        expect(count, greaterThanOrEqualTo(3));
      });
    });

    group('Repository: Impact Analysis', () {
      test('analyzes incident impact', () async {
        final analysis = await repository.analyzeIncidentImpact('inc_123');
        expect(analysis.analysisId, isNotEmpty);
        expect(analysis.incidentId, equals('inc_123'));
      });

      test('gets high impact incidents', () async {
        final analysis = await repository.analyzeIncidentImpact('inc_123');
        final highImpact = await repository.getHighImpactIncidents();
        expect(highImpact, isNotEmpty);
      });

      test('calculates total revenue loss', () async {
        await repository.analyzeIncidentImpact('inc_1');
        await repository.analyzeIncidentImpact('inc_2');
        final loss = await repository.calculateTotalRevenueLoss(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(loss, greaterThanOrEqualTo(0));
      });
    });

    group('Repository: Escalation Management', () {
      test('escalates incident', () async {
        final escalation = await repository.escalateIncident(
          'inc_123',
          2,
          'manager',
          'Critical issue',
        );
        expect(escalation.escalationLevel, equals(2));
        expect(escalation.isPending, isTrue);
      });

      test('gets pending escalations', () async {
        await repository.escalateIncident('inc_1', 1, 'lead', 'High priority');
        final pending = await repository.getPendingEscalations();
        expect(pending.isNotEmpty, isTrue);
      });

      test('acknowledges escalation', () async {
        final escalation = await repository.escalateIncident('inc_123', 1, 'lead', 'Urgent');
        await repository.acknowledgeEscalation(escalation.escalationId);
        final retrieved = await repository.getEscalation(escalation.escalationId);
        expect(retrieved!.isAcknowledged, isTrue);
      });
    });

    group('Repository: Communication', () {
      test('sends communication', () async {
        final comm = await repository.sendCommunication(
          'inc_123',
          'email',
          'team@example.com',
          'Incident alert',
          'system',
        );
        expect(comm.communicationId, isNotEmpty);
        expect(comm.recipient, equals('team@example.com'));
      });

      test('gets incident communications', () async {
        await repository.sendCommunication('inc_456', 'slack', 'channel', 'Alert', 'system');
        await repository.sendCommunication('inc_456', 'email', 'admin@example.com', 'Alert', 'system');
        final comms = await repository.getIncidentCommunications('inc_456');
        expect(comms.length, greaterThanOrEqualTo(2));
      });

      test('marks communication as read', () async {
        final comm = await repository.sendCommunication(
          'inc_789',
          'email',
          'user@example.com',
          'Message',
          'system',
        );
        await repository.markCommunicationAsRead(comm.communicationId);
        final retrieved = await repository.getCommunication(comm.communicationId);
        expect(retrieved!.isRead, isTrue);
      });

      test('gets pending communication count', () async {
        await repository.sendCommunication('inc_1', 'email', 'test@example.com', 'Msg', 'sys');
        final pending = await repository.getPendingCommunicationCount();
        expect(pending, greaterThanOrEqualTo(1));
      });
    });

    group('Repository: Resolution', () {
      test('records resolution', () async {
        final resolution = await repository.recordResolution(
          'inc_123',
          ResolutionType.rollback,
          'Rolled back to v1.2.3',
          'team',
        );
        expect(resolution.resolutionId, isNotEmpty);
        expect(resolution.resolutionType, equals(ResolutionType.rollback));
      });

      test('verifies resolution', () async {
        final resolution = await repository.recordResolution(
          'inc_456',
          ResolutionType.fix,
          'Applied patch',
          'team',
        );
        await repository.verifyResolution(resolution.resolutionId, 'All tests passed');
        final verified = await repository.getResolution(resolution.resolutionId);
        expect(verified!.isVerified, isTrue);
      });

      test('gets unverified resolutions', () async {
        await repository.recordResolution('inc_1', ResolutionType.fix, 'Fix applied', 'user');
        final unverified = await repository.getUnverifiedResolutions();
        expect(unverified.isNotEmpty, isTrue);
      });
    });

    group('Repository: Postmortem', () {
      test('creates postmortem', () async {
        final postmortem = await repository.createPostmortem(
          'inc_123',
          'Database Outage PM',
          'Connection pool exhaustion',
          'lead',
        );
        expect(postmortem.postmortemId, isNotEmpty);
        expect(postmortem.status, equals(PostmortemStatus.draft));
      });

      test('publishes postmortem', () async {
        final postmortem = await repository.createPostmortem(
          'inc_456',
          'API Timeout PM',
          'Slow database queries',
          'engineer',
        );
        await repository.publishPostmortem(postmortem.postmortemId);
        final published = await repository.getPostmortem(postmortem.postmortemId);
        expect(published!.isPublished, isTrue);
      });

      test('gets pending postmortems', () async {
        await repository.createPostmortem('inc_1', 'PM1', 'RCA1', 'user');
        final pending = await repository.getPendingPostmortems();
        expect(pending.isNotEmpty, isTrue);
      });
    });

    group('Repository: Notification', () {
      test('creates notification', () async {
        final notif = await repository.createNotification(
          'inc_123',
          'email',
          ['team@example.com'],
          'Critical Incident',
          'API is down',
        );
        expect(notif.notificationId, isNotEmpty);
      });

      test('records notification sent', () async {
        final notif = await repository.createNotification(
          'inc_456',
          'sms',
          ['1234567890'],
          'Alert',
          'Service degraded',
        );
        await repository.recordNotificationSent(notif.notificationId, 1, 0);
        final recorded = await repository.getNotification(notif.notificationId);
        expect(recorded!.isSent, isTrue);
      });

      test('gets unsent notifications', () async {
        await repository.createNotification('inc_1', 'email', ['test@example.com'], 'Subj', 'Body');
        final unsent = await repository.getUnsentNotifications();
        expect(unsent.isNotEmpty, isTrue);
      });
    });

    // ========== ENGINE TESTS ==========
    group('Detection Engine', () {
      test('detects incident severity', () async {
        final incident = await detectionEngine.detectAndCreateIncident(
          'Critical API Down',
          'API not responding',
          IncidentSeverity.critical,
        );
        expect(incident.severity, equals(IncidentSeverity.critical));
        expect(incident.priority, equals(IncidentPriority.p0));
      });

      test('maps severity to priority', () async {
        final critical = await detectionEngine.detectAndCreateIncident('T', 'D', IncidentSeverity.critical);
        final info = await detectionEngine.detectAndCreateIncident('T', 'D', IncidentSeverity.info);
        expect(critical.priority, equals(IncidentPriority.p0));
        expect(info.priority, equals(IncidentPriority.p4));
      });
    });

    group('Escalation Engine', () {
      test('escalates critical incidents', () async {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Critical',
          description: 'Desc',
          severity: IncidentSeverity.critical,
          status: IncidentStatus.open,
          priority: IncidentPriority.p0,
          createdAt: DateTime.now(),
          assignedTo: 'team',
          affectedServices: [],
          affectedUsers: [],
        );
        final escalation = await escalationEngine.determineEscalation(incident);
        expect(escalation.escalationLevel, greaterThan(0));
      });
    });

    group('Impact Analysis Engine', () {
      test('analyzes incident impact', () async {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Test',
          description: 'Desc',
          severity: IncidentSeverity.high,
          status: IncidentStatus.open,
          priority: IncidentPriority.p1,
          createdAt: DateTime.now(),
          assignedTo: 'team',
          affectedServices: ['svc1', 'svc2', 'svc3'],
          affectedUsers: List.generate(1000, (i) => 'user$i'),
        );
        final analysis = await impactEngine.analyzeImpact(incident);
        expect(analysis.estimatedAffectedUsers, greaterThan(0));
      });
    });

    group('Resolution Engine', () {
      test('recommends resolution type', () async {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Critical',
          description: 'Desc',
          severity: IncidentSeverity.critical,
          status: IncidentStatus.open,
          priority: IncidentPriority.p0,
          createdAt: DateTime.now(),
          assignedTo: 'team',
          affectedServices: [],
          affectedUsers: [],
        );
        final resolution = await resolutionEngine.recommendResolution(incident);
        expect(resolution.resolutionType, isNotNull);
      });
    });

    group('Postmortem Generation Engine', () {
      test('generates postmortem', () async {
        final incident = Incident(
          incidentId: 'inc_123',
          title: 'Test Incident',
          description: 'Desc',
          severity: IncidentSeverity.high,
          status: IncidentStatus.resolved,
          priority: IncidentPriority.p1,
          createdAt: DateTime.now(),
          assignedTo: 'team',
          affectedServices: [],
          affectedUsers: [],
        );
        final pm = await postmortemEngine.generatePostmortem(incident, 'Root cause identified');
        expect(pm.incidentId, equals('inc_123'));
        expect(pm.status, equals(PostmortemStatus.draft));
      });
    });

    // ========== MANAGER TESTS ==========
    group('Manager: Coordination', () {
      test('creates and processes incident', () async {
        final incident = await manager.createAndProcessIncident(
          'Database Down',
          'Unable to connect',
          IncidentSeverity.critical,
        );
        expect(incident.incidentId, isNotEmpty);
        expect(incident.isCritical, isTrue);
      });

      test('resolves incident', () async {
        final incident = await repository.createIncident(
          'Test',
          'Desc',
          IncidentSeverity.medium,
          'team',
        );
        await manager.resolveIncident(incident.incidentId, ResolutionType.fix);
        final resolved = await repository.getIncident(incident.incidentId);
        expect(resolved!.isResolved, isTrue);
      });
    });

    // ========== FACADE TESTS ==========
    group('Facade: Public API', () {
      test('reports incident', () async {
        final incident = await facade.reportIncident(
          'API Timeout',
          'API endpoints timing out',
          IncidentSeverity.high,
        );
        expect(incident.incidentId, isNotEmpty);
      });

      test('gets critical incidents', () async {
        await facade.reportIncident('Critical', 'Desc', IncidentSeverity.critical);
        final critical = await facade.getCriticalIncidents();
        expect(critical.isNotEmpty, isTrue);
      });

      test('acknowledges incident', () async {
        final incident = await facade.reportIncident('Test', 'Desc', IncidentSeverity.medium);
        await facade.acknowledgeIncident(incident.incidentId, 'Investigating');
        final acked = await facade.getIncidentDetails(incident.incidentId);
        expect(acked!.status, equals(IncidentStatus.acknowledged));
      });

      test('resolves incident via facade', () async {
        final incident = await facade.reportIncident('Bug', 'Desc', IncidentSeverity.low);
        await facade.resolveIncident(incident.incidentId, ResolutionType.fix);
        final resolved = await facade.getIncidentDetails(incident.incidentId);
        expect(resolved!.isResolved, isTrue);
      });

      test('generates report', () async {
        await facade.reportIncident('Inc1', 'Desc', IncidentSeverity.high);
        await facade.reportIncident('Inc2', 'Desc', IncidentSeverity.medium);
        final report = await facade.generateReport(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(report.reportId, isNotEmpty);
        expect(report.totalIncidents, greaterThanOrEqualTo(2));
      });
    });

    // ========== INTEGRATION TESTS ==========
    group('Integration: Full Incident Workflow', () {
      test('complete incident lifecycle', () async {
        final incident = await facade.reportIncident(
          'Critical Database Outage',
          'Production database unreachable',
          IncidentSeverity.critical,
        );

        await repository.createTimelineEvent(
          incident.incidentId,
          'detection',
          'Incident detected',
          'monitoring',
        );

        final analysis = await facade.analyzeIncidentImpact(incident.incidentId);
        expect(analysis.estimatedAffectedUsers, greaterThan(0));

        await facade.acknowledgeIncident(incident.incidentId, 'Investigating');

        await facade.resolveIncident(incident.incidentId, ResolutionType.rollback);

        final final_incident = await facade.getIncidentDetails(incident.incidentId);
        expect(final_incident!.isResolved, isTrue);
      });

      test('handles multiple concurrent incidents', () async {
        final incidents = <Incident>[];
        for (int i = 0; i < 5; i++) {
          final incident = await facade.reportIncident(
            'Incident $i',
            'Description $i',
            i % 2 == 0 ? IncidentSeverity.high : IncidentSeverity.medium,
          );
          incidents.add(incident);
        }
        expect(incidents.length, equals(5));
        final openList = await facade.getOpenIncidents();
        expect(openList.length, greaterThanOrEqualTo(5));
      });

      test('escalates and resolves critical incident', () async {
        final incident = await facade.reportIncident(
          'Critical Issue',
          'Needs immediate attention',
          IncidentSeverity.critical,
        );

        final escalation = await repository.escalateIncident(
          incident.incidentId,
          2,
          'director',
          'Critical impact',
        );
        expect(escalation.escalationLevel, equals(2));

        await repository.acknowledgeEscalation(escalation.escalationId);
        await facade.resolveIncident(incident.incidentId, ResolutionType.fix);

        final resolved = await facade.getIncidentDetails(incident.incidentId);
        expect(resolved!.isResolved, isTrue);
      });
    });

    // ========== EDGE CASES & PERFORMANCE ==========
    group('Edge Cases', () {
      test('handles missing incident gracefully', () async {
        final result = await repository.getIncident('nonexistent_id');
        expect(result, isNull);
      });

      test('handles empty timeline', () async {
        final timeline = await repository.getIncidentTimeline('inc_no_events');
        expect(timeline.isEmpty, isTrue);
      });

      test('handles incident with no affected services', () async {
        final incident = await repository.createIncident(
          'Test',
          'No services affected',
          IncidentSeverity.info,
          'team',
        );
        expect(incident.affectedServices.isEmpty, isTrue);
        expect(incident.affectedUsers.isEmpty, isTrue);
      });

      test('calculates metrics with zero incidents', () async {
        final metrics = await repository.getIncidentMetrics();
        expect(metrics, isA<Map<String, int>>());
      });
    });

    group('Performance', () {
      test('handles bulk incident creation', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createIncident(
            'Incident $i',
            'Description $i',
            IncidentSeverity.values[i % 5],
            'team_$i',
          );
        }
        final list = await repository.listIncidents(limit: 100);
        expect(list.length, greaterThanOrEqualTo(50));
      });

      test('retrieves incidents efficiently', () async {
        for (int i = 0; i < 20; i++) {
          await repository.createIncident(
            'Perf Test $i',
            'Test',
            IncidentSeverity.medium,
            'team',
          );
        }
        final start = DateTime.now();
        final incidents = await repository.listIncidents();
        final duration = DateTime.now().difference(start);
        expect(incidents.isNotEmpty, isTrue);
        expect(duration.inMilliseconds, lessThan(5000));
      });
    });
  });
}
