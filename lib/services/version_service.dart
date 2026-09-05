import '../models/version_models.dart';

abstract class VersionRepository {
  Future<void> createVersion(ResourceVersion version);
  Future<ResourceVersion?> getVersion(String versionId);
  Future<List<ResourceVersion>> getResourceVersions(String resourceId);
  Future<List<ResourceVersion>> getVersionsByStatus(VersionStatus status);
  Future<void> updateVersion(ResourceVersion version);

  Future<void> createBranch(VersionBranch branch);
  Future<VersionBranch?> getBranch(String branchId);
  Future<List<VersionBranch>> getResourceBranches(String resourceId);
  Future<List<VersionBranch>> getActiveBranches();
  Future<void> updateBranch(VersionBranch branch);

  Future<void> createChange(VersionChange change);
  Future<VersionChange?> getChange(String changeId);
  Future<List<VersionChange>> getVersionChanges(String versionId);

  Future<void> createTag(VersionTag tag);
  Future<VersionTag?> getTag(String tagId);
  Future<List<VersionTag>> getResourceTags(String resourceId);
  Future<List<VersionTag>> getReleaseTags();

  Future<void> saveComparison(VersionComparison comparison);
  Future<VersionComparison?> getComparison(String comparisonId);
  Future<List<VersionComparison>> getComparisonsByResource(String resourceId);

  Future<void> recordMerge(VersionMerge merge);
  Future<VersionMerge?> getMerge(String mergeId);
  Future<List<VersionMerge>> getMergesByResource(String resourceId);

  Future<void> recordConflict(VersionConflict conflict);
  Future<List<VersionConflict>> getConflictsByMerge(String mergeId);
  Future<List<VersionConflict>> getUnresolvedConflicts();

  Future<void> createHistory(VersionHistory history);
  Future<VersionHistory?> getHistory(String historyId);
  Future<VersionHistory?> getResourceHistory(String resourceId);
  Future<void> updateHistory(VersionHistory history);

  Future<void> createChangelog(Changelog changelog);
  Future<Changelog?> getChangelog(String changelogId);
  Future<List<Changelog>> getResourceChangelogs(String resourceId);

  Future<void> saveDiff(VersionDiff diff);
  Future<VersionDiff?> getDiff(String diffId);
  Future<List<VersionDiff>> getDiffsByResource(String resourceId);

  Future<void> recordRestore(VersionRestore restore);
  Future<VersionRestore?> getRestore(String restoreId);
  Future<List<VersionRestore>> getRestoresByResource(String resourceId);
}

class MemoryVersionRepository implements VersionRepository {
  final Map<String, ResourceVersion> _versions = {};
  final Map<String, VersionBranch> _branches = {};
  final Map<String, VersionChange> _changes = {};
  final Map<String, VersionTag> _tags = {};
  final Map<String, VersionComparison> _comparisons = {};
  final Map<String, VersionMerge> _merges = {};
  final Map<String, VersionConflict> _conflicts = {};
  final Map<String, VersionHistory> _histories = {};
  final Map<String, Changelog> _changelogs = {};
  final Map<String, VersionDiff> _diffs = {};
  final Map<String, VersionRestore> _restores = {};

  @override
  Future<void> createVersion(ResourceVersion version) async => _versions[version.versionId] = version;

  @override
  Future<ResourceVersion?> getVersion(String versionId) async => _versions[versionId];

  @override
  Future<List<ResourceVersion>> getResourceVersions(String resourceId) async =>
      _versions.values.where((v) => v.resourceId == resourceId).toList();

  @override
  Future<List<ResourceVersion>> getVersionsByStatus(VersionStatus status) async =>
      _versions.values.where((v) => v.status == status).toList();

  @override
  Future<void> updateVersion(ResourceVersion version) async => _versions[version.versionId] = version;

  @override
  Future<void> createBranch(VersionBranch branch) async => _branches[branch.branchId] = branch;

