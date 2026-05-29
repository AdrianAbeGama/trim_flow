import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

class ProfileSettingsView extends StatelessWidget {
  final UserProfile user;
  final bool isBarber;

  const ProfileSettingsView({
    super.key,
    required this.user,
    required this.isBarber,
  });

  @override
  Widget build(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();

    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAREA 1: REDISEÑO PREMIUM DEL HEADER EN CONFIGURACIÓN (Alineado con Perfil, Reservas, etc.)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Botón Volver + Icono
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded, 
                          size: 28, 
                          color: Colors.white70
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.settings_suggest_rounded, color: context.primaryGold, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Fila 2: Título Configuración
                  const Text(
                    'CONFIGURACIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Fila 3: Delgada línea divisoria horizontal
                  Container(width: 40, height: 3, color: context.primaryGold),
                ],
              ),
            ),
            
            // Contenido principal de configuración
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                children: [
                  // --- CATEGORÍA: AJUSTES GENERALES ---
                  _buildSectionTitle(context, 'AJUSTES GENERALES'),
                  
                  // Notificaciones
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final currentUser = state.user ?? user;
                      final isEnabled = currentUser.notificationsEnabled;

                      return _buildSettingsCell(
                        title: 'Notificaciones Push',
                        subtitle: 'Alertas y avisos en tiempo real',
                        trailing: OutlinedButton(
                          onPressed: () => profileBloc.add(const RequestNotificationPermissionEvent()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isEnabled ? Colors.greenAccent : context.primaryGold,
                            backgroundColor: isEnabled 
                                ? Colors.greenAccent.withValues(alpha: 0.05) 
                                : context.primaryGold.withValues(alpha: 0.05),
                            side: BorderSide(
                              color: isEnabled 
                                  ? Colors.greenAccent.withValues(alpha: 0.3) 
                                  : context.primaryGold.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isEnabled ? 'HABILITADO' : 'HABILITAR',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),

                  // Probar Alerta
                  _buildSettingsCell(
                    title: 'Probar Alerta',
                    subtitle: 'Lanza una notificación simulada',
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 12),
                    onTap: () => profileBloc.add(const TestNotificationEvent()),
                  ),
                  _buildDivider(),
                  const SizedBox(height: 16),

                  // --- CATEGORÍA: ADMINISTRACIÓN (Barbero únicamente) ---
                  if (isBarber) ...[
                    _buildSectionTitle(context, 'ADMINISTRACIÓN'),
                    ValueListenableBuilder<bool>(
                      valueListenable: BarberHomePage.showBarberBadge,
                      builder: (context, showBadge, child) {
                        return _buildSettingsCell(
                          title: 'Habilitar Nota',
                          subtitle: 'Ver etiqueta flotante "Modo Barbero"',
                          trailing: _PremiumSwitch(
                            value: showBadge,
                            onChanged: (val) {
                              BarberHomePage.showBarberBadge.value = val;
                            },
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    const SizedBox(height: 16),
                  ],

                  // --- CATEGORÍA: OPTIMIZACIÓN ---
                  _buildSectionTitle(context, 'RENDIMIENTO'),
                  ValueListenableBuilder<bool>(
                    valueListenable: HomePage.enableSwipe,
                    builder: (context, swipeEnabled, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSettingsCell(
                            title: 'Navegación por Desplazamiento',
                            subtitle: 'Desplazamiento horizontal por Swipe',
                            trailing: _PremiumSwitch(
                              value: swipeEnabled,
                              onChanged: (val) {
                                HomePage.enableSwipe.value = val;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: HomePage.persistentNavBar,
                            builder: (context, persistentEnabled, child) {
                              return _buildSettingsCell(
                                title: 'Barra siempre visible',
                                subtitle: 'Mantener la barra de navegación al hacer scroll',
                                trailing: _PremiumSwitch(
                                  value: persistentEnabled,
                                  onChanged: (val) {
                                    HomePage.persistentNavBar.value = val;
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF160F0F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Aviso: Activar el swipe puede ralentizar la fluidez en teléfonos de bajas prestaciones.',
                                    style: TextStyle(
                                      color: Colors.redAccent.withValues(alpha: 0.8),
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildDivider(),
                  const SizedBox(height: 20),

                  // --- TAREA 2: SOPORTE Y ACERCA DE (En blanco, sin creadores) ---
                  _buildSectionTitle(context, 'SOPORTE Y ACERCA DE'),
                  const SizedBox(height: 16),

                  // Cerrar Sesión
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'CERRAR SESIÓN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 12),
      child: Text(
        title,
        style: TextStyle(
          color: context.primaryGold.withValues(alpha: 0.5),
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCell({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.03), height: 1);
  }


}

// PREMIUM CUSTOM ANIMATED TOGGLE SWITCH
class _PremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = context.primaryGold;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? goldColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: value ? goldColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? goldColor : Colors.white60,
              boxShadow: value ? [
                BoxShadow(
                  color: goldColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ] : null,
            ),
          ),
        ),
      ),
    );
  }
}
