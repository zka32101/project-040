import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('InstitutionalQuestion', () {
    test('should create institutional question in draft status', () {
      final question = InstitutionalQuestion(
        questionId: 'q_1',
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: '信号機が赤の時にどうしますか？',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '交通規則',
        answerOptions: ['停止', '加速', '右折', 'クラクション'],
        correctAnswer: '停止',
        explanation: '赤信号では必ず停止する必要があります',
        status: ContentStatus.draft,
        accessLevel: ContentAccessLevel.institutional,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.status, ContentStatus.draft);
      expect(question.isApproved, false);
      expect(question.questionText, contains('信号機'));
    });

    test('should mark question as approved', () {
      final question = InstitutionalQuestion(
        questionId: 'q_1',
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Test Question',
        type: QuestionType.trueFalse,
        difficulty: QuestionDifficulty.intermediate,
        category: '危機回避',
        answerOptions: ['True', 'False'],
        correctAnswer: 'True',
        status: ContentStatus.published,
        accessLevel: ContentAccessLevel.institutional,
        reviewedAt: DateTime.now(),
        reviewedByUserId: 'reviewer_1',
        reviewNotes: 'Approved with minor fixes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.isApproved, true);
      expect(question.reviewedByUserId, 'reviewer_1');
    });

    test('should track question usage statistics', () {
      final question = InstitutionalQuestion(
        questionId: 'q_1',
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Usage Test',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.intermediate,
        category: '機械知識',
        answerOptions: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        usageCount: 150,
        averageTimeSpent: 45.5,
        averageAccuracy: 0.78,
        status: ContentStatus.published,
        accessLevel: ContentAccessLevel.institutional,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.usageCount, 150);
      expect(question.averageAccuracy, 0.78);
      expect(question.averageTimeSpent, 45.5);
    });
  });

  group('InstitutionalQuestionBank', () {
    test('should initialize question bank', () {
      final bank = InstitutionalQuestionBank(
        bankId: 'qb_1',
        partnershipId: 'p_1',
        bankName: '交通規則カスタム問題バンク',
        description: 'パートナー校用のカスタマイズ問題集',
        totalQuestions: 250,
        questionsByDifficulty: {
          'beginner': 100,
          'intermediate': 100,
          'advanced': 50,
        },
        questionsByCategory: {
          '交通規則': 150,
          '危機回避': 100,
        },
        creatorIds: ['user_1', 'user_2', 'user_3'],
        status: ContentStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(bank.bankName, contains('カスタム'));
      expect(bank.totalQuestions, 250);
      expect(bank.questionsByDifficulty.values.fold(0, (a, b) => a + b), 250);
    });
  });

  group('Course', () {
    test('should initialize course in draft status', () {
      final course = Course(
        courseId: 'c_1',
        partnershipId: 'p_1',
        courseName: '基礎交通規則講座',
        description: '初心者向けの交通規則コース',
        topicIds: ['topic_1', 'topic_2', 'topic_3'],
        questionIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        status: CourseStatus.draft,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(course.isActive, false);
      expect(course.status, CourseStatus.draft);
      expect(course.estimatedHours, 15);
    });

    test('should track course metrics', () {
      final course = Course(
        courseId: 'c_1',
        partnershipId: 'p_1',
        courseName: 'Advanced Course',
        description: 'Advanced driving techniques',
        topicIds: ['topic_1'],
        questionIds: ['q_1', 'q_2', 'q_3'],
        totalLessons: 20,
        estimatedHours: 30,
        status: CourseStatus.active,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
        enrolledStudents: 45,
        averageCompletion: 82.5,
        averageScore: 78.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(course.enrolledStudents, 45);
      expect(course.averageCompletion, 82.5);
      expect(course.isActive, true);
    });
  });

  group('Curriculum', () {
    test('should initialize curriculum in draft status', () {
      final curriculum = Curriculum(
        curriculumId: 'curr_1',
        partnershipId: 'p_1',
        curriculumName: '自動車免許完全カリキュラム',
        description: '免許取得に必要なすべてを網羅',
        type: CurriculumType.standardCurriculum,
        courseIds: ['c_1', 'c_2', 'c_3'],
        totalHours: 50,
        targetLevel: 5,
        targetExamType: 'license_exam',
        status: ContentStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(curriculum.isPublished, false);
      expect(curriculum.type, CurriculumType.standardCurriculum);
      expect(curriculum.courseIds.length, 3);
    });

    test('should track curriculum metrics', () {
      final curriculum = Curriculum(
        curriculumId: 'curr_1',
        partnershipId: 'p_1',
        curriculumName: 'Published Curriculum',
        description: 'Published',
        type: CurriculumType.standardCurriculum,
        courseIds: ['c_1', 'c_2'],
        totalHours: 40,
        targetLevel: 5,
        status: ContentStatus.published,
        enrolledStudents: 120,
        completionRate: 75.0,
        passProbability: 0.82,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(curriculum.enrolledStudents, 120);
      expect(curriculum.completionRate, 75.0);
      expect(curriculum.isPublished, true);
    });
  });

  group('CourseEnrollment', () {
    test('should initialize course enrollment', () {
      final enrollment = CourseEnrollment(
        enrollmentId: 'enr_1',
        courseId: 'c_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        enrolledAt: DateTime.now(),
        completionPercentage: 0.0,
        currentScore: 0.0,
        lessonsCompleted: 0,
      );

      expect(enrollment.isCompleted, false);
      expect(enrollment.isInProgress, false);
      expect(enrollment.completionPercentage, 0.0);
    });

    test('should track enrollment progress', () {
      final enrollment = CourseEnrollment(
        enrollmentId: 'enr_1',
        courseId: 'c_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        enrolledAt: DateTime.now().subtract(Duration(days: 7)),
        completionPercentage: 65.0,
        currentScore: 72.5,
        lessonsCompleted: 6,
        lastAccessedAt: DateTime.now().subtract(Duration(hours: 2)),
      );

      expect(enrollment.isInProgress, true);
      expect(enrollment.isCompleted, false);
      expect(enrollment.completionPercentage, 65.0);
    });

    test('should mark enrollment as completed', () {
      final enrollment = CourseEnrollment(
        enrollmentId: 'enr_1',
        courseId: 'c_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        enrolledAt: DateTime.now().subtract(Duration(days: 30)),
        completedAt: DateTime.now(),
        completionPercentage: 100.0,
        currentScore: 85.0,
        lessonsCompleted: 10,
      );

      expect(enrollment.isCompleted, true);
      expect(enrollment.completionPercentage, 100.0);
    });
  });

  group('CurriculumProgress', () {
    test('should initialize curriculum progress', () {
      final progress = CurriculumProgress(
        progressId: 'cp_1',
        curriculumId: 'curr_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        currentCourseIndex: 0,
        completedCourseIds: [],
        overallProgress: 0.0,
        currentScore: 0.0,
        hoursSpent: 0,
        startedAt: DateTime.now(),
      );

      expect(progress.isCompleted, false);
      expect(progress.currentCourseIndex, 0);
      expect(progress.overallProgress, 0.0);
    });

    test('should track curriculum progress', () {
      final progress = CurriculumProgress(
        progressId: 'cp_1',
        curriculumId: 'curr_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        currentCourseIndex: 2,
        completedCourseIds: ['c_1', 'c_2'],
        overallProgress: 66.67,
        currentScore: 78.5,
        hoursSpent: 25,
        startedAt: DateTime.now().subtract(Duration(days: 10)),
      );

      expect(progress.isCompleted, false);
      expect(progress.completedCourseIds.length, 2);
      expect(progress.hoursSpent, 25);
    });

    test('should mark curriculum as completed', () {
      final progress = CurriculumProgress(
        progressId: 'cp_1',
        curriculumId: 'curr_1',
        studentId: 's_1',
        partnershipId: 'p_1',
        currentCourseIndex: 3,
        completedCourseIds: ['c_1', 'c_2', 'c_3'],
        overallProgress: 100.0,
        currentScore: 85.0,
        hoursSpent: 40,
        startedAt: DateTime.now().subtract(Duration(days: 30)),
        completedAt: DateTime.now(),
      );

      expect(progress.isCompleted, true);
      expect(progress.overallProgress, 100.0);
    });
  });

  group('QuestionCreation', () {
    test('should create institutional question via service', () async {
      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: '安全運転の基本は何ですか？',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '交通規則',
        answerOptions: ['速度制限を守る', '一時停止を無視', '信号を無視', '急加速'],
        correctAnswer: '速度制限を守る',
        explanation: '安全運転の基本は速度制限を守ることです',
        accessLevel: ContentAccessLevel.institutional,
      );

      expect(questionId.isNotEmpty, true);
      expect(questionId.startsWith('iq_'), true);
    });

    test('should retrieve created question', () async {
      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Test Question',
        type: QuestionType.trueFalse,
        difficulty: QuestionDifficulty.intermediate,
        category: '危機回避',
        answerOptions: ['True', 'False'],
        correctAnswer: 'True',
        accessLevel: ContentAccessLevel.institutional,
      );

      final question = await service.getInstitutionalQuestion(questionId);

      expect(question, isNotNull);
      expect(question!.questionText, 'Test Question');
      expect(question.status, ContentStatus.draft);
    });

    test('should publish question', () async {
      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Publish Test',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.intermediate,
        category: '機械知識',
        answerOptions: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.publishQuestion(questionId);
      final question = await service.getInstitutionalQuestion(questionId);

      expect(question!.status, ContentStatus.published);
    });

    test('should approve question with review notes', () async {
      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Approval Test',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.advanced,
        category: '交通規則',
        answerOptions: ['A', 'B', 'C', 'D'],
        correctAnswer: 'B',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.approveQuestion(
        questionId: questionId,
        reviewedByUserId: 'reviewer_1',
        reviewNotes: 'Excellent question with clear explanation',
      );

      final question = await service.getInstitutionalQuestion(questionId);

      expect(question!.reviewedByUserId, 'reviewer_1');
      expect(question.reviewNotes, contains('Excellent'));
      expect(question.isApproved, true);
    });
  });

  group('QuestionBankManagement', () {
    test('should create question bank', () async {
      final bankId = await service.createQuestionBank(
        partnershipId: 'p_1',
        bankName: 'Safety Questions Bank',
        description: 'Custom questions about vehicle safety',
      );

      expect(bankId.isNotEmpty, true);
      expect(bankId.startsWith('qb_'), true);
    });

    test('should retrieve question bank', () async {
      final bankId = await service.createQuestionBank(
        partnershipId: 'p_1',
        bankName: 'Test Bank',
        description: 'Test Description',
      );

      final bank = await service.getQuestionBank(bankId);

      expect(bank, isNotNull);
      expect(bank!.bankName, 'Test Bank');
    });

    test('should get partnership question banks', () async {
      await service.createQuestionBank(
        partnershipId: 'p_1',
        bankName: 'Bank 1',
        description: 'Description 1',
      );

      await service.createQuestionBank(
        partnershipId: 'p_1',
        bankName: 'Bank 2',
        description: 'Description 2',
      );

      final banks = await service.getPartnershipQuestionBanks('p_1');

      expect(banks.length, greaterThanOrEqualTo(2));
    });
  });

  group('CourseManagement', () {
    test('should create course', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Beginner Safety Course',
        description: 'Learn the basics of safe driving',
        topicIds: ['topic_1', 'topic_2'],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      expect(courseId.isNotEmpty, true);
      expect(courseId.startsWith('course_'), true);
    });

    test('should retrieve course', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Test Course',
        description: 'Test Description',
        topicIds: [],
        totalLessons: 5,
        estimatedHours: 10,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final course = await service.getCourse(courseId);

      expect(course, isNotNull);
      expect(course!.courseName, 'Test Course');
      expect(course.status, CourseStatus.draft);
    });

    test('should publish course', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Publish Test Course',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 20,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.publishCourse(courseId);
      final course = await service.getCourse(courseId);

      expect(course!.status, CourseStatus.active);
      expect(course.isActive, true);
    });

    test('should add question to course', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Course with Questions',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Test Q',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '交通規則',
        answerOptions: ['A', 'B'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.addQuestionToCourse(
        courseId: courseId,
        questionId: questionId,
      );

      final course = await service.getCourse(courseId);

      expect(course!.questionIds.contains(questionId), true);
    });

    test('should get partnership courses', () async {
      await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Course 1',
        description: 'Desc 1',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Course 2',
        description: 'Desc 2',
        topicIds: [],
        totalLessons: 15,
        estimatedHours: 20,
        instructorId: 'instr_2',
        accessLevel: ContentAccessLevel.institutional,
      );

      final courses = await service.getPartnershipCourses('p_1');

      expect(courses.length, greaterThanOrEqualTo(2));
    });
  });

  group('CurriculumManagement', () {
    test('should create curriculum', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Complete License Program',
        description: 'Full curriculum for license preparation',
        type: CurriculumType.standardCurriculum,
        courseIds: ['c_1', 'c_2', 'c_3'],
        totalHours: 50,
        targetLevel: 5,
        targetExamType: 'license_exam',
      );

      expect(curriculumId.isNotEmpty, true);
      expect(curriculumId.startsWith('curr_'), true);
    });

    test('should retrieve curriculum', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Test Curriculum',
        description: 'Test',
        type: CurriculumType.customCurriculum,
        courseIds: ['c_1'],
        totalHours: 20,
        targetLevel: 3,
      );

      final curriculum = await service.getCurriculum(curriculumId);

      expect(curriculum, isNotNull);
      expect(curriculum!.curriculumName, 'Test Curriculum');
      expect(curriculum.type, CurriculumType.customCurriculum);
    });

    test('should publish curriculum', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Publish Test',
        description: 'Test',
        type: CurriculumType.standardCurriculum,
        courseIds: ['c_1'],
        totalHours: 30,
        targetLevel: 4,
      );

      await service.publishCurriculum(curriculumId);
      final curriculum = await service.getCurriculum(curriculumId);

      expect(curriculum!.isPublished, true);
      expect(curriculum.status, ContentStatus.published);
    });

    test('should get partnership curricula', () async {
      await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Curriculum 1',
        description: 'Desc',
        type: CurriculumType.standardCurriculum,
        courseIds: [],
        totalHours: 40,
        targetLevel: 5,
      );

      final curricula = await service.getPartnershipCurricula('p_1');

      expect(curricula, isList);
    });
  });

  group('StudentEnrollment', () {
    test('should enroll student in course', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Enrollment Test Course',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final enrollmentId = await service.enrollInCourse(
        courseId: courseId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      expect(enrollmentId.isNotEmpty, true);
    });

    test('should get course enrollment', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Test Course',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final enrollmentId = await service.enrollInCourse(
        courseId: courseId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      final enrollment = await service.getCourseEnrollment(enrollmentId);

      expect(enrollment, isNotNull);
      expect(enrollment!.studentId, 's_1');
      expect(enrollment.courseId, courseId);
    });

    test('should get student course enrollments', () async {
      final courseId1 = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Course 1',
        description: 'Desc',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final courseId2 = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Course 2',
        description: 'Desc',
        topicIds: [],
        totalLessons: 15,
        estimatedHours: 20,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.enrollInCourse(
        courseId: courseId1,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      await service.enrollInCourse(
        courseId: courseId2,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      final enrollments = await service.getStudentCourseEnrollments('s_1');

      expect(enrollments.length, 2);
    });

    test('should update course progress', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Progress Test',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final enrollmentId = await service.enrollInCourse(
        courseId: courseId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      await service.updateCourseProgress(
        enrollmentId: enrollmentId,
        completionPercentage: 75.0,
        currentScore: 82.5,
        lessonsCompleted: 7,
      );

      final enrollment = await service.getCourseEnrollment(enrollmentId);

      expect(enrollment!.completionPercentage, 75.0);
      expect(enrollment.currentScore, 82.5);
      expect(enrollment.lessonsCompleted, 7);
    });
  });

  group('CurriculumProgressTracking', () {
    test('should start curriculum progress', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Progress Test',
        description: 'Test',
        type: CurriculumType.standardCurriculum,
        courseIds: [],
        totalHours: 40,
        targetLevel: 5,
      );

      final progressId = await service.startCurriculumProgress(
        curriculumId: curriculumId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      expect(progressId.isNotEmpty, true);
    });

    test('should get curriculum progress', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Get Progress Test',
        description: 'Test',
        type: CurriculumType.standardCurriculum,
        courseIds: [],
        totalHours: 40,
        targetLevel: 5,
      );

      final progressId = await service.startCurriculumProgress(
        curriculumId: curriculumId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      final progress = await service.getCurriculumProgress(progressId);

      expect(progress, isNotNull);
      expect(progress!.studentId, 's_1');
      expect(progress.curriculumId, curriculumId);
    });

    test('should update curriculum progress', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Update Test',
        description: 'Test',
        type: CurriculumType.standardCurriculum,
        courseIds: [],
        totalHours: 40,
        targetLevel: 5,
      );

      final progressId = await service.startCurriculumProgress(
        curriculumId: curriculumId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      await service.updateCurriculumProgress(
        progressId: progressId,
        currentCourseIndex: 2,
        overallProgress: 66.67,
        currentScore: 78.5,
        hoursSpent: 25,
      );

      final progress = await service.getCurriculumProgress(progressId);

      expect(progress!.currentCourseIndex, 2);
      expect(progress.overallProgress, 66.67);
      expect(progress.hoursSpent, 25);
    });
  });

  group('QuestionStatistics', () {
    test('should get questions by category', () async {
      await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Q1',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '交通規則',
        answerOptions: ['A', 'B'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Q2',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '危機回避',
        answerOptions: ['A', 'B'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      final stats = await service.getQuestionStatsByCategory('p_1');

      expect(stats.isNotEmpty, true);
      expect(stats.containsKey('交通規則'), true);
    });

    test('should get questions by difficulty', () async {
      await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Easy Q',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.beginner,
        category: '交通規則',
        answerOptions: ['A', 'B'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      final stats = await service.getQuestionStatsByDifficulty('p_1');

      expect(stats.isNotEmpty, true);
      expect(stats.containsKey('beginner'), true);
    });
  });

  group('CompletionRates', () {
    test('should calculate course completion rate', () async {
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Completion Test',
        description: 'Test',
        topicIds: [],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      final enrollmentId = await service.enrollInCourse(
        courseId: courseId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      await service.updateCourseProgress(
        enrollmentId: enrollmentId,
        completionPercentage: 100.0,
        currentScore: 85.0,
        lessonsCompleted: 10,
      );

      final rate = await service.getCourseCompletionRate(courseId);

      expect(rate, greaterThan(0));
    });

    test('should calculate curriculum completion rate', () async {
      final curriculumId = await service.createCurriculum(
        partnershipId: 'p_1',
        curriculumName: 'Completion Test',
        description: 'Test',
        type: CurriculumType.standardCurriculum,
        courseIds: [],
        totalHours: 40,
        targetLevel: 5,
      );

      await service.startCurriculumProgress(
        curriculumId: curriculumId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      final rate = await service.getCurriculumCompletionRate(curriculumId);

      expect(rate, greaterThanOrEqualTo(0));
    });
  });

  group('ContentManagementIntegration', () {
    test('should manage complete course lifecycle', () async {
      // Create question bank
      final bankId = await service.createQuestionBank(
        partnershipId: 'p_1',
        bankName: 'Integration Test Bank',
        description: 'Test',
      );

      expect(bankId.isNotEmpty, true);

      // Create questions
      final questionId = await service.createInstitutionalQuestion(
        partnershipId: 'p_1',
        createdByUserId: 'user_1',
        questionText: 'Integration Test Q',
        type: QuestionType.multipleChoice,
        difficulty: QuestionDifficulty.intermediate,
        category: '交通規則',
        answerOptions: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        accessLevel: ContentAccessLevel.institutional,
      );

      // Approve question
      await service.approveQuestion(
        questionId: questionId,
        reviewedByUserId: 'reviewer_1',
      );

      // Create course
      final courseId = await service.createCourse(
        partnershipId: 'p_1',
        courseName: 'Integration Course',
        description: 'Full integration test',
        topicIds: ['topic_1'],
        totalLessons: 10,
        estimatedHours: 15,
        instructorId: 'instr_1',
        accessLevel: ContentAccessLevel.institutional,
      );

      // Add question to course
      await service.addQuestionToCourse(
        courseId: courseId,
        questionId: questionId,
      );

      // Publish course
      await service.publishCourse(courseId);

      // Student enrolls
      final enrollmentId = await service.enrollInCourse(
        courseId: courseId,
        studentId: 's_1',
        partnershipId: 'p_1',
      );

      // Student completes course
      await service.updateCourseProgress(
        enrollmentId: enrollmentId,
        completionPercentage: 100.0,
        currentScore: 90.0,
        lessonsCompleted: 10,
      );

      // Verify course completion
      final course = await service.getCourse(courseId);
      expect(course!.isActive, true);

      final enrollment = await service.getCourseEnrollment(enrollmentId);
      expect(enrollment!.isCompleted, true);
    });
  });
}
