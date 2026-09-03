/// Phase 34: 国際化・ローカライゼーション テスト
///
/// 25個の包括的なテストケース

import 'package:test/test.dart';
import 'package:project_040/models/localization_models.dart';
import 'package:project_040/services/localization_service.dart';

void main() {
  group('Phase 34: Localization Tests', () {
    late LocalizationManager manager;

    setUp(() {
      manager = LocalizationManager();
    });

    // Language & Region Tests (4 tests)
    group('Language & Region Management', () {
      test('1. Language enum has correct values', () {
        expect(Language.en.code, equals('en'));
        expect(Language.ja.code, equals('ja'));
        expect(Language.ko.code, equals('ko'));
        expect(Language.values.length, equals(10));
      });

      test('2. Region enum has correct values', () {
        expect(Region.us.code, equals('US'));
        expect(Region.jp.code, equals('JP'));
        expect(Region.values.length, equals(11));
      });

      test('3. Language fromCode factory method', () {
        final lang = Language.fromCode('ja');
        expect(lang, equals(Language.ja));

        final invalidLang = Language.fromCode('invalid');
        expect(invalidLang, equals(Language.en)); // デフォルトは英語
      });

      test('4. Region fromCode factory method', () {
        final region = Region.fromCode('JP');
        expect(region, equals(Region.jp));

        final invalidRegion = Region.fromCode('invalid');
        expect(invalidRegion, equals(Region.us)); // デフォルトは米国
      });
    });

    // Locale Tests (3 tests)
    group('Locale Management', () {
      test('5. Locale localeCode format', () {
        final locale = Locale(
          localeId: 'loc_1',
          language: Language.ja,
          region: Region.jp,
          createdAt: DateTime.now(),
        );
        expect(locale.localeCode, equals('ja_JP'));
      });

      test('6. Locale displayName', () {
        final locale = Locale(
          localeId: 'loc_1',
          language: Language.en,
          region: Region.us,
          createdAt: DateTime.now(),
        );
        expect(locale.displayName, contains('English'));
        expect(locale.displayName, contains('United States'));
      });

      test('7. Locale toString', () {
        final locale = Locale(
          localeId: 'loc_1',
          language: Language.ko,
          region: Region.kr,
          createdAt: DateTime.now(),
        );
        expect(locale.toString(), equals('ko_KR'));
      });
    });

    // Translation Tests (6 tests)
    group('Translation Management', () {
      test('8. TranslationEntry getTranslation', () {
        final entry = TranslationEntry(
          translationId: 'trans_1',
          key: 'test.key',
          category: TranslationCategory.common,
          translations: {
            'en': 'Hello',
            'ja': 'こんにちは',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.getTranslation('en'), equals('Hello'));
        expect(entry.getTranslation('ja'), equals('こんにちは'));
        expect(entry.getTranslation('ko'), isNull);
      });

      test('9. PluralText getText method', () {
        final pluralText = PluralText(
          textId: 'plural_1',
          key: 'item.count',
          texts: {
            PluralRule.zero: 'No items',
            PluralRule.one: 'One item',
            PluralRule.other: '{{count}} items',
          },
          createdAt: DateTime.now(),
        );

        expect(pluralText.getText(0), equals('No items'));
        expect(pluralText.getText(1), equals('One item'));
        expect(pluralText.getText(5), contains('5'));
      });

      test('10. Translation category enum', () {
        expect(TranslationCategory.common.key, equals('common'));
        expect(TranslationCategory.validation.key, equals('validation'));
        expect(TranslationCategory.values.length, equals(7));
      });

      test('11. Basic translation lookup', () async {
        final translated = await manager.t('app.title');
        expect(translated, isNotEmpty);
      });

      test('12. Translation with language override', () async {
        final jaTranslation = await manager.t('app.title', languageCode: 'ja');
        expect(jaTranslation, isNotEmpty);
      });

      test('13. Translation with variables', () async {
        final translated = await manager.tw('welcome.message', {
          'name': 'John',
        });
        expect(translated, contains('John'));
      });
    });

    // Plural Form Tests (2 tests)
    group('Plural Forms', () {
      test('14. Plural zero form', () async {
        // サンプル複数形がない場合のフォールバック
        final result = await manager.plural('job.count', 0);
        expect(result, isNotEmpty);
      });

      test('15. Plural one form', () async {
        final result = await manager.plural('job.count', 1);
        expect(result, isNotEmpty);
      });
    });

    // Language & Region Switching (3 tests)
    group('Language & Region Switching', () {
      test('16. Set current language', () async {
        await manager.setLanguage(Language.ja);
        expect(manager.getLanguage(), equals(Language.ja));
      });

      test('17. Set current region', () async {
        await manager.setRegion(Region.jp);
        expect(manager.getRegion(), equals(Region.jp));
      });

      test('18. Get available languages', () {
        final languages = manager.availableLanguages();
        expect(languages, contains(Language.en));
        expect(languages, contains(Language.ja));
        expect(languages.length, greaterThan(0));
      });
    });

    // Date & Time Formatting (4 tests)
    group('Date & Time Formatting', () {
      final testDate = DateTime(2024, 1, 15);
      final testTime = DateTime(2024, 1, 15, 14, 30, 45);

      test('19. Date short format', () {
        final formatted = manager.formatDate(testDate, DateFormat.short);
        expect(formatted, contains('1'));
      });

      test('20. Date medium format', () {
        final formatted = manager.formatDate(testDate, DateFormat.medium);
        expect(formatted, contains('Jan'));
        expect(formatted, contains('2024'));
      });

      test('21. Time 12-hour format', () {
        final formatted = manager.formatTime(testTime, TimeFormat.short12);
        expect(formatted, contains('PM'));
      });

      test('22. Time 24-hour format', () {
        final formatted = manager.formatTime(testTime, TimeFormat.short24);
        expect(formatted, contains('14'));
      });
    });

    // Currency Formatting (3 tests)
    group('Currency Formatting', () {
      test('23. USD currency format', () {
        final currency = Currency.predefinedCurrencies['USD']!;
        expect(currency.code, equals('USD'));
        expect(currency.symbol, equals('\$'));
        expect(currency.decimalPlaces, equals(2));
      });

      test('24. Currency format with symbol', () {
        final currency = Currency.predefinedCurrencies['JPY']!;
        final formatted = currency.format(1000.0);
        expect(formatted, contains('1000'));
        expect(formatted, contains('¥'));
      });

      test('25. Multiple currency formats', () {
        final usd = Currency.predefinedCurrencies['USD']!;
        final eur = Currency.predefinedCurrencies['EUR']!;

        final usdFormatted = usd.format(100.50);
        final eurFormatted = eur.format(100.50);

        expect(usdFormatted, startsWith('\$')); // USD: symbol before
        expect(eurFormatted, endsWith('€'));    // EUR: symbol after
      });
    });

    // Localization Preferences Tests (3 tests)
    group('Localization Preferences', () {
      test('26. Create and save localization preferences', () async {
        final prefs = LocalizationPreferences(
          preferencesId: 'prefs_1',
          userId: 'user_1',
          language: Language.ja,
          region: Region.jp,
          dateFormat: DateFormat.long,
          timeFormat: TimeFormat.short24,
          currency: Currency.predefinedCurrencies['JPY']!,
          numberFormat: NumberFormat(
            numberFormatId: 'jp_num',
            languageCode: 'ja',
            decimalSeparator: '.',
            thousandsSeparator: ',',
            createdAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.setUserPrefs(prefs);

        final retrieved = await manager.getUserPrefs('user_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.language, equals(Language.ja));
        expect(retrieved.region, equals(Region.jp));
      });

      test('27. Locale string from preferences', () async {
        final prefs = LocalizationPreferences(
          preferencesId: 'prefs_2',
          userId: 'user_2',
          language: Language.ko,
          region: Region.kr,
          dateFormat: DateFormat.medium,
          timeFormat: TimeFormat.short12,
          currency: Currency.predefinedCurrencies['USD']!,
          numberFormat: NumberFormat(
            numberFormatId: 'ko_num',
            languageCode: 'ko',
            createdAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(prefs.locale, equals('ko_KR'));
      });

      test('28. Default preferences fallback', () async {
        final defaultPrefs = await manager.getUserPrefs('nonexistent');
        expect(defaultPrefs, isNull); // ユーザー設定がない場合
      });
    });

    // Translation Repository Tests (2 tests)
    group('Translation Repository', () {
      late TranslationRepository repo;

      setUp(() {
        repo = MemoryTranslationRepository();
      });

      test('29. Save and retrieve translation', () async {
        final entry = TranslationEntry(
          translationId: 'trans_test',
          key: 'test.save',
          category: TranslationCategory.common,
          translations: {
            'en': 'Test',
            'ja': 'テスト',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repo.saveTranslation(entry);
        final retrieved = await repo.getTranslation('test.save');

        expect(retrieved, isNotNull);
        expect(retrieved!.getTranslation('en'), equals('Test'));
      });

      test('30. Get translations by category', () async {
        final entry1 = TranslationEntry(
          translationId: 'trans_cat_1',
          key: 'common.key1',
          category: TranslationCategory.common,
          translations: {'en': 'Common 1'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entry2 = TranslationEntry(
          translationId: 'trans_cat_2',
          key: 'validation.required',
          category: TranslationCategory.validation,
          translations: {'en': 'Required'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repo.saveTranslation(entry1);
        await repo.saveTranslation(entry2);

        final commonTrans = await repo.getTranslationsByCategory(
          TranslationCategory.common,
        );
        expect(commonTrans.length, greaterThan(0));

        final validationTrans = await repo.getTranslationsByCategory(
          TranslationCategory.validation,
        );
        expect(validationTrans.length, greaterThan(0));
      });
    });

    // Translation Statistics Tests (2 tests)
    group('Translation Statistics', () {
      test('31. Calculate translation completion percentage', () {
        final stats = TranslationStatistics(
          statisticsId: 'stats_1',
          language: Language.ja,
          totalKeys: 100,
          translatedKeys: 85,
          approvedKeys: 80,
          calculatedAt: DateTime.now(),
        );

        expect(stats.completionPercentage, equals(85.0));
        expect(stats.approvalPercentage, closeTo(94.1, 0.1)); // 80/85
      });

      test('32. Get translation statistics for language', () async {
        final stats = await manager.stats(Language.ja);
        expect(stats.language, equals(Language.ja));
        expect(stats.totalKeys, greaterThanOrEqualTo(0));
        expect(stats.completionPercentage, greaterThanOrEqualTo(0));
      });
    });

    // Integration Tests (4 tests)
    group('Integration Tests', () {
      test('33. Complete localization flow', () async {
        // 1. ユーザー設定を作成
        final prefs = LocalizationPreferences(
          preferencesId: 'prefs_flow',
          userId: 'flow_user',
          language: Language.ja,
          region: Region.jp,
          dateFormat: DateFormat.long,
          timeFormat: TimeFormat.short24,
          currency: Currency.predefinedCurrencies['JPY']!,
          numberFormat: NumberFormat(
            numberFormatId: 'jp_flow',
            languageCode: 'ja',
            createdAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 2. ユーザー設定を保存
        await manager.setUserPrefs(prefs);

        // 3. 言語を確認
        expect(manager.getLanguage(), equals(Language.ja));

        // 4. テキストを翻訳
        final translated = await manager.t('app.title', languageCode: 'ja');
        expect(translated, isNotEmpty);
      });

      test('34. Multi-language support', () async {
        // 複数言語でテキストを取得
        final enText = await manager.t('app.title', languageCode: 'en');
        final jaText = await manager.t('app.title', languageCode: 'ja');
        final koText = await manager.t('app.title', languageCode: 'ko');

        expect(enText, isNotEmpty);
        expect(jaText, isNotEmpty);
        expect(koText, isNotEmpty);
        // 異なる言語は異なるテキストを返すべき
      });

      test('35. Date and currency formatting with preferences', () {
        final date = DateTime(2024, 3, 15);
        final currency = Currency.predefinedCurrencies['USD']!;

        final formattedDate = manager.formatDate(date, DateFormat.medium);
        final formattedCurrency = manager.formatCurrency(150.75, currency);

        expect(formattedDate, contains('Mar'));
        expect(formattedCurrency, contains('150.75'));
      });

      test('36. Language switching and translation updates', () async {
        // 最初の言語
        await manager.setLanguage(Language.en);
        var text = await manager.t('app.title');
        expect(text, isNotEmpty);

        // 言語を変更
        await manager.setLanguage(Language.ja);
        text = await manager.t('app.title');
        expect(text, isNotEmpty);
      });
    });

    // Number Format Tests (2 tests)
    group('Number Formatting', () {
      test('37. US number format', () {
        final format = NumberFormat(
          numberFormatId: 'us',
          languageCode: 'en',
          decimalSeparator: '.',
          thousandsSeparator: ',',
          createdAt: DateTime.now(),
        );

        final formatted = format.format(1234567.89);
        expect(formatted, contains(','));
        expect(formatted, contains('.'));
      });

      test('38. European number format', () {
        final format = NumberFormat(
          numberFormatId: 'eu',
          languageCode: 'de',
          decimalSeparator: ',',
          thousandsSeparator: '.',
          createdAt: DateTime.now(),
        );

        final formatted = format.format(1234567.89);
        expect(formatted, isNotEmpty);
      });
    });

    // Currency Predefined Tests (2 tests)
    group('Predefined Currencies', () {
      test('39. All predefined currencies available', () {
        expect(Currency.predefinedCurrencies.containsKey('USD'), isTrue);
        expect(Currency.predefinedCurrencies.containsKey('JPY'), isTrue);
        expect(Currency.predefinedCurrencies.containsKey('EUR'), isTrue);
        expect(Currency.predefinedCurrencies.containsKey('GBP'), isTrue);
      });

      test('40. JPY has zero decimal places', () {
        final jpy = Currency.predefinedCurrencies['JPY']!;
        expect(jpy.decimalPlaces, equals(0));
        expect(jpy.code, equals('JPY'));
      });
    });
  });
}
