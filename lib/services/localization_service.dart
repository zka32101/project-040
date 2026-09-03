/// Phase 34: 国際化・ローカライゼーション サービス実装
///
/// 複数言語対応、地域設定、通貨・日付形式管理、翻訳管理

import 'package:project_040/models/localization_models.dart';

/// 翻訳リポジトリインターフェース
abstract class TranslationRepository {
  /// 翻訳エントリを取得
  Future<TranslationEntry?> getTranslation(String key);

  /// カテゴリ別に翻訳を取得
  Future<List<TranslationEntry>> getTranslationsByCategory(
    TranslationCategory category,
  );

  /// 言語の全翻訳を取得
  Future<Map<String, String>> getLanguageTranslations(String languageCode);

  /// 翻訳を保存
  Future<void> saveTranslation(TranslationEntry entry);

  /// 翻訳を削除
  Future<void> deleteTranslation(String key);

  /// 複数形テキストを取得
  Future<PluralText?> getPluralText(String key);

  /// 複数形テキストを保存
  Future<void> savePluralText(PluralText text);
}

/// メモリ実装の翻訳リポジトリ
class MemoryTranslationRepository implements TranslationRepository {
  final Map<String, TranslationEntry> _translations = {};
  final Map<String, PluralText> _pluralTexts = {};

  @override
  Future<TranslationEntry?> getTranslation(String key) async {
    return _translations[key];
  }

  @override
  Future<List<TranslationEntry>> getTranslationsByCategory(
    TranslationCategory category,
  ) async {
    return _translations.values
        .where((entry) => entry.category == category)
        .toList();
  }

  @override
  Future<Map<String, String>> getLanguageTranslations(
    String languageCode,
  ) async {
    final result = <String, String>{};
    _translations.forEach((key, entry) {
      if (entry.translations.containsKey(languageCode)) {
        result[key] = entry.translations[languageCode]!;
      }
    });
    return result;
  }

  @override
  Future<void> saveTranslation(TranslationEntry entry) async {
    _translations[entry.key] = entry;
  }

  @override
  Future<void> deleteTranslation(String key) async {
    _translations.remove(key);
  }

  @override
  Future<PluralText?> getPluralText(String key) async {
    return _pluralTexts[key];
  }

  @override
  Future<void> savePluralText(PluralText text) async {
    _pluralTexts[text.key] = text;
  }
}

/// ローカライゼーション設定リポジトリインターフェース
abstract class LocalizationPreferencesRepository {
  /// ユーザーの設定を取得
  Future<LocalizationPreferences?> getPreferences(String userId);

  /// 設定を保存
  Future<void> savePreferences(LocalizationPreferences prefs);

  /// 設定を削除
  Future<void> deletePreferences(String userId);

  /// 言語でフィルタリング
  Future<List<LocalizationPreferences>> getByLanguage(Language language);

  /// デフォルト設定を取得
  Future<LocalizationPreferences> getDefaultPreferences();
}

