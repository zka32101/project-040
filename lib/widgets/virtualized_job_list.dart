/// Phase 24: 仮想化ジョブリストウィジェット
/// 大規模ジョブリストのパフォーマンス最適化

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import 'job_progress_card.dart';

/// リスト仮想化設定
class VirtualizationConfig {
  /// キャッシュエクステント（ピクセル）
  final double cacheExtent;

  /// 初期アイテム数
  final int initialItemCount;

  /// 境界での読み込みオフセット
  final double endOfListThreshold;

  /// アイテムの推定高さ
  final double estimatedItemHeight;

  const VirtualizationConfig({
    this.cacheExtent = 1000.0,
    this.initialItemCount = 50,
    this.endOfListThreshold = 0.8,
    this.estimatedItemHeight = 200.0,
  });
}

/// リスト スクロール位置状態
class ScrollPositionState {
  /// 現在のオフセット
  final double offset;

  /// 最大スクロール距離
  final double maxScrollExtent;

  /// スクロール方向
  final ScrollDirection direction;

  /// タイムスタンプ
  final DateTime timestamp;

  const ScrollPositionState({
    required this.offset,
    required this.maxScrollExtent,
    required this.direction,
    required this.timestamp,
  });

  /// ページングが必要かチェック
  bool shouldLoadMore(double threshold) {
    return offset > maxScrollExtent * threshold;
  }

  /// コピー
  ScrollPositionState copyWith({
    double? offset,
    double? maxScrollExtent,
    ScrollDirection? direction,
    DateTime? timestamp,
  }) {
    return ScrollPositionState(
      offset: offset ?? this.offset,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// 仮想化ジョブリスト
class VirtualizedJobList extends ConsumerStatefulWidget {
  /// ジョブリスト
  final List<AsyncJob> jobs;

  /// アイテム構築関数
  final Widget Function(BuildContext, int, AsyncJob) itemBuilder;

  /// リスト仮想化設定
  final VirtualizationConfig config;

  /// ページング用のコールバック
  final Future<void> Function()? onLoadMore;

  /// リフレッシュ用のコールバック
  final Future<void> Function()? onRefresh;

  /// リスト空状態ウィジェット
  final Widget? emptyWidget;

  /// リスト読み込み状態ウィジェット
  final Widget? loadingWidget;

  const VirtualizedJobList({
    Key? key,
    required this.jobs,
    required this.itemBuilder,
    this.config = const VirtualizationConfig(),
    this.onLoadMore,
    this.onRefresh,
    this.emptyWidget,
    this.loadingWidget,
  }) : super(key: key);

  @override
  ConsumerState<VirtualizedJobList> createState() => _VirtualizedJobListState();
}

class _VirtualizedJobListState extends ConsumerState<VirtualizedJobList> {
  /// スクロールコントローラ
  late ScrollController _scrollController;

  /// スクロール位置状態
  ScrollPositionState? _scrollState;

  /// ローディング状態
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// スクロールイベントハンドラ
  void _onScroll() {
    final position = _scrollController.position;

    _scrollState = ScrollPositionState(
      offset: position.pixels,
      maxScrollExtent: position.maxScrollExtent,
      direction: position.userScrollDirection,
      timestamp: DateTime.now(),
    );

    // ページング判定
    if (_scrollState != null &&
        !_isLoading &&
        widget.onLoadMore != null &&
        _scrollState!.shouldLoadMore(widget.config.endOfListThreshold)) {
      _loadMore();
    }
  }

  /// さらにロード
  Future<void> _loadMore() async {
    if (_isLoading || widget.onLoadMore == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ジョブがありません',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          await widget.onRefresh!();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        cacheExtent: widget.config.cacheExtent,
        itemCount: widget.jobs.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.jobs.length) {
            return widget.loadingWidget ??
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
          }

          return widget.itemBuilder(
            context,
            index,
            widget.jobs[index],
          );
        },
      ),
    );
  }
}

/// CustomScrollView を使用した高度な仮想化リスト
class AdvancedVirtualizedJobList extends ConsumerStatefulWidget {
  /// ジョブリスト
  final List<AsyncJob> jobs;

  /// ヘッダーウィジェット
  final Widget? headerWidget;

  /// フッターウィジェット
  final Widget? footerWidget;

  /// アイテム構築関数
  final Widget Function(BuildContext, int, AsyncJob) itemBuilder;

  /// リスト仮想化設定
  final VirtualizationConfig config;

  /// ページング用のコールバック
  final Future<void> Function()? onLoadMore;

  /// リフレッシュ用のコールバック
  final Future<void> Function()? onRefresh;

  const AdvancedVirtualizedJobList({
    Key? key,
    required this.jobs,
    required this.itemBuilder,
    this.headerWidget,
    this.footerWidget,
    this.config = const VirtualizationConfig(),
    this.onLoadMore,
    this.onRefresh,
  }) : super(key: key);

  @override
  ConsumerState<AdvancedVirtualizedJobList> createState() =>
      _AdvancedVirtualizedJobListState();
}

class _AdvancedVirtualizedJobListState
    extends ConsumerState<AdvancedVirtualizedJobList> {
  /// スクロールコントローラ
  late ScrollController _scrollController;

  /// ローディング状態
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// スクロールイベントハンドラ
  void _onScroll() {
    final position = _scrollController.position;
    final pixels = position.pixels;
    final maxExtent = position.maxScrollExtent;

    if (!_isLoading &&
        widget.onLoadMore != null &&
        pixels > maxExtent * widget.config.endOfListThreshold) {
      _loadMore();
    }
  }

  /// さらにロード
  Future<void> _loadMore() async {
    if (_isLoading || widget.onLoadMore == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          await widget.onRefresh!();
        }
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ヘッダー
          if (widget.headerWidget != null)
            SliverToBoxAdapter(
              child: widget.headerWidget,
            ),

          // ジョブリスト
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= widget.jobs.length) {
                  return SizedBox.shrink();
                }
                return widget.itemBuilder(
                  context,
                  index,
                  widget.jobs[index],
                );
              },
              childCount: widget.jobs.length,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          ),

          // ローディング表示
          if (_isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // フッター
          if (widget.footerWidget != null)
            SliverToBoxAdapter(
              child: widget.footerWidget,
            ),
        ],
      ),
    );
  }
}

/// リスト パフォーマンス計測
class ListPerformanceMetrics {
  /// フレームレート
  final double fps;

  /// 平均フレーム時間（ms）
  final double avgFrameTime;

  /// 最大フレーム時間（ms）
  final double maxFrameTime;

  /// ジャンク数
  final int jankCount;

  /// タイムスタンプ
  final DateTime timestamp;

  const ListPerformanceMetrics({
    required this.fps,
    required this.avgFrameTime,
    required this.maxFrameTime,
    required this.jankCount,
    required this.timestamp,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'fps': fps,
        'avgFrameTime': avgFrameTime,
        'maxFrameTime': maxFrameTime,
        'jankCount': jankCount,
        'timestamp': timestamp.toIso8601String(),
      };
}
