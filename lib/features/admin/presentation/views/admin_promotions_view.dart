import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_promotion_form.dart';

class AdminPromotionsView extends StatefulWidget {
  const AdminPromotionsView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminPromotionsView> createState() => _AdminPromotionsViewState();
}

class _AdminPromotionsViewState extends State<AdminPromotionsView> {
  List<AdminPromotion>? _items;
  bool _loading = true;
  bool _error = false;

  AdminRepository get _repo => getIt<AdminRepository>();

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
      final items = await _repo.fetchPromotions(tenantId: widget.tenantId);
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _persist(AdminPromotion promo) async {
    try {
      await _repo.savePromotion(tenantId: widget.tenantId, promo: promo);
      if (!mounted) return;
      _snack('Promoción guardada');
      _load();
    } catch (_) {
      if (!mounted) return;
      _snack('No se pudo guardar. Revisa el código (no repetido) o tus permisos.');
    }
  }

  Future<void> _new() async {
    final r = await showPromotionForm(context);
    if (r != null) await _persist(r);
  }

  Future<void> _edit(AdminPromotion p) async {
    final r = await showPromotionForm(context, promo: p);
    if (r != null) await _persist(r);
  }

  Future<void> _archive(AdminPromotion p) async {
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Archivar promoción',
      message: '¿Archivar "${p.name}"? Dejará de estar disponible.',
    );
    if (!ok || p.id == null) return;
    try {
      await _repo.archivePromotion(tenantId: widget.tenantId, promotionId: p.id!);
      if (!mounted) return;
      _snack('Promoción archivada');
      _load();
    } catch (_) {
      if (!mounted) return;
      _snack('No se pudo archivar');
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text(text, style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
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
              title: 'Promociones',
              subtitle: 'Ofertas y cupones',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: _newButton(),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _newButton() {
    final gold = context.primaryGold;
    return PremiumPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        _new();
      },
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: gold, size: 20),
            const SizedBox(width: 6),
            Text(
              'Nueva promoción',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return Center(
        child: CupertinoActivityIndicator(color: context.primaryGold, radius: 14),
      );
    }
    if (_error) return AdminErrorView(onRetry: _load);
    final items = _items ?? const [];
    if (items.isEmpty) {
      return const Center(child: AdminEmptyHint(text: 'Aún no hay promociones'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => _PromoCard(
        promo: items[i],
        onTap: () => _edit(items[i]),
        onArchive: () => _archive(items[i]),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.promo,
    required this.onTap,
    required this.onArchive,
  });

  final AdminPromotion promo;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    final until = promo.validUntil;
    return Opacity(
      opacity: promo.isActive ? 1 : 0.55,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PremiumPressable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    promo.discountLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: onAccent,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${promo.code}  ·  ${promo.triggerLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: gold,
                        ),
                      ),
                      if (until != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Vence ${DateFormat('dd/MM/yyyy').format(until.toLocal())}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                PremiumPressable(
                  pressedScale: 0.85,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onArchive();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 17,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
