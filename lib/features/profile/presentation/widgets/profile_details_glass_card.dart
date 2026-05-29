import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart' as trim_flow_bloc;
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart' as trim_flow_bloc;
import 'package:core/core.dart';

class ProfileDetailsGlassCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onEdit;

  const ProfileDetailsGlassCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final phoneVal = user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Elegant Category Header matching layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 3.0,
                height: 13,
                decoration: BoxDecoration(
                  color: context.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DATOS PERSONALES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // 1. WhatsApp Row
              _buildItemRow(
                context: context,
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp de contacto',
                value: phoneVal,
                isPending: user.phone.isEmpty,
                onTap: onEdit,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white10, height: 1),
              ),
              // 2. Branch Selector Dropdown
              _buildBranchSelector(context, user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required BuildContext context,
    required dynamic icon,
    required String label,
    required String value,
    required bool isPending,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            // Styled Round Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.primaryGold.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
              ),
              child: icon is IconData
                  ? Icon(icon, color: context.primaryGold, size: 16)
                  : FaIcon(icon, color: context.primaryGold, size: 16),
            ),
            const SizedBox(width: 16),
            // Label & Value Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      color: isPending ? Colors.redAccent.withValues(alpha: 0.7) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: context.primaryGold, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector(BuildContext context, UserProfile user) {
    // Sucursales hardcodeadas como solicitó el usuario para simulación
    final branches = [
      {'id': 'sede-centro', 'name': 'Sede Centro'},
      {'id': 'sede-principal', 'name': 'Sede Principal'},
      {'id': 'sede-miraflores', 'name': 'Sede Miraflores'},
    ];

    final currentBranchId = user.branchId ?? 'sede-principal';
    final profileBloc = context.read<trim_flow_bloc.ProfileBloc>();

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.primaryGold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(Icons.store_mall_directory_rounded, color: context.primaryGold, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUCURSAL ACTIVA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: branches.any((b) => b['id'] == currentBranchId) ? currentBranchId : branches.first['id'] as String,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.primaryGold, size: 16),
                    isDense: true,
                    dropdownColor: const Color(0xFF161616),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        profileBloc.add(trim_flow_bloc.ProfileEvent.updateBranchId(newValue));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Sucursal cambiada a ${branches.firstWhere((b) => b['id'] == newValue)['name']}'),
                          backgroundColor: Colors.green,
                        ));
                      }
                    },
                    items: branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch['id'] as String,
                        child: Text(branch['name'] as String),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
