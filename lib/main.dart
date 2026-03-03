import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ui_kit_google_mobile_ads/flutter_ui_kit_google_mobile_ads.dart';

import 'core/theme/app_theme.dart';
import 'features/history/data/history_repository.dart';
import 'features/timecode_calculator/presentation/timecode_calculator_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HistoryRepository.init();

  // 초기 광고 로드 (콜드 스타트 시 첫 포그라운드에서 바로 표시 가능하도록)
  GlobalAdConfig().initialize();
  AppOpenAdManager.instance.configure(
    androidId: 'ca-app-pub-4656262305566191/6332542118',
    iosId: 'ca-app-pub-4656262305566191/3218100671'
  );

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
          home: TimecodeCalculatorScreen(),
        );
      },
    );
  }
}

