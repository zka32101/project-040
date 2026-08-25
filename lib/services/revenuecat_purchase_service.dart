import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/user.dart';
import 'purchase_service.dart';

/// RevenueCat を用いた In-app Purchases 実装。
///
/// Production環境ではこのサービスを PurchaseService として inject する。
/// RevenueCatのAPIキーは初期化時に設定済み（main.dart で Purchases.configure()）。
///
/// 非消費型パス（non-consumable）:
/// - single_category_pass_980: ¥980（1区分・合格まで無制限・広告非表示）
/// - all_category_set_pass_1980: ¥1,980（全区分・合格まで無制限・広告非表示）
///
/// オフラインモード:
/// - 購入直後は端末キャッシュから読み込み（オフライン対応）
/// - 定期的に RevenueCat サーバーと同期
class RevenueCatPurchaseService implements PurchaseService {
  static const String _singleCategoryProductId = 'single_category_pass_980';
  static const String _allCategorySetProductId = 'all_category_set_pass_1980';

  RevenueCatPurchaseService();

  /// 単一区分パス（¥980）を購入
  @override
  Future<PurchaseStatus> purchaseSingleCategoryPass() async {
    try {
      // 注意: purchaseProduct は deprecated、purchaseStoreProduct を使用推奨
      // ここでは互換性のため purchaseProduct を使用
      await Purchases.purchaseProduct(_singleCategoryProductId);
      return PurchaseStatus.singleCategoryPass;
    } catch (e) {
      // ユーザーキャンセルまたは他のエラーを区別
      if (e.toString().contains('cancelled')) {
        throw PurchaseCancelledException('ユーザーが購入をキャンセルしました');
      }
      rethrow;
    }
  }

  /// 全区分セットパス（¥1,980）を購入
  @override
  Future<PurchaseStatus> purchaseAllCategorySetPass() async {
    try {
      // 注意: purchaseProduct は deprecated、purchaseStoreProduct を使用推奨
      // ここでは互換性のため purchaseProduct を使用
      await Purchases.purchaseProduct(_allCategorySetProductId);
      return PurchaseStatus.allCategorySetPass;
    } catch (e) {
      // ユーザーキャンセルまたは他のエラーを区別
      if (e.toString().contains('cancelled')) {
        throw PurchaseCancelledException('ユーザーが購入をキャンセルしました');
      }
      rethrow;
    }
  }

  /// 購入履歴の復元（同じApple ID/Googleアカウントでの復元）
  @override
  Future<PurchaseStatus> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      // 復元後、エンタイトルメントを確認して現在のステータスを返す
      return _checkCurrentEntitlements();
    } catch (e) {
      rethrow;
    }
  }

  /// 現在のエンタイトルメント（購入状態）を確認
  static Future<PurchaseStatus> getCurrentPurchaseStatus() async {
    try {
      return await _checkCurrentEntitlements();
    } catch (e) {
      // エラー時は無料扱い
      return PurchaseStatus.free;
    }
  }

  /// RevenueCat APIからエンタイトルメントを取得して購入ステータスを判定
  static Future<PurchaseStatus> _checkCurrentEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // パスの有効性を確認
      if (customerInfo.entitlements.all['all_pass']?.isActive ?? false) {
        return PurchaseStatus.allCategorySetPass;
      }
      if (customerInfo.entitlements.all['single_pass']?.isActive ?? false) {
        return PurchaseStatus.singleCategoryPass;
      }

      return PurchaseStatus.free;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking entitlements: $e');
      }
      return PurchaseStatus.free;
    }
  }
}

/// 購入キャンセル例外
class PurchaseCancelledException implements Exception {
  PurchaseCancelledException(this.message);
  final String message;

  @override
  String toString() => 'PurchaseCancelledException: $message';
}

/// 購入エラー例外
class PurchaseException implements Exception {
  PurchaseException(this.message);
  final String message;

  @override
  String toString() => 'PurchaseException: $message';
}
