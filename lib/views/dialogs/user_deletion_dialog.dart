import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/user_deletion_service.dart';
import '../../viewmodels/providers.dart';

/// ユーザー削除確認ダイアログ
///
/// GDPR対応のアカウント削除フロー：
/// 1. 確認ダイアログを表示
/// 2. 削除処理の進行状況を表示
/// 3. 完了後にアプリをログアウト
class UserDeletionDialog extends ConsumerStatefulWidget {
  const UserDeletionDialog({super.key});

  @override
  ConsumerState<UserDeletionDialog> createState() => _UserDeletionDialogState();

  /// ダイアログを表示
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UserDeletionDialog(),
    );
  }
}

class _UserDeletionDialogState extends ConsumerState<UserDeletionDialog> {
  bool _isDeleting = false;
  UserDeletionProgress? _progress;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('アカウント削除'),
      content: _isDeleting ? _buildDeletingContent() : _buildConfirmationContent(),
      actions: _buildActions(context),
    );
  }

  Widget _buildConfirmationContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'このアクションは取り消せません。以下のデータが削除されます：',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildDeletedDataItem('あなたのプロフィール情報'),
        _buildDeletedDataItem('回答ログ'),
        _buildDeletedDataItem('バイク解放進捗'),
        _buildDeletedDataItem('ひっかけ道場記録'),
        _buildDeletedDataItem('合格予測スコア'),
        const SizedBox(height: 16),
        const Text(
          'アカウント削除を続行しますか？',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeletedDataItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Text(item),
        ],
      ),
    );
  }

  Widget _buildDeletingContent() {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'エラーが発生しました',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_progress == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress!.progressPercentage / 100,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_progress!.step}/${_progress!.totalSteps} - ${_progress!.currentMessage}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '進捗: ${_progress!.progressPercentage}%',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_isDeleting) {
      if (_error != null) {
        return [
          TextButton(
            onPressed: _reset,
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: _startDeletion,
            child: const Text('再試行'),
          ),
        ];
      }
      return [];
    }

    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('キャンセル'),
      ),
      TextButton(
        onPressed: _startDeletion,
        child: const Text(
          '削除',
          style: TextStyle(color: Colors.red),
        ),
      ),
    ];
  }

  Future<void> _startDeletion() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      final uid = ref.read(currentUidProvider);
      final deletionService = ref.read(userDeletionServiceProvider);

      // 削除進捗を監視
      await for (final progress in deletionService.progressStream) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }

        // 完了時
        if (progress.isComplete) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            // 削除完了 → ログアウト
            await _logoutAfterDeletion(context);
          }
          return;
        }

        // エラー時
        if (progress.error != null) {
          if (mounted) {
            setState(() {
              _error = progress.error;
            });
          }
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  Future<void> _logoutAfterDeletion(BuildContext context) async {
    try {
      // Firebase Auth からサインアウト
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // ダイアログを閉じてアプリをリセット
        Navigator.of(context).popUntil((route) => route.isFirst);

        // ホーム画面にリセット
        // （通常はアプリの初期化スクリーンに戻る）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アカウントが削除されました。アプリを再起動してください。'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログアウト処理でエラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _isDeleting = false;
      _progress = null;
      _error = null;
    });
  }
}

/// ユーザー削除確認ボタン
///
/// 設定画面などに配置して、ユーザー削除フローを開始
class UserDeletionButton extends StatelessWidget {
  const UserDeletionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text(
        'アカウント削除',
        style: TextStyle(color: Colors.red),
      ),
      subtitle: const Text('GDPR対応：すべてのデータが削除されます'),
      onTap: () => UserDeletionDialog.show(context),
    );
  }
}

/// アカウント削除セクション（設定画面用）
class AccountDeletionSection extends StatelessWidget {
  const AccountDeletionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'アカウント管理',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: UserDeletionButton(),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'アカウント削除は取り消せません。すべてのデータが削除されます。',
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
