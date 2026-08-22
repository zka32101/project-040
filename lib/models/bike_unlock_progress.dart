class BikeUnlockProgress {
  BikeUnlockProgress({
    required this.uid,
    required this.bikeId,
    this.unlockedAt,
    required this.requiredCorrectCount,
  });

  final String uid;

  /// BikeTier.name（原付/125/250/400/大型）。
  final String bikeId;
  final DateTime? unlockedAt;
  final int requiredCorrectCount;

  bool get isUnlocked => unlockedAt != null;

  factory BikeUnlockProgress.fromJson(Map<String, dynamic> json) =>
      BikeUnlockProgress(
        uid: json['uid'] as String,
        bikeId: json['bikeId'] as String,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        requiredCorrectCount: json['requiredCorrectCount'] as int,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'bikeId': bikeId,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'requiredCorrectCount': requiredCorrectCount,
  };
}
