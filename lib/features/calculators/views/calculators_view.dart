import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});
  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  int _selected = 0;
  final _weight = TextEditingController();
  final _rate = TextEditingController();
  final _making = TextEditingController(text: '10');
  final _wastage = TextEditingController(text: '0');
  final _gst = TextEditingController(text: '3');
  final _investment = TextEditingController();
  final _buyRate = TextEditingController();
  final _currentRate = TextEditingController();
  final _grams = TextEditingController();
  String _purity = '24K';
  String _metal = 'Gold';

  @override
  void dispose() {
    for (final c in [
      _weight,
      _rate,
      _making,
      _wastage,
      _gst,
      _investment,
      _buyRate,
      _currentRate,
      _grams,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim()) ?? 0;
    return parsed.isFinite && parsed > 0 ? parsed : 0;
  }

  String _inr(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
    children: [
      const Text(
        'Calculators',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Estimate costs and quantities with rates you provide.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      const SizedBox(height: 18),
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(
            value: 0,
            label: Text('Jewellery'),
            icon: Icon(Icons.diamond_outlined),
          ),
          ButtonSegment(
            value: 1,
            label: Text('Investment'),
            icon: Icon(Icons.savings_outlined),
          ),
          ButtonSegment(
            value: 2,
            label: Text('Convert'),
            icon: Icon(Icons.swap_horiz_rounded),
          ),
        ],
        selected: {_selected},
        onSelectionChanged: (value) => setState(() => _selected = value.first),
        showSelectedIcon: false,
      ),
      const SizedBox(height: 18),
      if (_selected == 0) _jewelleryCard(),
      if (_selected == 1) _investmentCard(),
      if (_selected == 2) _converterCard(),
    ],
  );

  Widget _jewelleryCard() {
    final weight = _number(_weight);
    final rate = _number(_rate);
    final base = weight * rate;
    final wastageCost = base * _number(_wastage) / 100;
    final makingCost = base * _number(_making) / 100;
    final taxable = base + wastageCost + makingCost;
    final tax = taxable * _number(_gst) / 100;
    final total = taxable + tax;
    return _panel(AppColors.pink, [
      _select('Metal', _metal, [
        'Gold',
        'Silver',
      ], (v) => setState(() => _metal = v)),
      _select('Purity', _purity, [
        '24K',
        '22K',
        '18K',
      ], (v) => setState(() => _purity = v)),
      _field(_weight, 'Weight', suffix: 'g'),
      _field(_rate, 'Rate per gram', suffix: '₹/g'),
      _field(_making, 'Making charges', suffix: '%'),
      _field(_wastage, 'Wastage', suffix: '%'),
      _field(_gst, 'GST', suffix: '%'),
      const Divider(height: 26),
      _result('Metal value', _inr(base)),
      _result('Wastage', _inr(wastageCost)),
      _result('Making charges', _inr(makingCost)),
      _result('GST on metal, wastage and making', _inr(tax)),
      const SizedBox(height: 8),
      _result('Estimated total', _inr(total), strong: true),
      const SizedBox(height: 10),
      const Text(
        'Estimate only. Jeweller pricing, stone costs and tax treatment can vary.',
        style: TextStyle(fontSize: 10, color: Colors.black54),
      ),
    ]);
  }

  Widget _investmentCard() {
    final amount = _number(_investment);
    final buyRate = _number(_buyRate);
    final currentRate = _number(_currentRate);
    final quantity = buyRate > 0 ? amount / buyRate : 0.0;
    final currentValue = quantity * currentRate;
    final pnl = currentValue - amount;
    final pct = amount > 0 ? pnl / amount * 100 : 0.0;
    return _panel(AppColors.blue, [
      _select('Metal', _metal, [
        'Gold',
        'Silver',
      ], (v) => setState(() => _metal = v)),
      _field(_investment, 'Investment amount', suffix: '₹'),
      _field(_buyRate, 'Purchase rate', suffix: '₹/g'),
      _field(_currentRate, 'Current indicative rate', suffix: '₹/g'),
      const Divider(height: 26),
      _result('Estimated quantity', '${quantity.toStringAsFixed(3)} g'),
      _result('Current indicative value', _inr(currentValue)),
      _result(
        'Estimated profit / loss',
        '${pnl < 0 ? '−' : '+'}${_inr(pnl.abs())}',
      ),
      _result('Estimated return', '${pct.toStringAsFixed(2)}%'),
      const SizedBox(height: 10),
      const Text(
        'Excludes taxes, spreads, resale deductions and transaction costs.',
        style: TextStyle(fontSize: 10, color: Colors.black54),
      ),
    ]);
  }

  Widget _converterCard() {
    final grams = _number(_grams);
    final pureFraction = switch (_purity) {
      '24K' => 1.0,
      '22K' => 22 / 24,
      _ => 18 / 24,
    };
    return _panel(AppColors.mint, [
      _select('Metal', _metal, [
        'Gold',
        'Silver',
      ], (v) => setState(() => _metal = v)),
      _select('Purity', _purity, [
        '24K',
        '22K',
        '18K',
      ], (v) => setState(() => _purity = v)),
      _field(_grams, 'Weight', suffix: 'g'),
      const Divider(height: 26),
      _result('Entered weight', '${grams.toStringAsFixed(3)} g'),
      _result(
        'Pure-metal equivalent',
        '${(grams * pureFraction).toStringAsFixed(3)} g',
      ),
      _result('Purity fraction', '${(pureFraction * 100).toStringAsFixed(2)}%'),
      const SizedBox(height: 10),
      const Text(
        'Purity conversion uses the stated karat fraction; it is not an assay.',
        style: TextStyle(fontSize: 10, color: Colors.black54),
      ),
    ]);
  }

  Widget _panel(Color color, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.ink, width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x24242735), offset: Offset(3, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    required String suffix,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    ),
  );

  Widget _select(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: options
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );

  Widget _result(String label, String value, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: strong ? 13 : 11,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: strong ? 16 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
