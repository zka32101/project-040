import '../models/question.dart';
import 'local_data_service.dart';

/// 統計計算用の質問メタデータ（テキスト・選択肢は除外してメモリ最適化）
class QuestionMeta {
  QuestionMeta({
    required this.id,
    required this.licenseCategory,
    required this.stageTag,
    required this.difficulty,
    required this.isTrapQuestion,
    required this.trapNumberType,
    this.topicTag,
  });

  final String id;
  final List<String> licenseCategory;
  final String stageTag;
  final int difficulty; // 1-5
  final bool isTrapQuestion;
  final TrapNumberType trapNumberType;

  /// オプション：トピックタグ（将来的に精度向上のため）
  final String? topicTag;

  /// 問題をQuestionオブジェクトから生成
  factory QuestionMeta.from(Question question) => QuestionMeta(
    id: question.id,
    licenseCategory: question.licenseCategory,
    stageTag: question.stageTag,
    difficulty: question.difficulty,
    isTrapQuestion: question.isTrapQuestion,
    trapNumberType: question.trapNumberType,
    topicTag: null, // TODO: Questionモデルに topicTag フィールドを追加後、ここで取得
  );
}

/// 全質問を高速に参照できるインデックス
/// 分析計算用に、質問をidでルックアップできるメモリ効率的な構造。
class QuestionIndex {
  QuestionIndex(this._byId);

  final Map<String, QuestionMeta> _byId;

  /// IDから質問メタデータを取得
  QuestionMeta? operator [](String id) => _byId[id];

  /// インデックスに含まれる問題数
  int get length => _byId.length;

  /// 全IDを取得
  Iterable<String> get allIds => _byId.keys;

  /// 全メタデータを取得
  Iterable<QuestionMeta> get allMeta => _byId.values;

  /// 特定の条件で問題をフィルタリング
  List<QuestionMeta> where(bool Function(QuestionMeta) predicate) {
    return _byId.values.where(predicate).toList();
  }

  /// ステージ別に問題をグループ化
  Map<String, List<QuestionMeta>> groupByStage() {
    final result = <String, List<QuestionMeta>>{};
    for (final meta in _byId.values) {
      result.putIfAbsent(meta.stageTag, () => []).add(meta);
    }
    return result;
  }

  /// カテゴリ別に問題をグループ化
  Map<String, List<QuestionMeta>> groupByCategory() {
    final result = <String, List<QuestionMeta>>{};
    for (final meta in _byId.values) {
      for (final category in meta.licenseCategory) {
        result.putIfAbsent(category, () => []).add(meta);
      }
    }
    return result;
  }

  /// トラップ問題の種別でグループ化
  Map<TrapNumberType, List<QuestionMeta>> groupByTrapType() {
    final result = <TrapNumberType, List<QuestionMeta>>{};
    for (final meta in _byId.values) {
      if (meta.isTrapQuestion) {
        result.putIfAbsent(meta.trapNumberType, () => []).add(meta);
      }
    }
    return result;
  }

  /// 難易度別にグループ化
  Map<int, List<QuestionMeta>> groupByDifficulty() {
    final result = <int, List<QuestionMeta>>{};
    for (final meta in _byId.values) {
      result.putIfAbsent(meta.difficulty, () => []).add(meta);
    }
    return result;
  }
}

/// QuestionIndexを構築するサービス
abstract class QuestionIndexBuilder {
  Future<QuestionIndex> build();
}

/// ローカルデータサービスを使用した実装
class LocalQuestionIndexBuilder implements QuestionIndexBuilder {
  LocalQuestionIndexBuilder(this._dataService);

  final DataService _dataService;

  @override
  Future<QuestionIndex> build() async {
    final byId = <String, QuestionMeta>{};

    // すべてのカテゴリで問題をロード（ステージフィルターなし = 全問題）
    final categories = ['futsuuNirin', 'gentsuki', 'ogataNirin'];
    for (final category in categories) {
      try {
        final questions =
            await _dataService.loadQuestions(licenseCategory: category);
        for (final question in questions) {
          // 同じIDが複数回出現する場合は、最初に出現したものを保持
          // （カテゴリをまたいで同一問題が使用されるため）
          byId.putIfAbsent(question.id, () => QuestionMeta.from(question));
        }
      } catch (e) {
        // 個別のカテゴリ読み込み失敗はスキップ
        print('Failed to load questions for category $category: $e');
      }
    }

    return QuestionIndex(byId);
  }
}
