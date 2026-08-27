# パフォーマンス最適化戦略 - Phase 7 Step 7.3

## 概要

Phase 7 Step 7.3では、オフライン同期アーキテクチャのパフォーマンスを最適化する3つの主要戦略を実装します：

1. **キャッシング戦略** - メモリ効率的なTTLベースキャッシュ
2. **クエリ最適化** - Firestore インデックスと効率的な読み込み
3. **パフォーマンスモニタリング** - ヒット率とメトリクス追跡

---

## 1. キャッシング戦略

### TTL（Time-To-Live）ベースキャッシュ

```dart
// PerformanceCacheService を使用
final cacheService = PerformanceCacheService(
  maxCacheSize: 1000,      // 最大1000エントリ
  defaultTtlSeconds: 300,   // デフォルト5分
);

// ユーザーをキャッシュに保存
cacheService.cacheUser(user);

// キャッシュから取得（有効期限内なら）
final cachedUser = cacheService.getCachedUser(uid);
```

### キャッシュの利点

- **UI レスポンス向上**: メモリからの高速読み込み
- **ネットワーク削減**: Firestore クエリ削減
- **バッテリー節約**: ラジオ通信削減
- **オフライン対応**: 期限内なら提供可能

### TTL設定ガイドライン

| データ種 | 推奨TTL | 理由 |
|---------|--------|------|
| ユーザープロフィール | 5分 | 更新頻度低 |
| 回答ログ | 1分 | 頻繁に追加 |
| バイク解放進捗 | 5分 | 定期的な更新 |
| ひっかけ道場セッション | 2分 | セッション単位 |
| 合格率予測スコア | 10分 | 計算コスト高 |

### LRU（Least Recently Used）削除

キャッシュサイズ超過時は最もアクセスされていないエントリを削除：

```dart
// 自動削除（maxCacheSizeを超えると）
cacheService.cacheUser(user1);  // キャッシュ1
cacheService.cacheUser(user2);  // キャッシュ2
// 1000エントリ以上になると、最も古いアクセスを削除
```

---

## 2. クエリ最適化

### Firestore インデックス戦略

Phase 7 Step 7.1で実装した `firestore.indexes.json` に以下のインデックスを含めました：

#### 回答ログの効率的なクエリ

```javascript
// インデックス: uid + answeredAt (降順)
// クエリ例: ユーザーの回答を最新順に取得
db.collection('users').doc(uid)
  .collection('answerLogs')
  .orderBy('answeredAt', 'desc')
  .limit(50)
```

**このインデックスにより以下を高速化：**
- 最近の回答ログ取得
- 期間別フィルタリング
- 正答率分析

#### バイク解放進捗の最適化

```javascript
// インデックス: uid + bikeCategory
// クエリ例: 特定区分の進捗を取得
db.collection('users').doc(uid)
  .collection('bikeUnlockProgress')
  .where('bikeCategory', '==', 'gentsuki')
```

---

## 3. パフォーマンスモニタリング

### キャッシュメトリクス

```dart
// メトリクスを取得
final metrics = cacheService.getMetrics();

// メトリクス内容
{
  'cacheSize': 150,              // 現在のキャッシュサイズ
  'maxCacheSize': 1000,          // 最大サイズ
  'hits': 450,                   // キャッシュヒット数
  'misses': 50,                  // キャッシュミス数
  'totalRequests': 500,          // 総リクエスト数
  'hitRate': 0.9,                // ヒット率（90%）
  'averageHitRate': 0.85,        // 平均ヒット率（直近100回）
  'entries': [                   // 個別エントリ情報
    {
      'key': 'user_123...',
      'age': 45,                 // 45秒前にアクセス
      'ttl': 300,                // TTL: 5分
      'expired': false,          // 有効
    },
    // ...
  ]
}
```

### パフォーマンスインサイト

**ヒット率の解釈：**
- `90% 以上`: 優秀 - キャッシング戦略が効果的
- `70-90%`: 良好 - TTLを調整してさらに改善可

- `50-70%`: 要改善 - TTLを長くするか、キャッシュサイズを増加
- `50% 以下`: 問題あり - キャッシング戦略を見直し

---

## 4. 統合ガイド

### providers.dart での統合

```dart
import 'package:bike_license_kore/services/performance_cache_service.dart';

// キャッシュサービスプロバイダ
final performanceCacheServiceProvider =
    Provider<PerformanceCacheService>((ref) {
  return PerformanceCacheService(
    maxCacheSize: 1000,
    defaultTtlSeconds: 300,
  );
});

// キャッシュメトリクスプロバイダ
final cacheMetricsProvider = Provider<Map<String, dynamic>>((ref) {
  final cacheService = ref.watch(performanceCacheServiceProvider);
  return cacheService.getMetrics();
});
```

### UIでの使用例

