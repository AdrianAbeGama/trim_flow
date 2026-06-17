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

  Future<void> _new() async {
    final ok = await showPromotionForm(
      context,
      onSubmit: (p) => _repo.savePromotion(tenantId: widget.tenantId, promo: p),
    );
    if (ok == true && mounted) {
      adminSnack(context, 'Promoción guardada');
      _load();
    }
  }

  Future<void> _edit(AdminPromotion p) async {
    final ok = await showPromotionForm(
      context,
      promo: p,
      onSubmit: (np) =>
          _repo.savePromotion(tenantId: widget.tenantId, promo: np),
    );
    if (ok == true && mounted) {
      adminSnack(context, 'Promoción guardada');
      _load();
    }
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
      adminSnack(context, 'Promoción archivada');
      _load();
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo archivar');
    }
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
    if (_loading) return const AdminLoader();
    if (_error) return AdminErrorView(onRetry: _load);
    final items = _items ?? const [];
    if (items.isEmpty) {
      return const Center(child: AdminEmptyHint(text: 'Aún no hay promociones'));
    }
    return RefreshIndicator(
      color: context.primaryGold,
      backgroundColor: const Color(0xFF0E0E0E),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) => _PromoCard(
          promo: items[i],
          onTap: () => _edit(items[i]),
          onArchive: () => _archive(items[i]),
        ),
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

  ({String label, Color color}) _status(BuildContext context) {
    final now = DateTime.now();
    if (!promo.isActive) {
      return (label: 'INACTIVA', color: Colors.white.withValues(alpha: 0.45));
    }
    if (promo.validUntil != null && promo.validUntil!.isBefore(now)) {
      return (label: 'VENCIDA', color: const Color(0xFFCF6679));
    }
    if (promo.validFrom.isAfter(now)) {
      return (label: 'PROGRAMADA', color: Colors.white.withValues(alpha: 0.6));
    }
    return (label: 'ACTIVA', color: context.primaryGold);
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final until = promo.validUntil;
    final status = _status(context);
    final venceStr =
        until == null ? null : DateFormat('dd/MM/yyyy').format(until.toLocal());
    return Opacity(
      opacity: promo.isActive ? 1 : 0.55,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PremiumPressable(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF17120C), Color(0xFF111111)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withValues(alpha: 0.3)),
                ),
                child: SizedBox(
                  height: 112,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 92,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo.discountLabel,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: gold,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'DESCUENTO',
                              style: GoogleFonts.inter(
                                color: gold.withValues(alpha: 0.6),
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _PromoDashed(color: gold.withValues(alpha: 0.32)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      promo.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusPill(
                                      label: status.label, color: status.color),
                                  const SizedBox(width: 2),
                                  PremiumPressable(
                                    pressedScale: 0.85,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      onArchive();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.archive_outlined,
                                        size: 16,
                                        color:
                                            Colors.white.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.bolt_rounded, size: 12, color: gold),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      promo.triggerLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (venceStr != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(Icons.schedule_rounded,
                                        size: 11,
                                        color: Colors.white
                                            .withValues(alpha: 0.4)),
                                    const SizedBox(width: 3),
                                    Text(
                                      venceStr,
                                      style: GoogleFonts.inter(
                                        color:
                                            Colors.white.withValues(alpha: 0.45),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: gold.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      color: gold.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.qr_code_2_rounded,
                                        size: 14, color: gold),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        promo.code,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.robotoMono(
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(left: 85, top: -7, child: _PromoNotch()),
              const Positioned(left: 85, bottom: -7, child: _PromoNotch()),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _PromoNotch extends StatelessWidget {
  const _PromoNotch();

  @override
  Widget build(BuildContext context) => Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          shape: BoxShape.circle,
        ),
      );
}

class _PromoDashed extends StatelessWidget {
  const _PromoDashed({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SizedBox(
        width: 1,
        child: LayoutBuilder(
          builder: (context, c) {
            final count = (c.maxHeight / 7).floor().clamp(1, 40);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                count,
                (_) => Container(width: 1, height: 4, color: color),
              ),
            );
          },
        ),
      ),
    );
  }
}
