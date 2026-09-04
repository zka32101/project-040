import 'package:flutter_test/flutter_test.dart';
import '../lib/models/version_models.dart';
import '../lib/services/version_service.dart';

void main() {
  group('Phase 65: Version Control & History Tracking Tests', () {
    late VersionFacade facade;
    late MemoryVersionRepository repository;

    setUp(() {
      repository = MemoryVersionRepository();
      final versionEngine = VersionEngine(repository: repository);
      final branchEngine = BranchEngine(repository: repository);
      final manager = VersionManager(
        repository: repository,
        versionEngine: versionEngine,
        branchEngine: branchEngine,
      );
      facade = VersionFacade(manager: manager);
    });

    group('Enum Tests', () {
      test('VersionStatus enum has all values', () {
        expect(VersionStatus.values.length, 4);
        expect(VersionStatus.values, contains(VersionStatus.active));
      });

      test('ChangeType enum has all values', () {
        expect(ChangeType.values.length, 3);
      });

      test('BranchType enum has all values', () {
        expect(BranchType.values.length, 5);
      });

      test('ReleaseType enum has all values', () {
        expect(ReleaseType.values.length, 4);
      });

      test('MergeStrategy enum has all values', () {
        expect(MergeStrategy.values.length, 4);
      });
    });

    group('ResourceVersion Model Tests', () {
      test('Create resource version', () {
        final version = ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {'title': 'Doc 1', 'content': 'Content'},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        expect(version.versionId, 'v1');
        expect(version.isActive, true);
        expect(version.versionNumber, 1);
      });

      test('Version content size calculation', () {
        final version = ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {'title': 'Test', 'data': List.filled(1000, 'x')},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        expect(version.contentSize, greaterThan(0));
      });

      test('Version age calculation', () {
        final version = ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {},
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        );
        expect(version.ageInDays, 5);
      });
    });

    group('VersionBranch Model Tests', () {
      test('Create version branch', () {
        final branch = VersionBranch(
          branchId: 'branch1',
          resourceId: 'res1',
          branchName: 'feature/new-feature',
          branchType: BranchType.feature,
          baseVersion: 1,
          headVersion: 3,
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        expect(branch.isActive, true);
        expect(branch.versionDifference, 2);
      });

      test('Merged branch is not active', () {
        final branch = VersionBranch(
          branchId: 'branch1',
          resourceId: 'res1',
          branchName: 'feature/merged',
          branchType: BranchType.feature,
          baseVersion: 1,
          headVersion: 3,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          mergedAt: DateTime.now(),
          isMerged: true,
        );
        expect(branch.isActive, false);
      });
    });

    group('VersionChange Model Tests', () {
      test('Create version change', () {
        final change = VersionChange(
          changeId: 'change1',
          versionId: 'v1',
          fieldName: 'title',
          oldValue: 'Old Title',
          newValue: 'New Title',
          changeType: ChangeType.minor,
          description: 'Updated title',
        );
        expect(change.hasChanged, true);
        expect(change.isMajorChange, false);
      });

      test('Breaking change detection', () {
        final change = VersionChange(
          changeId: 'change2',
          versionId: 'v2',
          fieldName: 'schema',
          oldValue: 'v1',
          newValue: 'v2',
          changeType: ChangeType.breaking,
          description: 'Schema update',
        );
        expect(change.isBreakingChange, true);
      });
    });

    group('VersionTag Model Tests', () {
      test('Create version tag', () {
        final tag = VersionTag(
          tagId: 'tag1',
          resourceId: 'res1',
          tagName: '1.0.0',
          targetVersion: 10,
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        expect(tag.tagName, '1.0.0');
        expect(tag.isRelease, false);
      });

      test('Release tag creation', () {
        final tag = VersionTag(
          tagId: 'tag2',
          resourceId: 'res1',
          tagName: 'v1.0.0',
          targetVersion: 10,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          isRelease: true,
          releaseType: ReleaseType.stable,
        );
        expect(tag.isStableRelease, true);
        expect(tag.isPrerelease, false);
      });

      test('Prerelease tag detection', () {
        final tag = VersionTag(
          tagId: 'tag3',
          resourceId: 'res1',
          tagName: 'v1.0.0-beta',
          targetVersion: 9,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          isRelease: true,
          releaseType: ReleaseType.beta,
        );
        expect(tag.isPrerelease, true);
        expect(tag.isStableRelease, false);
      });
    });

    group('VersionComparison Model Tests', () {
      test('Create version comparison', () {
        final comparison = VersionComparison(
          comparisonId: 'comp1',
          resourceId: 'res1',
          fromVersion: 1,
          toVersion: 5,
          changeIds: ['ch1', 'ch2', 'ch3'],
          createdAt: DateTime.now(),
          diffSummary: {'added': 10, 'removed': 5},
        );
        expect(comparison.hasChanges, true);
        expect(comparison.changeCount, 3);
        expect(comparison.versionSpan, 4);
      });
    });

    group('VersionMerge Model Tests', () {
      test('Successful merge', () {
        final merge = VersionMerge(
          mergeId: 'merge1',
          resourceId: 'res1',
          sourceBranch: 'feature',
          targetBranch: 'main',
          sourceVersion: 5,
          targetVersion: 3,
          mergedVersion: 6,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          strategy: MergeStrategy.threeWay,
          hasConflicts: false,
        );
        expect(merge.isSuccessful, true);
        expect(merge.conflictCount, 0);
      });

      test('Merge with conflicts', () {
        final merge = VersionMerge(
          mergeId: 'merge2',
          resourceId: 'res1',
          sourceBranch: 'feature',
          targetBranch: 'main',
          sourceVersion: 5,
          targetVersion: 3,
          mergedVersion: 0,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          strategy: MergeStrategy.threeWay,
          hasConflicts: true,
          conflictingFields: ['title', 'content'],
        );
        expect(merge.isSuccessful, false);
        expect(merge.conflictCount, 2);
      });
    });

    group('VersionConflict Model Tests', () {
      test('Create unresolved conflict', () {
        final conflict = VersionConflict(
          conflictId: 'conflict1',
          mergeId: 'merge1',
          fieldName: 'title',
          sourceValue: 'Source Title',
          targetValue: 'Target Title',
          currentValue: 'Current Title',
          detectedAt: DateTime.now(),
        );
        expect(conflict.isResolved, false);
      });

      test('Resolved conflict', () {
        final conflict = VersionConflict(
          conflictId: 'conflict2',
          mergeId: 'merge2',
          fieldName: 'content',
          sourceValue: 'Source',
          targetValue: 'Target',
          currentValue: 'Resolved',
          detectedAt: DateTime.now(),
          resolution: ConflictResolution.manual,
        );
        expect(conflict.isResolved, true);
        expect(conflict.isManuallyResolved, true);
      });
    });

    group('VersionHistory Model Tests', () {
      test('Create version history', () {
        final history = VersionHistory(
          historyId: 'hist1',
          resourceId: 'res1',
          versionIds: ['v1', 'v2', 'v3', 'v4', 'v5'],
          createdAt: DateTime.now(),
          totalVersions: 5,
          activeVersions: 1,
        );
        expect(history.hasVersions, true);
        expect(history.versionIds.length, 5);
      });
    });

    group('Changelog Model Tests', () {
      test('Create changelog', () {
        final changelog = Changelog(
          changelogId: 'cl1',
          resourceId: 'res1',
          title: 'Version 2.0.0',
          description: 'Major release',
          fromVersion: 5,
          toVersion: 10,
          features: ['Feature 1', 'Feature 2'],
          bugFixes: ['Bug 1', 'Bug 2', 'Bug 3'],
          breakingChanges: ['API change', 'Schema change'],
          releasedAt: DateTime.now(),
          releaseType: ReleaseType.stable,
        );
        expect(changelog.hasBreakingChanges, true);
        expect(changelog.totalChanges, 7);
        expect(changelog.isStable, true);
      });
    });

    group('VersionDiff Model Tests', () {
      test('Create version diff', () {
        final diff = VersionDiff(
          diffId: 'diff1',
          resourceId: 'res1',
          oldVersion: 1,
          newVersion: 2,
          additions: {'newField': 'value'},
          deletions: {'oldField': 'value'},
          modifications: {'title': 'modified'},
          createdAt: DateTime.now(),
        );
        expect(diff.hasChanges, true);
        expect(diff.addedCount, 1);
        expect(diff.deletedCount, 1);
        expect(diff.modifiedCount, 1);
        expect(diff.totalChangedFields, 3);
      });
    });

    group('VersionRestore Model Tests', () {
      test('Create restore operation', () {
        final restore = VersionRestore(
          restoreId: 'restore1',
          resourceId: 'res1',
          fromVersion: 5,
          toVersion: 3,
          initiatedBy: 'user1',
          initiatedAt: DateTime.now(),
          reason: 'Rollback due to error',
        );
        expect(restore.isPending, true);
        expect(restore.ageInHours, greaterThanOrEqualTo(0));
      });

      test('Completed restore', () {
        final now = DateTime.now();
        final restore = VersionRestore(
          restoreId: 'restore2',
          resourceId: 'res1',
          fromVersion: 5,
          toVersion: 3,
          initiatedBy: 'user1',
          initiatedAt: now,
          isCompleted: true,
          completedAt: now.add(Duration(seconds: 10)),
        );
        expect(restore.isPending, false);
        expect(restore.durationInSeconds, greaterThanOrEqualTo(10));
      });
    });

    group('Repository Tests', () {
      test('Create and retrieve version', () async {
        final version = ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {'title': 'Test'},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        await repository.createVersion(version);
        final retrieved = await repository.getVersion('v1');
        expect(retrieved?.resourceId, 'res1');
      });

      test('Get resource versions', () async {
        for (int i = 1; i <= 3; i++) {
          await repository.createVersion(ResourceVersion(
            versionId: 'v$i',
            resourceId: 'res1',
            resourceType: 'document',
            versionNumber: i,
            content: {},
            createdBy: 'user1',
            createdAt: DateTime.now(),
          ));
        }
        final versions = await repository.getResourceVersions('res1');
        expect(versions.length, 3);
      });

      test('Create and retrieve branch', () async {
        final branch = VersionBranch(
          branchId: 'b1',
          resourceId: 'res1',
          branchName: 'feature',
          branchType: BranchType.feature,
          baseVersion: 1,
          headVersion: 3,
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        await repository.createBranch(branch);
        final retrieved = await repository.getBranch('b1');
        expect(retrieved?.branchName, 'feature');
      });

      test('Create and retrieve tag', () async {
        final tag = VersionTag(
          tagId: 't1',
          resourceId: 'res1',
          tagName: '1.0.0',
          targetVersion: 10,
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        await repository.createTag(tag);
        final retrieved = await repository.getTag('t1');
        expect(retrieved?.tagName, '1.0.0');
      });

      test('Create and retrieve merge', () async {
        final merge = VersionMerge(
          mergeId: 'm1',
          resourceId: 'res1',
          sourceBranch: 'feature',
          targetBranch: 'main',
          sourceVersion: 5,
          targetVersion: 3,
          mergedVersion: 6,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          strategy: MergeStrategy.threeWay,
        );
        await repository.recordMerge(merge);
        final retrieved = await repository.getMerge('m1');
        expect(retrieved?.mergeId, 'm1');
      });

      test('Record and retrieve conflict', () async {
        final conflict = VersionConflict(
          conflictId: 'c1',
          mergeId: 'm1',
          fieldName: 'title',
          sourceValue: 'A',
          targetValue: 'B',
          currentValue: 'C',
          detectedAt: DateTime.now(),
        );
        await repository.recordConflict(conflict);
        final conflicts = await repository.getConflictsByMerge('m1');
        expect(conflicts.isNotEmpty, true);
      });

      test('Create and retrieve changelog', () async {
        final changelog = Changelog(
          changelogId: 'cl1',
          resourceId: 'res1',
          title: 'v1.0.0',
          description: 'Release',
          fromVersion: 1,
          toVersion: 10,
          features: [],
          bugFixes: [],
          breakingChanges: [],
          releasedAt: DateTime.now(),
          releaseType: ReleaseType.stable,
        );
        await repository.createChangelog(changelog);
        final retrieved = await repository.getChangelog('cl1');
        expect(retrieved?.title, 'v1.0.0');
      });

      test('Save and retrieve diff', () async {
        final diff = VersionDiff(
          diffId: 'd1',
          resourceId: 'res1',
          oldVersion: 1,
          newVersion: 2,
          additions: {},
          deletions: {},
          modifications: {},
          createdAt: DateTime.now(),
        );
        await repository.saveDiff(diff);
        final retrieved = await repository.getDiff('d1');
        expect(retrieved?.diffId, 'd1');
      });

      test('Record and retrieve restore', () async {
        final restore = VersionRestore(
          restoreId: 'r1',
          resourceId: 'res1',
          fromVersion: 5,
          toVersion: 3,
          initiatedBy: 'user1',
          initiatedAt: DateTime.now(),
        );
        await repository.recordRestore(restore);
        final retrieved = await repository.getRestore('r1');
        expect(retrieved?.restoreId, 'r1');
      });
    });

    group('Version Engine Tests', () {
      test('Create new version increments version number', () async {
        final engine = VersionEngine(repository: repository);
        
        final v1 = await engine.createNewVersion(
          'res1',
          'document',
          {'title': 'V1'},
          'user1',
          'Version 1',
        );
        expect(v1.versionNumber, 1);

        final v2 = await engine.createNewVersion(
          'res1',
          'document',
          {'title': 'V2'},
          'user1',
          'Version 2',
        );
        expect(v2.versionNumber, 2);
      });

      test('Compare versions creates diff', () async {
        final engine = VersionEngine(repository: repository);
        
        await repository.createVersion(ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {'title': 'Old'},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        ));

        await repository.createVersion(ResourceVersion(
          versionId: 'v2',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 2,
          content: {'title': 'New'},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        ));

        final diff = await engine.compareVersions('res1', 1, 2);
        expect(diff.diffId, isNotEmpty);
      });
    });

    group('Branch Engine Tests', () {
      test('Create branch with correct initial state', () async {
        final engine = BranchEngine(repository: repository);
        final branch = await engine.createBranch(
          'res1',
          'feature/new',
          BranchType.feature,
          5,
          'user1',
        );
        expect(branch.baseVersion, 5);
        expect(branch.headVersion, 5);
        expect(branch.isActive, true);
      });

      test('Merge branches records merge', () async {
        final engine = BranchEngine(repository: repository);
        final merge = await engine.mergeBranches(
          'res1',
          'feature',
          'main',
          5,
          3,
          6,
          'user1',
          MergeStrategy.threeWay,
        );
        expect(merge.mergeId, isNotEmpty);
        expect(merge.strategy, MergeStrategy.threeWay);
      });
    });

    group('Version Facade Integration Tests', () {
      test('Complete version workflow', () async {
        // Create version
        final v1 = await facade.createResourceVersion(
          'res1',
          'document',
          {'title': 'Doc 1'},
          'user1',
          'Initial version',
        );
        expect(v1.versionNumber, 1);

        // Get version history
        final history = await facade.getVersionHistory('res1');
        expect(history.isNotEmpty, true);
      });

      test('Branch and merge workflow', () async {
        // Create branch
        final branch = await facade.createBranch(
          'res1',
          'feature/update',
          BranchType.feature,
          1,
          'user1',
        );
        expect(branch.branchName, 'feature/update');

        // Get branches
        final branches = await facade.getBranches('res1');
        expect(branches.isNotEmpty, true);
      });

      test('Tagging workflow', () async {
        await facade.createTag(
          'res1',
          '1.0.0',
          10,
          'user1',
          'Release 1.0.0',
        );

        final tags = await facade.getTags('res1');
        expect(tags.isNotEmpty, true);
      });

      test('Changelog creation', () async {
        await facade.createChangelog(
          'res1',
          'v2.0.0',
          'Major release',
          10,
          20,
          ['Feature A', 'Feature B'],
          ['Bug 1'],
          ['API change'],
          ReleaseType.stable,
        );

        final changelogs = await facade.getChangelogs('res1');
        expect(changelogs.isNotEmpty, true);
      });

      test('Version comparison', () async {
        await repository.createVersion(ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'doc',
          versionNumber: 1,
          content: {'a': 1},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        ));

        await repository.createVersion(ResourceVersion(
          versionId: 'v2',
          resourceId: 'res1',
          resourceType: 'doc',
          versionNumber: 2,
          content: {'a': 2},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        ));

        final diff = await facade.compareVersions('res1', 1, 2);
        expect(diff.diffId, isNotEmpty);
      });

      test('Restore workflow', () async {
        await facade.recordRestore(
          'res1',
          5,
          3,
          'user1',
          'Rollback due to error',
        );

        final restores = await facade.getRestoreHistory('res1');
        expect(restores.isNotEmpty, true);
      });

      test('Multiple versions and operations', () async {
        for (int i = 1; i <= 5; i++) {
          await facade.createResourceVersion(
            'res1',
            'document',
            {'version': i},
            'user1',
            'Version $i',
          );
        }

        final history = await facade.getVersionHistory('res1');
        expect(history.length, 5);
      });
    });

    group('Edge Cases & Error Handling', () {
      test('Handle missing version', () async {
        final result = await facade.getVersion('nonexistent');
        expect(result, isNull);
      });

      test('Empty version content', () {
        final version = ResourceVersion(
          versionId: 'v1',
          resourceId: 'res1',
          resourceType: 'document',
          versionNumber: 1,
          content: {},
          createdBy: 'user1',
          createdAt: DateTime.now(),
        );
        expect(version.contentSize, greaterThanOrEqualTo(2));
      });

      test('Large version history', () async {
        for (int i = 1; i <= 100; i++) {
          await facade.createResourceVersion(
            'res1',
            'document',
            {'version': i},
            'user1',
            'V$i',
          );
        }

        final history = await facade.getVersionHistory('res1');
        expect(history.length, 100);
      });

      test('Complex merge scenarios', () async {
        final merge = await facade.mergeBranches(
          'res1',
          'feature',
          'main',
          10,
          5,
          11,
          'user1',
          MergeStrategy.squash,
        );
        expect(merge.mergeId, isNotEmpty);
      });

      test('Multiple branches concurrently', () async {
        final futures = List.generate(
          5,
          (i) => facade.createBranch(
            'res1',
            'feature/$i',
            BranchType.feature,
            1,
            'user1',
          ),
        );
        final results = await Future.wait(futures);
        expect(results.length, 5);
      });

      test('Version with special characters', () async {
        final version = await facade.createResourceVersion(
          'res@special#123',
          'doc/type',
          {'field@name': 'value#special'},
          'user@example.com',
          'Version with @special #chars',
        );
        expect(version.resourceId, contains('@'));
      });

      test('Release tag versions', () async {
        for (final release in ReleaseType.values) {
          await facade.createTag(
            'res1',
            'tag_$release',
            10,
            'user1',
            'Release $release',
          );
        }

        final tags = await facade.getTags('res1');
        expect(tags.length, greaterThanOrEqualTo(4));
      });
    });
  });
}
