import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 하단 고정 배너 광고 위젯.
///
/// 광고 로드 전/실패 시에는 공간을 차지하지 않음(SizedBox.shrink).
/// 로드 성공 시 50dp 높이의 배너를 표시하며, SafeArea로 시스템 내비게이션 바를 회피.
///
/// 실제 AdMob 광고 단위 ID는 출시 전 [_adUnitId]를 교체해야 한다.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // TODO: 실제 출시 전 AdMob 콘솔에서 발급받은 광고 단위 ID로 교체
  static String get _adUnitId {
    if (Platform.isAndroid) {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 배너
      }
      return 'ca-app-pub-4656262305566191/7150799760';
    } else {
      if(kDebugMode){
        return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너
      }
      return 'ca-app-pub-4656262305566191/3002478255';
      
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
