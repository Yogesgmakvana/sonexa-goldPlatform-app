import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../location/controllers/location_controller.dart';
import '../../location/views/city_picker_sheet.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Get.find<LocationController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.ink),
              ),
              child: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Make Sonexa feel like yours.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'LOCATION',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: () => showCityPicker(context, location),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.lemon,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ink),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current city',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          location.city.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (location.isLocating.value)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.my_location_outlined, size: 20),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            'Sonexa asks for location access when the app opens to detect your city. You can choose another city at any time. © OpenStreetMap contributors.',
            style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market data',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 5),
              Text(
                'Gold and silver reference prices: GoldPrice.dev free tier. No API key required. Quotes are INR spot references, not city jewellery buy/sell offers.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
