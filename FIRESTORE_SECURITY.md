# Firestore Security Rules デプロイメント・ガイド

## 概要

本ドキュメントは、Phase 7 Step 7.1で実装した Firestore Security Rules のデプロイ手順、セキュリティ戦略、および保守方法を説明します。

## セキュリティ戦略

### 基本原則

1. **所有者ベースアクセス制御**
   - ユーザーは自分のデータ（uid が一致）のみ読み込み・書き込み可能
   - すべてのサブコレクション（回答ログ、バイク解放進捗など）に適用

2. **データ検証**
   - すべての書き込みリクエストはスキーマ検証を実行
   - 必須フィールド、データ型、値の範囲を厳密に検証

3. **タイムスタンプ検証**
   - 過去のタイムスタンプのみ受け入れ
   - createdAt と updatedAt は現在時刻以前である必要がある

4. **デフォルト拒否**
   - マッチしないすべてのパスは読み込み・書き込みを拒否
   - より安全な「ホワイトリスト」型アプローチを採用

### コレクション別セキュリティ

#### users/{uid}
- **読み込み**: 所有者のみ
- **作成/更新**: 所有者、スキーマ検証付き
- **削除**: 所有者のみ
- **検証内容**:
  - uid は28文字のFirebase Auth UID
  - createdAt と updatedAt は有効なタイムスタンプ
  - uid はリクエストユーザーIDと一致

#### users/{uid}/answerLogs/{document}
- **読み込み**: 所有者のみ
- **作成/更新**: 所有者、スキーマ検証付き
- **削除**: 所有者のみ
- **検証内容**:
  - 必須フィールド: id, uid, questionId, selectedAnswer, isCorrect, answeredAt
  - uid は親パスの uid と一致
  - selectedAnswer は数値
  - isCorrect は論理値
  - answeredAt は有効なタイムスタンプ

#### users/{uid}/bikeUnlockProgress/{document}
- **読み込み**: 所有者のみ
- **作成/更新**: 所有者、スキーマ検証付き
- **削除**: 所有者のみ
- **検証内容**:
  - 必須フィールド: uid, bikeCategory, unlockedAt, unlockedPercentage
  - bikeCategory は許可リスト内（gentsuki, futsuu_nirin, ogata_nirin, 400cc, big_bike）
  - unlockedPercentage は0〜100の数値

#### users/{uid}/trapDojoSessions/{document}
- **読み込み**: 所有者のみ
- **作成/更新**: 所有者、スキーマ検証付き
- **削除**: 所有者のみ
- **検証内容**:
  - 必須フィールド: id, uid, startedAt, completedAt, score, totalQuestions
  - completedAt は null または有効なタイムスタンプ
  - score は非負数
  - totalQuestions は正の整数

#### users/{uid}/predictionScores/{document}
- **読み込み**: 所有者のみ
- **作成/更新**: 所有者、スキーマ検証付き
- **削除**: 所有者のみ
- **検証内容**:
  - 必須フィールド: uid, score, calculatedAt
  - score は0〜100の数値
  - calculatedAt は有効なタイムスタンプ

## デプロイ手順

### ステップ1: Firebase CLI インストール

```bash
npm install -g firebase-tools
```

### ステップ2: Firebase プロジェクト認証

```bash
firebase login
firebase use <PROJECT_ID>
```

### ステップ3: Firestore ルールのデプロイ

```bash
firebase deploy --only firestore:rules
```

### ステップ4: Firestore インデックスのデプロイ

```bash
firebase deploy --only firestore:indexes
```

### ステップ5: デプロイ確認

```bash
firebase firestore:indexes
```

## ルールのテスト

### ローカルテスト

Firebase Emulator を使用したローカルテスト：

```bash
firebase emulators:start
```

テスト用ルール：

```javascript
// ユーザーが自分のドキュメントを読み込めることを確認
describe('User Data Access', () => {
  it('should allow users to read their own documents', async () => {
    const userId = 'user123456789012345678901234';
    const db = getFirestore();
    const docRef = doc(db, 'users', userId);
    
    await setLoggedInState(userId);
    const snapshot = await getDoc(docRef);
    expect(snapshot.exists()).toBe(true);
  });

  it('should deny users from reading other users\' documents', async () => {
    const userId = 'user123456789012345678901234';
    const otherId = 'other12345678901234567890123';
    const db = getFirestore();
    const docRef = doc(db, 'users', otherId);
    
    await setLoggedInState(userId);
    const snapshot = await getDoc(docRef);
    expect(snapshot.exists()).toBe(false);
  });
});
```

### 本番前チェックリスト

- [ ] ローカル Emulator ですべてのテストを実行して合格
- [ ] Firebase Console で ルール構文検証を完了
- [ ] 各コレクションでサンプルデータを作成してアクセス制御を確認
- [ ] バックアップ・リカバリ計画を確認
- [ ] ロールバック計画を確認

