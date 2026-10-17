import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/market_controller.dart';

class MarketView extends StatelessWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Get.find<MarketController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.ink),
              ),
              child: const Icon(Icons.show_chart_rounded),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Markets',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Gold and silver · indicative INR quotes',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh rates',
              onPressed: market.refreshPrices,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E6ED)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF8B6A28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    market.statusMessage,
                    style: const TextStyle(fontSize: 12, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (market.state.value == MarketLoadState.loading &&
              market.prices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    SizedBox(width: 180, child: LinearProgressIndicator()),
                    SizedBox(height: 12),
                    Text('Loading market rates…'),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              _QuoteTile(
                title: 'Gold · 24K reference',
                price: market.priceText('gold', 'buy'),
                change: market.changeText('gold', 'buy'),
                color: AppColors.mint,
              ),
              _QuoteTile(
                title: 'Gold · 22K reference',
                price: market.priceText('gold', 'sell'),
                change: market.changeText('gold', 'sell'),
                color: AppColors.pink,
              ),
              _QuoteTile(
                title: 'Silver · reference',
                price: market.priceText('silver', 'buy'),
                change: market.changeText('silver', 'buy'),
                color: AppColors.blue,
              ),
              _QuoteTile(
                title: 'Silver · reference',
                price: market.priceText('silver', 'sell'),
                change: market.changeText('silver', 'sell'),
                color: const Color(0xFFFFDDA8),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        const Text(
          'Indicative INR reference prices, not dealer buy/sell quotes. City selection does not add local jewellery premiums; taxes and making charges may differ.',
          style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        const Text(
          'Rate data: GoldPrice.dev · free keyless INR reference feed',
          style: TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({
    required this.title,
    required this.price,
    required this.change,
    required this.color,
  });

  final String title;
  final String price;
  final String change;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.ink),
      boxShadow: const [
        BoxShadow(color: Color(0x20242735), offset: Offset(2, 3)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Text('INR per gram', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        Text(
          change,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
