import 'package:dio/dio.dart';

import '../models/market_history_point.dart';

class MarketApiException implements Exception {
  const MarketApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Keyless INR reference prices and daily history from GoldPrice.dev.
class MarketApiService {
  MarketApiService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;
  static const _goldEndpoint = 'https://api.goldprice.dev/v1/carat';
  static const _silverEndpoint = 'https://api.goldprice.dev/v1/convert';
  static const _spotEndpoint = 'https://api.goldprice.dev/v1/spot/XAU-USD-SPOT';
  static const _historyEndpoint = 'https://api.goldprice.dev/v1/bars';
  static const _gramsPerTroyOunce = 31.1034768;
  static const _apiKey = String.fromEnvironment('GOLDPRICE_API_KEY');

  static Dio _createDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept': 'application/json',
        if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
      },
    ),
  );

  bool get isConfigured => true;

  Future<List<MarketHistoryPoint>> fetchGoldHistory({
    required String range,
  }) async {
    if (range == '1Y') {
      throw const MarketApiException(
        'The free history feed covers 30 days. Choose 30D or a shorter range.',
      );
    }
    final now = DateTime.now().toUtc();
    final days = switch (range) {
      '1D' => 1,
      '1W' => 7,
      '30D' => 30,
      _ => 30,
    };
    final from = now.subtract(Duration(days: days - 1));
    String dateKey(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final responses = await Future.wait([
      _dio.get<dynamic>(
        _historyEndpoint,
        queryParameters: {
          'symbol': 'XAU-USD-SPOT',
          'interval': '1d',
          'from': dateKey(from),
          'to': dateKey(now),
          'limit': 100,
        },
      ),
      _dio.get<dynamic>(_goldEndpoint, queryParameters: {'currency': 'INR'}),
      _dio.get<dynamic>(_spotEndpoint),
    ]);
    final historyPayload = responses[0].data;
    final goldPayload = responses[1].data;
    final spotPayload = responses[2].data;
    final bars = historyPayload is Map ? historyPayload['bars'] : null;
    final inrPerGram = goldPayload is Map
        ? double.tryParse(goldPayload['price_gram_24k']?.toString() ?? '')
        : null;
    final usdPerOunce = spotPayload is Map
        ? double.tryParse(spotPayload['price']?.toString() ?? '')
        : null;
    if (bars is! List ||
        inrPerGram == null ||
        usdPerOunce == null ||
        usdPerOunce == 0) {
      throw const MarketApiException('Historical gold data is unavailable.');
    }
    final usdToInr = inrPerGram * _gramsPerTroyOunce / usdPerOunce;
    final points = <MarketHistoryPoint>[];
    for (final row in bars.whereType<Map>()) {
      final date = DateTime.tryParse(row['bar_start']?.toString() ?? '');
      final close = double.tryParse(row['close']?.toString() ?? '');
      if (date != null && close != null) {
        points.add(
          MarketHistoryPoint(
            date: date.toLocal(),
            price: close * usdToInr / _gramsPerTroyOunce,
          ),
        );
      }
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    if (points.isEmpty) {
      throw const MarketApiException(
        'No historical gold points were returned.',
      );
    }
    return points;
  }

  Future<List<Map<String, dynamic>>> fetchPrices({
    CancelToken? cancelToken,
  }) async {
    try {
      final responses = await Future.wait([
        _dio.get<dynamic>(
          _goldEndpoint,
          queryParameters: {'currency': 'INR'},
          cancelToken: cancelToken,
        ),
        _dio.get<dynamic>(
          _silverEndpoint,
          queryParameters: {
            'from': 'XAG',
            'to': 'INR',
            'amount': 1,
            'unit': 'gram',
          },
          cancelToken: cancelToken,
        ),
      ]);
      final gold = responses[0].data;
      final silver = responses[1].data;
      if (gold is! Map || silver is! Map) {
        throw const MarketApiException(
          'GoldPrice.dev returned an unexpected response.',
        );
      }
      final timestamp = gold['timestamp']?.toString();
      final rows = <Map<String, dynamic>>[];
      for (final purity in ['24k', '22k']) {
        final price = double.tryParse(
          gold['price_gram_$purity']?.toString() ?? '',
        );
        if (price == null) continue;
        rows.add({
          'metal': 'gold',
          'purity': purity,
          'price_per_gram_inr': price,
          'updated_at': timestamp,
          'source': 'GoldPrice.dev INR reference quote',
        });
      }
      final silverPerGram = double.tryParse(silver['result']?.toString() ?? '');
      if (silverPerGram != null) {
        rows.add({
          'metal': 'silver',
          'purity': 'spot',
          'price_per_gram_inr': silverPerGram,
          'updated_at': silver['timestamp']?.toString() ?? timestamp,
          'source': 'GoldPrice.dev INR silver reference quote',
        });
      }
      if (rows.length < 3) {
        throw const MarketApiException(
          'GoldPrice.dev returned incomplete rates.',
        );
      }
      return rows;
    } on DioException catch (error) {
      if (error.response?.statusCode == 429) {
        throw const MarketApiException(
          'Rate limit reached. Please wait a few minutes before refreshing.',
        );
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const MarketApiException(
          'The rate provider took too long to respond.',
        );
      }
      throw const MarketApiException('Rates could not be loaded. Try again.');
    }
  }
}
