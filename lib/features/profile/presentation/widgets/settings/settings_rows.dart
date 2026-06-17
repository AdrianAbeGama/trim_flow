import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Sección agrupada con título + lista de rows.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    required this.delay,
  });

  final String title;
  final List<Widget> children;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: gold.withValues(alpha: 0.9),
                letterSpacing: 1.6,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(children: children),
          ),
        ],
      )
          .animate()
          .fadeIn(delay: delay.ms, duration: 500.ms)
          .slideY(
            begin: 0.08, end: 0,
            delay: delay.ms, duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

/// Divider sutil entre rows (con padding izquierdo para alinear con el texto).
class SettingsRowDivider extends StatelessWidget {
  const SettingsRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 0.5,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

/// Fila de acción (tap → navega): icono + label + subtitle + chevron.
class SettingsActionRow extends StatefulWidget {
  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<SettingsActionRow> createState() => _SettingsActionRowState();
}

class _SettingsActionRowState extends State<SettingsActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        color: _pressed ? Colors.white.withValues(alpha: 0.02) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 17, color: widget.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.primaryGold.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila con toggle iOS (icono + label + subtitle + switch).
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          _IOSToggle(value: value, onChanged: onChanged, gold: context.primaryGold),
        ],
      ),
    );
  }
}

/// Toggle iOS-style — dorado ON, gris OFF, knob blanco con shadow.
class _IOSToggle extends StatelessWidget {
  const _IOSToggle({
    required this.value,
    required this.onChanged,
    required this.gold,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubic,
        width: 46, height: 28,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: value ? gold : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 23, height: 23,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de permiso de notificaciones: muestra el estado real del sistema
/// (Habilitado / Deshabilitado) a la derecha. Toca para pedir el permiso o,
/// si ya está concedido, abrir los ajustes del teléfono.
class SettingsNotificationRow extends StatefulWidget {
  const SettingsNotificationRow({super.key});

  @override
  State<SettingsNotificationRow> createState() =>
      _SettingsNotificationRowState();
}

class _SettingsNotificationRowState extends State<SettingsNotificationRow>
    with WidgetsBindingObserver {
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final st = await Permission.notification.status;
    if (mounted) setState(() => _granted = st.isGranted);
  }

  Future<void> _onTap() async {
    HapticFeedback.selectionClick();
    final st = await Permission.notification.status;
    if (st.isGranted) {
      await openAppSettings();
    } else {
      final res = await Permission.notification.request();
      if (mounted) setState(() => _granted = res.isGranted);
      if (res.isPermanentlyDenied) await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.notifications_active_rounded,
                  size: 17, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activar notificaciones',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text('Avisos de citas, ofertas y pedidos',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: _granted
                    ? gold.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: _granted
                        ? gold.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                _granted ? 'Habilitado' : 'Deshabilitado',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _granted ? gold : Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de ajuste tipo "estado" (sin switch): muestra Activado / Desactivado a
/// la derecha. Toca para alternar.
class SettingsStateRow extends StatelessWidget {
  const SettingsStateRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _MiniSwitch(value: value, gold: gold),
          ],
        ),
      ),
    );
  }
}

/// Switch premium propio: apagado = contorno fino; encendido = relleno del
/// acento con el botón a la derecha. Más cuidado que el switch estándar.
class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.gold});

  final bool value;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      width: 46,
      height: 27,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? gold : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: value
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.18),
          width: 1.4,
        ),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            color: value ? Colors.white : Colors.white.withValues(alpha: 0.32),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Opción dentro de una fila expandible.
class SettingsOption {
  const SettingsOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
}

/// Fila expandible: cabecera (icono + label + flechita abajo) que al tocar
/// despliega una lista de opciones. Para "Contactar" y "Reportar".
class SettingsExpandableRow extends StatefulWidget {
  const SettingsExpandableRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.options,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final List<SettingsOption> options;

  @override
  State<SettingsExpandableRow> createState() => _SettingsExpandableRowState();
}

class _SettingsExpandableRowState extends State<SettingsExpandableRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _open = !_open);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, size: 17, color: widget.iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 2),
                      Text(widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22, color: gold.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  children: [
                    for (final o in widget.options)
                      _OptionRow(option: o, gold: gold),
                    const SizedBox(height: 6),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option, required this.gold});

  final SettingsOption option;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final hi = option.highlight;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        option.onTap();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hi
              ? gold.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hi
                  ? gold.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(option.icon,
                size: 15,
                color: hi ? gold : Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(option.label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: hi ? FontWeight.w800 : FontWeight.w600,
                      color:
                          hi ? gold : Colors.white.withValues(alpha: 0.85))),
            ),
            Icon(Icons.arrow_outward_rounded,
                size: 14,
                color: hi
                    ? gold.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}
