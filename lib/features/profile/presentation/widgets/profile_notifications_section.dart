import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class ProfileNotificationsSection extends StatelessWidget {
  final UserProfile user;

  const ProfileNotificationsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notificaciones de Sistema', style: TextStyle(color: Colors.white, fontSize: 15)),
              TextButton(
                onPressed: () => context.read<ProfileBloc>().add(const RequestNotificationPermissionEvent()),
                style: TextButton.styleFrom(
                  backgroundColor: user.notificationsEnabled ? Colors.green.withValues(alpha: 0.05) : context.primaryGold.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  user.notificationsEnabled ? 'HABILITADO' : 'HABILITAR',
                  style: TextStyle(
                    color: user.notificationsEnabled ? Colors.greenAccent : context.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTestNotificationMenu(context),
        ],
      ),
    );
  }

  Widget _buildTestNotificationMenu(BuildContext context) {
    return PopupMenuButton<ProfileNotificationType>(
      onSelected: (type) => context.read<ProfileBloc>().add(TestNotificationEvent(type: type, mode: AppMode.client)),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildPopupItem(context, ProfileNotificationType.offer, 'Prueba de Oferta', Icons.local_offer_rounded),
        _buildPopupItem(context, ProfileNotificationType.birthday, 'Prueba de Cumpleaños', Icons.cake_rounded),
        _buildPopupItem(context, ProfileNotificationType.reservation, 'Prueba de Reserva', Icons.alarm_rounded),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_rounded, color: context.primaryGold, size: 16),
            const SizedBox(width: 12),
            const Text('PRUEBA DE NOTIFICACIONES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ProfileNotificationType> _buildPopupItem(BuildContext context, ProfileNotificationType value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: context.primaryGold, size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
