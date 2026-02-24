import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/ads/app_open_ad_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/timecode_calculator/presentation/timecode_calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  // 초기 광고 로드 (콜드 스타트 시 첫 포그라운드에서 바로 표시 가능하도록)
  AppOpenAdManager.instance.loadAd();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: const _AppLifecycleReactor(
            child: TimecodeCalculatorScreen(),
          ),
        );
      },
    );
  }
}

/// 앱 포그라운드 복귀 시 App Open 광고를 표시하는 라이프사이클 감지 위젯.
class _AppLifecycleReactor extends StatefulWidget {
  const _AppLifecycleReactor({required this.child});

  final Widget child;

  @override
  State<_AppLifecycleReactor> createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<_AppLifecycleReactor> {
  late final StreamSubscription<AppState> _subscription;

  @override
  void initState() {
    super.initState();
    AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen(_onAppState);
  }

  void _onAppState(AppState state) {
    if (state == AppState.foreground) {
      AppOpenAdManager.instance.showAdIfAvailable();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
