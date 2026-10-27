import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google's public test banner unit. Replace with your own AdMob unit ID
/// before publishing; never click real ads in your own app.
const _bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

bool get adsSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

Future<void> initAds() async {
  if (!adsSupported) return;
  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // Ads are optional; the app works without them.
  }
}

/// A small banner shown on browsing screens only, never on checklists.
class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!adsSupported) return;
    _ad = BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
