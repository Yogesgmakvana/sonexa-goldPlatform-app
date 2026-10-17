import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/widgets/sonexa_widgets.dart';
import '../../../core/widgets/market_price_skeleton.dart';
import '../../../core/widgets/in_app_web_page.dart';
import '../../markets/controllers/market_controller.dart';
import '../../location/controllers/location_controller.dart';
import '../../location/views/city_picker_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const axisStyle = TextStyle(fontSize: 9, color: Colors.black54);
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final _market = Get.find<MarketController>();
  final _location = Get.find<LocationController>();
  String range = '1W';
  String unit = '1 g';

  String _axisDate(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]}';

  void _openTradePage(BuildContext context, String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InAppWebPage(title: title, initialUrl: Uri.parse(url)),
      ),
    );
  }

  Widget _cityPill() => Obx(
    () => CityPill(
      city: _location.city.value,
      isLoading: _location.isLocating.value,
      onTap: () => showCityPicker(context, _location),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(
      child: SizedBox(
        width: constraints.maxWidth > 760 ? 760 : constraints.maxWidth,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.ink, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.asset(
                            'assets/sonexa_appicon.jpg',
                            fit: BoxFit.cover,
                            semanticLabel: 'Sonexa app icon',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SONEXA',
                              style: TextStyle(
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'METALS, AT A GLANCE',
                              style: TextStyle(
                                letterSpacing: 1.1,
                                fontSize: 9,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SonexaIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () =>
                            AppNotifier.show(context, 'You’re all caught up'),
                      ),
                      const SizedBox(width: 8),
                      SonexaIconButton(
                        icon: Icons.tune_rounded,
                        onTap: () => AppNotifier.show(context, 'Preferences'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final title = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good morning,',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Know your metals.',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: constraints.maxWidth < 350 ? 22 : 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.6,
                            ),
                          ),
                        ],
                      );
                      if (constraints.maxWidth < 390) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title,
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _cityPill(),
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: title),
                          _cityPill(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E8EF)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _market.state.value == MarketLoadState.error
                                ? Icons.error_outline
                                : _market.isShowingCache.value
                                ? Icons.cloud_done_outlined
                                : Icons.info_outline,
                            size: 15,
                            color: Color(0xFF8B6A28),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _market.statusMessage,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (_market.isConfigured ||
                              _market.state.value == MarketLoadState.error)
                            TextButton(
                              onPressed: _market.refreshPrices,
                              child: const Text(
                                'RETRY',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: .6,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8B6A28),
                                ),
                              ),
                            )
                          else
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: .6,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4A9672),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
                    decoration: BoxDecoration(
                      color: AppColors.lavender,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.ink, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33242735),
                          offset: Offset(3, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const heading = Text(
                              'Market snapshot',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            );
                            final selector = RangeSelector(
                              value: range,
                              onChanged: (v) {
                                setState(() => range = v);
                                _market.refreshHistory(
                                  city: _location.city.value,
                                  range: v,
                                );
                              },
                            );
                            if (constraints.maxWidth < 370) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  heading,
                                  const SizedBox(height: 9),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: selector,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                const Expanded(child: heading),
                                selector,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 13),
                        Obx(() {
                          if (_market.state.value == MarketLoadState.loading) {
                            return const Row(
                              children: [
                                Expanded(child: MarketPriceSkeleton()),
                                SizedBox(width: 10),
                                Expanded(child: MarketPriceSkeleton()),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: MetricCard(
                                  label: 'GOLD · 24K',
                                  value: _market.priceText('gold', 'buy'),
                                  unit: 'per gram',
                                  change: _market.changeText('gold', 'buy'),
                                  color: AppColors.mint,
                                  icon: Icons.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: MetricCard(
                                  label: 'SILVER · SPOT',
                                  value: _market.priceText('silver', 'buy'),
                                  unit: 'per gram',
                                  change: _market.changeText('silver', 'buy'),
                                  color: AppColors.blue,
                                  icon: Icons.circle,
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Obx(() {
                          if (_market.state.value == MarketLoadState.loading) {
                            return const Row(
                              children: [
                                Expanded(child: MarketPriceSkeleton()),
                                SizedBox(width: 10),
                                Expanded(child: MarketPriceSkeleton()),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: MetricCard(
                                  label: 'GOLD · 22K',
                                  value: _market.priceText('gold', 'sell'),
                                  unit: 'per gram',
                                  change: _market.changeText('gold', 'sell'),
                                  color: AppColors.pink,
                                  icon: Icons.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: MetricCard(
                                  label: 'SILVER · SPOT / KG',
                                  value: _market.priceText(
                                    'silver',
                                    'sell',
                                    multiplier: 1000,
                                  ),
                                  unit: 'per kilogram',
                                  change: _market.changeText('silver', 'sell'),
                                  color: Color(0xFFFFDDA8),
                                  icon: Icons.circle,
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        const Text(
                          'WEIGHT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          children: ['1 g', '8 g', '10 g', '100 g', '1 kg']
                              .map(
                                (w) => ChoiceChip(
                                  label: Text(w),
                                  selected: unit == w,
                                  onSelected: (_) => setState(() => unit = w),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  labelStyle: TextStyle(
                                    fontSize: 10,
                                    color: unit == w
                                        ? AppColors.ink
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  selectedColor: AppColors.lemon,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: .7,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.ink.withValues(alpha: .22),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 21),
                  SectionHeading(
                    title: 'Price performance',
                    action: 'View trends',
                    onTap: () => AppNotifier.show(
                      context,
                      'Open Markets for detailed trends',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.ink, width: 1.1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26242735),
                          offset: Offset(3, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Gold · 24K INR reference',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A9672),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Obx(
                              () => Text(
                                _market.prices.isEmpty
                                    ? 'NO DATA'
                                    : _market.isShowingCache.value
                                    ? 'SAVED'
                                    : _market.state.value ==
                                          MarketLoadState.error
                                    ? 'OFFLINE'
                                    : _market.state.value ==
                                          MarketLoadState.loading
                                    ? 'UPDATING'
                                    : 'LIVE',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(height: 8),
                        Obx(() {
                          if (_market.history.isEmpty &&
                              _market.isHistoryLoading.value) {
                            return const SizedBox(
                              height: 112,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (_market.history.isEmpty) {
                            return SizedBox(
                              height: 112,
                              child: Center(
                                child: InkWell(
                                  onTap: () => _market.refreshHistory(
                                    city: _location.city.value,
                                    range: range,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _market.historyError.value.isEmpty
                                              ? 'Chart data unavailable.'
                                              : _market.historyError.value,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'TAP TO RETRY',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          final points = _market.history.toList();
                          final values = points
                              .map((point) => point.price)
                              .toList(growable: false);
                          return Column(
                            children: [
                              if (_market.isHistoryLoading.value)
                                const LinearProgressIndicator(minHeight: 2),
                              SizedBox(
                                height: 112,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: MarketChartPainter(values: values),
                                ),
                              ),
                              if (points.length > 1)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _axisDate(points.first.date),
                                      style: axisStyle,
                                    ),
                                    Text(
                                      _axisDate(
                                        points[points.length ~/ 2].date,
                                      ),
                                      style: axisStyle,
                                    ),
                                    Text(
                                      _axisDate(points.last.date),
                                      style: axisStyle,
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  'Daily provider data · no intraday points',
                                  style: axisStyle,
                                ),
                              if (_market.historyError.value.isNotEmpty)
                                Text(
                                  _market.historyError.value,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 21),
                  SectionHeading(
                    title: 'Quick actions',
                    action: 'See all',
                    onTap: () =>
                        AppNotifier.show(context, 'More tools coming soon'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 96,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ActionTile(
                          icon: Icons.diamond_outlined,
                          label: 'Jewellery\ncalculator',
                          color: AppColors.pink,
                          onTap: () =>
                              AppNotifier.show(context, 'Jewellery calculator'),
                        ),
                        ActionTile(
                          icon: Icons.savings_outlined,
                          label: 'Investment\ncalculator',
                          color: AppColors.blue,
                          onTap: () => AppNotifier.show(
                            context,
                            'Investment calculator',
                          ),
                        ),
                        ActionTile(
                          icon: Icons.notifications_active_outlined,
                          label: 'Price\nalerts',
                          color: AppColors.lemon,
                          onTap: () =>
                              AppNotifier.show(context, 'No active alerts'),
                        ),
                        ActionTile(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Metal\nconverter',
                          color: AppColors.mint,
                          onTap: () =>
                              AppNotifier.show(context, 'Metal converter'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeading(
                    title: 'Market watch',
                    action: 'View all',
                    onTap: () => AppNotifier.show(context, 'Open Markets'),
                  ),
                  const SizedBox(height: 9),
                  Obx(
                    () => WatchRow(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Gold · 24K reference',
                      subtitle: 'Open Tanishq Digital Gold · buy',
                      tint: AppColors.lemon,
                      value: _market.priceText('gold', 'buy'),
                      onTap: () => _openTradePage(
                        context,
                        'Buy gold',
                        'https://www.tanishq.co.in/digigold/buy?buy-goldgrm=1&buy-goldinr=1&buyGoldOpt=grm',
                      ),
                    ),
                  ),
                  WatchRow(
                    icon: Icons.sell_outlined,
                    title: 'Gold · sell option',
                    subtitle: 'Sell Tanishq Digital Gold',
                    tint: AppColors.pink,
                    value: 'OPEN',
                    onTap: () => _openTradePage(
                      context,
                      'Sell gold',
                      'https://www.tanishq.co.in/digigold/sell?lang=en',
                    ),
                  ),
                  Obx(
                    () => WatchRow(
                      icon: Icons.circle_outlined,
                      title: 'Silver · spot reference',
                      subtitle: 'Shop MMTC-PAMP silver',
                      tint: AppColors.blue,
                      value: _market.priceText('silver', 'buy'),
                      onTap: () => _openTradePage(
                        context,
                        'Buy silver',
                        'https://www.mmtcpamp.com/shop',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Indicative provider quotes may differ from local jewellers. City lookup © OpenStreetMap contributors.',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
