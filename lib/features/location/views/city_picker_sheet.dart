import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:math' as math;

import '../../../app/theme/app_colors.dart';
import '../../markets/controllers/market_controller.dart';
import '../controllers/location_controller.dart';

Future<void> showCityPicker(
  BuildContext context,
  LocationController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  builder: (_) => CityPickerSheet(controller: controller),
);

class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({super.key, required this.controller});
  final LocationController controller;

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  late final TextEditingController _searchController;
  static const _popularCities = [
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Chennai',
    'Hyderabad',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _select(String city) async {
    await widget.controller.selectCity(city);
    if (!mounted) return;
    final market = Get.find<MarketController>();
    Navigator.of(context).pop();
    await market.refreshPrices(city: city);
    await market.refreshHistory(city: city, range: market.historyRange.value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = MediaQuery.sizeOf(context).height - bottomInset;
    final sheetHeight = math.min(
      700.0,
      math.max(math.min(160.0, availableHeight), availableHeight * .88),
    );
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose location',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Obx(
                          () => Text(
                            'Current city · ${widget.controller.city.value}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: widget.controller.searchCities,
                decoration: InputDecoration(
                  hintText: 'Search city',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(
                    () => widget.controller.isSearchingCities.value
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _searchController.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.searchCities('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppColors.ink.withValues(alpha: .15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppColors.ink.withValues(alpha: .15),
                    ),
                  ),
                ),
              ),
            ),
            if (bottomInset == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Obx(
                  () => InkWell(
                    onTap: widget.controller.isLocating.value
                        ? null
                        : widget.controller.useCurrentLocation,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lemon,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.ink),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded, size: 19),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Use my current location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (widget.controller.isLocating.value)
                            const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Obx(() {
              final message = widget.controller.locationError.value;
              if (message.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B4D36),
                  ),
                ),
              );
            }),
            if (bottomInset == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'INDIA-WIDE OR CITY RATES',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      'OpenStreetMap',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.ink.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Obx(() {
                final query = _searchController.text.trim();
                final results = widget.controller.citySuggestions;
                final isSearching = widget.controller.isSearchingCities.value;
                final list = query.length >= 2
                    ? results.toList()
                    : ['India', ..._popularCities];
                if (query.length >= 2 && list.isEmpty && isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                  itemCount: list.length + (query.length >= 2 ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    if (index == list.length && query.length >= 2) {
                      return ListTile(
                        onTap: () => _select(query),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        tileColor: AppColors.lavender.withValues(alpha: .65),
                        leading: const Icon(Icons.edit_location_alt_outlined),
                        title: Text('Use “$query”'),
                        subtitle: const Text('Set this city manually'),
                      );
                    }
                    final name = list[index];
                    return ListTile(
                      onTap: () => _select(name),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      tileColor: Colors.white,
                      leading: const Icon(Icons.location_city_outlined),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    );
                  },
                );
              }),
            ),
            if (bottomInset == 0)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'City lookup © OpenStreetMap contributors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Colors.black45),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
