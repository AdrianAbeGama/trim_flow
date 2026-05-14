import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'profile_premium_card.dart';

class ProfileHistoryCard extends StatelessWidget {
  final List<CuttingRecord> history;
  final bool isExpanded;
  final VoidCallback onTap;

  const ProfileHistoryCard({
    super.key,
    required this.history,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePremiumCard(
      title: 'HISTORIAL',
      subtitle: 'Tus últimos cortes realizados',
      isExpanded: isExpanded,
      onTap: onTap,
      children: [
        const SizedBox(height: 16),
        ...history.map((record) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.day, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(record.time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(record.price, style: TextStyle(color: context.primaryGold, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 20),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
