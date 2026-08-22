/// 免許区分。
///
/// 【重要・差別化の重心】原付は業界団体・メーカー公式の無料アプリ
/// （ゲンチャレ／ゲンツキ免許チャレンジ）が強く白地ではない。
/// 普通二輪・大型二輪・AT限定を先行実装・先行コンテンツ投入し、
/// 原付は入口機能に留める（企画設計書 v1.1 参照）。
enum LicenseCategory {
  gentsuki('原付', contentPriority: 5),
  kogataGentsukiNirin('小型限定普通二輪', contentPriority: 2),
  futsuuNirin('普通二輪', contentPriority: 1),
  ogataNirin('大型二輪', contentPriority: 1),
  atGentei('AT限定各種', contentPriority: 2);

  const LicenseCategory(this.label, {required this.contentPriority});

  /// 数字が小さいほどコンテンツ投入・ASO投資の優先度が高い。
  final String label;
  final int contentPriority;

  static LicenseCategory fromId(String id) =>
      LicenseCategory.values.firstWhere((e) => e.name == id);
}

/// バイク解放グリッドの段階（原付→…→大型二輪）。
enum BikeTier {
  gentsuki('原付', requiredCorrectCount: 0),
  cc125('125cc', requiredCorrectCount: 20),
  cc250('250cc', requiredCorrectCount: 50),
  cc400('400cc', requiredCorrectCount: 90),
  ogata('大型二輪', requiredCorrectCount: 150);

  const BikeTier(this.label, {required this.requiredCorrectCount});

  final String label;
  final int requiredCorrectCount;
}
