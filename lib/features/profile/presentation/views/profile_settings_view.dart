import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_contact.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/views/about_view.dart';
import 'package:trim_flow/features/profile/presentation/views/legal_view.dart';
import 'package:trim_flow/features/profile/presentation/views/support_faq_view.dart';
import 'package:trim_flow/features/profile/presentation/views/test_alerts_view.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_edit_sheet.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_edit_sheet.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_header.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_logout_button.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_rows.dart';

/// Configuración — minimalista premium. Íconos monocromáticos, secciones
/// divididas, filas de estado (sin switches), Acerca de inline, eliminar al
/// final. Mismo diseño para cliente y barbero.
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({
    super.key,
    required this.user,
    required this.isBarber,
  });

  final UserProfile user;
  final bool isBarber;

  static final Color _icon = Colors.white.withValues(alpha: 0.72);
  static final Color _iconBg = Colors.white.withValues(alpha: 0.05);

  void _editProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<ProfileBloc>();
    final current = bloc.state.user ?? user;
    showMaterialModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E0E0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => isBarber
          ? BlocProvider.value(
              value: bloc,
              child: BarberProfileEditSheet(user: current),
            )
          : ProfileEditSheet(user: current, profileBloc: bloc),
    );
  }

  void _push(BuildContext context, Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _clearCache(BuildContext context) {
    HapticFeedback.mediumImpact();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    AppToast.success(context, 'Caché limpiada', message: 'Liberamos las imágenes en memoria.');
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Cerrar sesión',
      message:
          '¿Seguro que quieres salir de tu cuenta? Tendrás que volver a iniciar sesión.',
      confirmLabel: 'CERRAR SESIÓN',
      icon: Icons.logout_rounded,
    );
    if (ok && context.mounted) {
      Navigator.pop(context);
      context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Eliminar cuenta',
      message:
          'Se borrarán tu cuenta y todos tus datos de forma permanente. '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'ELIMINAR MI CUENTA',
      icon: Icons.delete_forever_rounded,
    );
    if (!ok || !context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context);
    final appMode = context.read<AppModeBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    try {
      await getIt<ProfileRepository>().deleteMyAccount();
      navigator.pop();
      navigator.pop();
      appMode.add(const AppModeEvent.requestLogout());
    } catch (_) {
      navigator.pop();
      AppToast.showOn(overlay,
          type: AppToastType.error, title: 'No se pudo eliminar la cuenta');
    }
  }

  @override
  Widget build(BuildContext context) {
    var d = 150;
    int next() => d += 60;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SettingsHeader(onBack: () => Navigator.pop(context))
                  .animate()
                  .fadeIn(duration: 350.ms),
            ),
            SliverToBoxAdapter(
              child: SettingsProfilePreview(user: user)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),

            // === CUENTA ===
            _section('Cuenta', d, [
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.person_outline_rounded,
                label: 'Editar mis datos',
                subtitle: isBarber ? 'Nombre y WhatsApp' : 'Nombre, WhatsApp, cumpleaños',
                onTap: () => _editProfile(context),
              ),
            ]),

            // === NOTIFICACIONES ===
            _section('Notificaciones', next(), [
              const SettingsNotificationRow(),
              const SettingsRowDivider(),
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.notifications_none_rounded,
                label: 'Ver alertas de ejemplo',
                subtitle: 'Toca una para probarla',
                onTap: () => _push(context, const TestAlertsView()),
              ),
            ]),

            // === ADMINISTRACIÓN (solo barbero) ===
            if (isBarber)
              _section('Administración', next(), [
                ValueListenableBuilder<bool>(
                  valueListenable: BarberHomePage.showBarberBadge,
                  builder: (_, show, _) {
                    return SettingsStateRow(
                      iconColor: _icon,
                      iconBg: _iconBg,
                      icon: Icons.label_important_outline_rounded,
                      label: 'Etiqueta Modo Barbero',
                      subtitle: 'Indicador flotante en pantalla',
                      value: show,
                      onChanged: (v) => BarberHomePage.showBarberBadge.value = v,
                    );
                  },
                ),
              ]),

            // === RENDIMIENTO ===
            _section('Rendimiento', next(), [
              ValueListenableBuilder<bool>(
                valueListenable: HomePage.enableSwipe,
                builder: (_, swipe, _) => SettingsStateRow(
                  iconColor: _icon,
                  iconBg: _iconBg,
                  icon: Icons.swipe_rounded,
                  label: 'Navegación por swipe',
                  subtitle: 'Cambia de tab desplazando',
                  value: swipe,
                  onChanged: (v) => HomePage.enableSwipe.value = v,
                ),
              ),
              const SettingsRowDivider(),
              ValueListenableBuilder<bool>(
                valueListenable: HomePage.persistentNavBar,
                builder: (_, persistent, _) => SettingsStateRow(
                  iconColor: _icon,
                  iconBg: _iconBg,
                  icon: Icons.view_day_outlined,
                  label: 'Barra siempre visible',
                  subtitle: 'Mantener la barra al hacer scroll',
                  value: persistent,
                  onChanged: (v) => HomePage.persistentNavBar.value = v,
                ),
              ),
              const SettingsRowDivider(),
              ValueListenableBuilder<bool>(
                valueListenable: HomePage.reduceMotion,
                builder: (_, reduce, _) => SettingsStateRow(
                  iconColor: _icon,
                  iconBg: _iconBg,
                  icon: Icons.motion_photos_off_outlined,
                  label: 'Desactivar animaciones',
                  subtitle: 'Menos movimiento, más fluido',
                  value: reduce,
                  onChanged: (v) => HomePage.reduceMotion.value = v,
                ),
              ),
              const SettingsRowDivider(),
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.cleaning_services_outlined,
                label: 'Limpiar caché',
                subtitle: 'Libera espacio de imágenes',
                onTap: () => _clearCache(context),
              ),
            ]),

            // === PRIVACIDAD Y PERMISOS ===
            _section('Privacidad y permisos', next(), [
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.notifications_active_outlined,
                label: 'Notificaciones',
                subtitle: 'Administra el permiso en el sistema',
                onTap: () {
                  HapticFeedback.selectionClick();
                  openAppSettings();
                },
              ),
              const SettingsRowDivider(),
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.camera_alt_outlined,
                label: 'Cámara',
                subtitle: 'Para escanear códigos QR',
                onTap: () {
                  HapticFeedback.selectionClick();
                  openAppSettings();
                },
              ),
            ]),

            // === SOPORTE ===
            _section('Soporte', next(), [
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.help_outline_rounded,
                label: 'Preguntas frecuentes',
                subtitle: 'Resolvemos tus dudas',
                onTap: () => _push(context, const SupportFaqView()),
              ),
              const SettingsRowDivider(),
              _SupportContactRows(iconColor: _icon, iconBg: _iconBg),
              const SettingsRowDivider(),
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.star_outline_rounded,
                label: 'Calificar la app',
                subtitle: 'Tu opinión nos ayuda',
                onTap: () {
                  HapticFeedback.selectionClick();
                  _launch(
                      'https://play.google.com/store/apps/details?id=com.trimflow.app');
                },
              ),
            ]),

            // === INFORMACIÓN ===
            _section('Información', next(), [
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.shield_outlined,
                label: 'Términos y seguridad',
                subtitle: 'Condiciones de uso y protección de datos',
                onTap: () => _push(context, const LegalView()),
              ),
              const SettingsRowDivider(),
              SettingsActionRow(
                iconColor: _icon,
                iconBg: _iconBg,
                icon: Icons.info_outline_rounded,
                label: 'Acerca de TrimFlow',
                subtitle: 'Versión y créditos',
                onTap: () => _push(context, const AboutView()),
              ),
            ]),

            // === LOGOUT ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: SettingsLogoutButton(onTap: () => _confirmLogout(context))
                    .animate()
                    .fadeIn(delay: 660.ms, duration: 500.ms),
              ),
            ),

            // === ELIMINAR CUENTA ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => _confirmDeleteAccount(context),
                    child: const Text(
                      'Eliminar mi cuenta',
                      style: TextStyle(
                        color: Color(0xFFCF6679),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 720.ms, duration: 500.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 44)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, int delay, List<Widget> children) {
    return SliverToBoxAdapter(
      child: SettingsSection(title: title, delay: delay, children: children),
    );
  }
}

