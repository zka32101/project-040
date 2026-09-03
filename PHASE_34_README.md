# Phase 34: 国際化・ローカライゼーション (i18n/l10n)

Phase 34では、複数言語対応、地域設定、通貨・日付形式管理を実装し、エンタープライズグレードの国際化機能を完成させました。

## 実装内容

### 1. ローカライゼーション モデル (`lib/models/localization_models.dart`)

#### 言語・地域管理

**Language (enum)**:
```dart
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
}
```

**Region (enum)**:
```dart
enum Region {
  us('US', 'United States'),
  gb('GB', 'United Kingdom'),
  jp('JP', '日本'),
  kr('KR', '韓国'),
  // ... 合計11地域
}
```

**Locale**:
```dart
class Locale {
  final String localeId;
  final Language language;
  final Region region;
  final DateTime createdAt;
  final bool isDefault;

  // ロケール文字列: en_US, ja_JP
  String get localeCode => '${language.code}_${region.code}';
}
```

#### 翻訳管理

**TranslationEntry**:
```dart
class TranslationEntry {
  final String translationId;
  final String key;                          // 翻訳キー
  final TranslationCategory category;        // カテゴリ分類
  final Map<String, String> translations;    // 言語コード -> 翻訳テキスト
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isApproved;                     // 承認状態
}
```

**TranslationCategory (enum)**:
- common: 共通テキスト
- navigation: ナビゲーション
- validation: 検証メッセージ
- errors: エラーメッセージ
- messages: メッセージ
- jobStatus: ジョブステータス
- analytics: 分析

**PluralText**: 複数形対応
```dart
class PluralText {
  final String textId;
  final String key;
  final Map<PluralRule, String> texts; // zero, one, few, many, other

  // count値に基づいて適切なテキストを返す
  String getText(int count) { ... }
}
```

#### 地域別設定

**Currency**:
```dart
class Currency {
  final String currencyId;
  final String code;              // USD, JPY, EUR
  final String symbol;            // $, ¥, €
  final int decimalPlaces;        // JPY=0, USD=2
  final bool symbolBeforeAmount;  // 記号の位置

  // フォーマット: $1,234.56
  String format(double amount) { ... }
}
```

**DateFormat (enum)**:
- short: M/d/yy
- medium: MMM d, y
- long: MMMM d, y
- full: EEEE, MMMM d, y
- iso: y-MM-dd

**TimeFormat (enum)**:
- short12: h:mm a (2:30 PM)
- short24: HH:mm (14:30)
- medium: h:mm:ss a
- long: HH:mm:ss z

**NumberFormat**: 小数点・千位区切り文字の地域別設定
```dart
class NumberFormat {
  final String decimalSeparator;     // '.' or ','
  final String thousandsSeparator;   // ',' or '.'

  // フォーマット: 1,234.56 or 1.234,56
  String format(double value) { ... }
}
```

#### ユーザー設定

**LocalizationPreferences**:
```dart
class LocalizationPreferences {
  final String preferencesId;
  final String userId;
  final Language language;
  final Region region;
  final DateFormat dateFormat;
  final TimeFormat timeFormat;
  final Currency currency;
  final NumberFormat numberFormat;
}
```

### 2. ローカライゼーション サービス (`lib/services/localization_service.dart`)

#### リポジトリパターン

**TranslationRepository (interface)**:
```dart
abstract class TranslationRepository {
  Future<TranslationEntry?> getTranslation(String key);
  Future<List<TranslationEntry>> getTranslationsByCategory(TranslationCategory);
  Future<Map<String, String>> getLanguageTranslations(String languageCode);
  Future<void> saveTranslation(TranslationEntry entry);
  Future<void> deleteTranslation(String key);
  Future<PluralText?> getPluralText(String key);
  Future<void> savePluralText(PluralText text);
}
```

**MemoryTranslationRepository**: 開発・テスト用メモリ実装
- サンプル翻訳を自動初期化
- 複数言語の翻訳を一元管理

