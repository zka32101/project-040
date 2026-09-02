import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/community_model.dart';
import 'package:bike_license_kore/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('StudyMaterial', () {
    test('should create study material', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Road Signs Guide',
        description: 'Complete guide to road signs',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video/1',
        durationMinutes: 15,
        tags: ['signs', 'beginner'],
        createdByUserId: 'instructor1',
      );

      expect(materialId, isNotEmpty);
      expect(materialId.startsWith('material_'), true);
    });

    test('should get study material', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Traffic Rules Basics',
        description: 'Learn traffic rules',
        resourceType: ResourceType.pdf,
        format: ResourceFormat.pdf,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/pdf/1',
        createdByUserId: 'instructor1',
      );

      final material = await service.getStudyMaterial(materialId);
      expect(material, isNotNull);
      expect(material!.title, 'Traffic Rules Basics');
      expect(material.category, MaterialCategory.trafficRules);
    });

    test('should get materials by category', () async {
      await service.createStudyMaterial(
        title: 'Road Signs 1',
        description: 'First signs guide',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video/1',
        createdByUserId: 'instructor1',
      );

      await service.createStudyMaterial(
        title: 'Road Signs 2',
        description: 'Second signs guide',
        resourceType: ResourceType.pdf,
        format: ResourceFormat.pdf,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/pdf/1',
        createdByUserId: 'instructor1',
      );

      final materials = await service.getMaterialsByCategory(MaterialCategory.roadSigns);
      expect(materials.length, 2);
    });

    test('should get materials by difficulty', () async {
      await service.createStudyMaterial(
        title: 'Advanced Rules',
        description: 'Advanced traffic rules',
        resourceType: ResourceType.interactiveLesson,
        format: ResourceFormat.interactive,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.advanced,
        contentUrl: 'https://example.com/interactive/1',
        createdByUserId: 'instructor1',
      );

      await service.createStudyMaterial(
        title: 'Expert Techniques',
        description: 'Expert defensive driving',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.defensiveDriving,
        difficulty: ResourceDifficulty.advanced,
        contentUrl: 'https://example.com/video/2',
        createdByUserId: 'instructor1',
      );

      final materials = await service.getMaterialsByDifficulty(ResourceDifficulty.advanced);
      expect(materials.length, 2);
    });

    test('should search materials', () async {
      await service.createStudyMaterial(
        title: 'Stop Sign Guide',
        description: 'Understanding stop signs',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video/3',
        tags: ['stop', 'signs'],
        createdByUserId: 'instructor1',
      );

      await service.createStudyMaterial(
        title: 'Speed Limit Signs',
        description: 'Speed limit regulations',
        resourceType: ResourceType.pdf,
        format: ResourceFormat.pdf,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/pdf/2',
        tags: ['speed', 'limit'],
        createdByUserId: 'instructor1',
      );

      final results = await service.searchMaterials('stop');
      expect(results.length, greaterThanOrEqualTo(1));
    });

    test('should update material status', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Test Material',
        description: 'Test description',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.examTips,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/video/test',
        createdByUserId: 'instructor1',
      );

      await service.updateMaterialStatus(materialId, ResourceStatus.published);

      final material = await service.getStudyMaterial(materialId);
      expect(material!.status, ResourceStatus.published);
    });

    test('should include metadata', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Material with Metadata',
        description: 'Test metadata handling',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.studyGuide,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video/meta',
        createdByUserId: 'instructor1',
        metadata: {
          'author': 'John Doe',
          'license': 'CC-BY',
        },
      );

      final material = await service.getStudyMaterial(materialId);
      expect(material!.metadata['author'], 'John Doe');
    });
  });

  group('ResourceCollection', () {
    test('should create resource collection', () async {
      final collectionId = await service.createResourceCollection(
        collectionName: 'Beginner Road Signs',
        description: 'Complete beginner guide to road signs',
        primaryCategory: MaterialCategory.roadSigns,
        targetDifficulty: ResourceDifficulty.beginner,
      );

      expect(collectionId, isNotEmpty);
      expect(collectionId.startsWith('collection_'), true);
    });

    test('should get resource collection', () async {
      final collectionId = await service.createResourceCollection(
        collectionName: 'Traffic Laws',
        description: 'Traffic law essentials',
        primaryCategory: MaterialCategory.trafficRules,
        targetDifficulty: ResourceDifficulty.intermediate,
      );

      final collection = await service.getResourceCollection(collectionId);
      expect(collection, isNotNull);
      expect(collection!.collectionName, 'Traffic Laws');
    });

    test('should add material to collection', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Test Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/test',
        createdByUserId: 'instructor1',
      );

      final collectionId = await service.createResourceCollection(
        collectionName: 'Test Collection',
        description: 'Test collection',
        primaryCategory: MaterialCategory.roadSigns,
        targetDifficulty: ResourceDifficulty.beginner,
      );

      await service.addMaterialToCollection(
        collectionId: collectionId,
        materialId: materialId,
      );

      final collection = await service.getResourceCollection(collectionId);
      expect(collection!.materialIds.contains(materialId), true);
    });

    test('should remove material from collection', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Material to Remove',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/test2',
        createdByUserId: 'instructor1',
      );

      final collectionId = await service.createResourceCollection(
        collectionName: 'Test Collection 2',
        description: 'Test',
        primaryCategory: MaterialCategory.roadSigns,
        targetDifficulty: ResourceDifficulty.beginner,
        materialIds: [materialId],
      );

      await service.removeMaterialFromCollection(
        collectionId: collectionId,
        materialId: materialId,
      );

      final collection = await service.getResourceCollection(collectionId);
      expect(collection!.materialIds.contains(materialId), false);
    });

    test('should get published collections', () async {
      final collectionId = await service.createResourceCollection(
        collectionName: 'Published Collection',
        description: 'A published collection',
        primaryCategory: MaterialCategory.roadSigns,
        targetDifficulty: ResourceDifficulty.beginner,
      );

      var collections = await service.getPublishedCollections();
      expect(collections.length, 0);
    });
  });

  group('StudentResourceProgress', () {
    test('should start resource progress', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Study Material',
        description: 'Test material',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final progressId = await service.startResourceProgress(
        userId: 'student1',
        materialId: materialId,
      );

      expect(progressId, isNotEmpty);
      expect(progressId.startsWith('progress_'), true);
    });

    test('should update resource progress', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Study Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final progressId = await service.startResourceProgress(
        userId: 'student1',
        materialId: materialId,
      );

      await service.updateResourceProgress(
        progressId: progressId,
        progressPercent: 50.0,
        timeSpentMinutes: 8,
      );

      final progress = await service.getResourceProgress(progressId);
      expect(progress!.progressPercent, 50.0);
      expect(progress.timeSpentMinutes, 8);
    });

    test('should mark progress as completed', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Material',
        description: 'Test',
        resourceType: ResourceType.pdf,
        format: ResourceFormat.pdf,
        category: MaterialCategory.studyGuide,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/pdf',
        createdByUserId: 'instructor1',
      );

      final progressId = await service.startResourceProgress(
        userId: 'student2',
        materialId: materialId,
      );

      await service.updateResourceProgress(
        progressId: progressId,
        progressPercent: 100.0,
      );

      final progress = await service.getResourceProgress(progressId);
      expect(progress!.isCompleted, true);
      expect(progress.completedAt, isNotNull);
    });

    test('should bookmark material', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Bookmarkable Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final progressId = await service.startResourceProgress(
        userId: 'student3',
        materialId: materialId,
      );

      await service.bookmarkMaterial(
        progressId: progressId,
        isBookmarked: true,
      );

      final progress = await service.getResourceProgress(progressId);
      expect(progress!.isBookmarked, true);
    });

    test('should rate material', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Rateable Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final progressId = await service.startResourceProgress(
        userId: 'student4',
        materialId: materialId,
      );

      await service.rateMaterial(
        progressId: progressId,
        rating: 4.5,
      );

      final progress = await service.getResourceProgress(progressId);
      expect(progress!.userRating, 4.5);
    });

    test('should get user bookmarks', () async {
      final materialId1 = await service.createStudyMaterial(
        title: 'Material 1',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video1',
        createdByUserId: 'instructor1',
      );

      final progressId1 = await service.startResourceProgress(
        userId: 'student5',
        materialId: materialId1,
      );

      await service.bookmarkMaterial(
        progressId: progressId1,
        isBookmarked: true,
      );

      final bookmarks = await service.getUserBookmarks('student5');
      expect(bookmarks.length, 1);
      expect(bookmarks[0].materialId, materialId1);
    });

    test('should get user resource progress', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      await service.startResourceProgress(
        userId: 'student6',
        materialId: materialId,
      );

      final progress = await service.getUserResourceProgress('student6');
      expect(progress.length, 1);
    });
  });

  group('ResourceRecommendation', () {
    test('should create resource recommendation', () async {
      final recommendationId = await service.createResourceRecommendation(
        userId: 'student1',
        materialIds: ['material1', 'material2'],
        recommendationReason: 'Based on weak areas',
        relevanceScore: 0.85,
        recommendedCategories: ['roadSigns', 'trafficRules'],
      );

      expect(recommendationId, isNotEmpty);
      expect(recommendationId.startsWith('recommendation_'), true);
    });

    test('should get user recommendations', () async {
      await service.createResourceRecommendation(
        userId: 'student2',
        materialIds: ['material1'],
        recommendationReason: 'For improvement',
        relevanceScore: 0.75,
      );

      final recommendations = await service.getUserRecommendations('student2');
      expect(recommendations.length, 1);
    });

    test('should mark recommendation as viewed', () async {
      final recId = await service.createResourceRecommendation(
        userId: 'student3',
        materialIds: ['material1'],
        recommendationReason: 'Test',
        relevanceScore: 0.8,
      );

      await service.markRecommendationAsViewed(recId);

      final recommendations = await service.getUserRecommendations('student3');
      expect(recommendations[0].viewedAt, isNotNull);
    });

    test('should accept recommendation', () async {
      final recId = await service.createResourceRecommendation(
        userId: 'student4',
        materialIds: ['material1'],
        recommendationReason: 'Test',
        relevanceScore: 0.8,
      );

      await service.acceptRecommendation(recId);

      final recommendations = await service.getUserRecommendations('student4');
      expect(recommendations[0].isAccepted, true);
    });

    test('should include score breakdown', () async {
      final recId = await service.createResourceRecommendation(
        userId: 'student5',
        materialIds: ['material1'],
        recommendationReason: 'Test',
        relevanceScore: 0.85,
        scoreBreakdown: {
          'weakAreaMatch': 0.90,
          'userPreference': 0.80,
          'popularity': 0.85,
        },
      );

      final recommendations = await service.getUserRecommendations('student5');
      expect(recommendations[0].scoreBreakdown['weakAreaMatch'], 0.90);
    });
  });

  group('ResourceAnalytics', () {
    test('should get resource analytics', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Analytics Test Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final analytics = await service.getResourceAnalytics(materialId);
      expect(analytics, isNotNull);
      expect(analytics!.totalViews, 0);
    });

    test('should record material view', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Viewable Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      await service.recordMaterialView(
        materialId: materialId,
        userId: 'student1',
      );

      final material = await service.getStudyMaterial(materialId);
      expect(material!.viewCount, 1);
    });

    test('should track material completion rate', () async {
      final materialId = await service.createStudyMaterial(
        title: 'Trackable Material',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/video',
        createdByUserId: 'instructor1',
      );

      final progressId1 = await service.startResourceProgress(
        userId: 'student1',
        materialId: materialId,
      );

      final progressId2 = await service.startResourceProgress(
        userId: 'student2',
        materialId: materialId,
      );

      await service.completeResourceProgress(progressId1);

      final completionRate = await service.getMaterialCompletionRate(materialId);
      expect(completionRate, 50.0);
    });
  });

  group('ResourceIntegration', () {
    test('should complete full resource workflow', () async {
      // 1. Create material
      final materialId = await service.createStudyMaterial(
        title: 'Complete Workflow Material',
        description: 'Full test workflow',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video',
        durationMinutes: 10,
        tags: ['signs', 'beginner'],
        createdByUserId: 'instructor1',
      );

      // 2. Create collection
      final collectionId = await service.createResourceCollection(
        collectionName: 'Workflow Collection',
        description: 'Test collection',
        primaryCategory: MaterialCategory.roadSigns,
        targetDifficulty: ResourceDifficulty.beginner,
      );

      // 3. Add material to collection
      await service.addMaterialToCollection(
        collectionId: collectionId,
        materialId: materialId,
      );

      // 4. Publish material
      await service.updateMaterialStatus(materialId, ResourceStatus.published);

      // 5. Record view
      await service.recordMaterialView(
        materialId: materialId,
        userId: 'student1',
      );

      // 6. Start progress
      final progressId = await service.startResourceProgress(
        userId: 'student1',
        materialId: materialId,
      );

      // 7. Update progress
      await service.updateResourceProgress(
        progressId: progressId,
        progressPercent: 100.0,
        timeSpentMinutes: 10,
      );

      // 8. Rate material
      await service.rateMaterial(
        progressId: progressId,
        rating: 5.0,
      );

      // 9. Bookmark material
      await service.bookmarkMaterial(
        progressId: progressId,
        isBookmarked: true,
      );

      // 10. Verify final state
      final material = await service.getStudyMaterial(materialId);
      expect(material!.status, ResourceStatus.published);
      expect(material.viewCount, 1);
      expect(material.averageRating, 5.0);

      final progress = await service.getResourceProgress(progressId);
      expect(progress!.isCompleted, true);
      expect(progress.isBookmarked, true);

      final collection = await service.getResourceCollection(collectionId);
      expect(collection!.materialIds.contains(materialId), true);
    });

    test('should handle recommendations and personalization', () async {
      // Create multiple materials in different categories
      final roadSignsMaterialId = await service.createStudyMaterial(
        title: 'Road Signs',
        description: 'Test',
        resourceType: ResourceType.video,
        format: ResourceFormat.video,
        category: MaterialCategory.roadSigns,
        difficulty: ResourceDifficulty.beginner,
        contentUrl: 'https://example.com/video1',
        createdByUserId: 'instructor1',
      );

      final trafficRulesMaterialId = await service.createStudyMaterial(
        title: 'Traffic Rules',
        description: 'Test',
        resourceType: ResourceType.pdf,
        format: ResourceFormat.pdf,
        category: MaterialCategory.trafficRules,
        difficulty: ResourceDifficulty.intermediate,
        contentUrl: 'https://example.com/pdf',
        createdByUserId: 'instructor1',
      );

      // Create recommendations
      final recId1 = await service.createResourceRecommendation(
        userId: 'student1',
        materialIds: [roadSignsMaterialId],
        recommendationReason: 'Weak in road signs',
        relevanceScore: 0.90,
      );

      final recId2 = await service.createResourceRecommendation(
        userId: 'student1',
        materialIds: [trafficRulesMaterialId],
        recommendationReason: 'Next level challenge',
        relevanceScore: 0.75,
      );

      // Verify recommendations
      final recommendations = await service.getUserRecommendations('student1');
      expect(recommendations.length, 2);
      expect(recommendations[0].relevanceScore, greaterThanOrEqualTo(0.75));
    });
  });
}