/// Filas de soporte que leen el contacto real del negocio
/// (`tenants.branding.contact`). WhatsApp usa `contact.phone`; el reporte usa
/// `contact.email`. Si el dato no esta cargado en la web admin, queda como
/// "No configurado aun".
class _SupportContactRows extends StatefulWidget {
  const _SupportContactRows({required this.iconColor, required this.iconBg});

  final Color iconColor;
  final Color iconBg;

  @override
  State<_SupportContactRows> createState() => _SupportContactRowsState();
}

class _SupportContactRowsState extends State<_SupportContactRows> {
  late final Future<TenantContact> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<TenantThemeBloc>().fetchActiveTenantContact();
  }

  Future<void> _launch(String url) async {
    HapticFeedback.selectionClick();
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TenantContact>(
      future: _future,
      builder: (context, snapshot) {
        final contact = snapshot.data ?? const TenantContact();
        final loading = snapshot.connectionState == ConnectionState.waiting;
        return Column(
          children: [
            SettingsActionRow(
              iconColor: widget.iconColor,
              iconBg: widget.iconBg,
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Contactar por WhatsApp',
              subtitle: loading
                  ? 'Cargando…'
                  : contact.hasPhone
                      ? 'Escríbenos por WhatsApp'
                      : 'No configurado aún',
              onTap: contact.hasPhone
                  ? () => _launch('https://wa.me/${contact.phoneDigits}')
                  : () {},
            ),
            const SettingsRowDivider(),
            SettingsActionRow(
              iconColor: widget.iconColor,
              iconBg: widget.iconBg,
              icon: Icons.flag_outlined,
              label: 'Reportar un problema',
              subtitle: loading
                  ? 'Cargando…'
                  : contact.hasEmail
                      ? 'Escríbenos por correo'
                      : 'No configurado aún',
              onTap: contact.hasEmail
                  ? () => _launch(
                      'mailto:${contact.email!.trim()}?subject=Soporte%20-%20TrimFlow')
                  : () {},
            ),
          ],
        );
      },
    );
  }
}

