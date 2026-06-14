import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_info.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Bottom sheet premium para cambiar de tenant activo.
/// Animación de entrada escalonada por tarjeta, haptics al seleccionar.
class TenantSwitcherSheet extends StatefulWidget {
  const TenantSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TenantThemeBloc>(),
        child: const TenantSwitcherSheet(),
      ),
    );
  }

  @override
  State<TenantSwitcherSheet> createState() => _TenantSwitcherSheetState();
}

class _TenantSwitcherSheetState extends State<TenantSwitcherSheet> {
  String? _selecting;

  Future<void> _select(
      BuildContext context, TenantInfo tenant, String activeTenantId) async {
    if (tenant.id == activeTenantId) {
      Navigator.pop(context);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _selecting = tenant.id);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (context.mounted) {
      context.read<TenantThemeBloc>().switchTenant(tenant.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TenantThemeBloc>().state;
    final tenants = state.availableTenants;
    final activeTenantId = state.tenantId;
    final gold = context.primaryGold;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cambiar de negocio',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tenant cards with stagger animation
              ...List.generate(tenants.length, (i) {
                final tenant = tenants[i];
                final isActive = tenant.id == activeTenantId;
                final isSelecting = _selecting == tenant.id;
                final accentColor = tenant.colors.primaryGold;
                final initial = tenant.name.isNotEmpty
                    ? tenant.name[0].toUpperCase()
                    : '?';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TenantCard(
                    initial: initial,
                    name: tenant.name,
                    accentColor: accentColor,
                    isActive: isActive,
                    isSelecting: isSelecting,
                    gold: gold,
                    onTap: () => _select(context, tenant, activeTenantId),
                  )
                      .animate()
                      .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: (60 * i).ms,
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                      ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantCard extends StatefulWidget {
  const _TenantCard({
    required this.initial,
    required this.name,
    required this.accentColor,
    required this.isActive,
    required this.isSelecting,
    required this.gold,
    required this.onTap,
  });

  final String initial;
  final String name;
  final Color accentColor;
  final bool isActive;
  final bool isSelecting;
  final Color gold;
  final VoidCallback onTap;

  @override
  State<_TenantCard> createState() => _TenantCardState();
}

class _TenantCardState extends State<_TenantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.accentColor.withValues(alpha: 0.08)
                : const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? widget.accentColor.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.06),
              width: widget.isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Accent circle with initial
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.initial,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.accentColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Tenant name
              Expanded(
                child: Text(
                  widget.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.75),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Checkmark or loading
              if (widget.isSelecting)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.accentColor,
                  ),
                )
              else if (widget.isActive)
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: widget.accentColor,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 150.ms),
            ],
          ),
        ),
      ),
    );
  }
}
