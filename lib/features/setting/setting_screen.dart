import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ui_kit_setting/flutter_ui_kit_setting.dart';
import 'package:flutter_ui_kit_theme/flutter_ui_kit_theme.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({
    super.key, 
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.brand,
    required this.onBrandChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final DsBrand brand;
  final ValueChanged<DsBrand> onBrandChanged;

  @override
  State<AppSettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<AppSettingScreen> {
  late ThemeMode _themeMode;
  late DsBrand _brand;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _brand = widget.brand;
  }

  @override
  Widget build(BuildContext context) {
    return SettingScreen(
      title: 'Setting',
      sections: [
        ...buildDefaultSettingSections(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) {
            setState(() => _themeMode = mode);
            widget.onThemeModeChanged(mode);
          },
          brand: _brand,
          onBrandChanged: (brand) {
            setState(() => _brand = brand);
            widget.onBrandChanged(brand);
          },
          developerEmail: 'juny3738@gmail.com',
          emailSubject: '[Frame Time Pro] Questions',
          shareText: 'http://juny.blog/redirect/app/store/name/frame-time-pro',
          appStoreUrl: Platform.isIOS ? 'https://apps.apple.com/us/app/frame-time-pro/id6759611898' : null,
          playStoreUrl: Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=juny.frame_time_pro' : null,
          showAppVersion: true,
          showBuildNumber: true,
          homepageUrl: 'https://juny.blog/blog/4743110c-39cf-4c1a-b8f7-059958c4dd45',
          appName: 'Frame Time Pro',
          appDescription: 'SMPTE Frame & Timecode Tool'
        )
      ],
    );
  }
}