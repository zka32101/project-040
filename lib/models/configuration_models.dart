/// Configuration Management Models

enum ConfigType { application, system, database, network, storage, security, custom }
enum ConfigStatus { draft, active, deprecated, archived, suspended }
enum ValueType { string, integer, boolean, decimal, json, secret, list, map }
enum ValidationStatus { valid, invalid, pending, warning }
enum DeploymentStage { development, staging, production, rollback }
enum ConfigChangeType { create, update, delete, rollback, override }

class ConfigurationItem {
  final String itemId;
  final String itemName;
  final String description;
  final ConfigType configType;
  final ValueType valueType;
  final dynamic defaultValue;
  final dynamic currentValue;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final String? modifiedBy;
  final List<String> tags;
  final bool isRequired;

  ConfigurationItem({
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.configType,
    required this.valueType,
    required this.defaultValue,
    required this.currentValue,
    required this.createdAt,
    this.modifiedAt,
    this.modifiedBy,
    required this.tags,
    this.isRequired = false,
  });

  bool get hasChanged => currentValue != defaultValue;
  bool get isModified => modifiedAt != null;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isSecret => valueType == ValueType.secret;
}

class ConfigurationVersion {
  final String versionId;
  final String itemId;
  final int versionNumber;
  final dynamic value;
  final String createdBy;
  final DateTime createdAt;
  final String? changeReason;
  final ConfigChangeType changeType;
  final bool isActive;

  ConfigurationVersion({
    required this.versionId,
    required this.itemId,
    required this.versionNumber,
    required this.value,
    required this.createdBy,
    required this.createdAt,
    this.changeReason,
    required this.changeType,
    this.isActive = false,
  });

  bool get isRecent => DateTime.now().difference(createdAt).inDays < 7;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ConfigurationProfile {
  final String profileId;
  final String profileName;
  final String description;
  final ConfigStatus status;
  final Map<String, dynamic> configurations;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final String? activatedBy;
  final int priority;

  ConfigurationProfile({
    required this.profileId,
    required this.profileName,
    required this.description,
    required this.status,
    required this.configurations,
    required this.createdAt,
    this.activatedAt,
    this.activatedBy,
    this.priority = 0,
  });

  bool get isActive => status == ConfigStatus.active;
  bool get isDeprecated => status == ConfigStatus.deprecated;
  int get configCount => configurations.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ConfigurationTemplate {
  final String templateId;
  final String templateName;
  final String description;
  final ConfigType applicableType;
  final Map<String, ValueType> schema;
  final Map<String, dynamic> defaultValues;
  final DateTime createdAt;
  final bool isReadOnly;
  final List<String> supportedEnvironments;

  ConfigurationTemplate({
    required this.templateId,
    required this.templateName,
    required this.description,
    required this.applicableType,
    required this.schema,
    required this.defaultValues,
    required this.createdAt,
    this.isReadOnly = false,
    required this.supportedEnvironments,
  });

  bool get hasSchema => schema.isNotEmpty;
  int get fieldCount => schema.length;
  int get environmentCount => supportedEnvironments.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ConfigurationValidation {
  final String validationId;
  final String itemId;
  final ValidationStatus status;
  final DateTime validatedAt;
  final List<String> errorMessages;
  final List<String> warningMessages;
  final String? validationRules;
  final double validationScore;

  ConfigurationValidation({
    required this.validationId,
    required this.itemId,
    required this.status,
    required this.validatedAt,
    required this.errorMessages,
    required this.warningMessages,
    this.validationRules,
    required this.validationScore,
  });

  bool get isValid => status == ValidationStatus.valid;
  bool get hasErrors => errorMessages.isNotEmpty;
  bool get hasWarnings => warningMessages.isNotEmpty;
  int get totalIssues => errorMessages.length + warningMessages.length;
  int get ageInHours => DateTime.now().difference(validatedAt).inHours;
}

class ConfigurationEnvironment {
  final String environmentId;
  final String environmentName;
  final DeploymentStage stage;
  final Map<String, dynamic> overrides;
  final DateTime createdAt;
  final bool isProduction;
  final int replicaCount;
  final String? description;

  ConfigurationEnvironment({
    required this.environmentId,
    required this.environmentName,
    required this.stage,
    required this.overrides,
    required this.createdAt,
    this.isProduction = false,
    this.replicaCount = 1,
    this.description,
  });

  bool get hasOverrides => overrides.isNotEmpty;
  int get overrideCount => overrides.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ConfigurationAudit {
  final String auditId;
  final String itemId;
  final String modifiedBy;
  final ConfigChangeType changeType;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime modifiedAt;
  final String? reason;
  final Map<String, dynamic> metadata;

  ConfigurationAudit({
    required this.auditId,
    required this.itemId,
    required this.modifiedBy,
    required this.changeType,
    required this.oldValue,
    required this.newValue,
    required this.modifiedAt,
    this.reason,
    required this.metadata,
  });

  bool get hasChanged => oldValue != newValue;
  int get ageInDays => DateTime.now().difference(modifiedAt).inDays;
  bool get isRecent => DateTime.now().difference(modifiedAt).inHours < 24;
}

class ConfigurationDeployment {
  final String deploymentId;
  final String profileId;
  final DeploymentStage targetStage;
  final DateTime deployedAt;
  final String deployedBy;
  final bool isSuccessful;
  final String? errorMessage;
  final int affectedItemCount;
  final DateTime? completedAt;

  ConfigurationDeployment({
    required this.deploymentId,
    required this.profileId,
    required this.targetStage,
    required this.deployedAt,
    required this.deployedBy,
    required this.isSuccessful,
    this.errorMessage,
    required this.affectedItemCount,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;
  bool get isPending => !isCompleted;
  int get durationInSeconds => isCompleted ? completedAt!.difference(deployedAt).inSeconds : 0;
  int get ageInHours => DateTime.now().difference(deployedAt).inHours;
}

class ConfigurationRollback {
  final String rollbackId;
  final String deploymentId;
  final String targetVersionId;
  final DateTime initiatedAt;
  final String initiatedBy;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? reason;

  ConfigurationRollback({
    required this.rollbackId,
    required this.deploymentId,
    required this.targetVersionId,
    required this.initiatedAt,
    required this.initiatedBy,
    this.isCompleted = false,
    this.completedAt,
    this.reason,
  });

  bool get isPending => !isCompleted;
  int get ageInHours => DateTime.now().difference(initiatedAt).inHours;
  int get durationInSeconds => isCompleted ? completedAt!.difference(initiatedAt).inSeconds : 0;
}

class ConfigurationBackup {
  final String backupId;
  final String profileId;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, dynamic> backupData;
  final int backupSize;
  final bool isRestored;
  final DateTime? restoredAt;

  ConfigurationBackup({
    required this.backupId,
    required this.profileId,
    required this.createdAt,
    required this.createdBy,
    required this.backupData,
    required this.backupSize,
    this.isRestored = false,
    this.restoredAt,
  });

  bool get isPending => !isRestored;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isRecent => ageInDays < 30;
}
