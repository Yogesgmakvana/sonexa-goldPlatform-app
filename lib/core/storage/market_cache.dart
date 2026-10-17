import 'package:get_storage/get_storage.dart';

import '../../features/markets/models/market_price.dart';

class CachedMarketSnapshot {
  const CachedMarketSnapshot({required this.prices, required this.savedAt});
  final List<MarketPrice> prices;
  final DateTime savedAt;
  bool get isStale =>
      DateTime.now().difference(savedAt) > const Duration(minutes: 15);
}

class MarketCache {
  MarketCache.persistent(GetStorage storage) : _storage = storage;
  MarketCache.memory() : _storage = null;

  final GetStorage? _storage;
  final Map<String, dynamic> _memory = {};
  static const _cacheKey = 'market_snapshot_v1';

  CachedMarketSnapshot? read() {
    final data =
        _storage?.read<Map<dynamic, dynamic>>(_cacheKey) ??
        _memory[_cacheKey] as Map<dynamic, dynamic>?;
    if (data == null ||
        data['prices'] is! List ||
        data['saved_at'] is! String) {
      return null;
    }
    final savedAt = DateTime.tryParse(data['saved_at'] as String);
    if (savedAt == null) return null;
    try {
      final prices = (data['prices'] as List)
          .whereType<Map>()
          .map((row) => MarketPrice.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
      if (prices.isEmpty) return null;
      return CachedMarketSnapshot(prices: prices, savedAt: savedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<MarketPrice> prices) {
    final snapshot = {
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'prices': prices
          .map(
            (price) => {
              'metal': price.metal,
              'purity': price.purity,
              'price_per_gram_inr': price.pricePerGramInr,
              'change_percent': price.changePercent,
              'updated_at': price.updatedAt?.toIso8601String(),
              'source': price.source,
            },
          )
          .toList(growable: false),
    };
    if (_storage == null) {
      _memory[_cacheKey] = snapshot;
      return Future.value();
    }
    return _storage.write(_cacheKey, snapshot);
  }

  Future<void> clear() async {
    if (_storage == null) {
      _memory.remove(_cacheKey);
      return;
    }
    await _storage.remove(_cacheKey);
  }
}
