import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage/market_cache.dart';

import '../features/markets/controllers/market_controller.dart';
import '../features/markets/repositories/market_repository.dart';
import '../features/markets/services/market_api_service.dart';
import '../features/location/controllers/location_controller.dart';

import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'splash_screen.dart';

class SonexaApp extends StatelessWidget {
  const SonexaApp({super.key, this.storageAvailable = false});
  final bool storageAvailable;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Sonexa',
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      final cache = storageAvailable
          ? MarketCache.persistent(GetStorage())
          : MarketCache.memory();
      Get.put(
        LocationController(storage: storageAvailable ? GetStorage() : null),
      );
      Get.put(MarketController(MarketRepository(MarketApiService(), cache)));
    }),
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    // The supplied design is a light pastel interface. Do not let Android's
    // system dark mode apply dark foregrounds to its pastel surfaces.
    themeMode: ThemeMode.light,
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.paper,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
      child: child ?? const SizedBox.shrink(),
    ),
    home: const SonexaSplashScreen(),
  );
}
