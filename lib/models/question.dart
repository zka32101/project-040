/// 二輪特有のひっかけで間違えやすい数字の種類。
/// 道場モードの出題選定・ボス化ロジックで参照する。
enum TrapNumberType {
  none,
  twoPersonRiding, // 二人乗り条件
  loadLimit, // 積載制限
  twoStageRightTurn, // 二段階右折
  speedLimit,
  followingDistance,
  other,
}

class Question {
  Question({
    required this.id,
    required this.licenseCategory,
    required this.stageTag,
    required this.difficulty,
    required this.questionText,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.isTrapQuestion = false,
    this.trapNumberType = TrapNumberType.none,
  }) : assert(choices.length >= 2, 'choices must have at least 2 options'),
       assert(
         answer >= 0 && answer < choices.length,
         'answer index out of range',
       );

  final String id;

  /// 対象免許区分（複数区分で共通出題されうるため配列）。
  final List<String> licenseCategory;

  /// 教習所段階タグ（例: '第一段階', '第二段階', 'AT教習'）。段階別モードのフィルタに使う。
  final String stageTag;

  /// 1(易)〜5(難)。
  final int difficulty;

  final String questionText;
  final List<String> choices;

  /// choices のうち正解のインデックス。
  final int answer;
  final String explanation;

  /// ひっかけ道場の対象問題か。
  final bool isTrapQuestion;

  /// ひっかけの種類（isTrapQuestion=true のときのみ意味を持つ）。
  final TrapNumberType trapNumberType;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      licenseCategory: List<String>.from(json['licenseCategory'] as List),
      stageTag: json['stageTag'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      questionText: json['questionText'] as String,
      choices: List<String>.from(json['choices'] as List),
      answer: json['answer'] as int,
      explanation: json['explanation'] as String? ?? '',
      isTrapQuestion: json['isTrapQuestion'] as bool? ?? false,
      trapNumberType: TrapNumberType.values.firstWhere(
        (e) => e.name == (json['trapNumberType'] as String? ?? 'none'),
        orElse: () => TrapNumberType.none,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'licenseCategory': licenseCategory,
    'stageTag': stageTag,
    'difficulty': difficulty,
    'questionText': questionText,
    'choices': choices,
    'answer': answer,
    'explanation': explanation,
    'isTrapQuestion': isTrapQuestion,
    'trapNumberType': trapNumberType.name,
  };
}
