/// 広告表示制御ガード（実装引き継ぎ書「重点実装・レビューで指摘された致命論点」）。
///
/// 【禁止ゾーン・コードレベルで強制】
/// - 問題回答中（出題〜正誤演出）
/// - ひっかけ道場のボス戦中
/// - 合格予測メーター表示直後（Aha Moment直後は課金導線を優先）
///
/// UI側は広告を表示する直前に必ず `AdGateService.canShowInterstitial` /
/// `canShowRewarded` を通し、false の場合は一切表示しないこと。
/// Remote Configで頻度を上げる場合も、このガード自体は緩めない
/// （初期値は保守的に、というレビュー指摘のコード側の担保）。
enum AdBlockingContext {
  none,
  answeringQuestion,
  trapDojoBossBattle,
  justShowedPredictionMeter,
}

class AdGateService {
  AdGateService();

  AdBlockingContext _currentContext = AdBlockingContext.none;

  bool _interstitialShownThisSession = false;
  bool _dailyQuotaCompletedToday = false;

  void enterContext(AdBlockingContext context) {
    _currentContext = context;
  }

  void exitContext() {
    _currentContext = AdBlockingContext.none;
  }

  void markDailyQuotaCompleted() {
    _dailyQuotaCompletedToday = true;
  }

  /// 新しい日・新しいセッション開始時に呼ぶ。
  void resetSession() {
    _interstitialShownThisSession = false;
    _dailyQuotaCompletedToday = false;
  }

  /// インタースティシャルは「1日ノルマ完走後の結果画面」でのみ・1日1回・
  /// 同一セッション内2回目表示は禁止。
  bool get canShowInterstitial {
    if (_currentContext != AdBlockingContext.none) return false;
    if (!_dailyQuotaCompletedToday) return false;
    if (_interstitialShownThisSession) return false;
    return true;
  }

  /// リワード広告はユーザー起点のみ（自動再生・カウントダウン誘導は実装しない）。
  /// 呼び出し側は必ずユーザーのタップハンドラ内からのみ呼ぶこと。
  bool get canShowRewardedAd => _currentContext == AdBlockingContext.none;

  void markInterstitialShown() {
    _interstitialShownThisSession = true;
  }

  /// バナー広告は不採用の方針のため、常に false を返す（実装ミス防止の明示ガード）。
  bool get canShowBanner => false;
}
