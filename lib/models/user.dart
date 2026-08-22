enum PurchaseStatus { free, singleCategoryPass, allCategorySetPass }

class AppUser {
  AppUser({
    required this.uid,
    this.licenseCategories = const [],
    this.trainingStage,
    this.examDate,
    this.streakCount = 0,
    this.purchaseStatus = PurchaseStatus.free,
  });

  final String uid;

  /// 複数選択可（Step2 画面フロー：免許区分選択(複数選択可)）。
  final List<String> licenseCategories;

  /// 教習所の進行段階。任意入力・スキップ可。
  final String? trainingStage;

  final DateTime? examDate;
  final int streakCount;
  final PurchaseStatus purchaseStatus;

  /// 無料枠：区分1つまで無料。2区分目以降は単一/全区分パスが必要。
  bool get hasFreeCategoryOnly =>
      purchaseStatus == PurchaseStatus.free && licenseCategories.length <= 1;

  AppUser copyWith({
    List<String>? licenseCategories,
    String? trainingStage,
    DateTime? examDate,
    int? streakCount,
    PurchaseStatus? purchaseStatus,
  }) {
    return AppUser(
      uid: uid,
      licenseCategories: licenseCategories ?? this.licenseCategories,
      trainingStage: trainingStage ?? this.trainingStage,
      examDate: examDate ?? this.examDate,
      streakCount: streakCount ?? this.streakCount,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'] as String,
    licenseCategories: List<String>.from(
      json['licenseCategories'] as List? ?? [],
    ),
    trainingStage: json['trainingStage'] as String?,
    examDate: json['examDate'] != null
        ? DateTime.parse(json['examDate'] as String)
        : null,
    streakCount: json['streakCount'] as int? ?? 0,
    purchaseStatus: PurchaseStatus.values.firstWhere(
      (e) => e.name == (json['purchaseStatus'] as String? ?? 'free'),
      orElse: () => PurchaseStatus.free,
    ),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'licenseCategories': licenseCategories,
    'trainingStage': trainingStage,
    'examDate': examDate?.toIso8601String(),
    'streakCount': streakCount,
    'purchaseStatus': purchaseStatus.name,
  };
}
