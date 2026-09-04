/// Phase 24: アクセシブルジョブダッシュボード
/// スクリーンリーダー・キーボードナビゲーション対応

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../models/job_monitoring_model.dart';
import '../providers/job_monitoring_provider.dart';

/// アクセシビリティ設定
class AccessibilityConfig {
  /// スクリーンリーダー有効
  final bool screenReaderEnabled;

  /// 高コントラストモード
  final bool highContrastMode;

  /// フォントサイズ倍率
  final double fontSizeFactor;

  /// キーボードナビゲーション有効
  final bool keyboardNavigationEnabled;

  /// 縮減モーション有効
  final bool reduceMotionEnabled;

  const AccessibilityConfig({
    this.screenReaderEnabled = false,
    this.highContrastMode = false,
    this.fontSizeFactor = 1.0,
    this.keyboardNavigationEnabled = true,
    this.reduceMotionEnabled = false,
  });

  /// コピー
  AccessibilityConfig copyWith({
    bool? screenReaderEnabled,
    bool? highContrastMode,
    double? fontSizeFactor,
    bool? keyboardNavigationEnabled,
    bool? reduceMotionEnabled,
  }) {
    return AccessibilityConfig(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      keyboardNavigationEnabled: keyboardNavigationEnabled ?? this.keyboardNavigationEnabled,
      reduceMotionEnabled: reduceMotionEnabled ?? this.reduceMotionEnabled,
    );
  }
}

/// アクセシブルジョブプログレスカード
class AccessibleJobProgressCard extends StatefulWidget {
  /// ジョブ
  final AsyncJob job;

  /// タップコールバック
  final VoidCallback? onTap;

  /// キャンセルコールバック
  final VoidCallback? onCancel;

  /// 詳細表示コールバック
  final VoidCallback? onShowDetails;

  /// アクセシビリティ設定
  final AccessibilityConfig accessibilityConfig;

  const AccessibleJobProgressCard({
    Key? key,
    required this.job,
    this.onTap,
    this.onCancel,
    this.onShowDetails,
    this.accessibilityConfig = const AccessibilityConfig(),
  }) : super(key: key);

  @override
  State<AccessibleJobProgressCard> createState() => _AccessibleJobProgressCardState();
}

class _AccessibleJobProgressCardState extends State<AccessibleJobProgressCard> {
  /// フォーカスノード
  late FocusNode _focusNode;

  /// ボタンフォーカスノード
  late FocusNode _cancelButtonFocusNode;
  late FocusNode _detailsButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _cancelButtonFocusNode = FocusNode();
    _detailsButtonFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _cancelButtonFocusNode.dispose();
    _detailsButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = widget.job.status == AsyncJobStatus.processing ||
        widget.job.status == AsyncJobStatus.queued;

