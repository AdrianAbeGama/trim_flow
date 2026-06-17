import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/core/widgets/image_cache_size.dart';

class SafeImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const SafeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.white.withValues(alpha: 0.05),
          child: Icon(Icons.image, color: Colors.white24, size: (width != null && width! < 30) ? 14 : 20),
        );

    if (url.isEmpty) {
      return fallback;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho real de pintado: el width explicito o el del contenedor. Sirve
        // para limitar la decodificacion (memCacheWidth/cacheWidth) y no gastar
        // RAM con fotos enormes mostradas chicas.
        final logicalW =
            width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : null);
        final cacheW = targetCacheWidth(context, logicalW);

        if (url.startsWith('http') || url.startsWith('https')) {
          return CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: cacheW,
            placeholder: (context, _) => Container(
              width: width,
              height: height,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            errorWidget: (context, url, error) => fallback,
          );
        }

        if (url.startsWith('assets/')) {
          return Image.asset(
            url,
            width: width,
            height: height,
            fit: fit,
            cacheWidth: cacheW,
            errorBuilder: (context, error, stackTrace) => fallback,
          );
        }

        try {
          final cleanPath =
              url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
          return Image.file(
            File(cleanPath),
            width: width,
            height: height,
            fit: fit,
            cacheWidth: cacheW,
            errorBuilder: (context, error, stackTrace) => fallback,
          );
        } catch (_) {
          return fallback;
        }
      },
    );
  }
}