**LocalizationPreferencesRepository (interface)**:
```dart
abstract class LocalizationPreferencesRepository {
  Future<LocalizationPreferences?> getPreferences(String userId);
  Future<void> savePreferences(LocalizationPreferences prefs);
  Future<void> deletePreferences(String userId);
  Future<List<LocalizationPreferences>> getByLanguage(Language language);
  Future<LocalizationPreferences> getDefaultPreferences();
}
```

**MemoryLocalizationPreferencesRepository**: 開発・テスト用メモリ実装
- デフォルト設定 (en_US) を自動初期化

#### ローカライゼーションサービス

**LocalizationService (interface)**:
```dart
abstract class LocalizationService {
  // 翻訳
  Future<String> translate(String key, {String? languageCode});
  Future<String> getPluralForm(String key, int count);
  Future<String> translateWithVariables(String key, Map<String, String> vars);

  // ユーザー設定
  Future<LocalizationPreferences?> getUserPreferences(String userId);
  Future<void> updateUserPreferences(LocalizationPreferences prefs);

  // 言語・地域切り替え
  Future<void> setCurrentLanguage(Language language);
  Future<void> setCurrentRegion(Region region);
  Language getCurrentLanguage();
  Region getCurrentRegion();

  // フォーマット
  String formatDate(DateTime date, DateFormat format);
  String formatTime(DateTime dateTime, TimeFormat format);
  String formatCurrency(double amount, Currency currency);
  String formatNumber(double value);

  // ユーティリティ
  List<Language> getAvailableLanguages();
  Future<TranslationStatistics> getTranslationStatistics(Language language);
}
```

**MemoryLocalizationService**: 完全な開発実装
- サンプル翻訳データを自動初期化
- 言語・地域の動的切り替え
- 日付・時刻・通貨・数値のフォーマット機能
- テンプレート文字列の変数置換

### 3. ローカライゼーション マネージャー

**LocalizationManager (ファサードパターン)**:
```dart
class LocalizationManager {
  // 簡潔なメソッド名
  Future<String> t(String key, {String? languageCode});           // 翻訳
  Future<String> tw(String key, Map<String, String> vars);        // テンプレート
  Future<String> plural(String key, int count);                   // 複数形
  Future<LocalizationPreferences?> getUserPrefs(String userId);   // 設定取得
  Future<void> setUserPrefs(LocalizationPreferences prefs);        // 設定更新
  Future<void> setLanguage(Language lang);                         // 言語変更
  Future<void> setRegion(Region region);                           // 地域変更
  Language getLanguage();                                          // 言語取得
  Region getRegion();                                              // 地域取得
  String formatDate(DateTime date, DateFormat format);             // 日付フォーマット
  String formatTime(DateTime time, TimeFormat format);             // 時刻フォーマット
  String formatCurrency(double amount, Currency currency);         // 通貨フォーマット
  String formatNumber(double value);                               // 数値フォーマット
  List<Language> availableLanguages();                             // 利用可能言語
  Future<TranslationStatistics> stats(Language lang);              // 統計取得
}
```

## 使用例

### 基本的な翻訳

```dart
final manager = LocalizationManager();

// テキストを翻訳
final greeting = await manager.t('app.title');
print(greeting); // "Job Monitoring System" (英語の場合)

// 特定言語での翻訳
final japaneseTitle = await manager.t('app.title', languageCode: 'ja');
print(japaneseTitle); // "ジョブ監視システム"
```

### テンプレート翻訳（変数置換）

```dart
// 翻訳文: "Welcome, {{name}}!"
final message = await manager.tw('welcome.message', {
  'name': 'Alice',
});
print(message); // "Welcome, Alice!"
```

### 複数形処理

```dart
// 複数形対応
final jobText = await manager.plural('job.count', 5);
print(jobText); // "5 jobs"

final jobText1 = await manager.plural('job.count', 1);
print(jobText1); // "One job"
```

### 言語・地域の切り替え

```dart
// 言語を日本語に変更
await manager.setLanguage(Language.ja);

// 地域を日本に変更
await manager.setRegion(Region.jp);

// 現在の設定を確認
print(manager.getLanguage());  // Language.ja
print(manager.getRegion());    // Region.jp
```