  @override
  Future<VersionBranch?> getBranch(String branchId) async => _branches[branchId];

  @override
  Future<List<VersionBranch>> getResourceBranches(String resourceId) async =>
      _branches.values.where((b) => b.resourceId == resourceId).toList();

  @override
  Future<List<VersionBranch>> getActiveBranches() async =>
      _branches.values.where((b) => b.isActive).toList();

  @override
  Future<void> updateBranch(VersionBranch branch) async => _branches[branch.branchId] = branch;

  @override
  Future<void> createChange(VersionChange change) async => _changes[change.changeId] = change;

  @override
  Future<VersionChange?> getChange(String changeId) async => _changes[changeId];

  @override
  Future<List<VersionChange>> getVersionChanges(String versionId) async =>
      _changes.values.where((c) => c.versionId == versionId).toList();

  @override
  Future<void> createTag(VersionTag tag) async => _tags[tag.tagId] = tag;

  @override
  Future<VersionTag?> getTag(String tagId) async => _tags[tagId];

  @override
  Future<List<VersionTag>> getResourceTags(String resourceId) async =>
      _tags.values.where((t) => t.resourceId == resourceId).toList();

  @override
  Future<List<VersionTag>> getReleaseTags() async =>
      _tags.values.where((t) => t.isRelease).toList();

  @override
  Future<void> saveComparison(VersionComparison comparison) async =>
      _comparisons[comparison.comparisonId] = comparison;

  @override
  Future<VersionComparison?> getComparison(String comparisonId) async =>
      _comparisons[comparisonId];

  @override
  Future<List<VersionComparison>> getComparisonsByResource(String resourceId) async =>
      _comparisons.values.where((c) => c.resourceId == resourceId).toList();

  @override
  Future<void> recordMerge(VersionMerge merge) async => _merges[merge.mergeId] = merge;

  @override
  Future<VersionMerge?> getMerge(String mergeId) async => _merges[mergeId];

  @override
  Future<List<VersionMerge>> getMergesByResource(String resourceId) async =>
      _merges.values.where((m) => m.resourceId == resourceId).toList();

  @override
  Future<void> recordConflict(VersionConflict conflict) async =>
      _conflicts[conflict.conflictId] = conflict;

  @override
  Future<List<VersionConflict>> getConflictsByMerge(String mergeId) async =>
      _conflicts.values.where((c) => c.mergeId == mergeId).toList();

  @override
  Future<List<VersionConflict>> getUnresolvedConflicts() async =>
      _conflicts.values.where((c) => !c.isResolved).toList();

  @override
  Future<void> createHistory(VersionHistory history) async =>
      _histories[history.historyId] = history;

  @override
  Future<VersionHistory?> getHistory(String historyId) async => _histories[historyId];

  @override
  Future<VersionHistory?> getResourceHistory(String resourceId) async =>
      _histories.values.cast<VersionHistory?>().firstWhere(
        (h) => h?.resourceId == resourceId,
        orElse: () => null,
      );

  @override
  Future<void> updateHistory(VersionHistory history) async =>
      _histories[history.historyId] = history;

  @override
  Future<void> createChangelog(Changelog changelog) async =>
      _changelogs[changelog.changelogId] = changelog;

  @override
  Future<Changelog?> getChangelog(String changelogId) async =>
      _changelogs[changelogId];

  @override
  Future<List<Changelog>> getResourceChangelogs(String resourceId) async =>
      _changelogs.values.where((c) => c.resourceId == resourceId).toList();

  @override
  Future<void> saveDiff(VersionDiff diff) async => _diffs[diff.diffId] = diff;

  @override
  Future<VersionDiff?> getDiff(String diffId) async => _diffs[diffId];

  @override
  Future<List<VersionDiff>> getDiffsByResource(String resourceId) async =>
      _diffs.values.where((d) => d.resourceId == resourceId).toList();

  @override
  Future<void> recordRestore(VersionRestore restore) async =>
      _restores[restore.restoreId] = restore;

