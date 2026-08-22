import '../models/user.dart';

/// 課金体系：サブスクではなく期間パス（非消費型 non-consumable）。
/// - 単一区分パス：¥980（合格まで無制限・広告非表示）
/// - 全区分セットパス：¥1,980
///
/// 本番実装は RevenueCat(purchases_flutter) の non-consumable product を
/// このインターフェースの裏に差し込む。Firebase/RevenueCatのAPIキー未設定の
/// 状態でもUI検証ができるよう、初期実装はローカル状態のみを更新するスタブ。
abstract class PurchaseService {
  Future<PurchaseStatus> purchaseSingleCategoryPass();
  Future<PurchaseStatus> purchaseAllCategorySetPass();
  Future<PurchaseStatus> restorePurchases();
}

class StubPurchaseService implements PurchaseService {
  @override
  Future<PurchaseStatus> purchaseSingleCategoryPass() async {
    // TODO(revenuecat-setup): Purchases.purchaseProduct('single_category_pass_980')
    return PurchaseStatus.singleCategoryPass;
  }

  @override
  Future<PurchaseStatus> purchaseAllCategorySetPass() async {
    // TODO(revenuecat-setup): Purchases.purchaseProduct('all_category_set_pass_1980')
    return PurchaseStatus.allCategorySetPass;
  }

  @override
  Future<PurchaseStatus> restorePurchases() async {
    // TODO(revenuecat-setup): Purchases.restorePurchases()
    return PurchaseStatus.free;
  }
}
