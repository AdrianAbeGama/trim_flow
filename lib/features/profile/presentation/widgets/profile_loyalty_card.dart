import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ProfileLoyaltyCard extends StatefulWidget {
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
  State<ProfileLoyaltyCard> createState() => _ProfileLoyaltyCardState();
}

class _ProfileLoyaltyCardState extends State<ProfileLoyaltyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 3.0, end: 15.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canClaim = widget.completedCuts >= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expandable Header Row
        InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3.0,
                      height: 13,
                      decoration: BoxDecoration(
                        color: context.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CARTILLA DE FIDELIZACIÓN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // Premium rotating chevron to denote collapse/expand state
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.primaryGold,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Beautiful Glassmorphic Loyalty Card Body wrapped in AnimatedCrossFade
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.03),
                      width: 1,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'PROGRAMA DE FIDELIDAD',
                                        style: TextStyle(
                                          color: context.primaryGold.withValues(alpha: 0.85),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: context.primaryGold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: context.primaryGold.withValues(alpha: 0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${widget.completedCuts} / 8',
                                        style: TextStyle(
                                          color: context.primaryGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  canClaim
                                      ? '¡Llegaste! Tu próximo corte tiene 50% OFF.'
                                      : widget.completedCuts == 0
                                          ? 'Reserva tu primer corte y empieza a ganar.'
                                          : 'Te faltan ${8 - widget.completedCuts} cortes para tu 50% OFF.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Premium progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: (widget.completedCuts / 8).clamp(0.0, 1.0),
                                    minHeight: 4,
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    valueColor: AlwaysStoppedAnimation(context.primaryGold),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Loyalty circles list
                                Center(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(7, (index) {
                                      final isCompleted = index < widget.completedCuts;
                                      return Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted ? context.primaryGold : Colors.transparent,
                                          border: Border.all(
                                            color: context.primaryGold.withValues(alpha: isCompleted ? 1 : 0.35),
                                            width: 1.5,
                                          ),
                                          boxShadow: isCompleted
                                              ? [
                                                  BoxShadow(
                                                    color: context.primaryGold.withValues(alpha: 0.2),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: isCompleted
                                              ? Icon(Icons.check_rounded, color: context.backgroundBlack, size: 18)
                                              : Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white24,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Claim reward button with pulsing glow
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: canClaim
                                            ? [
                                                BoxShadow(
                                                  color: context.primaryGold.withValues(alpha: 0.4),
                                                  blurRadius: _glowAnimation.value,
                                                  spreadRadius: _glowAnimation.value / 3,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: canClaim ? widget.onClaimReward : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: canClaim ? context.primaryGold : Colors.white.withValues(alpha: 0.04),
                                          foregroundColor: context.backgroundBlack,
                                          minimumSize: const Size(double.infinity, 48),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
                                          disabledForegroundColor: Colors.white12,
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          canClaim ? '★ RECLAMAR RECOMPENSA (50% OFF) ★' : 'RECLAMAR RECOMPENSA',
                                          style: TextStyle(
                                            color: canClaim ? Colors.black : Colors.white24,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
