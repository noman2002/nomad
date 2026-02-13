import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

const String kRevenueCatEntitlementId = 'pro';

bool isRevenueCatSupportedPlatform() {
  return Platform.isIOS || Platform.isAndroid;
}

Future<void> initializeRevenueCat() async {
  String apiKey;

  if (Platform.isIOS) {
    apiKey = 'test_lCVQtUaVjvnPqBdWOjoiWvPWMok';
  } else if (Platform.isAndroid) {
    apiKey = 'test_lCVQtUaVjvnPqBdWOjoiWvPWMok';
  } else {
    return;
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));
}

Future<void> syncRevenueCatUser(String appUserId) async {
  if (!isRevenueCatSupportedPlatform()) return;
  await Purchases.logIn(appUserId);
}

Future<void> clearRevenueCatUser() async {
  if (!isRevenueCatSupportedPlatform()) return;
  await Purchases.logOut();
}

Future<bool> hasActiveEntitlement() async {
  if (!isRevenueCatSupportedPlatform()) return false;

  final customerInfo = await Purchases.getCustomerInfo();
  return customerInfoHasActiveEntitlement(customerInfo);
}

bool customerInfoHasActiveEntitlement(CustomerInfo customerInfo) {
  if (customerInfo.entitlements.active.containsKey(kRevenueCatEntitlementId)) {
    return true;
  }
  return customerInfo.entitlements.active.isNotEmpty;
}

Future<Offering?> getCurrentOffering() async {
  if (!isRevenueCatSupportedPlatform()) return null;
  final offerings = await Purchases.getOfferings();
  return offerings.current;
}

Future<PurchaseResult> purchaseRevenueCatPackage(Package package) async {
  return Purchases.purchase(
    PurchaseParams.package(package),
  );
}

Future<CustomerInfo> restoreRevenueCatPurchases() async {
  return Purchases.restorePurchases();
}
