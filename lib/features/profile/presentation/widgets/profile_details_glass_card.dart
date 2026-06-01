import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class ProfileDetailsGlassCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onEdit;
  final bool isBarber;

  const ProfileDetailsGlassCard({
    super.key,
    required this.user,
    required this.onEdit,
    this.isBarber = false,
  });

  @override
  Widget build(BuildContext context) {
    final phoneVal = user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}';
    final birthVal = user.birthDate.isEmpty ? 'Pendiente' : _formatBirthDate(user.birthDate);

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
              if (!isBarber) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _buildItemRow(
                  context: context,
                  icon: FontAwesomeIcons.cakeCandles,
                  label: 'Fecha de nacimiento',
                  value: birthVal,
                  isPending: user.birthDate.isEmpty,
                  onTap: onEdit,
                ),
              ],
              if (isBarber) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _BranchReadonlyRow(branchId: user.branchId),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatBirthDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
      ];
      return '${d.day} de ${months[d.month - 1]}';
    } catch (_) {
      return raw;
    }
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

}

class _BranchReadonlyRow extends StatelessWidget {
  const _BranchReadonlyRow({required this.branchId});

  final String? branchId;

  static final Map<String, String> _cache = {};

  Future<String?> _fetchBranchName(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    try {
      final row = await Supabase.instance.client
          .from('branches')
          .select('name')
          .eq('id', id)
          .maybeSingle();
      final name = row?['name'] as String?;
      if (name != null) _cache[id] = name;
      return name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = branchId;
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
                  'SUCURSAL ASIGNADA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                if (id == null)
                  const Text(
                    'Sin asignar',
                    style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold),
                  )
                else
                  FutureBuilder<String?>(
                    future: _fetchBranchName(id),
                    builder: (context, snap) {
                      final isLoading = snap.connectionState == ConnectionState.waiting;
                      final name = snap.data ?? 'Sede asignada';
                      return Text(
                        isLoading ? 'Cargando...' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
