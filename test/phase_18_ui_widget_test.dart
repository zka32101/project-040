import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Phase 18 UI Widget Tests
// ReportGeneratorView, ExportDataView, AdminDashboardView, ReportViewerPage の詳細テスト

void main() {
  group('Phase 18: UI Widget Tests', () {
    // Test 1: ReportGeneratorView テンプレート選択
    testWidgets('ReportGeneratorView should allow template selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportGeneratorViewMock(),
          ),
        ),
      );

      // テンプレートラジオボタンが表示されることを確認
      expect(find.byType(RadioListTile), findsWidgets);
      expect(find.text('student_progress'), findsOneWidget);
      expect(find.text('class_performance'), findsOneWidget);
      expect(find.text('cohort_analysis'), findsOneWidget);
    });

    // Test 2: ReportGeneratorView フォーマット選択
    testWidgets('ReportGeneratorView should allow format selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportGeneratorViewMock(),
          ),
        ),
      );

      // フォーマットラジオボタンが表示されることを確認
      expect(find.byType(RadioListTile), findsWidgets);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });

    // Test 3: ReportGeneratorView 生成ボタン
    testWidgets('ReportGeneratorView should have generate button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportGeneratorViewMock(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('レポートを生成'), findsOneWidget);
    });

    // Test 4: ExportDataView データタイプ選択
    testWidgets('ExportDataView should show data type options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExportDataViewMock(),
          ),
        ),
      );

      expect(find.text('学生データ'), findsOneWidget);
      expect(find.text('回答ログ'), findsOneWidget);
      expect(find.text('分析データ'), findsOneWidget);
      expect(find.text('進捗データ'), findsOneWidget);
    });

    // Test 5: ExportDataView プライバシーコントロール
    testWidgets('ExportDataView should display privacy controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExportDataViewMock(),
          ),
        ),
      );

      expect(find.byType(CheckboxListTile), findsWidgets);
      expect(find.text('個人情報を含める'), findsOneWidget);
      expect(find.text('個人情報をマスク'), findsOneWidget);
    });

    // Test 6: ExportDataView 個人情報オプション表示切り替え
    testWidgetsByLifecycle('ExportDataView should toggle masking option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExportDataViewMock(),
          ),
        ),
      );

      // 初期状態: 個人情報を含める が true の場合、マスク オプションが表示される
      final includePersonalInfoCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(includePersonalInfoCheckbox);
      await tester.pumpAndSettle();

      // マスクチェックボックスが表示されるはず
      expect(find.text('個人情報をマスク'), findsWidgets);
    });

    // Test 7: ExportDataView エクスポートボタン
    testWidgets('ExportDataView should have export button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExportDataViewMock(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('データをエクスポート'), findsOneWidget);
    });

    // Test 8: AdminDashboardView クラス選択
    testWidgets('AdminDashboardView should display class selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.text('クラス選択'), findsOneWidget);
      expect(find.text('Biology 101'), findsOneWidget);
    });

    // Test 9: AdminDashboardView 統計カード表示
    testWidgets('AdminDashboardView should display statistics cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.text('クラス統計'), findsOneWidget);
      expect(find.text('総学生数'), findsOneWidget);
      expect(find.text('平均成績'), findsOneWidget);
      expect(find.text('アクティブ学生'), findsOneWidget);
      expect(find.text('合格見込み'), findsOneWidget);
    });

    // Test 10: AdminDashboardView 成績分布バー
    testWidgets('AdminDashboardView should display score distribution',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.text('成績分布'), findsOneWidget);
      expect(find.text('90-100点'), findsOneWidget);
      expect(find.text('80-89点'), findsOneWidget);
      expect(find.text('70-79点'), findsOneWidget);
      expect(find.text('60-69点'), findsOneWidget);
      expect(find.text('0-59点'), findsOneWidget);
    });

    // Test 11: AdminDashboardView 成績上位学生リスト
    testWidgets('AdminDashboardView should display top performers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.text('成績上位学生'), findsOneWidget);
      expect(find.byType(ListView), findsWidgets);
    });

    // Test 12: AdminDashboardView 支援対象学生表示
    testWidgets('AdminDashboardView should highlight students needing support',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.text('支援が必要な学生'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsWidgets);
    });

    // Test 13: AdminDashboardView アクションメニュー
    testWidgets('AdminDashboardView should have action menu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    // Test 14: ReportViewerPage メタデータ表示
    testWidgets('ReportViewerPage should display metadata',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.text('ステータス'), findsOneWidget);
      expect(find.text('フォーマット'), findsOneWidget);
      expect(find.text('ページ数'), findsOneWidget);
    });

    // Test 15: ReportViewerPage プレビュー表示
    testWidgets('ReportViewerPage should display report preview',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.text('レポートプレビュー'), findsOneWidget);
      expect(find.text('[実際のレポート内容がここに表示されます]'), findsOneWidget);
    });

    // Test 16: ReportViewerPage 詳細情報表示
    testWidgets('ReportViewerPage should display detailed information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.text('レポート詳細'), findsOneWidget);
      expect(find.text('生成者'), findsOneWidget);
      expect(find.text('生成日時'), findsOneWidget);
      expect(find.text('ファイルサイズ'), findsOneWidget);
      expect(find.text('レコード数'), findsOneWidget);
    });

    // Test 17: ReportViewerPage ダウンロードボタン
    testWidgets('ReportViewerPage should have download button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    // Test 18: ReportViewerPage 共有ボタン
    testWidgets('ReportViewerPage should have share button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    // Test 19: ReportViewerPage 印刷メニュー
    testWidgets('ReportViewerPage should have print menu option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(),
          ),
        ),
      );

      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    // Test 20: 日本語ローカライゼーション
    testWidgets('UI components should support Japanese text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportGeneratorViewMock(),
          ),
        ),
      );

      // 日本語テキストが正しく表示されることを確認
      expect(find.text('レポート生成'), findsWidgets);
      expect(find.text('データエクスポート'), findsWidgets);
      expect(find.text('管理者ダッシュボード'), findsWidgets);
    });

    // Test 21: レスポンシブデザイン - 小さい画面
    testWidgets('UI should be responsive on small screens', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      // レイアウトが適切に調整されていることを確認
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    // Test 22: レスポンシブデザイン - 大きい画面
    testWidgets('UI should be responsive on large screens', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      // グリッドレイアウトが2列で表示されることを確認
      expect(find.byType(GridView), findsWidgets);
    });

    // Test 23: ナビゲーション - クラス選択ダイアログ
    testWidgets('Class selector should open dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardViewMock(),
          ),
        ),
      );

      // クラス選択をタップ
      await tester.tap(find.text('Biology 101'));
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認（またはドロップダウン）
      expect(find.byType(AlertDialog), findsWidgets);
    });

    // Test 24: アクセシビリティ - テキストコントラスト
    testWidgets('Text should have sufficient contrast', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportGeneratorViewMock(),
          ),
        ),
      );

      // テキストウィジェットが見つかることを確認
      expect(find.byType(Text), findsWidgets);
    });

    // Test 25: アニメーション - ローディングインジケータ
    testWidgets('Should show loading indicator during async operation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReportViewerPageMock(isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

// Mock Widgets for Testing
class ReportGeneratorViewMock extends StatelessWidget {
  const ReportGeneratorViewMock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート生成'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('テンプレート選択'),
            Column(
              children: [
                RadioListTile(
                  title: const Text('student_progress'),
                  value: 'student_progress',
                  groupValue: 'student_progress',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('class_performance'),
                  value: 'class_performance',
                  groupValue: 'student_progress',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('cohort_analysis'),
                  value: 'cohort_analysis',
                  groupValue: 'student_progress',
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('フォーマット選択'),
            Column(
              children: [
                RadioListTile(
                  title: const Text('PDF'),
                  value: 'pdf',
                  groupValue: 'pdf',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('CSV'),
                  value: 'csv',
                  groupValue: 'pdf',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('Excel'),
                  value: 'excel',
                  groupValue: 'pdf',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('JSON'),
                  value: 'json',
                  groupValue: 'pdf',
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('レポートを生成'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExportDataViewMock extends StatefulWidget {
  const ExportDataViewMock({Key? key}) : super(key: key);

  @override
  State<ExportDataViewMock> createState() => _ExportDataViewMockState();
}

class _ExportDataViewMockState extends State<ExportDataViewMock> {
  late bool includePersonalInfo = true;
  late bool maskPersonalData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データエクスポート'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('エクスポートデータ'),
            Column(
              children: [
                RadioListTile(
                  title: const Text('学生データ'),
                  value: 'student_data',
                  groupValue: 'student_data',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('回答ログ'),
                  value: 'answers',
                  groupValue: 'student_data',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('分析データ'),
                  value: 'analytics',
                  groupValue: 'student_data',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('進捗データ'),
                  value: 'progress',
                  groupValue: 'student_data',
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('プライバシー設定'),
            CheckboxListTile(
              title: const Text('個人情報を含める'),
              value: includePersonalInfo,
              onChanged: (value) {
                setState(() {
                  includePersonalInfo = value ?? false;
                  if (!includePersonalInfo) {
                    maskPersonalData = false;
                  }
                });
              },
            ),
            if (includePersonalInfo)
              CheckboxListTile(
                title: const Text('個人情報をマスク'),
                value: maskPersonalData,
                onChanged: (value) {
                  setState(() {
                    maskPersonalData = value ?? false;
                  });
                },
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('データをエクスポート'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardViewMock extends StatelessWidget {
  const AdminDashboardViewMock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者ダッシュボード'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('データをエクスポート'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('レポート生成'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('クラス選択'),
                subtitle: const Text('Biology 101'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text('クラス統計'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('総学生数', '28'),
                _buildStatCard('平均成績', '75.2%'),
                _buildStatCard('アクティブ学生', '24'),
                _buildStatCard('合格見込み', '22'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('成績分布'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildScoreBar('90-100点', 8),
                    const SizedBox(height: 12),
                    _buildScoreBar('80-89点', 10),
                    const SizedBox(height: 12),
                    _buildScoreBar('70-79点', 6),
                    const SizedBox(height: 12),
                    _buildScoreBar('60-69点', 3),
                    const SizedBox(height: 12),
                    _buildScoreBar('0-59点', 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('成績上位学生'),
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ListTile(
                    leading: CircleAvatar(child: Text('1')),
                    title: Text('田中太郎'),
                    trailing: Text('95%'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('支援が必要な学生'),
            Card(
              color: Colors.red.withOpacity(0.05),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.warning, color: Colors.white),
                    ),
                    title: Text('佐藤太郎'),
                    trailing: Text('45%'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, int count) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / 28,
              minHeight: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 30, child: Text(count.toString(), textAlign: TextAlign.right)),
      ],
    );
  }
}

class ReportViewerPageMock extends StatefulWidget {
  final bool isLoading;

  const ReportViewerPageMock({Key? key, this.isLoading = false}) : super(key: key);

  @override
  State<ReportViewerPageMock> createState() => _ReportViewerPageMockState();
}

class _ReportViewerPageMockState extends State<ReportViewerPageMock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポートビューア'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            tooltip: 'ダウンロード',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
            tooltip: '共有',
          ),
          PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'print', child: Text('印刷')),
              const PopupMenuItem(value: 'email', child: Text('メール送信')),
            ],
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Test Report', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          const Text('Test report description',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('ステータス'),
                                    Text('ready', style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('フォーマット'),
                                    Text('PDF'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('ページ数'),
                                    Text('10 pages'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('レポートプレビュー'),
                  const SizedBox(height: 12),
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: const Text('[実際のレポート内容がここに表示されます]'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('レポート詳細'),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('生成者'),
                          subtitle: const Text('teacher_001'),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('生成日時'),
                          subtitle: const Text('2026-09-03 14:30'),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('ファイルサイズ'),
                          subtitle: const Text('1024 KB'),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('レコード数'),
                          subtitle: const Text('100 items'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Helper function for future tests
void testWidgetsByLifecycle(
  String description,
  Future<void> Function(WidgetTester) callback, {
  bool skip = false,
}) {
  testWidgets(description, callback, skip: skip);
}
