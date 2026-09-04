/// Phase 23: 通知センターウィジェット
/// ユーザーの通知を集中管理

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../services/fcm_notification_service.dart';
import '../providers/notification_provider.dart';

/// 通知センター
class NotificationCenter extends ConsumerStatefulWidget {
  /// ページタイトル
  final String title;

  const NotificationCenter({
    Key? key,
    this.title = '通知',
  }) : super(key: key);

  @override
  ConsumerState<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends ConsumerState<NotificationCenter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: Text(
                '${state.unreadCount}件を既読',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationProvider.notifier).fetchNotifications();
            },
            tooltip: '更新',
          ),
        ],
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationProvider.notifier).fetchNotifications();
                  },
                  child: ListView.builder(
                    itemCount: state.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return _buildNotificationItem(context, ref, notification);
                    },
                  ),
                ),
    );
  }

  /// 空状態を構築
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '通知はありません',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// 通知アイテムを構築
  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    LocalNotification notification,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                onTap: () {
                  ref.read(notificationProvider.notifier).markAsRead(notification.id);
                },
                child: const Text('既読にする'),
              ),
            PopupMenuItem(
              onTap: () {
                ref.read(notificationProvider.notifier).cancelNotification(notification.id);
              },
              child: const Text('削除'),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(notification.id);
          }
        },
      ),
    );
  }

  /// 通知アイコンを構築
  Widget _buildNotificationIcon(LocalNotification notification) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          _getNotificationIconData(notification),
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// 通知の色を取得
  Color _getNotificationColor(LocalNotification notification) {
    if (notification.title.contains('完了')) return Colors.green;
    if (notification.title.contains('失敗')) return Colors.red;
    if (notification.title.contains('開始')) return Colors.orange;
    return Colors.blue;
  }

  /// 通知アイコンを取得
  IconData _getNotificationIconData(LocalNotification notification) {
    if (notification.title.contains('完了')) return Icons.check_circle;
    if (notification.title.contains('失敗')) return Icons.error;
    if (notification.title.contains('開始')) return Icons.play_circle;
    return Icons.notifications;
  }

  /// 時刻を形式化
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
}