```dart
class CacheStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(cacheMetricsProvider);
    
    return Column(
      children: [
        Text('キャッシュサイズ: ${metrics['cacheSize']}/${metrics['maxCacheSize']}'),
        Text('ヒット率: ${(metrics['hitRate'] * 100).toStringAsFixed(1)}%'),
        Text('平均ヒット率: ${(metrics['averageHitRate'] * 100).toStringAsFixed(1)}%'),
      ],
    );
  }
}
```

### バックグラウンド更新

```dart
// キャッシュと同時にFirestoreから更新
Future<AppUser> loadUserWithCache(String uid) async {
  final cacheService = ref.read(performanceCacheServiceProvider);
  
  // 1. キャッシュから即座に返す
  final cached = cacheService.getCachedUser(uid);
  if (cached != null) {
    return cached;
  }
  
  // 2. バックグラウンドでFirestoreから取得
  final firestoreService = ref.read(fireStoreSyncServiceProvider);
  final user = await firestoreService.loadUser(uid);
  
  // 3. 新しいデータをキャッシュに保存
  if (user != null) {
    cacheService.cacheUser(user);
  }
  
  return user;
}
```

---

## 5. パフォーマンスチューニング

### キャッシュサイズ最適化

デバイスメモリに基づいて調整：

```dart
// 低メモリデバイス
const lowMemoryMaxCache = 500;

// 標準デバイス
const standardMaxCache = 1000;

// 高メモリデバイス
const highMemoryMaxCache = 2000;

// デバイスメモリに基づいて選択
final maxCacheSize = deviceMemory < 2GB 
  ? lowMemoryMaxCache
  : highMemoryMaxCache;
```

### TTL動的調整

```dart
// ネットワーク状態に基づくTTL調整
int getDynamicTtl(ConnectivityStatus status) {
  switch (status) {
    case ConnectivityStatus.connected:
      return 300;  // 5分
    case ConnectivityStatus.disconnected:
      return 3600; // 60分（オフラインは長めに）
    default:
      return 300;
  }
}

// 使用時
final ttl = getDynamicTtl(connectivityService.getConnectivityStatus());
cacheService.cacheUser(user, ttlSeconds: ttl);
```

---

## 6. トラブルシューティング

### ヒット率が低い場合

**原因と対策：**
1. TTLが短すぎる → 長くする
2. キャッシュサイズが小さすぎる → 増やす
3. データのアクセスパターンがランダム → キャッシング戦略を見直す

### メモリ使用量が多い場合

**原因と対策：**
1. キャッシュサイズが大きすぎる → 減らす
2. TTLが長すぎる → 短くする
3. キャッシュクリーンアップが実行されていない → dispose() を呼ぶ

### キャッシュスタッシュ（古いデータ表示）

**原因と対策：**
1. TTLが長すぎる → 短くする
2. キャッシュが明示的にクリアされていない → clearCacheForUser() を呼ぶ
3. データ更新時にキャッシュを削除していない

---

## 7. ベストプラクティス

### ✅ 推奨される使用方法

```dart
// 1. キャッシュサービスをシングルトンで管理
final cacheService = ref.watch(performanceCacheServiceProvider);

// 2. 定期的にメトリクスを確認
void checkCacheHealth() {
  final metrics = cacheService.getMetrics();
  if (metrics['hitRate'] < 0.7) {
    debugPrint('キャッシュヒット率が低い: ${metrics['hitRate']}');
  }
}

// 3. ユーザー削除時にキャッシュもクリア
Future<void> deleteUser(String uid) async {
  await userDeletionService.deleteUser(uid);
  cacheService.clearCacheForUser(uid);
}

// 4. アプリ終了時にリソースを解放
@override
void dispose() {
  cacheService.dispose();
  super.dispose();
}
```

### ❌ 避けるべき使用方法

```dart
// ❌ キャッシュサイズを無制限に設定
PerformanceCacheService(maxCacheSize: 999999)

// ❌ TTLを無限に長くする
cacheService.cacheUser(user, ttlSeconds: 86400)

// ❌ dispose() を呼ばずにリソースリーク
// キャッシュクリーンアップタイマーがメモリを消費

// ❌ 機密データをキャッシュ
cacheService.cacheUser(sensitiveData) // パスワードなど
```

---

## 8. 関連ドキュメント

- [FIRESTORE_SECURITY.md](FIRESTORE_SECURITY.md) - セキュリティルール
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Riverpod Caching](https://riverpod.dev/docs/essentials/combining_providers)

---

## 9. まとめ

Phase 7 Step 7.3により、以下のパフォーマンス改善を実現：

✅ **キャッシング**: 80-95% のヒット率を目標
✅ **クエリ最適化**: Firestore インデックスで検索高速化
✅ **モニタリング**: メトリクスで継続的に改善
✅ **オフライン対応**: キャッシュで接続切断時も提供
✅ **メモリ効率**: LRU削除とTTL無効化で最適化