  @override
  Future<VersionRestore?> getRestore(String restoreId) async => _restores[restoreId];

  @override
  Future<List<VersionRestore>> getRestoresByResource(String resourceId) async =>
      _restores.values.where((r) => r.resourceId == resourceId).toList();
}

class VersionEngine {
  final VersionRepository repository;

  VersionEngine({required this.repository});

  Future<ResourceVersion> createNewVersion(
    String resourceId,
    String resourceType,
    Map<String, dynamic> content,
    String createdBy,
    String? description,
  ) async {
    final versions = await repository.getResourceVersions(resourceId);
    final versionNumber = versions.isEmpty ? 1 : versions.map((v) => v.versionNumber).reduce((a, b) => a > b ? a : b) + 1;

    final version = ResourceVersion(
      versionId: 'v_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      resourceType: resourceType,
      versionNumber: versionNumber,
      content: content,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      description: description,
    );
    await repository.createVersion(version);
    return version;
  }

  Future<VersionDiff> compareVersions(
    String resourceId,
    int oldVersion,
    int newVersion,
  ) async {
    final versions = await repository.getResourceVersions(resourceId);
    final oldV = versions.where((v) => v.versionNumber == oldVersion).firstOrNull;
    final newV = versions.where((v) => v.versionNumber == newVersion).firstOrNull;

    if (oldV == null || newV == null) throw Exception('Version not found');

    final diff = VersionDiff(
      diffId: 'diff_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      oldVersion: oldVersion,
      newVersion: newVersion,
      additions: newV.content.cast<String, dynamic>(),
      deletions: oldV.content.cast<String, dynamic>(),
      modifications: {},
      createdAt: DateTime.now(),
    );
    await repository.saveDiff(diff);
    return diff;
  }
}

class BranchEngine {
  final VersionRepository repository;

  BranchEngine({required this.repository});

  Future<VersionBranch> createBranch(
    String resourceId,
    String branchName,
    BranchType branchType,
    int baseVersion,
    String createdBy,
  ) async {
    final branch = VersionBranch(
      branchId: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      branchName: branchName,
      branchType: branchType,
      baseVersion: baseVersion,
      headVersion: baseVersion,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    await repository.createBranch(branch);
    return branch;
  }

  Future<VersionMerge> mergeBranches(
    String resourceId,
    String sourceBranch,
    String targetBranch,
    int sourceVersion,
    int targetVersion,
    int mergedVersion,
    String createdBy,
    MergeStrategy strategy,
  ) async {
    final merge = VersionMerge(
      mergeId: 'merge_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      sourceBranch: sourceBranch,
      targetBranch: targetBranch,
      sourceVersion: sourceVersion,
      targetVersion: targetVersion,
      mergedVersion: mergedVersion,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      strategy: strategy,
    );
    await repository.recordMerge(merge);
    return merge;
  }
}

class VersionManager {
  final VersionRepository repository;
  final VersionEngine versionEngine;
  final BranchEngine branchEngine;

  VersionManager({
    required this.repository,
    required this.versionEngine,
    required this.branchEngine,
  });

  Future<ResourceVersion> createVersion(
    String resourceId,
    String resourceType,
    Map<String, dynamic> content,
    String createdBy,
    String? description,
  ) async {
    return await versionEngine.createNewVersion(
      resourceId,
      resourceType,
      content,
      createdBy,
      description,
    );
  }

  Future<List<ResourceVersion>> getVersionHistory(String resourceId) async {
    return await repository.getResourceVersions(resourceId);
  }

  Future<VersionDiff> compareVersions(String resourceId, int oldVersion, int newVersion) async {
    return await versionEngine.compareVersions(resourceId, oldVersion, newVersion);
  }

