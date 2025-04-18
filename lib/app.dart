import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'src/core/theme/theme_service.dart';
import 'src/routes/app_pages.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/utils/initial_bindings.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Initialize controller
  @override
  Widget build(BuildContext context) {
    final ThemeService _themeService = ThemeService();

    return GetMaterialApp(
      title: "Zarity",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.themeMode,
      initialBinding: InitialBindings(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
