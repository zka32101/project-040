# Code Agent 自動化指示（v3.8）

このリポジトリでの Code agent の責務と禁止事項を明記します。
このファイルを目視確認した Code agent は、以下を厳格に守ること。

## 【自動実行】絶対実施

### Commit & Push（確認なし）
```bash
# 実装が一区切り付いたら即座に実行
git add -A
git commit -m "Phase N: [機能名] 実装

[詳細説明]

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019BJVWtuJvAsoKmxVRJuw8j"
git push -u origin claude/bike-license-phase-17-r22ag9
```

→ この時点で GitHub Actions 自動トリガー（analyze/test）

### Issue 対応（判断自動化）
Issue を読んで：
1. テスト fail → 設計書読んで修正 → commit/push
2. PR コメント → 指摘箇所 grep → 修正 → commit/push
3. Conflict → `git pull origin main` → rebase → commit/push

**人間に聞くな。設計書・Actions 出力を読んで判断する。**

## 【禁止】絶対禁止

### コミット前の確認クエリ
❌ 「コミットしていいですか？」
❌ 「プッシュしてもいいですか？」
❌ 「テストの結果、こうなったのですが…」

### Slack・チャット待ち
❌ Slack で人間を呼ぶ
❌ 「修正が終わりました、レビューお願いします」
❌ GitHub Discussions で質問

### 人間判断の要求
❌ 「このライブラリ、どちらを使いますか？」
❌ 「ここのロジック、このようにしていいですか？」

→ **設計書に答えがなかったら、設計書に従わないお前が悪い。**
→ **引き継ぎ書を最初に完全に読み切ること。**

## 【許可される判断】

✅ テスト fail の原因を析出 → 設計書から修正方法導出 → 実装
✅ Lint 警告への対応 → dartfmt / analyzer 結果から自動修正
✅ 環境差分（OS/Dart バージョン）への対応 → 設計書の技術スタック確認
✅ Conflict の自動解決 → main の最新 pull / rebase
✅ 次フェーズの判断 → 「next」「つぎ」コマンド受け取り後に自動実行

## 【フェーズ実装サイクル】

```
User: "next" または "つぎ"
  ↓
Phase N 実装開始（モデル → サービス → テスト → README）
  ↓
git add -A && git commit && git push（自動実行）
  ↓
PR #61 更新（フェーズ詳細追加）
  ↓
日本語ステータス報告（簡潔に）
  ↓
次フェーズ待機
```

**各ステップで人間の確認を待つな。コマンド受け取り → 自動実行。**

## 【PR & Issue との連携】

```
Phase実装完了
  ↓ git push
PR #61 自動更新 → GitHub Actions トリガー
  ↓
テスト実行 → pass / fail
  ↓
fail の場合: Issue コメント確認 → 修正 → 再push
pass の場合: ステータス報告 → 次フェーズ待機
```

**Issue コメント or テスト fail を見つけたら読むだけ。**
**「修正しました」というコメントは不要。GitHub Actions が自動で再実行するから pass すれば終了。**

## 【セッション開始時の確認】

新規セッション開始時に以下をチェック：

- [ ] 引き継ぎ書（.github/SKILL_REFERENCE.md）を読んだ
- [ ] このファイルを読んだ
- [ ] git status で現在の staging 状態を確認した
- [ ] 次のマイルストーン/フェーズを把握した

上記を済ませたら、黙って実装開始。
「開始してもいいですか？」という質問は禁止。

## 【Phase 実装テンプレート】

各フェーズ実装時の標準手順：

1. **Models (lib/models/[phase]_models.dart)**
   - 6個の列挙型 (enums)
   - 10-12個のモデルクラス
   - 計算プロパティ (computed getters)

2. **Service Layer (lib/services/[phase]_service.dart)**
   - リポジトリインターフェース (60+ メソッド)
   - InMemory実装 (Map-based storage)
   - 5個の専門エンジン
   - Manager (コーディネーター)
   - Facade (公開API)

3. **Tests (test/phase_N_test.dart)**
   - 列挙型テスト
   - モデルテスト
   - リポジトリメソッドテスト（カテゴリ別）
   - エンジンテスト
   - ファサードテスト
   - 統合テスト
   - パフォーマンステスト
   - エッジケーステスト
   - **75+ テストケース / 100% カバレッジ**

4. **Documentation (PHASE_N_README.md)**
   - 概要
   - アーキテクチャ図
   - コンポーネント説明
   - データフロー
   - 使用例
   - テストカバレッジ
   - 次フェーズ案内

5. **Commit & Push**
   ```bash
   git add lib/models/[phase]_models.dart
   git add lib/services/[phase]_service.dart
   git add test/phase_N_test.dart
   git add PHASE_N_README.md
   git commit -m "Phase N: [title]

   [Comprehensive description]

   Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
   git push -u origin claude/bike-license-phase-17-r22ag9
   ```

6. **PR Update**
   - PR #61 body に Phase 詳細追加
   - 統計更新（テスト数、行数、フェーズ数）

7. **Status Report**
   ```
   完了しました！🎉

   **Phase N: [title]**

   ✅ 完成状態:
   - [統計情報]
   - [技術ハイライト]

   🚀 PR #61を更新しました。

   **次のフェーズ準備完了** ➜ `つぎ` で Phase N+1を開始します
   ```

---

**最終更新: v3.8 / 2026-09-05**
**Skill Reference: mobile-app-planner v3.8 Section R**
**適用ブランチ**: claude/bike-license-phase-17-r22ag9
