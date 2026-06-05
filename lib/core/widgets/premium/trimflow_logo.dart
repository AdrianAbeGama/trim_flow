import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Símbolo de marca TrimFlow tintable. Renderiza el SVG `currentColor`
/// con el color indicado. Si [shimmer] es true, un brillo lo recorre en bucle.
class TrimflowLogo extends StatelessWidget {
  const TrimflowLogo({
    super.key,
    required this.color,
    this.size = 56,
    this.shimmer = false,
  });

  final Color color;
  final double size;
  final bool shimmer;

  static const String _asset = 'images/brand/trimflow_mark.svg';

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

    if (!shimmer) return logo;

    return logo
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1800.ms,
          color: Colors.white.withValues(alpha: 0.6),
          angle: 0.5,
        );
  }
}
