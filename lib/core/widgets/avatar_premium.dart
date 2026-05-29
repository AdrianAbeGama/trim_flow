import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class AvatarPremium extends StatelessWidget {
  const AvatarPremium({
    super.key,
    required this.displayName,
    this.photoUrl,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  final String displayName;
  final String? photoUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  String get _initials {
    final cleaned = displayName.trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    final initials = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final ring = borderColor ?? gold.withValues(alpha: 0.45);
    final isUsableUrl = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: borderWidth),
      ),
      child: ClipOval(
        child: isUsableUrl
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _InitialsBlock(initials: _initials, gold: gold),
                errorWidget: (context, url, error) =>
                    _InitialsBlock(initials: _initials, gold: gold),
              )
            : _InitialsBlock(initials: _initials, gold: gold),
      ),
    );
  }
}

class _InitialsBlock extends StatelessWidget {
  const _InitialsBlock({required this.initials, required this.gold});

  final String initials;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gold.withValues(alpha: 0.22),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            initials,
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
