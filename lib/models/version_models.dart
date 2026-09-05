/// Version Control & History Tracking Models

enum VersionStatus { active, archived, deprecated, deleted }
enum ChangeType { minor, major, breaking }
enum MergeStrategy { fastForward, squash, threeWay, rebase }
enum ConflictResolution { accept, reject, custom, manual }
enum BranchType { main, feature, release, hotfix, develop }
enum ReleaseType { alpha, beta, rc, stable }

class ResourceVersion {
  final String versionId;
  final String resourceId;
  final String resourceType;
  final int versionNumber;
  final Map<String, dynamic> content;
  final String createdBy;
  final DateTime createdAt;
  final String? description;
  final VersionStatus status;
  final Map<String, dynamic> metadata;

  ResourceVersion({
    required this.versionId,
    required this.resourceId,
    required this.resourceType,
    required this.versionNumber,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.description,
    this.status = VersionStatus.active,
    this.metadata = const {},
  });

  bool get isActive => status == VersionStatus.active;
  bool get isArchived => status == VersionStatus.archived;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get contentSize => content.toString().length;
}

class VersionBranch {
  final String branchId;
  final String resourceId;
  final String branchName;
  final BranchType branchType;
  final int baseVersion;
  final int headVersion;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? mergedAt;
  final bool isMerged;

  VersionBranch({
    required this.branchId,
    required this.resourceId,
    required this.branchName,
    required this.branchType,
    required this.baseVersion,
    required this.headVersion,
    required this.createdBy,
    required this.createdAt,
    this.mergedAt,
    this.isMerged = false,
  });

  bool get isActive => !isMerged;
  int get versionDifference => headVersion - baseVersion;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class VersionChange {
  final String changeId;
  final String versionId;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final ChangeType changeType;
  final String description;

  VersionChange({
    required this.changeId,
    required this.versionId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.changeType,
    required this.description,
  });

  bool get hasChanged => oldValue != newValue;
  bool get isMajorChange => changeType == ChangeType.major;
  bool get isBreakingChange => changeType == ChangeType.breaking;
}

class VersionTag {
  final String tagId;
  final String resourceId;
  final String tagName;
  final int targetVersion;
  final String createdBy;
  final DateTime createdAt;
  final String? description;
  final bool isRelease;
  final ReleaseType? releaseType;

  VersionTag({
    required this.tagId,
    required this.resourceId,
    required this.tagName,
    required this.targetVersion,
    required this.createdBy,
    required this.createdAt,
    this.description,
    this.isRelease = false,
    this.releaseType,
  });

  bool get isStableRelease => isRelease && releaseType == ReleaseType.stable;
  bool get isPrerelease => isRelease && (releaseType == ReleaseType.alpha || releaseType == ReleaseType.beta || releaseType == ReleaseType.rc);
}

class VersionComparison {
  final String comparisonId;
  final String resourceId;
  final int fromVersion;
  final int toVersion;
  final List<String> changeIds;
  final DateTime createdAt;
  final Map<String, dynamic> diffSummary;

  VersionComparison({
    required this.comparisonId,
    required this.resourceId,
    required this.fromVersion,
    required this.toVersion,
    required this.changeIds,
    required this.createdAt,
    required this.diffSummary,
  });

  bool get hasChanges => changeIds.isNotEmpty;
  int get changeCount => changeIds.length;
  int get versionSpan => toVersion - fromVersion;
}

class VersionMerge {
  final String mergeId;
  final String resourceId;
  final String sourceBranch;
  final String targetBranch;
  final int sourceVersion;
  final int targetVersion;
  final int mergedVersion;
  final String createdBy;
  final DateTime createdAt;
  final MergeStrategy strategy;
  final bool hasConflicts;
  final List<String> conflictingFields;