### ユーザーのローカライゼーション設定

```dart
// ユーザー設定を作成
final preferences = LocalizationPreferences(
  preferencesId: 'prefs_user_1',
  userId: 'user_1',
  language: Language.ja,
  region: Region.jp,
  dateFormat: DateFormat.long,
  timeFormat: TimeFormat.short24,
  currency: Currency.predefinedCurrencies['JPY']!,
  numberFormat: NumberFormat(
    numberFormatId: 'jp_format',
    languageCode: 'ja',
    decimalSeparator: '.',
    thousandsSeparator: ',',
    createdAt: DateTime.now(),
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// 設定を保存
await manager.setUserPrefs(preferences);

// ユーザー設定を取得
final userPrefs = await manager.getUserPrefs('user_1');
if (userPrefs != null) {
  print('User locale: ${userPrefs.locale}'); // ja_JP
}
```

### 日付・時刻フォーマット

```dart
final date = DateTime(2024, 3, 15);
final time = DateTime(2024, 3, 15, 14, 30, 45);

// 日付をフォーマット
print(manager.formatDate(date, DateFormat.short));  // 3/15/24
print(manager.formatDate(date, DateFormat.medium)); // Mar 15, 2024
print(manager.formatDate(date, DateFormat.long));   // March 15, 2024
print(manager.formatDate(date, DateFormat.iso));    // 2024-03-15

// 時刻をフォーマット
print(manager.formatTime(time, TimeFormat.short12)); // 2:30 PM
print(manager.formatTime(time, TimeFormat.short24)); // 14:30
print(manager.formatTime(time, TimeFormat.medium));  // 2:30:45 PM
```

### 通貨フォーマット

```dart
// 定義済みの通貨を使用
final usd = Currency.predefinedCurrencies['USD']!;
final jpy = Currency.predefinedCurrencies['JPY']!;
final eur = Currency.predefinedCurrencies['EUR']!;

// フォーマット
print(manager.formatCurrency(1234.56, usd));  // $1234.56
print(manager.formatCurrency(1000.0, jpy));   // ¥1000
print(manager.formatCurrency(100.50, eur));   // 100.50€

// マネージャーを使用
print(usd.format(1234.56));  // $1234.56
print(jpy.format(1000.0));   // ¥1000 (小数点なし)
```

### 数値フォーマット

```dart
// 数値をフォーマット
print(manager.formatNumber(1234.56)); // 1234.56

// 地域別フォーマット
final usFormat = NumberFormat(
  numberFormatId: 'us',
  languageCode: 'en',
  decimalSeparator: '.',
  thousandsSeparator: ',',
  createdAt: DateTime.now(),
);

final euFormat = NumberFormat(
  numberFormatId: 'eu',
  languageCode: 'de',
  decimalSeparator: ',',
  thousandsSeparator: '.',
  createdAt: DateTime.now(),
);

print(usFormat.format(1234567.89));  // 1,234,567.89
print(euFormat.format(1234567.89));  // 1.234.567,89
```

### 翻訳統計

```dart
// 言語の翻訳完成度を確認
final stats = await manager.stats(Language.ja);
print('Total keys: ${stats.totalKeys}');
print('Translated: ${stats.translatedKeys}');
print('Completion: ${stats.completionPercentage}%');
print('Approved: ${stats.approvalPercentage}%');
```

### 利用可能言語の取得

```dart
// サポートしている言語一覧
final languages = manager.availableLanguages();
for (final lang in languages) {
  print('${lang.code}: ${lang.displayName}');
}
```

## テスト カバレッジ

`test/phase_34_localization_test.dart` - 40個のテストケース

### テスト分類
1. **言語・地域管理** (4 tests)
   - Language enum検証
   - Region enum検証
   - Language fromCode factory
   - Region fromCode factory

2. **ロケール管理** (3 tests)
   - Locale localeCode形式
   - Locale displayName
   - Locale toString

3. **翻訳管理** (6 tests)
   - TranslationEntry.getTranslation
   - PluralText.getText
   - TranslationCategory enum
   - 基本翻訳検索
   - 言語別翻訳取得
   - テンプレート翻訳

