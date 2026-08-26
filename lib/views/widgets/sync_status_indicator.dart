import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/sync_queue_service.dart';
import '../../viewmodels/providers.dart';

/// 同期ステータスを表示するインジケータウィジェット
///
/// アプリバーやステータスバーに配置して、現在の同期状態を表示します：
/// - connected: チェックマーク（緑）
/// - syncing: 回転アイコン（青）
/// - offline: エラーアイコン（黄）
/// - failed: エラーアイコン（赤）
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    this.showLabel = false,
    this.size = 20.0,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  /// ステータスラベルを表示するかどうか
  final bool showLabel;

  /// アイコンサイズ
  final double size;

  /// パディング
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      data: (status) => _buildStatusWidget(context, status),
      loading: () => Padding(
        padding: padding,
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      error: (error, stack) => _buildErrorWidget(context),
    );
  }

  Widget _buildStatusWidget(BuildContext context, SyncStatus status) {
    final (icon, color, label) = _getStatusProperties(status);

    return Padding(
      padding: padding,
      child: Tooltip(
        message: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: size,
              color: color,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Padding(
      padding: padding,
      child: Icon(
        Icons.error_outline,
        size: size,
        color: Colors.red,
      ),
    );
  }

  /// ステータスに応じたアイコン・色・ラベルを取得
  (IconData, Color, String) _getStatusProperties(SyncStatus status) {
    return switch (status) {
      SyncStatus.connected => (
        Icons.check_circle_outline,
        Colors.green,
        'データ同期完了',
      ),
      SyncStatus.syncing => (
        Icons.sync,
        Colors.blue,
        '同期中...',
      ),
      SyncStatus.offline => (
        Icons.cloud_off,
        Colors.orange,
        'オフライン（キューに保存）',
      ),
      SyncStatus.failed => (
        Icons.error_outline,
        Colors.red,
        '同期失敗（自動再試行中）',
      ),
    };
  }
}

/// スナックバーに表示する同期ステータス通知
class SyncStatusSnackbar extends ConsumerWidget {
  const SyncStatusSnackbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      data: (status) {
        // 接続成功時のみスナックバーを表示（オフラインや失敗は常時表示されるため）
        if (status == SyncStatus.connected) {
          // スナックバーは自動で消える
          return const SizedBox.shrink();
        }

        final (icon, color, message) = _getStatusMessage(status);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  (IconData, Color, String) _getStatusMessage(SyncStatus status) {
    return switch (status) {
      SyncStatus.connected => (
        Icons.check_circle,
        Colors.green,
        'データを同期しました',
      ),
      SyncStatus.syncing => (
        Icons.sync,
        Colors.blue,
        '現在データを同期中...',
      ),
      SyncStatus.offline => (
        Icons.cloud_off,
        Colors.orange,
        'オフラインです。接続時にデータを同期します。',
      ),
      SyncStatus.failed => (
        Icons.warning,
        Colors.red,
        'データ同期に失敗しました。再試行中...',
      ),
    };
  }
}

/// ステータスに応じたバッジを表示（アプリバーなど）
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      data: (status) {
        if (status == SyncStatus.connected) {
          return const SizedBox.shrink();
        }

        final (icon, backgroundColor) = switch (status) {
          SyncStatus.syncing => (
            Icons.sync,
            Colors.blue,
          ),
          SyncStatus.offline => (
            Icons.cloud_off,
            Colors.orange,
          ),
          SyncStatus.failed => (
            Icons.error,
            Colors.red,
          ),
          _ => (Icons.info, Colors.grey),
        };

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      error: (_, __) => Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.error,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
