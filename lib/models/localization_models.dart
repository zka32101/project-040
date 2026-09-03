/// Phase 34: 国際化・ローカライゼーション モデル定義
///
/// 複数言語対応、地域設定、通貨・日付形式を管理するモデルセット

/// 言語コード (ISO 639-1)
enum Language {
  en('en', 'English'),
  ja('ja', '日本語'),
  ko('ko', '한국어'),
  zh('zh', '中文'),
  de('de', 'Deutsch'),
  fr('fr', 'Français'),
  es('es', 'Español'),
  it('it', 'Italiano'),
  ru('ru', 'Русский'),
  pt('pt', 'Português');

  final String code;
  final String displayName;

  const Language(this.code, this.displayName);

  static Language fromCode(String code) {
    try {
      return Language.values.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return Language.en; // デフォルトは英語
    }
  }
}

/// 地域コード (ISO 3166-1)
enum Region {
  us('US', 'United States'),
  gb('GB', 'United Kingdom'),
  jp('JP', '日本'),
  kr('KR', '韓国'),
  cn('CN', '中国'),
  de('DE', 'ドイツ'),
  fr('FR', 'フランス'),
  es('ES', 'スペイン'),
  it('IT', 'イタリア'),
  ru('RU', 'ロシア'),
  br('BR', 'ブラジル');

  final String code;
  final String displayName;

  const Region(this.code, this.displayName);

  static Region fromCode(String code) {
    try {
      return Region.values.firstWhere((region) => region.code == code);
    } catch (e) {
      return Region.us; // デフォルトは米国
    }
  }
}

/// ロケール設定 (言語 + 地域)
class Locale {
  final String localeId;
  final Language language;
  final Region region;
  final DateTime createdAt;
  final bool isDefault;

  Locale({
    required this.localeId,
    required this.language,
    required this.region,
    required this.createdAt,
    this.isDefault = false,
  });

  /// ロケール文字列を返す (例: en_US, ja_JP)
  String get localeCode => '${language.code}_${region.code}';

  /// 表示用フルロケール名を返す (例: English (United States))
  String get displayName => '${language.displayName} (${region.displayName})';

  @override
  String toString() => localeCode;
}

/// 翻訳キーのキャテゴリ
enum TranslationCategory {
  common('common'),
  navigation('navigation'),
  validation('validation'),
  errors('errors'),
  messages('messages'),
  jobStatus('jobStatus'),
  analytics('analytics');

  final String key;
  const TranslationCategory(this.key);
}

/// 翻訳エントリ
class TranslationEntry {
  final String translationId;
  final String key;
  final TranslationCategory category;
  final Map<String, String> translations; // language code -> translated text
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isApproved;

  TranslationEntry({
    required this.translationId,
    required this.key,
    required this.category,
    required this.translations,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isApproved = false,
  });

  /// 特定言語の翻訳を取得
  String? getTranslation(String languageCode) {
    return translations[languageCode];
  }
}

/// 複数形ルール (言語によって複数形の規則が異なる)
enum PluralRule {
  zero('zero'),
  one('one'),
  two('two'),
  few('few'),
  many('many'),
  other('other');

  final String key;
  const PluralRule(this.key);
}

/// 複数形テキスト
class PluralText {
  final String textId;
  final String key;
  final Map<PluralRule, String> texts; // rule -> text
  final DateTime createdAt;

  PluralText({
    required this.textId,
    required this.key,
    required this.texts,
    required this.createdAt,
  });

  /// 数値に基づいて適切なテキストを返す (簡易実装)
  String getText(int count) {
    if (count == 0 && texts.containsKey(PluralRule.zero)) {
      return texts[PluralRule.zero]!;
    }
    if (count == 1 && texts.containsKey(PluralRule.one)) {
      return texts[PluralRule.one]!;
    }
    if (count == 2 && texts.containsKey(PluralRule.two)) {
      return texts[PluralRule.two]!;
    }
    return texts[PluralRule.other] ?? texts[PluralRule.one] ?? '';
  }
}

/// 日付フォーマット設定
enum DateFormat {
  short('short', 'M/d/yy'),      // 1/1/24
  medium('medium', 'MMM d, y'),  // Jan 1, 2024
  long('long', 'MMMM d, y'),     // January 1, 2024
  full('full', 'EEEE, MMMM d, y'), // Monday, January 1, 2024
  iso('iso', 'y-MM-dd');         // 2024-01-01

