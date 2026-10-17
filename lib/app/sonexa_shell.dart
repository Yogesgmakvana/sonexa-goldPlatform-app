import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/calculators/views/calculators_view.dart';
import '../features/home/views/home_view.dart';
import '../features/markets/views/markets_view.dart';
import '../features/settings/views/settings_view.dart';
import '../features/location/controllers/location_controller.dart';
import 'theme/app_colors.dart';

class SonexaShell extends StatefulWidget {
  const SonexaShell({super.key});
  @override
  State<SonexaShell> createState() => _SonexaShellState();
}

class _SonexaShellState extends State<SonexaShell> {
  int _tab = 0;
  final _pages = const [
    HomeView(),
    MarketView(),
    CalculatorView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<LocationController>().requestPermissionOnLaunch();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(index: _tab, children: _pages),
        ),
      ),
    ),
    bottomNavigationBar: SizedBox(
      height: 80,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.lavender,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.show_chart_rounded),
                label: 'Markets',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                label: 'Calculators',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
