import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_info.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/auth/presentation/views/claim_profile_view.dart';

/// Hoja inferior para cambiar de negocio activo. Carrusel horizontal centrado
/// de circulos por marca (icono + nombre debajo), con un circulo "+ Código" al
/// final. Generico para cualquier rubro. Hace scroll si hay muchos.
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

  static String _short(String name) {
    final s = name.replaceFirst(RegExp(r'^[^\s]+\s+'), '').trim();
    return s.isEmpty ? name : s;
  }

  static String _initial(String name) {
    final s = _short(name);
    return s.isNotEmpty ? s[0].toUpperCase() : '?';
  }

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

  void _addCode(BuildContext context) {
    HapticFeedback.lightImpact();
    final nav = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    nav.push(MaterialPageRoute(builder: (_) => const ClaimProfileView()));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TenantThemeBloc>().state;
    final tenants = state.availableTenants;
    final activeTenantId = state.tenantId;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Cambiar de negocio',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Elige a cuál quieres entrar',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 104,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final items = <Widget>[
                      for (var i = 0; i < tenants.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: _CircleItem(
                            name: _short(tenants[i].name),
                            initial: _initial(tenants[i].name),
                            accent: tenants[i].colors.primaryGold,
                            isActive: tenants[i].id == activeTenantId,
                            isSelecting: _selecting == tenants[i].id,
                            onTap: () =>
                                _select(context, tenants[i], activeTenantId),
                          )
                              .animate()
                              .fadeIn(delay: (50 * i).ms, duration: 280.ms)
                              .slideX(
                                begin: 0.18,
                                end: 0,
                                delay: (50 * i).ms,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: _AddCircle(onTap: () => _addCode(context)),
                      ),
                    ];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleItem extends StatelessWidget {
  const _CircleItem({
    required this.name,
    required this.initial,
    required this.accent,
    required this.isActive,
    required this.isSelecting,
    required this.onTap,
  });

  final String name;
  final String initial;
  final Color accent;
  final bool isActive;
  final bool isSelecting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.92,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: isActive ? 0.9 : 0.4),
                        width: isActive ? 2 : 1.2,
                      ),
                    ),
                    child: isSelecting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: accent),
                          )
                        : Text(
                            initial,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: -0.4,
                            ),
                          ),
                  ),
                  if (isActive && !isSelecting)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0C0C0C), width: 2.5),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: premiumOnAccent(accent),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color:
                    isActive ? Colors.white : Colors.white.withValues(alpha: 0.78),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCircle extends StatelessWidget {
  const _AddCircle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.92,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1.2),
              ),
              child: Icon(Icons.add_rounded,
                  size: 28, color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 9),
            Text(
              'Código',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
