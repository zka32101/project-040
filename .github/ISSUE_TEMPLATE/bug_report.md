---
name: Code 修正対応
about: PR QA の問題を Code agent に渡す
title: 'fix: [フェーズ] [問題箇所]'
labels: code-fix, qa
assignees: ''

---

## 問題箇所
[モジュール名] / [クラス名] で発生

## 再現手順
1. [ステップ1]
2. [ステップ2]
3. [実際の動作] vs [期待される動作]

## 技術的ヒント（Code agent 向け）
- [grep すべきファイル・関数]
- [関連する設計書セクション]
- [テストすべきパターン]

## Code Agent へ
このコメントを読んだら、以下を自動実行すること：
1. grep で問題個所を特定
2. 設計書（.github/CODE_AGENT_INSTRUCTIONS.md 参照）を読んで修正方法を確認
3. コード修正 → テスト実行
4. git commit/push （確認なし）

修正後に「修正しました」というコメントは不要。
GitHub Actions が自動で test 再実行するから、pass すれば終了。
