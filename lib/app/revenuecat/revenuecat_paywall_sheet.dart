import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'revenuecat_bootstrap.dart';

Future<bool> showRevenueCatPaywall(BuildContext context) async {
  if (!isRevenueCatSupportedPlatform()) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Purchases are only available on iOS/Android.')));
    }
    return false;
  }

  try {
    final offering = await getCurrentOffering();
    if (offering == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No RevenueCat current offering found. Configure one in dashboard.'),
          ),
        );
      }
      return false;
    }

    final result = await RevenueCatUI.presentPaywall(offering: offering, displayCloseButton: true);

    switch (result) {
      case PaywallResult.purchased:
      case PaywallResult.restored:
        return true;
      case PaywallResult.notPresented:
      case PaywallResult.cancelled:
      case PaywallResult.error:
        return false;
    }
  } catch (e) {
    if (e is MissingPluginException || e.toString().contains('presentPaywall')) {
      debugPrint('RevenueCat native paywall unavailable, using fallback UI: $e');
      return _showFallbackRevenueCatPaywall(context);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open RevenueCat paywall: $e')));
    }
    debugPrint('RevenueCat native paywall error: $e');
    return false;
  }
}

Future<bool> _showFallbackRevenueCatPaywall(BuildContext context) async {
  final upgraded = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _FallbackRevenueCatPaywallSheet(),
  );

  return upgraded ?? false;
}

class _FallbackRevenueCatPaywallSheet extends StatefulWidget {
  const _FallbackRevenueCatPaywallSheet();

  @override
  State<_FallbackRevenueCatPaywallSheet> createState() => _FallbackRevenueCatPaywallSheetState();
}

class _FallbackRevenueCatPaywallSheetState extends State<_FallbackRevenueCatPaywallSheet> {
  Offering? _offering;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final offering = await getCurrentOffering();
      if (!mounted) return;
      setState(() {
        _offering = offering;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load plans. Please try again.';
      });
      debugPrint('RevenueCat fallback offering error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _busy = true);
    try {
      final purchaseResult = await purchaseRevenueCatPackage(package);
      final unlocked = customerInfoHasActiveEntitlement(purchaseResult.customerInfo);
      if (!mounted) return;
      if (unlocked) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase completed but entitlement is not active yet.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final customerInfo = await restoreRevenueCatPurchases();
      final unlocked = customerInfoHasActiveEntitlement(customerInfo);
      if (!mounted) return;
      if (unlocked) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No active subscription to restore.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = _offering?.availablePackages ?? const <Package>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  FilledButton.tonal(onPressed: _loadOffering, child: const Text('Retry')),
                ],
              )
            else if (packages.isEmpty)
              const Text('No plans available. Configure your current offering in RevenueCat.')
            else
              ...packages.map((pkg) {
                final product = pkg.storeProduct;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: FilledButton(
                      onPressed: _busy ? null : () => _purchase(pkg),
                      child: Text(product.priceString),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 6),
            TextButton(onPressed: _busy ? null : _restore, child: const Text('Restore purchases')),
          ],
        ),
      ),
    );
  }
}
