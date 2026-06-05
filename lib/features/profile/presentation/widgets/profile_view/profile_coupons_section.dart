import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';

/// Seccion "Mis cupones" — cupones reales del cliente, mostrados de uno en uno
/// rotando automaticamente (estilo spotlight de productos del Inicio).
class ProfileCouponsSection extends StatelessWidget {
  const ProfileCouponsSection({super.key, required this.coupons});

  final List<CustomerCoupon> coupons;

  @override
  Widget build(BuildContext context) {
    final usable = coupons.where((c) => c.isUsable).toList();
    if (usable.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final gold = context.primaryGold;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number_rounded, size: 16, color: gold),
                const SizedBox(width: 8),
                Text(
                  'Mis cupones',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: gold.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '${usable.length}',
                    style: GoogleFonts.inter(color: gold, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _CouponSpotlight(coupons: usable),
          ],
        ).animate().fadeIn(delay: 240.ms, duration: 500.ms),
      ),
    );
  }
}

class _CouponSpotlight extends StatefulWidget {
  const _CouponSpotlight({required this.coupons});
  final List<CustomerCoupon> coupons;

  @override
  State<_CouponSpotlight> createState() => _CouponSpotlightState();
}

class _CouponSpotlightState extends State<_CouponSpotlight> {
  int _index = 0;
  Timer? _timer;
  PageController? _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 1.0);
    _startRotation();
  }

  void _startRotation() {
    _timer?.cancel();
    if (widget.coupons.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.coupons.length < 2) return;
      final next = (_index + 1) % widget.coupons.length;
      _pageCtrl?.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.coupons.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _index = i);
              _timer?.cancel();
              _startRotation();
            },
            itemBuilder: (_, i) => _CouponCard(coupon: widget.coupons[i]),
          ),
        ),
        if (widget.coupons.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(widget.coupons.length, (i) {
                final active = i == _index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _pageCtrl?.animateToPage(i, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? gold : Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Text(
                  '${_index + 1} / ${widget.coupons.length}',
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.55), letterSpacing: 1),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});
  final CustomerCoupon coupon;

  static const double _leftW = 100;
  static const Color _notchBg = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final d = coupon.validUntil;
    final venceStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Stack(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _leftW,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon.discountLabel,
                      style: GoogleFonts.inter(color: gold, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 2200.ms, delay: 1400.ms, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      'DESCUENTO',
                      style: GoogleFonts.inter(color: gold.withValues(alpha: 0.6), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.6),
                    ),
                  ],
                ),
              ),
              _DashedDivider(color: gold.withValues(alpha: 0.32)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        coupon.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(width: 5),
                          Text(
                            'Válido hasta $venceStr',
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: gold.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 14, color: gold),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                coupon.code,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoMono(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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
        // Troquel (perforacion) estilo ticket
        Positioned(left: _leftW - 7, top: -7, child: _notch()),
        Positioned(left: _leftW - 7, bottom: -7, child: _notch()),
      ],
    );
  }

  Widget _notch() => Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(color: _notchBg, shape: BoxShape.circle),
      );
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: 1,
        child: LayoutBuilder(
          builder: (context, c) {
            final count = (c.maxHeight / 7).floor().clamp(1, 40);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(count, (_) => Container(width: 1, height: 4, color: color)),
            );
          },
        ),
      ),
    );
  }
}
