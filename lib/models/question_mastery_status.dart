/// ユーザーが「記憶した」フラグを管理するモデル。
/// 学習済みの問題を除外・復習時に優先表示する際に使用。
class QuestionMasteryStatus {
  QuestionMasteryStatus({
    required this.uid,
    required this.questionId,
    required this.isMastered,
    this.masteredAt,
  });

  final String uid;
  final String questionId;
  final bool isMastered;
  final DateTime? masteredAt;

  factory QuestionMasteryStatus.fromJson(Map<String, dynamic> json) =>
      QuestionMasteryStatus(
        uid: json['uid'] as String,
        questionId: json['questionId'] as String,
        isMastered: json['isMastered'] as bool,
        masteredAt: json['masteredAt'] != null
            ? DateTime.parse(json['masteredAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'questionId': questionId,
    'isMastered': isMastered,
    'masteredAt': masteredAt?.toIso8601String(),
  };

  QuestionMasteryStatus copyWith({
    String? uid,
    String? questionId,
    bool? isMastered,
    DateTime? masteredAt,
  }) {
    return QuestionMasteryStatus(
      uid: uid ?? this.uid,
      questionId: questionId ?? this.questionId,
      isMastered: isMastered ?? this.isMastered,
      masteredAt: masteredAt ?? this.masteredAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionMasteryStatus &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          questionId == other.questionId &&
          isMastered == other.isMastered &&
          masteredAt == other.masteredAt;

  @override
  int get hashCode =>
      uid.hashCode ^
      questionId.hashCode ^
      isMastered.hashCode ^
      masteredAt.hashCode;
}
