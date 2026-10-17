import '../models/market_price.dart';
import '../models/market_history_point.dart';
import '../services/market_api_service.dart';
import '../../../core/storage/market_cache.dart';

class MarketRepository {
  const MarketRepository(this._api, this._cache);
  final MarketApiService _api;
  final MarketCache _cache;

  bool get isConfigured => _api.isConfigured;

  Future<List<MarketPrice>> loadPrices({String? city}) async {
    final rows = await _api.fetchPrices();
    final prices = rows.map(MarketPrice.fromJson).toList(growable: false);
    if (city == null || city == 'India') await _cache.write(prices);
    return prices;
  }

  Future<List<MarketHistoryPoint>> loadGoldHistory({required String range}) =>
      _api.fetchGoldHistory(range: range);

  CachedMarketSnapshot? loadCachedPrices() => _cache.read();
}
