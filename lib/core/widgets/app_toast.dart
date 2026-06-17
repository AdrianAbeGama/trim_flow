import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipos de aviso (tostada) de la app.
enum AppToastType { success, info, warning, error, cancel }

class _ToastPalette {
  const _ToastPalette(this.base, this.icon, this.title, this.message,
      this.bg, this.border, this.iconData, this.defaultTitle);
  final Color base;
  final Color icon;
  final Color title;
  final Color message;
  final Color bg;
  final Color border;
  final IconData iconData;
  final String defaultTitle;
}

const Map<AppToastType, _ToastPalette> _palettes = {
  AppToastType.success: _ToastPalette(
    Color(0xFF63D983),
    Color(0xFF7BE38C),
    Color(0xFFA8F0B4),
    Color(0xFF86C99A),
    Color(0x1A63D983),
    Color(0x4D63D983),
    Icons.check_circle_rounded,
    'Listo',
  ),
  AppToastType.info: _ToastPalette(
    Color(0xFF378ADD),
    Color(0xFF5BA3EB),
    Color(0xFF9EC9F4),
    Color(0xFF7FA8D6),
    Color(0x1A378ADD),
    Color(0x4D378ADD),
    Icons.info_rounded,
    'Información',
  ),
  AppToastType.warning: _ToastPalette(
    Color(0xFFEF9F27),
    Color(0xFFFAC775),
    Color(0xFFFAD9A0),
    Color(0xFFD4A867),
    Color(0x1AEF9F27),
    Color(0x4DEF9F27),
    Icons.warning_rounded,
    'Atención',
  ),
  AppToastType.error: _ToastPalette(
    Color(0xFFFF6B7A),
    Color(0xFFFF8A95),
    Color(0xFFFFB3BB),
    Color(0xFFE08891),
    Color(0x1AFF6B7A),
    Color(0x4DFF6B7A),
    Icons.error_rounded,
    'Error',
  ),
  AppToastType.cancel: _ToastPalette(
    Color(0xFFC7C7CC),
    Color(0xFFC7C7CC),
    Color(0xFFE5E5EA),
    Color(0xFFA0A0A6),
    Color(0x0FFFFFFF),
    Color(0x24FFFFFF),
    Icons.do_not_disturb_on_rounded,
    'Cancelado',
  ),
};

/// Avisos tipo "tostada" — abajo, entran por la derecha y salen por la
/// izquierda, con una línea que se vacía hasta auto-cerrarse. Reemplaza los
/// SnackBar genéricos.
class AppToast {
  static void show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? message,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    showOn(overlay,
        type: type, title: title, message: message, duration: duration);
  }

  /// Variante para usar tras un `await`: captura el [OverlayState] antes del
  /// gap asíncrono y muéstralo aquí (sin tocar un BuildContext caducado).
  static void showOn(
    OverlayState overlay, {
    required AppToastType type,
    required String title,
    String? message,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    HapticFeedback.lightImpact();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        type: type,
        title: title,
        message: message,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }

  static void success(BuildContext c, String title, {String? message}) =>
      show(c, type: AppToastType.success, title: title, message: message);
  static void info(BuildContext c, String title, {String? message}) =>
      show(c, type: AppToastType.info, title: title, message: message);
  static void warning(BuildContext c, String title, {String? message}) =>
      show(c, type: AppToastType.warning, title: title, message: message);
  static void error(BuildContext c, String title, {String? message}) =>
      show(c, type: AppToastType.error, title: title, message: message);
  static void cancel(BuildContext c, String title, {String? message}) =>
      show(c, type: AppToastType.cancel, title: title, message: message);
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final AppToastType type;
  final String title;
  final String? message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  Offset _offset = const Offset(1.15, 0);
  double _opacity = 0;
  Timer? _exitTimer;
  Timer? _removeTimer;
  static const Duration _slideDur = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _offset = Offset.zero;
        _opacity = 1;
      });
    });
    final visible = widget.duration - _slideDur;
    _exitTimer = Timer(visible.isNegative ? widget.duration : visible, () {
      if (!mounted) return;
      setState(() {
        _offset = const Offset(-1.15, 0);
        _opacity = 0;
      });
    });
    _removeTimer = Timer(widget.duration + _slideDur, widget.onDismissed);
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _removeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _palettes[widget.type]!;
    final bottom = MediaQuery.of(context).viewPadding.bottom + 96;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: IgnorePointer(
        child: AnimatedSlide(
          offset: _offset,
          duration: _slideDur,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: _slideDur,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: p.bg,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            child: Row(
                              children: [
                                Icon(p.iconData, color: p.icon, size: 20),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: p.title,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (widget.message != null &&
                                          widget.message!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.message!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: p.message,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 2.5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 1, end: 0),
                                duration: widget.duration,
                                curve: Curves.linear,
                                builder: (_, v, _) => FractionallySizedBox(
                                  widthFactor: v.clamp(0.0, 1.0),
                                  child: Container(color: p.base),
                                ),
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
          ),
        ),
      ),
    );
  }
}
