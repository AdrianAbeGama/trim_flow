import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class GalleryExpertBadge extends StatelessWidget {
  const GalleryExpertBadge({
    super.key,
    required this.barberName,
    required this.specialty,
    this.avatarUrl,
  });

  final String? barberName;
  final String? specialty;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasContent = (barberName != null && barberName!.trim().isNotEmpty) ||
        (specialty != null && specialty!.trim().isNotEmpty);
    if (!hasContent) return const SizedBox.shrink();

    final gold = context.primaryGold;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(avatarUrl: avatarUrl, gold: gold),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (barberName != null && barberName!.trim().isNotEmpty)
                Text(
                  barberName!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              if (specialty != null && specialty!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  specialty!,
                  style: TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.gold});

  final String? avatarUrl;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gold.withValues(alpha: 0.2),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 18,
        color: gold,
      ),
    );

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.4),
      ),
      child: ClipOval(
        child: avatarUrl == null || avatarUrl!.trim().isEmpty
            ? fallback
            : Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
