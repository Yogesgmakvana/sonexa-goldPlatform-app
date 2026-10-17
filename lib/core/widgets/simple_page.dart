import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class SonexaFeaturePage extends StatelessWidget {
  const SonexaFeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.content,
    required this.note,
  });
  final String title, subtitle, note;
  final Color color;
  final IconData icon;
  final List<String> content;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.ink),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      ...content.map(
        (item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E6ED)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Text(
                '—',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B6A28),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          note,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.ink,
          ),
        ),
      ),
    ],
  );
}
