class UserAnswerLog {
  UserAnswerLog({
    required this.uid,
    required this.questionId,
    required this.isCorrect,
    required this.answeredAt,
  });

  final String uid;
  final String questionId;
  final bool isCorrect;
  final DateTime answeredAt;

  factory UserAnswerLog.fromJson(Map<String, dynamic> json) => UserAnswerLog(
    uid: json['uid'] as String,
    questionId: json['questionId'] as String,
    isCorrect: json['isCorrect'] as bool,
    answeredAt: DateTime.parse(json['answeredAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'questionId': questionId,
    'isCorrect': isCorrect,
    'answeredAt': answeredAt.toIso8601String(),
  };
}
