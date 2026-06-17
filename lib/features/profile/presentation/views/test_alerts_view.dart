import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/notifications/notifications.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Previsualización de alertas (cliente + barbero). Diseño neutro porque son
/// pruebas. Al tocar una, dispara esa misma notificación real en el sistema.
class TestAlertsView extends StatelessWidget {
  const TestAlertsView({super.key});

  static const Color _cBlue = Color(0xFF378ADD);
  static const Color _cGreen = Color(0xFF63D983);
  static const Color _cGold = Color(0xFFEFAE27);
  static const Color _cOrange = Color(0xFFEF7C27);
  static const Color _cRed = Color(0xFFFF6B7A);

  static const List<_MockAlert> _alerts = [
    _MockAlert('Tu cita es mañana', 'Corte clásico con Pedro a las 10:30',
        FontAwesomeIcons.calendarCheck, '2 h', false, _cBlue),
    _MockAlert('Nueva oferta', '20% OFF en corte + barba esta semana',
        FontAwesomeIcons.tag, '1 d', false, _cGold),
    _MockAlert('Tu pedido está listo', 'Pasa a recogerlo cuando quieras',
        FontAwesomeIcons.bagShopping, '3 h', false, _cGreen),
    _MockAlert('Ganaste 50 puntos', 'Por tu última reserva. Sigue así',
        FontAwesomeIcons.gift, '1 d', false, _cGold),
    _MockAlert('Nueva reserva', 'Carlos reservó Fade para mañana 4pm',
        FontAwesomeIcons.calendarPlus, '10 min', true, _cGreen),
    _MockAlert('Walk-in en espera', 'Un cliente llegó sin cita',
        FontAwesomeIcons.userClock, '20 min', true, _cOrange),
    _MockAlert('Cita cancelada', 'Miguel canceló su cita de las 5pm',
        FontAwesomeIcons.ban, '1 h', true, _cRed),
    _MockAlert('Resumen del día', '8 cortes, S/240 facturado',
        FontAwesomeIcons.chartColumn, 'ayer', true, _cBlue),
  ];

  Future<void> _fire(BuildContext context, _MockAlert a, int id) async {
    HapticFeedback.mediumImpact();
    try {
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: a.title,
        body: a.message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'trimflow_test_channel',
            'Alertas TrimFlow',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_stat_trimflow',
            color: a.color,
            largeIcon:
                const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              a.message,
              contentTitle: a.title,
            ),
          ),
        ),
      );
    } catch (_) {}
    if (context.mounted) {
      AppToast.info(context, 'Notificación enviada',
          message: 'Revisa tu barra de notificaciones.');
    }
  }

  static const List<_ToastPreview> _toasts = [
    _ToastPreview(AppToastType.success, 'Éxito', 'Cambios guardados',
        'Tu perfil se actualizó correctamente.'),
    _ToastPreview(AppToastType.info, 'Información', 'Buen dato',
        'Tienes una cita el viernes a las 10:30.'),
    _ToastPreview(AppToastType.warning, 'Atención', 'Revisa esto',
        'Te queda poco tiempo para confirmar.'),
    _ToastPreview(AppToastType.error, 'Error', 'Algo salió mal',
        'Código no válido, intenta de nuevo.'),
    _ToastPreview(AppToastType.cancel, 'Cancelado', 'Acción cancelada',
        'No se realizó ningún cambio.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          children: [
            Row(
              children: [PremiumBackButton(onTap: () => Navigator.pop(context))],
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 20),
            Text(
              'Alertas',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ).animate().fadeIn(delay: 60.ms, duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              'Toca una para verla en tu barra de notificaciones',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.4),
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
            const SizedBox(height: 26),
            Text(
              'Tostadas en la app',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.primaryGold,
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(delay: 140.ms, duration: 400.ms),
            const SizedBox(height: 2),
            Text(
              'Avisos breves que aparecen abajo. Toca para ver cada tipo.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.4),
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
            const SizedBox(height: 14),
            for (var i = 0; i < _toasts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ToastPreviewCard(
                  preview: _toasts[i],
                  onTap: () => AppToast.show(
                    context,
                    type: _toasts[i].type,
                    title: _toasts[i].toastTitle,
                    message: _toasts[i].toastMessage,
                  ),
                ).animate().fadeIn(
                      delay: (180 + 40 * i).ms,
                      duration: 360.ms,
                    ),
              ),
            const SizedBox(height: 26),
            Text(
              'Notificaciones del sistema',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.primaryGold,
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 14),
            for (var i = 0; i < _alerts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AlertCard(
                  alert: _alerts[i],
                  onTap: () => _fire(context, _alerts[i], i),
                )
                    .animate()
                    .fadeIn(delay: (180 + 50 * i).ms, duration: 380.ms)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: (180 + 50 * i).ms,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToastPreview {
  const _ToastPreview(
      this.type, this.label, this.toastTitle, this.toastMessage);

  final AppToastType type;
  final String label;
  final String toastTitle;
  final String toastMessage;
}

class _ToastPreviewCard extends StatelessWidget {
  const _ToastPreviewCard({required this.preview, required this.onTap});

  final _ToastPreview preview;
  final VoidCallback onTap;

  static const Map<AppToastType, (Color, IconData)> _meta = {
    AppToastType.success: (Color(0xFF63D983), Icons.check_circle_rounded),
    AppToastType.info: (Color(0xFF378ADD), Icons.info_rounded),
    AppToastType.warning: (Color(0xFFEF9F27), Icons.warning_rounded),
    AppToastType.error: (Color(0xFFFF6B7A), Icons.error_rounded),
    AppToastType.cancel: (Color(0xFFC7C7CC), Icons.do_not_disturb_on_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _meta[preview.type]!;
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                preview.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(Icons.play_arrow_rounded,
                size: 18, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _MockAlert {
  const _MockAlert(this.title, this.message, this.icon, this.time,
      this.forBarber, this.color);

  final String title;
  final String message;
  final FaIconData icon;
  final String time;
  final bool forBarber;
  final Color color;
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.onTap});

  final _MockAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: alert.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: alert.color.withValues(alpha: 0.22)),
              ),
              alignment: Alignment.center,
              child: FaIcon(alert.icon, size: 15, color: alert.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  alert.time,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    alert.forBarber ? 'BARBERO' : 'CLIENTE',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
