# yourwish SKILL 参照

このリポジトリは以下のスキルに準拠しています：

## Core Skill
- **mobile-app-planner v3.8**
  - 最重要セクション: Section P（運用）/ Q（継続性）/ R（Code自動化）
  - v3.8 新設: Section R（Code自動化プロトコル）

## Project Index
- **yourwish_PROJECT_INDEX_v1_3**
  - 自社内被り確認は台帳を参照

## このリポジトリの自動化設定

### GitHub Actions
- `claude/bike-license-phase-17-r22ag9` push → CI/CD 自動実行
- `main` push → 本番タグ自動生成
- PR template: `.github/pull_request_template.md` 自動適用

### Code Agent 責務
- git add/commit/push は自動実行（確認不要）
- Test fail は設計書読んで自己修正 → 再push
- Conflict は pull/rebase → 再push
- Issue 対応は issue を読んで判断 → 自動修正

### 禁止事項
- ❌ 「コミットしていいですか？」の確認クエリ
- ❌ Slack/メール待ち
- ❌ CI/CD 結果を人間に報告
- ❌ PR レビュー待ち（自動作成・自動マージ指示後のみ）

## Code Handoff 書

このリポジトリの実装は以下の引き継ぎ書に完全準拠：
- ファイル: `.github/CODE_AGENT_INSTRUCTIONS.md`
- 最終更新: 2026-09-05
- 確認・判断不要宣言: あり（Section R-2参照）

新規セッション開始時は、上記の引き継ぎ書を最初に読むこと。

## 実装フェーズ進捗

**完了フェーズ: 1-81**
- Phase 1-60: Foundation & Core Systems
- Phase 61-81: Enterprise Features (Analytics, Audit, Integration, Security, SLA)

**現在進行中**: Phase 82 以降
- 自動化プロトコル適用
- git add/commit/push 自動実行
- テスト自動修正
- Issue 自動対応

---

**最終更新: v3.8 / 2026-09-05**
**適用セッション**: claude/bike-license-phase-17-r22ag9
