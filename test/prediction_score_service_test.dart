import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/services/prediction_score_service.dart';
import 'package:flutter_test/flutter_test.dart';

Question _q(String id, {int difficulty = 1, List<String>? categories}) {
  return Question(
    id: id,
    licenseCategory: categories ?? const ['futsuuNirin'],
    stageTag: '',
    difficulty: difficulty,
    questionText: 'q',
    choices: const ['a', 'b'],
    answer: 0,
    explanation: '',
  );
}

void main() {
  final service = PredictionScoreService();
  final now = DateTime(2026, 8, 22);

  test('no logs → score is 0, empty breakdown', () {
    final result = service.calculate(
      uid: 'u1',
      logs: const [],
      questionsById: const {},
      now: now,
    );
    expect(result.score, 0);
    expect(result.breakdown, isEmpty);
  });

  test('few answers stay pulled toward 50% (confidence penalty)', () {
    final q1 = _q('q1');
    final logs = [
      UserAnswerLog(uid: 'u1', questionId: 'q1', isCorrect: true, answeredAt: now),
    ];
    final result = service.calculate(
      uid: 'u1',
      logs: logs,
      questionsById: {'q1': q1},
      now: now,
    );
    // 1問しか答えていないので、100%正解でも50%からあまり離れないはず。
    expect(result.score, lessThan(70));
    expect(result.score, greaterThan(50));
  });

  test('hasEnoughDataForPrediction respects the threshold', () {
    expect(service.hasEnoughDataForPrediction(9), isFalse);
    expect(service.hasEnoughDataForPrediction(10), isTrue);
  });

  test('all-correct with enough answers approaches 100%', () {
    final questionsById = <String, Question>{};
    final logs = <UserAnswerLog>[];
    for (var i = 0; i < 12; i++) {
      final id = 'q$i';
      questionsById[id] = _q(id);
      logs.add(
        UserAnswerLog(uid: 'u1', questionId: id, isCorrect: true, answeredAt: now),
      );
    }
    final result = service.calculate(
      uid: 'u1',
      logs: logs,
      questionsById: questionsById,
      now: now,
    );
    expect(result.score, greaterThan(90));
    expect(result.breakdown['futsuuNirin'], 1.0);
  });

  test('breakdown is computed per license category', () {
    final qA = _q('qa', categories: ['futsuuNirin']);
    final qB = _q('qb', categories: ['ogataNirin']);
    final logs = [
      UserAnswerLog(uid: 'u1', questionId: 'qa', isCorrect: true, answeredAt: now),
      UserAnswerLog(uid: 'u1', questionId: 'qb', isCorrect: false, answeredAt: now),
    ];
    final result = service.calculate(
      uid: 'u1',
      logs: logs,
      questionsById: {'qa': qA, 'qb': qB},
      now: now,
    );
    expect(result.breakdown['futsuuNirin'], 1.0);
    expect(result.breakdown['ogataNirin'], 0.0);
  });
}
