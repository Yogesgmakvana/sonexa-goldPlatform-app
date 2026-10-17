import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable animated skeleton primitives for price, list, and chart loading states.
class ShimmerBlock extends StatefulWidget {
  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.radius = 10,
  });
  final double width, height, radius;
  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final start = -1.4 + _controller.value * 2.8;
        return LinearGradient(
          begin: Alignment(start, 0),
          end: Alignment(start + 1.4, 0),
          colors: const [
            Color(0xFFE8E9EF),
            Color(0xFFFFFFFF),
            Color(0xFFE8E9EF),
          ],
          stops: const [0.15, 0.5, 0.85],
        ).createShader(bounds);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E9EF),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    ),
  );
}

class MarketPriceSkeleton extends StatelessWidget {
  const MarketPriceSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.ink),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBlock(width: 92, height: 11),
        SizedBox(height: 16),
        ShimmerBlock(width: 128, height: 28),
        SizedBox(height: 8),
        ShimmerBlock(width: 72, height: 10),
      ],
    ),
  );
}

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.ink),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBlock(width: 110, height: 12),
        SizedBox(height: 14),
        Expanded(
          child: ShimmerBlock(width: double.infinity, height: 88, radius: 12),
        ),
      ],
    ),
  );
}