  final String key;
  final String pattern;
  const DateFormat(this.key, this.pattern);
}

/// 時刻フォーマット設定
enum TimeFormat {
  short12('short12', 'h:mm a'),        // 2:30 PM
  short24('short24', 'HH:mm'),         // 14:30
  medium('medium', 'h:mm:ss a'),       // 2:30:45 PM
  long('long', 'HH:mm:ss z');          // 14:30:45 UTC

  final String key;
  final String pattern;
  const TimeFormat(this.key, this.pattern);
}

/// 通貨設定
class Currency {
  final String currencyId;
  final String code;       // ISO 4217 (USD, JPY, EUR等)
  final String symbol;     // $, ¥, €等
  final String displayName;
  final int decimalPlaces; // 小数点以下桁数 (通常2, JPYは0)
  final bool symbolBeforeAmount; // 記号が金額の前か後ろか
  final DateTime createdAt;

  Currency({
    required this.currencyId,
    required this.code,
    required this.symbol,
    required this.displayName,
    this.decimalPlaces = 2,
    this.symbolBeforeAmount = true,
    required this.createdAt,
  });

  /// フォーマットされた通貨文字列を返す
  String format(double amount) {
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);
    if (symbolBeforeAmount) {
      return '$symbol$formattedAmount';
    } else {
      return '$formattedAmount$symbol';
    }
  }

  static final predefinedCurrencies = {
    'USD': Currency(
      currencyId: 'usd',
      code: 'USD',
      symbol: '\$',
      displayName: 'US Dollar',
      decimalPlaces: 2,
      symbolBeforeAmount: true,
      createdAt: DateTime.now(),
    ),
    'JPY': Currency(
      currencyId: 'jpy',
      code: 'JPY',
      symbol: '¥',
      displayName: '日本円',
      decimalPlaces: 0,
      symbolBeforeAmount: true,
      createdAt: DateTime.now(),
    ),
    'EUR': Currency(
      currencyId: 'eur',
      code: 'EUR',
      symbol: '€',
      displayName: 'Euro',
      decimalPlaces: 2,
      symbolBeforeAmount: false,
      createdAt: DateTime.now(),
    ),
    'GBP': Currency(
      currencyId: 'gbp',
      code: 'GBP',
      symbol: '£',
      displayName: 'British Pound',
      decimalPlaces: 2,
      symbolBeforeAmount: true,
      createdAt: DateTime.now(),
    ),
  };
}

/// 数値フォーマット設定
class NumberFormat {
  final String numberFormatId;
  final String languageCode;
  final String decimalSeparator;    // '.' or ','
  final String thousandsSeparator;  // ',' or '.'
  final DateTime createdAt;

  NumberFormat({
    required this.numberFormatId,
    required this.languageCode,
    this.decimalSeparator = '.',
    this.thousandsSeparator = ',',
    required this.createdAt,
  });

  /// 数値をフォーマットする
  String format(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // 3桁ごとに区切る
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = thousandsSeparator + formatted;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }

    return '$formatted$decimalSeparator$decimalPart';
  }
}

/// ユーザーのローカライゼーション設定
class LocalizationPreferences {
  final String preferencesId;
  final String userId;
  final Language language;
  final Region region;
  final DateFormat dateFormat;
  final TimeFormat timeFormat;
  final Currency currency;
  final NumberFormat numberFormat;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocalizationPreferences({
    required this.preferencesId,
    required this.userId,
    required this.language,
    required this.region,
    required this.dateFormat,
    required this.timeFormat,
    required this.currency,
    required this.numberFormat,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ロケール文字列を返す
  String get locale => '${language.code}_${region.code}';
}

/// 翻訳統計 (翻訳の完成度)
class TranslationStatistics {
  final String statisticsId;
  final Language language;
  final int totalKeys;
  final int translatedKeys;
  final int approvedKeys;
  final DateTime calculatedAt;

  TranslationStatistics({
    required this.statisticsId,
    required this.language,
    required this.totalKeys,
    required this.translatedKeys,
    required this.approvedKeys,
    required this.calculatedAt,
  });

  /// 翻訳の完成率 (%)
  double get completionPercentage {
    if (totalKeys == 0) return 0.0;
    return (translatedKeys / totalKeys) * 100;
  }

  /// 承認率 (%)
  double get approvalPercentage {
    if (translatedKeys == 0) return 0.0;
    return (approvedKeys / translatedKeys) * 100;
  }
}
