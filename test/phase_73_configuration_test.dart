import 'package:flutter_test/flutter_test.dart';
import '../lib/models/configuration_models.dart';
import '../lib/services/configuration_service.dart';

void main() {
  group('Phase 73: Configuration Management', () {
    late ConfigurationRepository repository;
    late ConfigurationFacade facade;

    setUp(() {
      repository = MemoryConfigurationRepository();
      final configEngine = ConfigurationEngine(repository: repository);
      final profileEngine = ProfileManagementEngine(repository: repository);
      final deploymentEngine = DeploymentEngine(repository: repository);
      final validationEngine = ValidationEngine(repository: repository);
      final backupEngine = BackupEngine(repository: repository);
      final manager = ConfigurationManager(
        repository: repository,
        configEngine: configEngine,
        profileEngine: profileEngine,
        deploymentEngine: deploymentEngine,
        validationEngine: validationEngine,
        backupEngine: backupEngine,
      );
      facade = ConfigurationFacade(manager: manager);
    });

    // Enum Tests
    group('Enums', () {
      test('ConfigType contains all values', () {
        expect(ConfigType.values.length, equals(7));
      });

      test('ConfigStatus contains all values', () {
        expect(ConfigStatus.values.length, equals(5));
      });

      test('ValueType contains all values', () {
        expect(ValueType.values.length, equals(8));
      });

      test('ValidationStatus contains all values', () {
        expect(ValidationStatus.values.length, equals(4));
      });

      test('DeploymentStage contains all values', () {
        expect(DeploymentStage.values.length, equals(4));
      });

      test('ConfigChangeType contains all values', () {
        expect(ConfigChangeType.values.length, equals(5));
      });
    });

    // ConfigurationItem Tests
    group('ConfigurationItem', () {
      test('create configuration item', () {
        final item = ConfigurationItem(
          itemId: 'item_1',
          itemName: 'App Name',
          description: 'Application name',
          configType: ConfigType.application,
          valueType: ValueType.string,
          defaultValue: 'MyApp',
          currentValue: 'MyApp',
          createdAt: DateTime.now(),
          tags: ['app', 'name'],
        );

        expect(item.hasChanged, isFalse);
        expect(item.isModified, isFalse);
      });

      test('item with changed value', () {
        final item = ConfigurationItem(
          itemId: 'item_2',
          itemName: 'Debug Mode',
          description: 'Debug flag',
          configType: ConfigType.application,
          valueType: ValueType.boolean,
          defaultValue: false,
          currentValue: true,
          createdAt: DateTime.now(),
          tags: [],
        );

        expect(item.hasChanged, isTrue);
      });

      test('secret value detection', () {
        final item = ConfigurationItem(
          itemId: 'item_3',
          itemName: 'API Key',
          description: 'Secret API key',
          configType: ConfigType.security,
          valueType: ValueType.secret,
          defaultValue: null,
          currentValue: 'secret_key_123',
          createdAt: DateTime.now(),
          tags: [],
        );

        expect(item.isSecret, isTrue);
      });
    });

    // ConfigurationVersion Tests
    group('ConfigurationVersion', () {
      test('create configuration version', () {
        final version = ConfigurationVersion(
          versionId: 'ver_1',
          itemId: 'item_1',
          versionNumber: 1,
          value: 'v1.0.0',
          createdBy: 'user_1',
          createdAt: DateTime.now(),
          changeType: ConfigChangeType.create,
          isActive: true,
        );

        expect(version.isActive, isTrue);
        expect(version.isRecent, isTrue);
      });

      test('version aging', () {
        final version = ConfigurationVersion(
          versionId: 'ver_2',
          itemId: 'item_1',
          versionNumber: 5,
          value: 'v1.5.0',
          createdBy: 'user_1',
          createdAt: DateTime.now().subtract(Duration(days: 40)),
          changeType: ConfigChangeType.update,
        );

        expect(version.ageInDays, greaterThanOrEqualTo(40));
        expect(version.isRecent, isFalse);
      });
    });

    // ConfigurationProfile Tests
    group('ConfigurationProfile', () {
      test('create configuration profile', () {
        final profile = ConfigurationProfile(
          profileId: 'profile_1',
          profileName: 'Production',
          description: 'Production settings',
          status: ConfigStatus.draft,
          configurations: {'timeout': 30, 'retries': 3},
          createdAt: DateTime.now(),
        );

        expect(profile.isActive, isFalse);
        expect(profile.configCount, equals(2));
      });

      test('active profile', () {
        final profile = ConfigurationProfile(
          profileId: 'profile_2',
          profileName: 'Development',
          description: 'Dev settings',
          status: ConfigStatus.active,
          configurations: {},
          createdAt: DateTime.now(),
          activatedAt: DateTime.now(),
          activatedBy: 'admin',
        );

        expect(profile.isActive, isTrue);
      });

      test('deprecated profile', () {
        final profile = ConfigurationProfile(
          profileId: 'profile_3',
          profileName: 'Legacy',
          description: 'Old settings',
          status: ConfigStatus.deprecated,
          configurations: {},
          createdAt: DateTime.now().subtract(Duration(days: 180)),
        );

        expect(profile.isDeprecated, isTrue);
      });
    });

    // ConfigurationTemplate Tests
    group('ConfigurationTemplate', () {
      test('create configuration template', () {
        final template = ConfigurationTemplate(
          templateId: 'template_1',
          templateName: 'Database Config',
          description: 'Database configuration template',
          applicableType: ConfigType.database,
          schema: {'host': ValueType.string, 'port': ValueType.integer, 'ssl': ValueType.boolean},
          defaultValues: {'port': 5432, 'ssl': true},
          createdAt: DateTime.now(),
          supportedEnvironments: ['dev', 'staging', 'prod'],
        );

        expect(template.hasSchema, isTrue);
        expect(template.fieldCount, equals(3));
        expect(template.environmentCount, equals(3));
      });
    });

    // ConfigurationValidation Tests
    group('ConfigurationValidation', () {
      test('valid configuration', () {
        final validation = ConfigurationValidation(
          validationId: 'val_1',
          itemId: 'item_1',
          status: ValidationStatus.valid,
          validatedAt: DateTime.now(),
          errorMessages: [],
          warningMessages: [],
          validationScore: 1.0,
        );

        expect(validation.isValid, isTrue);
        expect(validation.hasErrors, isFalse);
        expect(validation.totalIssues, equals(0));
      });

      test('invalid configuration with errors', () {
        final validation = ConfigurationValidation(
          validationId: 'val_2',
          itemId: 'item_2',
          status: ValidationStatus.invalid,
          validatedAt: DateTime.now(),
          errorMessages: ['Missing required field', 'Invalid format'],
          warningMessages: ['Performance might be affected'],
          validationScore: 0.3,
        );

        expect(validation.isValid, isFalse);
        expect(validation.hasErrors, isTrue);
        expect(validation.hasWarnings, isTrue);
        expect(validation.totalIssues, equals(3));
      });
    });

    // ConfigurationEnvironment Tests
    group('ConfigurationEnvironment', () {
      test('create environment with overrides', () {
        final env = ConfigurationEnvironment(
          environmentId: 'env_1',
          environmentName: 'Production',
          stage: DeploymentStage.production,
          overrides: {'timeout': 60, 'log_level': 'error'},
          createdAt: DateTime.now(),
          isProduction: true,
          replicaCount: 5,
        );

        expect(env.isProduction, isTrue);
        expect(env.hasOverrides, isTrue);
        expect(env.overrideCount, equals(2));
      });

      test('development environment', () {
        final env = ConfigurationEnvironment(
          environmentId: 'env_2',
          environmentName: 'Development',
          stage: DeploymentStage.development,
          overrides: {},
          createdAt: DateTime.now(),
          isProduction: false,
          replicaCount: 1,
        );

        expect(env.isProduction, isFalse);
        expect(env.hasOverrides, isFalse);
      });
    });

    // ConfigurationAudit Tests
    group('ConfigurationAudit', () {
      test('audit trail for configuration change', () {
        final audit = ConfigurationAudit(
          auditId: 'audit_1',
          itemId: 'item_1',
          modifiedBy: 'user_1',
          changeType: ConfigChangeType.update,
          oldValue: 'old_value',
          newValue: 'new_value',
          modifiedAt: DateTime.now(),
          reason: 'Performance tuning',
          metadata: {},
        );

        expect(audit.hasChanged, isTrue);
        expect(audit.isRecent, isTrue);
      });

      test('no change audit', () {
        final audit = ConfigurationAudit(
          auditId: 'audit_2',
          itemId: 'item_2',
          modifiedBy: 'user_2',
          changeType: ConfigChangeType.update,
          oldValue: 'same_value',
          newValue: 'same_value',
          modifiedAt: DateTime.now(),
          metadata: {},
        );

        expect(audit.hasChanged, isFalse);
      });
    });

    // ConfigurationDeployment Tests
    group('ConfigurationDeployment', () {
      test('successful deployment', () {
        final deployment = ConfigurationDeployment(
          deploymentId: 'deploy_1',
          profileId: 'profile_1',
          targetStage: DeploymentStage.production,
          deployedAt: DateTime.now(),
          deployedBy: 'admin',
          isSuccessful: true,
          affectedItemCount: 5,
          completedAt: DateTime.now(),
        );

        expect(deployment.isCompleted, isTrue);
        expect(deployment.isPending, isFalse);
        expect(deployment.durationInSeconds, greaterThanOrEqualTo(0));
      });

      test('pending deployment', () {
        final deployment = ConfigurationDeployment(
          deploymentId: 'deploy_2',
          profileId: 'profile_1',
          targetStage: DeploymentStage.staging,
          deployedAt: DateTime.now(),
          deployedBy: 'user_1',
          isSuccessful: false,
          errorMessage: 'Validation failed',
          affectedItemCount: 3,
        );

        expect(deployment.isPending, isTrue);
        expect(deployment.isCompleted, isFalse);
      });
    });

    // ConfigurationRollback Tests
    group('ConfigurationRollback', () {
      test('pending rollback', () {
        final rollback = ConfigurationRollback(
          rollbackId: 'rollback_1',
          deploymentId: 'deploy_1',
          targetVersionId: 'ver_1',
          initiatedAt: DateTime.now(),
          initiatedBy: 'admin',
          isCompleted: false,
          reason: 'Issues detected',
        );

        expect(rollback.isPending, isTrue);
        expect(rollback.isCompleted, isFalse);
      });

      test('completed rollback', () {
        final rollback = ConfigurationRollback(
          rollbackId: 'rollback_2',
          deploymentId: 'deploy_2',
          targetVersionId: 'ver_2',
          initiatedAt: DateTime.now().subtract(Duration(hours: 2)),
          initiatedBy: 'admin',
          isCompleted: true,
          completedAt: DateTime.now(),
          reason: 'Service recovery',
        );

        expect(rollback.isCompleted, isTrue);
        expect(rollback.durationInSeconds, greaterThan(0));
      });
    });

    // ConfigurationBackup Tests
    group('ConfigurationBackup', () {
      test('create backup', () {
        final backup = ConfigurationBackup(
          backupId: 'backup_1',
          profileId: 'profile_1',
          createdAt: DateTime.now(),
          createdBy: 'admin',
          backupData: {'config1': 'value1', 'config2': 'value2'},
          backupSize: 1024,
        );

        expect(backup.isRestored, isFalse);
        expect(backup.isPending, isTrue);
        expect(backup.isRecent, isTrue);
      });

      test('restored backup', () {
        final backup = ConfigurationBackup(
          backupId: 'backup_2',
          profileId: 'profile_1',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          createdBy: 'admin',
          backupData: {},
          backupSize: 512,
          isRestored: true,
          restoredAt: DateTime.now().subtract(Duration(hours: 2)),
        );

        expect(backup.isRestored, isTrue);
        expect(backup.isPending, isFalse);
      });
    });

    // Repository Tests
    group('MemoryConfigurationRepository', () {
      test('create and retrieve item', () async {
        final item = ConfigurationItem(
          itemId: 'item_repo_1',
          itemName: 'Test Item',
          description: 'Test',
          configType: ConfigType.application,
          valueType: ValueType.string,
          defaultValue: 'default',
          currentValue: 'current',
          createdAt: DateTime.now(),
          tags: [],
        );

        await repository.createConfigurationItem(item);
        final retrieved = await repository.getConfigurationItem('item_repo_1');

        expect(retrieved, isNotNull);
        expect(retrieved?.itemName, equals('Test Item'));
      });

      test('get items by type', () async {
        final appItem = ConfigurationItem(
          itemId: 'item_app',
          itemName: 'App Config',
          description: 'App',
          configType: ConfigType.application,
          valueType: ValueType.string,
          defaultValue: 'app',
          currentValue: 'app',
          createdAt: DateTime.now(),
          tags: [],
        );

        final dbItem = ConfigurationItem(
          itemId: 'item_db',
          itemName: 'DB Config',
          description: 'Database',
          configType: ConfigType.database,
          valueType: ValueType.string,
          defaultValue: 'db',
          currentValue: 'db',
          createdAt: DateTime.now(),
          tags: [],
        );

        await repository.createConfigurationItem(appItem);
        await repository.createConfigurationItem(dbItem);
        final appItems = await repository.getItemsByType(ConfigType.application);

        expect(appItems.length, equals(1));
      });

      test('get active profiles', () async {
        final activeProfile = ConfigurationProfile(
          profileId: 'profile_active',
          profileName: 'Active',
          description: 'Active profile',
          status: ConfigStatus.active,
          configurations: {},
          createdAt: DateTime.now(),
        );

        final draftProfile = ConfigurationProfile(
          profileId: 'profile_draft',
          profileName: 'Draft',
          description: 'Draft profile',
          status: ConfigStatus.draft,
          configurations: {},
          createdAt: DateTime.now(),
        );

        await repository.createConfigurationProfile(activeProfile);
        await repository.createConfigurationProfile(draftProfile);
        final active = await repository.getActiveProfiles();

        expect(active.length, equals(1));
      });

      test('get failed validations', () async {
        final failedVal = ConfigurationValidation(
          validationId: 'val_failed',
          itemId: 'item_1',
          status: ValidationStatus.invalid,
          validatedAt: DateTime.now(),
          errorMessages: ['Error'],
          warningMessages: [],
          validationScore: 0.0,
        );

        await repository.createValidation(failedVal);
        final failed = await repository.getFailedValidations();

        expect(failed.isNotEmpty, isTrue);
      });
    });

    // Facade Integration Tests
    group('ConfigurationFacade Integration', () {
      test('create and update configuration item', () async {
        final item = await facade.createConfigItem('Timeout', ConfigType.application, ValueType.integer, 30);
        expect(item.currentValue, equals(30));

        await facade.updateItemValue(item.itemId, 60, 'admin', 'Performance tuning');

        final updated = await repository.getConfigurationItem(item.itemId);
        expect(updated?.currentValue, equals(60));
      });

      test('profile lifecycle', () async {
        final profile = await facade.createProfile('Staging', {'timeout': 45, 'retries': 2});
        expect(profile.isActive, isFalse);

        await facade.activateProfile(profile.profileId, 'admin');

        final active = await facade.getActiveProfiles();
        expect(active.isNotEmpty, isTrue);
      });

      test('deployment workflow', () async {
        final deployment = await facade.deployProfile('profile_1', DeploymentStage.staging, 'admin', 5);
        expect(deployment.isPending, isTrue);

        await facade.completeDeployment(deployment.deploymentId);

        final pending = await facade.getPendingDeployments();
        final stillPending = pending.where((d) => d.deploymentId == deployment.deploymentId).isEmpty;
        expect(stillPending, isTrue);
      });

      test('backup and restore', () async {
        final backup = await facade.createBackup('profile_1', 'admin', {'key': 'value'});
        expect(backup.isRestored, isFalse);

        await facade.restoreBackup(backup.backupId);

        final restored = await repository.getBackup(backup.backupId);
        expect(restored?.isRestored, isTrue);
      });
    });

    // Edge Cases
    group('Edge Cases', () {
      test('empty configuration profile', () {
        final profile = ConfigurationProfile(
          profileId: 'profile_empty',
          profileName: 'Empty',
          description: 'Empty config',
          status: ConfigStatus.draft,
          configurations: {},
          createdAt: DateTime.now(),
        );

        expect(profile.configCount, equals(0));
      });

      test('configuration with null modifiedBy', () {
        final item = ConfigurationItem(
          itemId: 'item_no_mod',
          itemName: 'Never Modified',
          description: 'Original',
          configType: ConfigType.application,
          valueType: ValueType.string,
          defaultValue: 'default',
          currentValue: 'default',
          createdAt: DateTime.now(),
          modifiedBy: null,
          tags: [],
        );

        expect(item.isModified, isFalse);
      });

      test('validation with only warnings', () {
        final validation = ConfigurationValidation(
          validationId: 'val_warn_only',
          itemId: 'item_1',
          status: ValidationStatus.warning,
          validatedAt: DateTime.now(),
          errorMessages: [],
          warningMessages: ['Warning 1', 'Warning 2'],
          validationScore: 0.8,
        );

        expect(validation.hasErrors, isFalse);
        expect(validation.hasWarnings, isTrue);
        expect(validation.isValid, isFalse);
      });

      test('deployment with zero affected items', () {
        final deployment = ConfigurationDeployment(
          deploymentId: 'deploy_zero',
          profileId: 'profile_1',
          targetStage: DeploymentStage.production,
          deployedAt: DateTime.now(),
          deployedBy: 'admin',
          isSuccessful: true,
          affectedItemCount: 0,
        );

        expect(deployment.affectedItemCount, equals(0));
      });
    });

    // Performance Tests
    group('Performance', () {
      test('handle large configuration volume', () async {
        for (int i = 0; i < 100; i++) {
          final item = ConfigurationItem(
            itemId: 'item_$i',
            itemName: 'Config_$i',
            description: 'Configuration item $i',
            configType: ConfigType.application,
            valueType: ValueType.string,
            defaultValue: 'value_$i',
            currentValue: 'value_$i',
            createdAt: DateTime.now(),
            tags: [],
          );
          await repository.createConfigurationItem(item);
        }

        final items = await facade.getAllConfigItems();
        expect(items.length, equals(100));
      });

      test('rapid audit logging', () async {
        for (int i = 0; i < 50; i++) {
          final audit = ConfigurationAudit(
            auditId: 'audit_$i',
            itemId: 'item_1',
            modifiedBy: 'user_1',
            changeType: ConfigChangeType.update,
            oldValue: 'old_$i',
            newValue: 'new_$i',
            modifiedAt: DateTime.now(),
            metadata: {},
          );
          await repository.recordAudit(audit);
        }

        final audits = await repository.getItemAudits('item_1');
        expect(audits.length, equals(50));
      });
    });
  });
}
