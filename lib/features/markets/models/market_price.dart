class MarketPrice {
  const MarketPrice({
    required this.metal,
    required this.pricePerGramInr,
    required this.updatedAt,
    this.purity,
    this.changePercent,
    this.source,
  });

  final String metal;
  final String? purity;
  final double? pricePerGramInr;
  final double? changePercent;
  final DateTime? updatedAt;
  final String? source;

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    DateTime? date(Object? value) =>
        value == null ? null : DateTime.tryParse(value.toString())?.toUtc();

    return MarketPrice(
      metal: json['metal']?.toString() ?? 'unknown',
      purity: json['purity']?.toString(),
      pricePerGramInr: number(json['price_per_gram_inr']),
      changePercent: number(json['change_percent']),
      updatedAt: date(json['updated_at']),
      source: json['source']?.toString(),
    );
  }
}
