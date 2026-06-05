import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/data/offers_store.dart';
import 'package:trim_flow/features/products/domain/models/promo_offer.dart';

/// Panel administrativo de ofertas/promociones (pantalla completa).
class ProductOffersAdminView extends StatelessWidget {
  const ProductOffersAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Header(),
              Expanded(child: ProductOffersBody()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenido CRUD de ofertas (CTA + lista). Reutilizable como tab del admin.
class ProductOffersBody extends StatelessWidget {
  const ProductOffersBody({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: _NewOfferCta(onTap: () => _openForm(context)),
        ),
        Expanded(
          child: ValueListenableBuilder<List<PromoOffer>>(
            valueListenable: OffersStore.instance.offers,
            builder: (context, offers, _) {
              if (offers.isEmpty) return const _EmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return _OfferTile(
                    offer: offer,
                    gold: gold,
                    onEdit: () => _openForm(context, offer),
                    onDelete: () async {
                      final ok = await PremiumConfirmDelete.show(
                        context,
                        title: 'Eliminar oferta',
                        message: '¿Seguro que quieres eliminar "${offer.title}"?',
                      );
                      if (ok) OffersStore.instance.remove(offer.id);
                    },
                  ).animate().fadeIn(
                        delay: (40 * index).clamp(0, 300).ms,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, [PromoOffer? existing]) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OfferFormSheet(existing: existing),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumBackButton(onTap: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              const PremiumPill(icon: Icons.campaign_rounded, label: 'PANEL · OFERTAS'),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 22),
          Text(
            'Promos',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
          ).animate().fadeIn(delay: 120.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 4),
          Text(
            'Ofertas',
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.4, height: 1.05),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 16, height: 1.5, color: context.primaryGold),
              const SizedBox(width: 8),
              Text(
                'Banners que rotan en la tienda',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1),
              ),
            ],
          ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _NewOfferCta extends StatelessWidget {
  const _NewOfferCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 14, spreadRadius: 1)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.black, size: 18),
            const SizedBox(width: 8),
            Text('NUEVA OFERTA', style: GoogleFonts.inter(color: Colors.black, fontSize: 12.5, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.gold, required this.onEdit, required this.onDelete});

  final PromoOffer offer;
  final Color gold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(offer.icon, color: gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  offer.eyebrow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: gold, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 3),
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          _IconBtn(icon: Icons.edit_rounded, color: gold, onTap: onEdit),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.delete_outline_rounded, color: const Color(0xFFFF8A95), onTap: onDelete),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: gold.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.campaign_outlined, color: gold.withValues(alpha: 0.75), size: 40),
            ),
            const SizedBox(height: 20),
            Text('Sin ofertas aún', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
            const SizedBox(height: 6),
            Text(
              'Crea una oferta para que rote en el banner de la tienda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferFormSheet extends StatefulWidget {
  const _OfferFormSheet({this.existing});
  final PromoOffer? existing;

  @override
  State<_OfferFormSheet> createState() => _OfferFormSheetState();
}

class _OfferFormSheetState extends State<_OfferFormSheet> {
  late final TextEditingController _eyebrow;
  late final TextEditingController _title;
  late final TextEditingController _caption;
  late String _iconKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _eyebrow = TextEditingController(text: e?.eyebrow ?? '');
    _title = TextEditingController(text: e?.title ?? '');
    _caption = TextEditingController(text: e?.caption ?? '');
    _iconKey = e?.iconKey ?? PromoOffer.iconChoices.keys.first;
  }

  @override
  void dispose() {
    _eyebrow.dispose();
    _title.dispose();
    _caption.dispose();
    super.dispose();
  }

  bool get _canSave => _eyebrow.text.trim().isNotEmpty && _title.text.trim().isNotEmpty;

  void _save() {
    final store = OffersStore.instance;
    final e = widget.existing;
    if (e == null) {
      store.add(iconKey: _iconKey, eyebrow: _eyebrow.text.trim(), title: _title.text.trim(), caption: _caption.text.trim());
    } else {
      store.update(e.copyWith(iconKey: _iconKey, eyebrow: _eyebrow.text.trim(), title: _title.text.trim(), caption: _caption.text.trim()));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Nueva oferta' : 'Editar oferta',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4),
            ),
            const SizedBox(height: 16),
            const PremiumSectionLabel('Ícono'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PromoOffer.iconChoices.entries.map((entry) {
                final selected = entry.key == _iconKey;
                return PremiumPressable(
                  pressedScale: 0.9,
                  onTap: () => setState(() => _iconKey = entry.key),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: selected ? gold.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? gold.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Icon(entry.value, color: selected ? gold : Colors.white.withValues(alpha: 0.6), size: 20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const PremiumSectionLabel('Etiqueta'),
            const SizedBox(height: 8),
            _Field(controller: _eyebrow, hint: 'OFERTA DE LA SEMANA', onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            const PremiumSectionLabel('Título'),
            const SizedBox(height: 8),
            _Field(controller: _title, hint: '20% DESCUENTO', onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            const PremiumSectionLabel('Descripción'),
            const SizedBox(height: 8),
            _Field(controller: _caption, hint: 'En toda la línea de pomadas...', maxLines: 2),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PremiumPressable(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text('CANCELAR', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PremiumPressable(
                    onTap: _canSave ? _save : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _canSave ? gold : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('GUARDAR', style: GoogleFonts.inter(color: _canSave ? Colors.black : Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, this.maxLines = 1, this.onChanged});
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      cursorColor: gold,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFF0E0E0E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: gold, width: 1.2)),
      ),
    );
  }
}
