import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_header.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_logout_button.dart';
import 'package:trim_flow/features/profile/presentation/widgets/settings/settings_rows.dart';

/// Configuración — orquestador limpio.
/// Toda la UI vive en widgets/settings/.
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({
    super.key,
    required this.user,
    required this.isBarber,
  });

  final UserProfile user;
  final bool isBarber;

  Future<void> _confirmLogout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.pop(context);
      context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();

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
                    begin: 0.08, end: 0,
                    delay: 100.ms, duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),
            // === AJUSTES ===
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Ajustes',
                delay: 200,
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final currentUser = state.user ?? user;
                      return SettingsToggleRow(
                        iconColor: const Color(0xFFFF8A95),
                        iconBg: const Color(0xFFFF8A95).withValues(alpha: 0.12),
                        icon: Icons.notifications_active_rounded,
                        label: 'Notificaciones push',
                        subtitle: 'Avisos en tiempo real',
                        value: currentUser.notificationsEnabled,
                        onChanged: (_) => profileBloc
                            .add(const RequestNotificationPermissionEvent()),
                      );
                    },
                  ),
                  const SettingsRowDivider(),
                  SettingsActionRow(
                    iconColor: context.primaryGold,
                    iconBg: context.primaryGold.withValues(alpha: 0.12),
                    icon: Icons.volume_up_rounded,
                    label: 'Probar alerta',
                    subtitle: 'Lanza una notificación de prueba',
                    onTap: () => profileBloc.add(const TestNotificationEvent()),
                  ),
                ],
              ),
            ),
            // === ADMINISTRACIÓN (solo barbero) ===
            if (isBarber)
              SliverToBoxAdapter(
                child: SettingsSection(
                  title: 'Administración',
                  delay: 280,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: BarberHomePage.showBarberBadge,
                      builder: (_, show, _) {
                        return SettingsToggleRow(
                          iconColor: context.primaryGold,
                          iconBg: context.primaryGold.withValues(alpha: 0.12),
                          icon: Icons.label_important_rounded,
                          label: 'Etiqueta Modo Barbero',
                          subtitle: 'Indicador flotante en pantalla',
                          value: show,
                          onChanged: (v) =>
                              BarberHomePage.showBarberBadge.value = v,
                        );
                      },
                    ),
                  ],
                ),
              ),
            // === RENDIMIENTO ===
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Rendimiento',
                delay: isBarber ? 360 : 280,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: HomePage.enableSwipe,
                    builder: (_, swipe, _) {
                      return SettingsToggleRow(
                        iconColor: context.primaryGold,
                        iconBg: context.primaryGold.withValues(alpha: 0.12),
                        icon: Icons.swipe_rounded,
                        label: 'Navegación por swipe',
                        subtitle: 'Cambia de tab desplazando',
                        value: swipe,
                        onChanged: (v) => HomePage.enableSwipe.value = v,
                      );
                    },
                  ),
                  const SettingsRowDivider(),
                  ValueListenableBuilder<bool>(
                    valueListenable: HomePage.persistentNavBar,
                    builder: (_, persistent, _) {
                      return SettingsToggleRow(
                        iconColor: context.primaryGold,
                        iconBg: context.primaryGold.withValues(alpha: 0.12),
                        icon: Icons.view_day_rounded,
                        label: 'Barra siempre visible',
                        subtitle: 'Mantener la barra al hacer scroll',
                        value: persistent,
                        onChanged: (v) => HomePage.persistentNavBar.value = v,
                      );
                    },
                  ),
                ],
              ),
            ),
            // === SOPORTE ===
            SliverToBoxAdapter(
              child: SettingsSection(
                title: 'Soporte',
                delay: isBarber ? 440 : 360,
                children: [
                  SettingsActionRow(
                    iconColor: const Color(0xFF5DCBF9),
                    iconBg: const Color(0xFF5DCBF9).withValues(alpha: 0.12),
                    icon: Icons.info_outline_rounded,
                    label: 'Acerca de TrimFlow',
                    subtitle: 'Versión, créditos, agradecimientos',
                    onTap: () => HapticFeedback.selectionClick(),
                  ),
                  const SettingsRowDivider(),
                  SettingsActionRow(
                    iconColor: Colors.white.withValues(alpha: 0.7),
                    iconBg: Colors.white.withValues(alpha: 0.05),
                    icon: Icons.description_outlined,
                    label: 'Términos y privacidad',
                    subtitle: 'Política de uso de la app',
                    onTap: () => HapticFeedback.selectionClick(),
                  ),
                ],
              ),
            ),
            // === VERSIÓN ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'TRIMFLOW',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.22),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0 · build 2026.06',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.15),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              ),
            ),
            // === LOGOUT ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: SettingsLogoutButton(
                  onTap: () => _confirmLogout(context),
                )
                    .animate()
                    .fadeIn(delay: 680.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.15, end: 0,
                      delay: 680.ms, duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
