import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';

// ============================================================================
// PRESSABLE — wrapper con AnimatedScale al press
// ============================================================================

class HomePressable extends StatefulWidget {
  const HomePressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<HomePressable> createState() => _HomePressableState();
}

class _HomePressableState extends State<HomePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE — Título principal + subtitle + edit pencil (cuando isEditing)
// ============================================================================

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({
    super.key,
    required this.text,
    this.subtitle,
    this.trailing,
    this.onEdit,
  });

  final String text;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (_, hs) {
              if (!hs.isEditing || onEdit == null) {
                return trailing ?? const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: HomeMiniEditPencil(onTap: onEdit!),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MINI EDIT PENCIL — lápiz rosa para edit
// ============================================================================

class HomeMiniEditPencil extends StatefulWidget {
  const HomeMiniEditPencil({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<HomeMiniEditPencil> createState() => _HomeMiniEditPencilState();
}

class _HomeMiniEditPencilState extends State<HomeMiniEditPencil> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF8A95);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.edit_rounded, size: 14, color: accent),
        ),
      ),
    );
  }
}

// ============================================================================
// SEE ALL PILL — "VER TODOS →" pill
// ============================================================================

class HomeSeeAllPill extends StatefulWidget {
  const HomeSeeAllPill({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<HomeSeeAllPill> createState() => _HomeSeeAllPillState();
}

class _HomeSeeAllPillState extends State<HomeSeeAllPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: gold.withValues(alpha: 0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 11, color: gold),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SMART IMAGE — detecta http vs file local vs asset
// ============================================================================

class HomeSmartImage extends StatelessWidget {
  // ignore: unused_element_parameter
  const HomeSmartImage({
    super.key,
    required this.path,
    // ignore: unused_element_parameter
    this.fit = BoxFit.cover,
    // ignore: unused_element_parameter
    this.width,
    // ignore: unused_element_parameter
    this.height,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return Container(width: width, height: height, color: const Color(0xFF181818));
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        width: width,
        height: height,
        errorWidget: (_, _, _) => Container(
          width: width, height: height,
          color: const Color(0xFF181818),
        ),
        placeholder: (_, _) => Container(
          width: width, height: height,
          color: const Color(0xFF181818),
        ),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => Container(
        width: width, height: height,
        color: const Color(0xFF181818),
      ),
    );
  }
}

// ============================================================================
// ITEM THUMB — miniatura universal con fallback icon
// ============================================================================

class HomeItemThumb extends StatelessWidget {
  const HomeItemThumb({super.key, required this.image, this.size = 48});
  final String image;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Container(
        width: size, height: size,
        color: const Color(0xFF181818),
        child: Icon(Icons.image_outlined, color: Colors.white.withValues(alpha: 0.2), size: 16),
      );
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Container(width: size, height: size, color: const Color(0xFF181818)),
        placeholder: (_, _) => Container(width: size, height: size, color: const Color(0xFF181818)),
      );
    }
    return Image.file(
      File(image),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size, height: size,
        color: const Color(0xFF181818),
        child: Icon(Icons.broken_image_outlined, color: Colors.white.withValues(alpha: 0.2), size: 16),
      ),
    );
  }
}


// ============================================================================
// SOCIAL SPEC — descriptor de una red social
// ============================================================================

class HomeSocialSpec {
  final String key;
  final String label;
  final Color brandColor;
  final Widget Function(Color color, double size) builder;
  const HomeSocialSpec(this.key, this.label, this.brandColor, this.builder);
}
