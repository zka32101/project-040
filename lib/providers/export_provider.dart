/// Phase 26: エクスポートプロバイダー
/// Riverpod を使用したファイルエクスポートの状態管理

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_export_model.dart';
import '../models/async_job_model.dart';
import '../services/search_export_service.dart';

/// ファイルエクスポートサービスプロバイダー
final exportServiceProvider = Provider<FileExportService>((ref) {
  return MemoryFileExportService();
});

/// エクスポート設定プロバイダー
final exportConfigProvider = StateProvider<ExportConfig>((ref) {
  return const ExportConfig(
    format: ExportFormat.csv,
    fields: [
      'jobId',
      'userId',
      'jobType',
      'status',
      'createdAt',
      'completedAt',
    ],
  );
});

/// アクティブなエクスポートリストプロバイダー
final activeExportsProvider =
    StateNotifierProvider<ActiveExportsNotifier, List<ExportResult>>(
  (ref) => ActiveExportsNotifier(ref.watch(exportServiceProvider)),
);

/// エクスポート進捗プロバイダー
final exportProgressProvider =
    FutureProvider.family<ExportResult?, String>((ref, exportId) async {
  final service = ref.watch(exportServiceProvider);
  return service.getExportStatus(exportId);
});

/// エクスポート中フラグプロバイダー
final isExportingProvider = StateProvider<bool>((ref) => false);

/// 最後のエクスポート結果プロバイダー
final lastExportResultProvider = StateProvider<ExportResult?>((ref) => null);

/// エクスポートエラーメッセージプロバイダー
final exportErrorProvider = StateProvider<String?>((ref) => null);

/// アクティブなエクスポート状態管理クラス
class ActiveExportsNotifier extends StateNotifier<List<ExportResult>> {
  final FileExportService _service;

  ActiveExportsNotifier(this._service) : super([]);

  /// エクスポートを追加
  void addExport(ExportResult export) {
    state = [...state, export];
  }

  /// エクスポート状態を更新
  Future<void> updateExportStatus(String exportId) async {
    final updated = await _service.getExportStatus(exportId);
    if (updated != null) {
      state = [
        for (final export in state)
          if (export.exportId == exportId) updated else export,
      ];
    }
  }

  /// 完了したエクスポートを削除
  void removeCompleted() {
    state = [
      for (final export in state)
        if (export.status != ExportStatus.completed) export,
    ];
  }

  /// 全エクスポートをクリア
  void clearAll() {
    state = [];
  }
}

/// エクスポート操作ヘルパー
class ExportOperations {
  final Ref ref;

  ExportOperations(this.ref);

  /// エクスポートを実行
  Future<void> executeExport(
    List<AsyncJob> jobs,
    ExportConfig config,
  ) async {
    ref.read(isExportingProvider.notifier).state = true;
    ref.read(exportErrorProvider.notifier).state = null;

    try {
      final service = ref.read(exportServiceProvider);
      final result = await service.exportJobs(jobs, config);

      ref.read(lastExportResultProvider.notifier).state = result;
      ref.read(activeExportsProvider.notifier).addExport(result);

      if (result.status == ExportStatus.failed) {
        ref.read(exportErrorProvider.notifier).state =
            result.errorMessage ?? 'エクスポートが失敗しました';
      }
    } catch (e) {
      ref.read(exportErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(isExportingProvider.notifier).state = false;
    }
  }

  /// エクスポート設定を更新
  void updateConfig(ExportConfig config) {
    ref.read(exportConfigProvider.notifier).state = config;
  }

  /// エクスポートをキャンセル
  Future<void> cancelExport(String exportId) async {
    final service = ref.read(exportServiceProvider);
    await service.cancelExport(exportId);

    // 状態を更新
    await ref
        .read(activeExportsProvider.notifier)
        .updateExportStatus(exportId);
  }

  /// エクスポートをダウンロード
  Future<List<int>?> downloadExport(String exportId) async {
    try {
      final service = ref.read(exportServiceProvider);
      return await service.downloadExport(exportId);
    } catch (e) {
      ref.read(exportErrorProvider.notifier).state = e.toString();
      return null;
    }
  }

  /// フォーマットを更新
  void updateFormat(ExportFormat format) {
    final current = ref.read(exportConfigProvider);
    ref.read(exportConfigProvider.notifier).state =
        current.copyWith(format: format);
  }

  /// フィールドを更新
  void updateFields(List<String> fields) {
    final current = ref.read(exportConfigProvider);
    ref.read(exportConfigProvider.notifier).state =
        current.copyWith(fields: fields);
  }

  /// 圧縮設定を更新
  void updateCompression(bool compressed) {
    final current = ref.read(exportConfigProvider);
    ref.read(exportConfigProvider.notifier).state =
        current.copyWith(compressed: compressed);
  }
}