  Future<VersionBranch> createBranch(
    String resourceId,
    String branchName,
    BranchType branchType,
    int baseVersion,
    String createdBy,
  ) async {
    return await branchEngine.createBranch(
      resourceId,
      branchName,
      branchType,
      baseVersion,
      createdBy,
    );
  }
}

class VersionFacade {
  final VersionManager manager;

  VersionFacade({required VersionManager? manager})
      : manager = manager ??
            VersionManager(
              repository: MemoryVersionRepository(),
              versionEngine: VersionEngine(repository: MemoryVersionRepository()),
              branchEngine: BranchEngine(repository: MemoryVersionRepository()),
            );

  Future<ResourceVersion> createResourceVersion(
    String resourceId,
    String resourceType,
    Map<String, dynamic> content,
    String createdBy,
    String? description,
  ) async {
    return await manager.createVersion(
      resourceId,
      resourceType,
      content,
      createdBy,
      description,
    );
  }

  Future<ResourceVersion?> getVersion(String versionId) async {
    return await manager.repository.getVersion(versionId);
  }

  Future<List<ResourceVersion>> getVersionHistory(String resourceId) async {
    return await manager.getVersionHistory(resourceId);
  }

  Future<VersionDiff> compareVersions(String resourceId, int oldVersion, int newVersion) async {
    return await manager.compareVersions(resourceId, oldVersion, newVersion);
  }

  Future<VersionBranch> createBranch(
    String resourceId,
    String branchName,
    BranchType branchType,
    int baseVersion,
    String createdBy,
  ) async {
    return await manager.createBranch(resourceId, branchName, branchType, baseVersion, createdBy);
  }

  Future<List<VersionBranch>> getBranches(String resourceId) async {
    return await manager.repository.getResourceBranches(resourceId);
  }

  Future<void> createTag(
    String resourceId,
    String tagName,
    int targetVersion,
    String createdBy,
    String? description,
  ) async {
    final tag = VersionTag(
      tagId: 'tag_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      tagName: tagName,
      targetVersion: targetVersion,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      description: description,
    );
    await manager.repository.createTag(tag);
  }

  Future<List<VersionTag>> getTags(String resourceId) async {
    return await manager.repository.getResourceTags(resourceId);
  }

  Future<void> createChangelog(
    String resourceId,
    String title,
    String description,
    int fromVersion,
    int toVersion,
    List<String> features,
    List<String> bugFixes,
    List<String> breakingChanges,
    ReleaseType releaseType,
  ) async {
    final changelog = Changelog(
      changelogId: 'changelog_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      title: title,
      description: description,
      fromVersion: fromVersion,
      toVersion: toVersion,
      features: features,
      bugFixes: bugFixes,
      breakingChanges: breakingChanges,
      releasedAt: DateTime.now(),
      releaseType: releaseType,
    );
    await manager.repository.createChangelog(changelog);
  }

  Future<List<Changelog>> getChangelogs(String resourceId) async {
    return await manager.repository.getResourceChangelogs(resourceId);
  }

  Future<VersionMerge> mergeBranches(
    String resourceId,
    String sourceBranch,
    String targetBranch,
    int sourceVersion,
    int targetVersion,
    int mergedVersion,
    String createdBy,
    MergeStrategy strategy,
  ) async {
    return await manager.branchEngine.mergeBranches(
      resourceId,
      sourceBranch,
      targetBranch,
      sourceVersion,
      targetVersion,
      mergedVersion,
      createdBy,
      strategy,
    );
  }

  Future<void> recordRestore(
    String resourceId,
    int fromVersion,
    int toVersion,
    String initiatedBy,
    String? reason,
  ) async {
    final restore = VersionRestore(
      restoreId: 'restore_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      fromVersion: fromVersion,
      toVersion: toVersion,
      initiatedBy: initiatedBy,
      initiatedAt: DateTime.now(),
      reason: reason,
    );
    await manager.repository.recordRestore(restore);
  }

  Future<List<VersionRestore>> getRestoreHistory(String resourceId) async {
    return await manager.repository.getRestoresByResource(resourceId);
  }
}
