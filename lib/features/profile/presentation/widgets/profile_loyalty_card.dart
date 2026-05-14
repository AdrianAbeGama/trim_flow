import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'profile_premium_card.dart';

class ProfileLoyaltyCard extends StatelessWidget {
  final int completedCuts;
  final bool isRewardAvailable;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onClaimReward;

  const ProfileLoyaltyCard({
    super.key,
    required this.completedCuts,
    required this.isRewardAvailable,
    required this.isExpanded,
    required this.onTap,
    required this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePremiumCard(
      title: 'VIP MEMBER',
      subtitle: 'Cartilla de Fidelización',
      isExpanded: isExpanded,
      onTap: onTap,
      children: [
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(7, (index) {
            final isCompleted = index < completedCuts;
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? context.primaryGold : Colors.transparent,
                border: Border.all(color: context.primaryGold.withValues(alpha: isCompleted ? 1 : 0.3), width: 1.5),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded, color: context.backgroundBlack, size: 20)
                    : Text('${index + 1}', style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isRewardAvailable ? onClaimReward : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryGold,
            foregroundColor: context.backgroundBlack,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
            disabledForegroundColor: Colors.white10,
            elevation: 0,
          ),
          child: const Text('RECLAMAR RECOMPENSA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }
}
