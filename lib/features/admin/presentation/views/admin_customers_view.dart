import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_customer.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

class AdminCustomersView extends StatefulWidget {
  const AdminCustomersView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminCustomersView> createState() => _AdminCustomersViewState();
}

class _AdminCustomersViewState extends State<AdminCustomersView> {
  List<AdminCustomer>? _all;
  bool _loading = true;
  bool _error = false;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  AdminRepository get _repo => getIt<AdminRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final c = await _repo.fetchCustomers(tenantId: widget.tenantId);
      if (!mounted) return;
      setState(() {
        _all = c;
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

  List<AdminCustomer> get _filtered {
    final all = _all ?? const <AdminCustomer>[];
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.whatsapp.contains(q))
        .toList();
  }

  Future<void> _giveCoupon(AdminCustomer c) async {
    final promo = await _showPromoPicker(context, widget.tenantId);
    if (promo == null || promo.id == null) return;
    final emittedBy = Supabase.instance.client.auth.currentUser?.id;
    if (emittedBy == null) {
      if (mounted) adminSnack(context, 'Tu sesión expiró, vuelve a entrar');
      return;
    }
    try {
      final code = await _repo.emitCustomerCoupon(
        tenantId: widget.tenantId,
        customerId: c.id,
        promotionId: promo.id!,
        emittedBy: emittedBy,
      );
      if (!mounted) return;
      adminSnack(context, 'Cupón $code enviado a ${c.name}');
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo dar el cupón (quizás ya lo tiene o expiró).');
    }
  }

  Future<void> _adjustPoints(AdminCustomer c) async {
    final ok = await showPointsEditor(
      context,
      customer: c,
      onSubmit: (delta, reason) => _repo.adjustCustomerPoints(
        tenantId: widget.tenantId,
        customerId: c.id,
        delta: delta,
        reason: reason,
      ),
    );
    if (ok == true && mounted) {
      adminSnack(context, 'Puntos actualizados');
      _load();
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
              title: 'Clientes',
              subtitle: 'Dar cupones y puntos',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: AdminTextField(
                controller: _searchCtrl,
                hint: 'Buscar cliente...',
                prefixIcon: Icons.search_rounded,
                onChanged: (v) => setState(() => _query = v),
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
    final items = _filtered;
    if (items.isEmpty) {
      final hint = _query.trim().isEmpty
          ? 'Sin clientes'
          : 'Sin resultados para "${_query.trim()}"';
      return Center(child: AdminEmptyHint(text: hint));
    }
    return RefreshIndicator(
      color: context.primaryGold,
      backgroundColor: const Color(0xFF0E0E0E),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) => _customerCard(items[i]),
      ),
    );
  }

  Widget _customerCard(AdminCustomer c) {
    final gold = context.primaryGold;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
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
                  '${c.points} ${c.points == 1 ? 'punto' : 'puntos'}'
                  '${c.whatsapp.isNotEmpty ? '  ·  ${c.whatsapp}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(Icons.card_giftcard_rounded, () => _giveCoupon(c)),
          const SizedBox(width: 6),
          _iconBtn(Icons.stars_rounded, () => _adjustPoints(c)),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: gold, size: 18),
      ),
    );
  }
}

// ============================================================================
// Sheet: elegir promoción para dar como cupón
// ============================================================================

Future<AdminPromotion?> _showPromoPicker(BuildContext context, String tenantId) {
  return showAdminSheet<AdminPromotion>(context, _PromoPicker(tenantId: tenantId));
}

class _PromoPicker extends StatefulWidget {
  const _PromoPicker({required this.tenantId});

  final String tenantId;

  @override
  State<_PromoPicker> createState() => _PromoPickerState();
}

class _PromoPickerState extends State<_PromoPicker> {
  late final Future<List<AdminPromotion>> _future =
      getIt<AdminRepository>().fetchPromotions(tenantId: widget.tenantId);

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    return AdminSheetScaffold(
      title: 'Elige una promoción',
      scrollable: false,
      child: FutureBuilder<List<AdminPromotion>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: AdminLoader(),
            );
          }
          final promos =
              (snap.data ?? const []).where((p) => p.isActive).toList();
          if (promos.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AdminEmptyHint(text: 'No hay promociones activas'),
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: promos.length,
              itemBuilder: (_, i) {
                final p = promos[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PremiumPressable(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context, p);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p.discountLabel,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: onAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Sheet: ajustar puntos (+/-)
// ============================================================================

Future<bool?> showPointsEditor(
  BuildContext context, {
  required AdminCustomer customer,
  required Future<void> Function(int delta, String reason) onSubmit,
}) {
  return showAdminSheet<bool>(
      context, _PointsEditor(customer: customer, onSubmit: onSubmit));
}

class _PointsEditor extends StatefulWidget {
  const _PointsEditor({required this.customer, required this.onSubmit});

  final AdminCustomer customer;
  final Future<void> Function(int delta, String reason) onSubmit;

  @override
  State<_PointsEditor> createState() => _PointsEditorState();
}

class _PointsEditorState extends State<_PointsEditor> {
  bool _add = true;
  bool _saving = false;
  final TextEditingController _ctrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n <= 0) return adminSnack(context, 'Pon una cantidad');
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onSubmit(
        _add ? n : -n,
        _reasonCtrl.text.trim().isEmpty ? 'Ajuste manual' : _reasonCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudieron ajustar los puntos');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminSheetScaffold(
      title: 'Ajustar puntos',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.customer.name} · ${widget.customer.points} pts',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AdminChoiceChip(
                label: 'Sumar',
                selected: _add,
                expand: true,
                onTap: () => setState(() => _add = true),
              ),
              const SizedBox(width: 8),
              AdminChoiceChip(
                label: 'Quitar',
                selected: !_add,
                expand: true,
                onTap: () => setState(() => _add = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminTextField(controller: _ctrl, hint: 'Cantidad', number: true),
          const SizedBox(height: 10),
          AdminTextField(controller: _reasonCtrl, hint: 'Motivo (opcional)'),
          const SizedBox(height: 20),
          AdminPrimaryButton(
            label: 'Guardar',
            loading: _saving,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}