    return Semantics(
      container: true,
      label: _getSemanticLabel(),
      onTap: widget.onTap,
      enabled: true,
      child: Focus(
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.space)) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
            node.unfocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        focusNode: _focusNode,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル行
                Semantics(
                  label: 'ジョブタイトル',
                  child: Text(
                    _getJobTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: _scaleFontSize(
                            Theme.of(context).textTheme.titleMedium?.fontSize ?? 16,
                          ),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                // 進捗バー
                if (isProcessing) ...[
                  Semantics(
                    slider: true,
                    label: 'ジョブ進捗: ${widget.job.progressPercent}%',
                    onIncrease: null,
                    onDecrease: null,
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: widget.job.getProgress(),
                              minHeight: _scaleFontSize(8),
                              semanticsLabel: 'ジョブ進捗バー',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          label: '進捗率',
                          child: Text(
                            '${widget.job.progressPercent}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: _scaleFontSize(14),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // アクションボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onShowDetails != null)
                      Semantics(
                        button: true,
                        enabled: true,
                        label: '詳細表示',
                        onTap: widget.onShowDetails,
                        child: TextButton(
                          focusNode: _detailsButtonFocusNode,
                          onPressed: widget.onShowDetails,
                          child: Text(
                            '詳細',
                            semanticsLabel: 'ジョブ詳細を表示',
                          ),
                        ),
                      ),
                    if (isProcessing && widget.onCancel != null)
                      Semantics(
                        button: true,
                        enabled: true,
                        label: 'ジョブをキャンセル',
                        onTap: widget.onCancel,
                        child: TextButton(
                          focusNode: _cancelButtonFocusNode,
                          onPressed: widget.onCancel,
                          child: Text(
                            'キャンセル',
                            semanticsLabel: 'ジョブをキャンセルする',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// セマンティックラベルを取得
  String _getSemanticLabel() {
    final title = _getJobTitle();
    final status = _getStatusLabel();
    final progress = widget.job.status == AsyncJobStatus.processing
        ? ', 進捗: ${widget.job.progressPercent}%'
        : '';
    return '$title, ステータス: $status$progress';
  }

  /// ジョブタイトルを取得
  String _getJobTitle() {
    if (widget.job is ReportGenerationJob) {
      final job = widget.job as ReportGenerationJob;
      return job.title.isNotEmpty ? job.title : 'レポート生成';
    } else if (widget.job is ExportDataJob) {
      final job = widget.job as ExportDataJob;
      return 'データエクスポート (${job.dataType})';
    } else if (widget.job is EmailDeliveryJob) {
      final job = widget.job as EmailDeliveryJob;
      return 'メール配信 (${job.recipientEmails.length} 件)';
    }
    return 'ジョブ #${widget.job.jobId.substring(0, 8)}';
  }

  /// ステータスラベルを取得
  String _getStatusLabel() {
    switch (widget.job.status) {
      case AsyncJobStatus.queued:
        return 'キュー待機中';
      case AsyncJobStatus.processing:
        return '処理中';
      case AsyncJobStatus.completed:
        return '完了';
      case AsyncJobStatus.failed:
        return '失敗';
      case AsyncJobStatus.cancelled:
        return 'キャンセル';
    }
  }

  /// フォントサイズをスケール
  double _scaleFontSize(double size) {
    return size * widget.accessibilityConfig.fontSizeFactor;
  }
}

/// アクセシブルダッシュボード統計ヘッダー
class AccessibleStatisticsHeader extends StatelessWidget {
  /// ジョブ統計
  final JobStatistics statistics;

  /// アクセシビリティ設定
  final AccessibilityConfig accessibilityConfig;

  const AccessibleStatisticsHeader({
    Key? key,
    required this.statistics,
    this.accessibilityConfig = const AccessibilityConfig(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'ジョブ統計',
      child: Container(
        padding: const EdgeInsets.all(16),
        color: _getHeaderColor(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              heading: true,
              label: 'ジョブ統計セクション',
              child: Text(
                'ジョブ統計',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: _scaleFontSize(
                        Theme.of(context).textTheme.titleMedium?.fontSize ?? 16,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatisticItem(
                  context,
                  '総数',
                  statistics.totalJobs.toString(),
                ),
                _buildStatisticItem(
                  context,
                  'アクティブ',
                  statistics.activeJobs.toString(),
                ),
                _buildStatisticItem(
                  context,
                  '完了',
                  statistics.completedJobs.toString(),
                ),
                _buildStatisticItem(
                  context,
                  '失敗',
                  statistics.failedJobs.toString(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              slider: true,
              label: '平均進捗: ${(statistics.averageProgress * 100).toStringAsFixed(1)}%',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: statistics.averageProgress,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '平均進捗: ${(statistics.averageProgress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: _scaleFontSize(12),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 統計アイテムを構築
  Widget _buildStatisticItem(BuildContext context, String label, String value) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: _scaleFontSize(
                    Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24,
                  ),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: _scaleFontSize(12),
                ),
          ),
        ],
      ),
    );
  }

  /// ヘッダーの色を取得
  Color _getHeaderColor() {
    if (accessibilityConfig.highContrastMode) {
      return Colors.grey[900]!;
    }
    return Colors.blue[50]!;
  }

  /// フォントサイズをスケール
  double _scaleFontSize(double size) {
    return size * accessibilityConfig.fontSizeFactor;
  }
}

/// キーボードナビゲーション ヘルパー
class KeyboardNavigationHelper {
  /// 次のフォーカス対象に移動
  static void moveFocusDown(FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(currentFocus.context!).requestFocus(nextFocus);
  }

  /// 前のフォーカス対象に移動
  static void moveFocusUp(FocusNode currentFocus, FocusNode previousFocus) {
    currentFocus.unfocus();
    FocusScope.of(currentFocus.context!).requestFocus(previousFocus);
  }

  /// Enter キーでアクション実行
  static bool handleEnterKey(KeyEvent event, VoidCallback onAction) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
        event.isKeyPressed(LogicalKeyboardKey.space)) {
      onAction();
      return true;
    }
    return false;
  }

  /// Escape キーでフォーカス解除
  static bool handleEscapeKey(KeyEvent event, FocusNode focusNode) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      focusNode.unfocus();
      return true;
    }
    return false;
  }
}

/// Semantics ラッパー拡張
extension SemanticsHelper on BuildContext {
  /// スクリーンリーダー用アナウンスメント
  void announceForAccessibility(String message) {
    SemanticsService.announce(message);
  }

  /// 高コントラストモードが有効か
  bool get isHighContrastMode {
    return MediaQuery.highContrastOf(this);
  }

  /// 縮減モーションが有効か
  bool get isReducedMotionEnabled {
    return MediaQuery.disableAnimationsOf(this);
  }

  /// テキストスケール係数
  double get textScaleFactor {
    return MediaQuery.textScaleFactorOf(this);
  }
}
