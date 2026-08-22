import 'package:bike_license_kore/services/ad_gate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdGateService', () {
    test('banner is always disallowed (方針: バナー広告不採用)', () {
      expect(AdGateService().canShowBanner, isFalse);
    });

    test('interstitial blocked before daily quota is completed', () {
      final gate = AdGateService();
      expect(gate.canShowInterstitial, isFalse);
    });

    test('interstitial allowed exactly once after quota completion', () {
      final gate = AdGateService();
      gate.markDailyQuotaCompleted();
      expect(gate.canShowInterstitial, isTrue);

      gate.markInterstitialShown();
      expect(gate.canShowInterstitial, isFalse, reason: '同一セッション内2回目は禁止');
    });

    test('interstitial blocked while inside a protected context', () {
      final gate = AdGateService();
      gate.markDailyQuotaCompleted();
      gate.enterContext(AdBlockingContext.answeringQuestion);
      expect(gate.canShowInterstitial, isFalse);

      gate.enterContext(AdBlockingContext.trapDojoBossBattle);
      expect(gate.canShowInterstitial, isFalse);

      gate.enterContext(AdBlockingContext.justShowedPredictionMeter);
      expect(gate.canShowInterstitial, isFalse);
    });

    test('rewarded ad blocked while inside a protected context', () {
      final gate = AdGateService();
      gate.enterContext(AdBlockingContext.answeringQuestion);
      expect(gate.canShowRewardedAd, isFalse);

      gate.exitContext();
      expect(gate.canShowRewardedAd, isTrue);
    });

    test('resetSession clears daily/session flags', () {
      final gate = AdGateService();
      gate.markDailyQuotaCompleted();
      gate.markInterstitialShown();
      gate.resetSession();
      expect(gate.canShowInterstitial, isFalse, reason: '新セッションではまだノルマ未完走扱い');

      gate.markDailyQuotaCompleted();
      expect(gate.canShowInterstitial, isTrue, reason: 'セッションフラグはリセットされている');
    });
  });
}