  VersionMerge({
    required this.mergeId,
    required this.resourceId,
    required this.sourceBranch,
    required this.targetBranch,
    required this.sourceVersion,
    required this.targetVersion,
    required this.mergedVersion,
    required this.createdBy,
    required this.createdAt,
    required this.strategy,
    this.hasConflicts = false,
    this.conflictingFields = const [],
  });

  bool get isSuccessful => !hasConflicts;
  int get conflictCount => conflictingFields.length;
}

class VersionConflict {
  final String conflictId;
  final String mergeId;
  final String fieldName;
  final dynamic sourceValue;
  final dynamic targetValue;
  final dynamic currentValue;
  final DateTime detectedAt;
  final ConflictResolution? resolution;

  VersionConflict({
    required this.conflictId,
    required this.mergeId,
    required this.fieldName,
    required this.sourceValue,
    required this.targetValue,
    required this.currentValue,
    required this.detectedAt,
    this.resolution,
  });

  bool get isResolved => resolution != null;
  bool get isManuallyResolved => resolution == ConflictResolution.manual;
}

class VersionHistory {
  final String historyId;
  final String resourceId;
  final List<String> versionIds;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final int totalVersions;
  final int activeVersions;

  VersionHistory({
    required this.historyId,
    required this.resourceId,
    required this.versionIds,
    required this.createdAt,
    this.lastModifiedAt,
    this.totalVersions = 0,
    this.activeVersions = 0,
  });

  bool get hasVersions => versionIds.isNotEmpty;
  bool get isRecentlyModified => lastModifiedAt != null && DateTime.now().difference(lastModifiedAt!).inDays < 7;
}

class Changelog {
  final String changelogId;
  final String resourceId;
  final String title;
  final String description;
  final int fromVersion;
  final int toVersion;
  final List<String> features;
  final List<String> bugFixes;
  final List<String> breakingChanges;
  final DateTime releasedAt;
  final ReleaseType releaseType;

  Changelog({
    required this.changelogId,
    required this.resourceId,
    required this.title,
    required this.description,
    required this.fromVersion,
    required this.toVersion,
    required this.features,
    required this.bugFixes,
    required this.breakingChanges,
    required this.releasedAt,
    required this.releaseType,
  });

  bool get hasBreakingChanges => breakingChanges.isNotEmpty;
  int get totalChanges => features.length + bugFixes.length + breakingChanges.length;
  bool get isStable => releaseType == ReleaseType.stable;
}

class VersionDiff {
  final String diffId;
  final String resourceId;
  final int oldVersion;
  final int newVersion;
  final Map<String, dynamic> additions;
  final Map<String, dynamic> deletions;
  final Map<String, dynamic> modifications;
  final DateTime createdAt;

  VersionDiff({
    required this.diffId,
    required this.resourceId,
    required this.oldVersion,
    required this.newVersion,
    required this.additions,
    required this.deletions,
    required this.modifications,
    required this.createdAt,
  });

  bool get hasChanges => additions.isNotEmpty || deletions.isNotEmpty || modifications.isNotEmpty;
  int get totalChangedFields => (additions.length + deletions.length + modifications.length);
  int get addedCount => additions.length;
  int get deletedCount => deletions.length;
  int get modifiedCount => modifications.length;
}

class VersionRestore {
  final String restoreId;
  final String resourceId;
  final int fromVersion;
  final int toVersion;
  final String initiatedBy;
  final DateTime initiatedAt;
  final String? reason;
  final bool isCompleted;
  final DateTime? completedAt;

  VersionRestore({
    required this.restoreId,
    required this.resourceId,
    required this.fromVersion,
    required this.toVersion,
    required this.initiatedBy,
    required this.initiatedAt,
    this.reason,
    this.isCompleted = false,
    this.completedAt,
  });

  bool get isPending => !isCompleted;
  int get durationInSeconds => isCompleted && completedAt != null ? completedAt!.difference(initiatedAt).inSeconds : 0;
  int get ageInHours => DateTime.now().difference(initiatedAt).inHours;
}