4. **複数形処理** (2 tests)
   - Plural zero form
   - Plural one form

5. **言語・地域切り替え** (3 tests)
   - 言語設定
   - 地域設定
   - 利用可能言語取得

6. **日付・時刻フォーマット** (4 tests)
   - 日付 short/medium
   - 時刻 12時間/24時間

7. **通貨フォーマット** (3 tests)
   - USD通貨設定
   - 通貨フォーマット
   - 複数通貨フォーマット

8. **ローカライゼーション設定** (3 tests)
   - 設定の作成・保存
   - 設定からのロケール文字列
   - デフォルト設定フォールバック

9. **翻訳リポジトリ** (2 tests)
   - 翻訳の保存・取得
   - カテゴリ別翻訳取得

10. **翻訳統計** (2 tests)
    - 完成率・承認率計算
    - 言語別統計取得

11. **統合テスト** (4 tests)
    - 完全なローカライゼーションフロー
    - 複数言語サポート
    - 日付・通貨フォーマット統合
    - 言語切り替え

12. **数値フォーマット** (2 tests)
    - US形式
    - EU形式

13. **定義済み通貨** (2 tests)
    - 通貨の可用性
    - JPY小数点なし検証

## アーキテクチャパターン

### リポジトリパターン
- インターフェースで契約を定義
- メモリ実装で開発・テスト効率化
- 依存性の注入により実装の切り替え可能

### ファサードパターン
- LocalizationManager が複雑な実装を隠蔽
- クライアントは単一のエントリーポイント経由でアクセス
- 簡潔なメソッド名 (t, tw, plural等) で使いやすさを実現

### ストラテジーパターン
- DateFormat, TimeFormat, Currency等で異なるフォーマット戦略を実装
- ユーザー設定に基づいて動的に戦略を切り替え

### テンプレートメソッドパターン
- TranslationEntry, PluralText で共通の翻訳処理を定義
- 言語ごとの翻訳を柔軟に追加可能

## 実装統計

```
Total Lines: ~1,200
├─ Models: ~320
├─ Services: ~580
├─ Tests: ~300
└─ Documentation: ~200

Test Coverage: 40 comprehensive tests (100% target)
Supported Languages: 10 languages
Supported Currencies: 5+ currencies
```

## 今後の拡張ポイント

1. **HTTP実装** - サーバーから翻訳をロード
2. **キャッシング** - 翻訳結果をキャッシュ
3. **RTL言語対応** - アラビア語・ヘブライ語等
4. **タイムゾーン対応** - タイムゾーン別日時フォーマット
5. **通知ローカライゼーション** - 通知メッセージの多言語対応
6. **Riverpod統合** - ローカライゼーション設定を状態管理
7. **動的翻訳ローディング** - 言語ごとの翻訳パッケージ
8. **翻訳管理画面** - 翻訳追加・編集UI
9. **複数形規則** - 言語別複数形規則の詳細実装
10. **通知ゆうっぱっし翻訳** - 複雑な言語特性対応

## システム完成度

Phase 34により、10フェーズすべてでエンタープライズグレード機能が完成：

```
Phase 24 ✅ Async Job System & Optimization
Phase 25 ✅ Analytics, Search, Export
Phase 26 ✅ UI & State Management (Riverpod)
Phase 27 ✅ Backend Integration (API, DB, Notifications)
Phase 28 ✅ HTTP Client & JWT Authentication
Phase 29 ✅ Security Enhancement
Phase 30 ✅ Caching & Performance
Phase 31 ✅ Real-time Features
Phase 32 ✅ Advanced Authentication
Phase 33 ✅ Monitoring & Logging
Phase 34 ✅ Internationalization & Localization
```

## グローバル対応の完成

- **複数言語**: 10言語以上対応
- **地域設定**: 11地域以上対応
- **通貨**: 5通貨以上対応可
- **日付・時刻**: 複数フォーマット対応
- **数値フォーマット**: 地域別フォーマット対応
- **ユーザー設定**: ユーザー別のローカライゼーション設定

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
