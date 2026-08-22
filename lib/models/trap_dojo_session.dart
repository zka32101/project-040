/// ひっかけ道場：誤答は自動でボス化し再挑戦キューに積まれる。
class TrapDojoSession {
  TrapDojoSession({
    required this.uid,
    required this.bossQuestionId,
    this.defeatedAt,
    this.retryCount = 0,
  });

  final String uid;
  final String bossQuestionId;
  final DateTime? defeatedAt;
  final int retryCount;

  bool get isDefeated => defeatedAt != null;

  TrapDojoSession copyWithRetry() => TrapDojoSession(
    uid: uid,
    bossQuestionId: bossQuestionId,
    defeatedAt: defeatedAt,
    retryCount: retryCount + 1,
  );

  TrapDojoSession copyAsDefeated(DateTime at) => TrapDojoSession(
    uid: uid,
    bossQuestionId: bossQuestionId,
    defeatedAt: at,
    retryCount: retryCount,
  );

  factory TrapDojoSession.fromJson(Map<String, dynamic> json) =>
      TrapDojoSession(
        uid: json['uid'] as String,
        bossQuestionId: json['bossQuestionId'] as String,
        defeatedAt: json['defeatedAt'] != null
            ? DateTime.parse(json['defeatedAt'] as String)
            : null,
        retryCount: json['retryCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'bossQuestionId': bossQuestionId,
    'defeatedAt': defeatedAt?.toIso8601String(),
    'retryCount': retryCount,
  };
}
