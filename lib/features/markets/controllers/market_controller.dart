import 'dart:async';

import 'package:get/get.dart';

import '../models/market_price.dart';
import '../models/market_history_point.dart';
import '../repositories/market_repository.dart';
import '../services/market_api_service.dart';
import '../../location/controllers/location_controller.dart';

enum MarketLoadState { unconfigured, loading, ready, error }

class MarketController extends GetxController {
  MarketController(this._repository);
  final MarketRepository _repository;
  bool get isConfigured => _repository.isConfigured;

  final prices = <MarketPrice>[].obs;
  final state = MarketLoadState.unconfigured.obs;
  final errorMessage = ''.obs;
  final lastUpdated = Rxn<DateTime>();
  final isShowingCache = false.obs;
  final isCacheStale = false.obs;
  final history = <MarketHistoryPoint>[].obs;
  final isHistoryLoading = false.obs;
  final historyError = ''.obs;
  final historyRange = '1W'.obs;
  String _selectedCity = 'India';
  int _historyRequestId = 0;

  String get statusMessage {
    if (state.value == MarketLoadState.error && isShowingCache.value) {
      return 'Refresh failed. Showing previously saved prices.';
    }
    if (state.value == MarketLoadState.error) return errorMessage.value;
    if (state.value == MarketLoadState.loading) {
      return 'Updating market prices…';
    }
    if (state.value == MarketLoadState.ready && !isShowingCache.value) {
      return lastUpdated.value == null
          ? 'GoldPrice.dev INR reference quotes · city premiums unavailable'
          : 'GoldPrice.dev INR reference · ${lastUpdated.value!.toLocal().toString().substring(0, 16)}${_selectedCity == 'India' ? '' : ' · city rates unavailable; showing reference prices'}';
    }
    if (isShowingCache.value && lastUpdated.value != null) {
      final label = isCacheStale.value ? 'Stale saved prices' : 'Saved prices';
      return '$label · ${lastUpdated.value!.toLocal().toString().substring(0, 16)}';
    }
    return 'Connect a market data provider to see current prices.';
  }

  String priceText(String metal, String purity, {double multiplier = 1}) {
    const purityAliases = {
      '24k': {'24k', '999', '999.9'},
      '22k': {'22k', '916', '91.6'},
      '18k': {'18k', '750', '75.0'},
    };
    var normalized = purity.toLowerCase();
    if (metal.toLowerCase() == 'gold') {
      normalized = normalized == 'buy'
          ? '24k'
          : normalized == 'sell'
          ? '22k'
          : normalized;
    } else if (metal.toLowerCase() == 'silver') {
      normalized = 'spot';
    }
    final acceptedPurities = normalized == 'buy' || normalized == 'sell'
        ? {normalized}
        : purityAliases[normalized] ?? {normalized};
    final match = prices.where(
      (price) =>
          price.metal.toLowerCase() == metal.toLowerCase() &&
          (purity.isEmpty ||
              acceptedPurities.contains(price.purity?.toLowerCase())),
    );
    if (match.isEmpty || match.first.pricePerGramInr == null) return '—';
    return '₹${(match.first.pricePerGramInr! * multiplier).toStringAsFixed(2)}';
  }

  String changeText(String metal, String purity) {
    var normalized = purity.toLowerCase();
    if (metal.toLowerCase() == 'gold') {
      normalized = normalized == 'buy'
          ? '24k'
          : normalized == 'sell'
          ? '22k'
          : normalized;
    } else if (metal.toLowerCase() == 'silver') {
      normalized = 'spot';
    }
    final accepted = switch (normalized) {
      'buy' || 'sell' => {normalized},
      '24k' => {'24k', '999', '999.9'},
      '22k' => {'22k', '916', '91.6'},
      '18k' => {'18k', '750', '75.0'},
      _ => {purity.toLowerCase()},
    };
    final match = prices.where(
      (price) =>
          price.metal.toLowerCase() == metal.toLowerCase() &&
          (purity.isEmpty || accepted.contains(price.purity?.toLowerCase())),
    );
    if (match.isEmpty || match.first.changePercent == null) {
      return 'Change unavailable';
    }
    final change = match.first.changePercent!;
    final prefix = change > 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(2)}%';
  }

  @override
  void onInit() {
    super.onInit();
    final cached = _repository.loadCachedPrices();
    if (cached != null) {
      prices.assignAll(cached.prices);
      lastUpdated.value = cached.savedAt;
      isShowingCache.value = true;
      isCacheStale.value = cached.isStale;
      state.value = MarketLoadState.ready;
    }
    if (_repository.isConfigured) {
      final city = Get.find<LocationController>().city.value;
      refreshPrices(city: city);
      refreshHistory(city: city, range: historyRange.value);
    }
  }

  Future<void> refreshPrices({String city = 'India'}) async {
    if (!_repository.isConfigured) {
      state.value = MarketLoadState.unconfigured;
      return;
    }
    state.value = MarketLoadState.loading;
    errorMessage.value = '';
    try {
      final loaded = await _repository.loadPrices(city: city);
      prices.assignAll(loaded);
      _selectedCity = city;
      lastUpdated.value = prices.isEmpty
          ? DateTime.now()
          : prices.first.updatedAt ?? DateTime.now();
      isShowingCache.value = false;
      isCacheStale.value = false;
      state.value = MarketLoadState.ready;
    } on MarketApiException catch (error) {
      if (city != 'India') {
        try {
          prices.assignAll(await _repository.loadPrices());
          lastUpdated.value = prices.isEmpty
              ? DateTime.now()
              : prices.first.updatedAt ?? DateTime.now();
          _selectedCity = city;
          isShowingCache.value = false;
          isCacheStale.value = false;
        } catch (_) {
          // Leave the last known prices visible if both providers are down.
        }
      }
      errorMessage.value = city == 'India'
          ? error.message
          : '${error.message} Showing India-wide rates instead.';
      state.value = MarketLoadState.error;
    } catch (_) {
      errorMessage.value = 'Market prices could not be loaded. Try again.';
      state.value = MarketLoadState.error;
    }
  }

  Future<void> refreshHistory({
    required String city,
    required String range,
  }) async {
    final requestId = ++_historyRequestId;
    historyRange.value = range;
    historyError.value = '';
    isHistoryLoading.value = true;
    try {
      final points = await _repository
          .loadGoldHistory(range: range)
          .timeout(const Duration(seconds: 8));
      if (requestId != _historyRequestId) return;
      history.assignAll(points);
      if (range == '1D' && history.length == 1) {
        historyError.value =
            'The provider supplies daily points, not intraday history.';
      }
    } on MarketApiException catch (error) {
      if (requestId != _historyRequestId) return;
      historyError.value = error.message;
    } on TimeoutException {
      if (requestId != _historyRequestId) return;
      historyError.value = 'Chart data is taking too long. Tap to retry.';
    } catch (_) {
      if (requestId != _historyRequestId) return;
      historyError.value = 'Historical prices could not be loaded. Try again.';
    } finally {
      if (requestId == _historyRequestId) isHistoryLoading.value = false;
    }
  }
}
