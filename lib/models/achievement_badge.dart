/// バッジの種類。
enum BadgeType {
  passLevelOne,      // 第一段階 90%以上
  passLevelTwo,      // 第二段階 90%以上
  masterTrapDojo,    // トラップ道場 95%以上
  masterNirin,       // 普通二輪マスター 95%以上
  masterGentsuki,    // 原付マスター 95%以上
  masterOgataNirin,  // 大型二輪マスター 95%以上
  weeklyStreak7,     // 7日連続学習
  questionMilestone100, // 100問解答達成
  questionMilestone500, // 500問解答達成
}

extension BadgeTypeExt on BadgeType {
  String get displayName {
    switch (this) {
      case BadgeType.passLevelOne:
        return '第一段階合格';
      case BadgeType.passLevelTwo:
        return '第二段階合格';
      case BadgeType.masterTrapDojo:
        return 'トラップマスター';
      case BadgeType.masterNirin:
        return '普通二輪マスター';
      case BadgeType.masterGentsuki:
        return '原付マスター';
      case BadgeType.masterOgataNirin:
        return '大型二輪マスター';
      case BadgeType.weeklyStreak7:
        return '7日連続学習';
      case BadgeType.questionMilestone100:
        return '100問達成';
      case BadgeType.questionMilestone500:
        return '500問達成';
    }
  }

  String get description {
    switch (this) {
      case BadgeType.passLevelOne:
        return '第一段階の問題で90%以上の正答率を達成';
      case BadgeType.passLevelTwo:
        return '第二段階の問題で90%以上の正答率を達成';
      case BadgeType.masterTrapDojo:
        return 'トラップ問題で95%以上の正答率を達成';
      case BadgeType.masterNirin:
        return '普通二輪で95%以上の正答率を達成';
      case BadgeType.masterGentsuki:
        return '原付で95%以上の正答率を達成';
      case BadgeType.masterOgataNirin:
        return '大型二輪で95%以上の正答率を達成';
      case BadgeType.weeklyStreak7:
        return '7日間連続で学習';
      case BadgeType.questionMilestone100:
        return '合計100問の解答に到達';
      case BadgeType.questionMilestone500:
        return '合計500問の解答に到達';
    }
  }

  String get icon {
    switch (this) {
      case BadgeType.passLevelOne:
      case BadgeType.passLevelTwo:
        return '🎓';
      case BadgeType.masterTrapDojo:
      case BadgeType.masterNirin:
      case BadgeType.masterGentsuki:
      case BadgeType.masterOgataNirin:
        return '👑';
      case BadgeType.weeklyStreak7:
        return '🔥';
      case BadgeType.questionMilestone100:
      case BadgeType.questionMilestone500:
        return '🎯';
    }
  }
}

class AchievementBadge {
  AchievementBadge({
    required this.uid,
    required this.badgeType,
    required this.unlockedAt,
    required this.criteria,
  });

  final String uid;
  final BadgeType badgeType;
  final DateTime unlockedAt;
  final String criteria; // "第一段階 正答率 90.5%" など

  factory AchievementBadge.fromJson(Map<String, dynamic> json) =>
      AchievementBadge(
        uid: json['uid'] as String,
        badgeType:
            BadgeType.values.firstWhere((e) => e.name == json['badgeType'] as String),
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
        criteria: json['criteria'] as String,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'badgeType': badgeType.name,
    'unlockedAt': unlockedAt.toIso8601String(),
    'criteria': criteria,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementBadge &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          badgeType == other.badgeType &&
          unlockedAt == other.unlockedAt;

  @override
  int get hashCode => uid.hashCode ^ badgeType.hashCode ^ unlockedAt.hashCode;
}
