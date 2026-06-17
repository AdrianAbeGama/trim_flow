import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_commission_config.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_visuals.dart';

/// Pantalla provisional (demo, sin backend) para asignar accesos por barbero y
/// previsualizar la app con esos permisos.
class RolesPermissionsView extends StatefulWidget {
  const RolesPermissionsView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<RolesPermissionsView> createState() => _RolesPermissionsViewState();
}

class _RolesPermissionsViewState extends State<RolesPermissionsView> {
  List<AdminBarberRef>? _barbers;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      await PermissionsStore.instance.load();
      final b =
          await getIt<AdminRepository>().fetchBarbers(tenantId: widget.tenantId);
      if (!mounted) return;
      setState(() {
        _barbers = b;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _open(AdminBarberRef b) {
    HapticFeedback.lightImpact();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => _BarberPermsView(barber: b)),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminScreenHeader(
              title: 'Roles y permisos',
              subtitle: 'Elige un barbero y define sus accesos',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text(
                'Decide qué puede ver y editar cada uno. Toca "Ver la app como" para probarlo en vivo. (Demo provisional.)',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.4),
                  height: 1.4,
                ),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const AdminLoader();
    if (_error) return AdminErrorView(onRetry: _load);
    final barbers = _barbers ?? const [];
    if (barbers.isEmpty) {
      return const Center(child: AdminEmptyHint(text: 'No hay barberos'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: barbers.length,
      itemBuilder: (_, i) => _barberRow(barbers[i]),
    );
  }

  Widget _barberRow(AdminBarberRef b) {
    final count = PermissionsStore.instance.permsFor(b.id).length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          PremiumPressable(
            onTap: () => _open(b),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  AdminInitialAvatar(name: b.name, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$count de ${kPermCaps.length} accesos activos',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: context.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.25), size: 20),
                ],
              ),
            ),
          ),
          const AdminHairline(),
        ],
      ),
    );
  }
}

class _BarberPermsView extends StatefulWidget {
  const _BarberPermsView({required this.barber});

  final AdminBarberRef barber;

  @override
  State<_BarberPermsView> createState() => _BarberPermsViewState();
}

class _BarberPermsViewState extends State<_BarberPermsView> {
  late final Set<String> _caps =
      Set<String>.from(PermissionsStore.instance.permsFor(widget.barber.id));

  Future<void> _toggle(String key, bool on) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (on) {
        _caps.add(key);
      } else {
        _caps.remove(key);
      }
    });
    await PermissionsStore.instance.setPermsFor(widget.barber.id, _caps);
    final p = PermissionsStore.instance.preview.value;
    if (p != null && p.id == widget.barber.id) {
      PermissionsStore.instance
          .startPreview(widget.barber.id, widget.barber.name, _caps);
    }
  }

  void _previewAs() {
    HapticFeedback.mediumImpact();
    PermissionsStore.instance
        .startPreview(widget.barber.id, widget.barber.name, _caps);
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final groups = <String, List<PermCap>>{};
    for (final c in kPermCaps) {
      (groups[c.group] ??= []).add(c);
    }
    final firstName = widget.barber.name.trim().split(RegExp(r'\s+')).first;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminScreenHeader(
              title: widget.barber.name,
              subtitle: 'Permisos del barbero',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (final entry in groups.entries) ...[
                    PremiumSectionLabel(entry.key),
                    const SizedBox(height: 6),
                    for (final c in entry.value) _permRow(c),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_done_outlined,
                          size: 13, color: Colors.white.withValues(alpha: 0.35)),
                      const SizedBox(width: 6),
                      Text(
                        'Los cambios se guardan solos',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PremiumPressable(
                    onTap: _previewAs,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 18, color: premiumOnAccent(gold)),
                          const SizedBox(width: 8),
                          Text(
                            'Ver la app como $firstName',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: premiumOnAccent(gold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permRow(PermCap c) {
    final gold = context.primaryGold;
    final on = _caps.contains(c.key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: on ? 0.12 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(c.icon,
                size: 18,
                color: on ? gold : Colors.white.withValues(alpha: 0.4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              c.label,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: on ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          _PermSwitch(value: on, onChanged: (v) => _toggle(c.key, v)),
        ],
      ),
    );
  }
}

/// Toggle premium (pista + perilla animada) en vez del Switch generico.
class _PermSwitch extends StatelessWidget {
  const _PermSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? gold : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? gold : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value
                  ? premiumOnAccent(gold)
                  : Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