/// メモリ実装のローカライゼーション設定リポジトリ
class MemoryLocalizationPreferencesRepository
    implements LocalizationPreferencesRepository {
  final Map<String, LocalizationPreferences> _preferences = {};
  late LocalizationPreferences _defaultPrefs;

  MemoryLocalizationPreferencesRepository() {
    // デフォルト設定を初期化 (en_US)
    _defaultPrefs = LocalizationPreferences(
      preferencesId: 'default_prefs',
      userId: 'system',
      language: Language.en,
      region: Region.us,
      dateFormat: DateFormat.medium,
      timeFormat: TimeFormat.short12,
      currency: Currency.predefinedCurrencies['USD']!,
      numberFormat: NumberFormat(
        numberFormatId: 'us_number',
        languageCode: 'en',
        decimalSeparator: '.',
        thousandsSeparator: ',',
        createdAt: DateTime.now(),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<LocalizationPreferences?> getPreferences(String userId) async {
    return _preferences[userId];
  }

  @override
  Future<void> savePreferences(LocalizationPreferences prefs) async {
    _preferences[prefs.userId] = prefs;
  }

  @override
  Future<void> deletePreferences(String userId) async {
    _preferences.remove(userId);
  }

  @override
  Future<List<LocalizationPreferences>> getByLanguage(
    Language language,
  ) async {
    return _preferences.values
        .where((prefs) => prefs.language == language)
        .toList();
  }

  @override
  Future<LocalizationPreferences> getDefaultPreferences() async {
    return _defaultPrefs;
  }
}

/// ローカライゼーションサービスインターフェース
abstract class LocalizationService {
  /// テキストを翻訳
  Future<String> translate(String key, {String? languageCode});

  /// 複数形テキストを取得
  Future<String> getPluralForm(String key, int count);

  /// テンプレート文字列を翻訳 (変数置換)
  Future<String> translateWithVariables(
    String key,
    Map<String, String> variables, {
    String? languageCode,
  });

  /// ユーザーのローカライゼーション設定を取得
  Future<LocalizationPreferences?> getUserPreferences(String userId);

  /// ローカライゼーション設定を更新
  Future<void> updateUserPreferences(LocalizationPreferences prefs);

  /// 現在の言語を設定
  Future<void> setCurrentLanguage(Language language);

  /// 現在の地域を設定
  Future<void> setCurrentRegion(Region region);

  /// 現在の言語を取得
  Language getCurrentLanguage();

  /// 現在の地域を取得
  Region getCurrentRegion();

  /// 日付をフォーマット
  String formatDate(DateTime date, DateFormat format);

  /// 時刻をフォーマット
  String formatTime(DateTime dateTime, TimeFormat format);

  /// 通貨をフォーマット
  String formatCurrency(double amount, Currency currency);

  /// 数値をフォーマット
  String formatNumber(double value);

  /// 利用可能な言語を取得
  List<Language> getAvailableLanguages();

  /// 翻訳統計を取得
  Future<TranslationStatistics> getTranslationStatistics(Language language);
}

/// メモリ実装のローカライゼーションサービス
class MemoryLocalizationService implements LocalizationService {
  late TranslationRepository _translationRepo;
  late LocalizationPreferencesRepository _preferencesRepo;
  late Language _currentLanguage;
  late Region _currentRegion;

  MemoryLocalizationService() {
    _translationRepo = MemoryTranslationRepository();
    _preferencesRepo = MemoryLocalizationPreferencesRepository();
    _currentLanguage = Language.en;
    _currentRegion = Region.us;

    // サンプル翻訳データを初期化
    _initializeSampleTranslations();
  }

  /// サンプル翻訳データを初期化
  void _initializeSampleTranslations() {
    final translations = [
      TranslationEntry(
        translationId: 'trans_1',
        key: 'app.title',
        category: TranslationCategory.common,
        translations: {
          'en': 'Job Monitoring System',
          'ja': 'ジョブ監視システム',
          'ko': '작업 모니터링 시스템',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
      ),
      TranslationEntry(
        translationId: 'trans_2',
        key: 'job.status.completed',
        category: TranslationCategory.jobStatus,
        translations: {
          'en': 'Completed',
          'ja': '完了',
          'ko': '완료됨',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
      ),
      TranslationEntry(
        translationId: 'trans_3',
        key: 'job.status.failed',
        category: TranslationCategory.jobStatus,
        translations: {
          'en': 'Failed',
          'ja': '失敗',
          'ko': '실패',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
      ),
      TranslationEntry(
        translationId: 'trans_4',
        key: 'error.validation.required',
        category: TranslationCategory.validation,
        translations: {
          'en': 'This field is required',
          'ja': 'このフィールドは必須です',
          'ko': '이 필드는 필수입니다',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
      ),
      TranslationEntry(
        translationId: 'trans_5',
        key: 'welcome.message',
        category: TranslationCategory.messages,
        translations: {
          'en': 'Welcome, {{name}}!',
          'ja': 'いらっしゃいませ、{{name}}さん！',
          'ko': '환영합니다, {{name}}님!',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isApproved: true,
      ),
    ];

    for (var entry in translations) {
      _translationRepo.saveTranslation(entry);
    }

    // サンプル複数形テキスト
    final pluralTexts = [
      PluralText(
        textId: 'plural_1',
        key: 'job.count',
        texts: {
          PluralRule.zero: 'No jobs',
          PluralRule.one: 'One job',
          PluralRule.other: '{{count}} jobs',
        },
        createdAt: DateTime.now(),
      ),
    ];

    for (var text in pluralTexts) {
      _translationRepo.savePluralText(text);
    }
  }

  @override
  Future<String> translate(String key, {String? languageCode}) async {
    final lang = languageCode ?? _currentLanguage.code;
    final entry = await _translationRepo.getTranslation(key);
    if (entry == null) return key; // キーが見つからない場合はキー自体を返す

    return entry.getTranslation(lang) ?? key;
  }

  @override
  Future<String> getPluralForm(String key, int count) async {
    final entry = await _translationRepo.getPluralText(key);
    if (entry == null) return count.toString();

    var text = entry.getText(count);
    text = text.replaceAll('{{count}}', count.toString());
    return text;
  }

  @override
  Future<String> translateWithVariables(
    String key,
    Map<String, String> variables, {
    String? languageCode,
  }) async {
    var text = await translate(key, languageCode: languageCode);

    variables.forEach((varKey, value) {
      text = text.replaceAll('{{$varKey}}', value);
    });

    return text;
  }

  @override
  Future<LocalizationPreferences?> getUserPreferences(String userId) async {
    return _preferencesRepo.getPreferences(userId);
  }

  @override
  Future<void> updateUserPreferences(LocalizationPreferences prefs) async {
    await _preferencesRepo.savePreferences(prefs);
    _currentLanguage = prefs.language;
    _currentRegion = prefs.region;
  }

  @override
  Future<void> setCurrentLanguage(Language language) async {
    _currentLanguage = language;
  }

  @override
  Future<void> setCurrentRegion(Region region) async {
    _currentRegion = region;
  }

  @override
  Language getCurrentLanguage() => _currentLanguage;

  @override
  Region getCurrentRegion() => _currentRegion;

  @override
  String formatDate(DateTime date, DateFormat format) {
    // 簡易実装 (実際はintlパッケージを使用すべき)
    switch (format) {
      case DateFormat.short:
        return '${date.month}/${date.day}/${date.year % 100}';
      case DateFormat.medium:
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      case DateFormat.long:
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      case DateFormat.full:
        const weekdays = [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday'
        ];
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
      case DateFormat.iso:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  String formatTime(DateTime dateTime, TimeFormat format) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    switch (format) {
      case TimeFormat.short12:
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour12:$minute $ampm';
      case TimeFormat.short24:
        return '${hour.toString().padLeft(2, '0')}:$minute';
      case TimeFormat.medium:
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour12:$minute:$second $ampm';
      case TimeFormat.long:
        return '${hour.toString().padLeft(2, '0')}:$minute:$second UTC';
    }
  }

  @override
  String formatCurrency(double amount, Currency currency) {
    return currency.format(amount);
  }

  @override
  String formatNumber(double value) {
    // 現在のユーザー設定に基づいてフォーマット
    // 簡易実装
    return value.toStringAsFixed(2);
  }

  @override
  List<Language> getAvailableLanguages() {
    return Language.values;
  }

  @override
  Future<TranslationStatistics> getTranslationStatistics(
    Language language,
  ) async {
    // すべてのカテゴリから翻訳を取得
    final allTranslations = <TranslationEntry>[];
    for (final category in TranslationCategory.values) {
      allTranslations.addAll(
        await _translationRepo.getTranslationsByCategory(category),
      );
    }

    final totalKeys = allTranslations.length;
    final translatedKeys = allTranslations
        .where((entry) => entry.translations.containsKey(language.code))
        .length;
    final approvedKeys =
        allTranslations.where((entry) => entry.isApproved).length;

    return TranslationStatistics(
      statisticsId: 'stats_${language.code}',
      language: language,
      totalKeys: totalKeys,
      translatedKeys: translatedKeys,
      approvedKeys: approvedKeys,
      calculatedAt: DateTime.now(),
    );
  }
}

/// ローカライゼーションマネージャー (ファサードパターン)
class LocalizationManager {
  late LocalizationService _service;
  late TranslationRepository _translationRepo;
  late LocalizationPreferencesRepository _preferencesRepo;

  LocalizationManager({
    LocalizationService? service,
    TranslationRepository? translationRepo,
    LocalizationPreferencesRepository? preferencesRepo,
  }) {
    _service = service ?? MemoryLocalizationService();
    _translationRepo = translationRepo ?? MemoryTranslationRepository();
    _preferencesRepo =
        preferencesRepo ?? MemoryLocalizationPreferencesRepository();
  }

  /// テキストを翻訳
  Future<String> t(String key, {String? languageCode}) =>
      _service.translate(key, languageCode: languageCode);

  /// テンプレート翻訳
  Future<String> tw(String key, Map<String, String> vars) =>
      _service.translateWithVariables(key, vars);

  /// 複数形
  Future<String> plural(String key, int count) =>
      _service.getPluralForm(key, count);

  /// ユーザー設定を取得
  Future<LocalizationPreferences?> getUserPrefs(String userId) =>
      _service.getUserPreferences(userId);

  /// ユーザー設定を更新
  Future<void> setUserPrefs(LocalizationPreferences prefs) =>
      _service.updateUserPreferences(prefs);

  /// 言語を変更
  Future<void> setLanguage(Language lang) =>
      _service.setCurrentLanguage(lang);

  /// 地域を変更
  Future<void> setRegion(Region region) => _service.setCurrentRegion(region);

  /// 現在の言語を取得
  Language getLanguage() => _service.getCurrentLanguage();

  /// 現在の地域を取得
  Region getRegion() => _service.getCurrentRegion();

  /// 日付フォーマット
  String formatDate(DateTime date, DateFormat format) =>
      _service.formatDate(date, format);

  /// 時刻フォーマット
  String formatTime(DateTime time, TimeFormat format) =>
      _service.formatTime(time, format);

  /// 通貨フォーマット
  String formatCurrency(double amount, Currency currency) =>
      _service.formatCurrency(amount, currency);

  /// 数値フォーマット
  String formatNumber(double value) => _service.formatNumber(value);

  /// 利用可能言語
  List<Language> availableLanguages() => _service.getAvailableLanguages();

  /// 翻訳統計
  Future<TranslationStatistics> stats(Language lang) =>
      _service.getTranslationStatistics(lang);
}