## セキュリティ考慮事項

### 1. ユーザーIDの厳格性

```
// ✓ 許可
{
  "uid": "xvZ1a2b3c4d5e6f7g8h9i0j1k2l3m",
  "createdAt": "2026-08-27T00:00:00Z",
  "updatedAt": "2026-08-27T00:00:00Z"
}

// ✗ 拒否 - UID が無効
{
  "uid": "invalid_uid",
  "createdAt": "2026-08-27T00:00:00Z",
  "updatedAt": "2026-08-27T00:00:00Z"
}
```

### 2. タイムスタンプの検証

```
// ✓ 許可 - 現在時刻以前
{
  "answeredAt": "2026-08-26T10:30:00Z"  // 過去
}

// ✗ 拒否 - 将来のタイムスタンプ
{
  "answeredAt": "2026-08-28T10:30:00Z"  // 未来
}
```

### 3. データ型の強制

```
// ✓ 許可 - 正しいデータ型
{
  "isCorrect": true,
  "selectedAnswer": 2,
  "score": 85.5
}

// ✗ 拒否 - 不正なデータ型
{
  "isCorrect": "true",        // 文字列（論理値が必須）
  "selectedAnswer": "2",      // 文字列（数値が必須）
  "score": "85.5"             // 文字列（数値が必須）
}
```

### 4. 値の範囲検証

```
// ✓ 許可 - 有効な範囲
{
  "unlockedPercentage": 75,   // 0 ≤ x ≤ 100
  "score": 90.5               // 0 ≤ x ≤ 100
}

// ✗ 拒否 - 範囲外
{
  "unlockedPercentage": 150,  // > 100
  "score": -10                // < 0
}
```

## トラブルシューティング

### 問題: Permission Denied エラー

**原因**: ユーザーが自分のデータ以外へのアクセスを試みている

**解決策**:
- リクエストの UID が正しいか確認
- ドキュメントの uid フィールドがリクエスト UID と一致するか確認

### 問題: Invalid Data エラー

**原因**: 書き込みデータが検証ルールに違反

**解決策**:
- Firebase Console で実際のエラーメッセージを確認
- スキーマ検証をもう一度確認
- 必須フィールドがすべて含まれているか確認
- データ型が正しいか確認

### 問題: Timestamp Field Error

**原因**: タイムスタンプが無効または将来の日付

**解決策**:
- クライアント側の時刻を確認
- `DateTime.now()` ではなく、サーバータイムスタンプを使用（推奨）
- Firestore の `serverTimestamp()` を使用

## 監視・ロギング

### 推奨される監視項目

1. **拒否されたリクエスト数**
   - Firebase Console → Firestore → インサイト → 拒否率

2. **エラー分布**
   - どのオペレーション（読み込み/書き込み）が最も拒否されているか

3. **ユーザー別アクセスパターン**
   - 異常なアクセスパターンの検出

### Cloud Logging でのカスタムログ

今後、ルール内でカスタムログを追加することで、より詳細な監視が可能：

```javascript
function validateUserData(data) {
  let isValid = data.keys().hasAll(['uid', 'createdAt', 'updatedAt']) &&
                isValidUid(data.uid) &&
                hasValidTimestamp(data.createdAt) &&
                hasValidTimestamp(data.updatedAt) &&
                data.uid == getUserId();
  
  // 今後: Cloud Logging 連携
  return isValid;
}
```

## 保守・更新手順

### ルール更新フロー

1. **ローカル環境で変更**
   ```bash
   # firestore.rules を編集
   firebase emulators:start
   # テストで検証
   ```

2. **ステージング環境でテスト**
   ```bash
   firebase deploy --only firestore:rules --project <STAGING_PROJECT>
   ```

3. **本番環境にデプロイ**
   ```bash
   firebase deploy --only firestore:rules --project <PRODUCTION_PROJECT>
   ```

4. **ロールバック計画**
   - デプロイ前に現在のルールをバックアップ
   - 問題発生時は即座に前のバージョンに戻せるよう準備

### バージョン管理

ルール変更は Git で追跡：

```bash
git add firestore.rules firestore.indexes.json
git commit -m "chore: update firestore security rules for [REASON]"
git push
```

## 関連ドキュメント

- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Cloud Firestore のベストプラクティス](https://firebase.google.com/docs/firestore/best-practices)

## まとめ

このセキュリティ設定により、以下を実現します：

✅ ユーザーは自分のデータのみアクセス可能
✅ データスキーマの完全性を保証
✅ タイムスタンプに基づくコンフリクト検出をサポート
✅ 本番環境対応のセキュリティ
✅ GDPR 準拠のアカウント削除フロー
