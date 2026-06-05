import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/staff/domain/models/staff_member.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Inputs y CTAs reutilizables del create form de la galería.
/// El header vive en gallery_form_header.dart.

// ============================================================================
// FIELDS BÁSICOS
// ============================================================================

class GalleryFormField extends StatelessWidget {
  const GalleryFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.30),
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFF111111),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.50), width: 1.2),
        ),
      ),
    );
  }
}

// ============================================================================
// BARBER DROPDOWN
// ============================================================================

class GalleryBarberDropdown extends StatelessWidget {
  const GalleryBarberDropdown({
    super.key,
    required this.staff,
    required this.loading,
    required this.selectedStaffId,
    required this.useNewBarber,
    required this.onStaffSelected,
    required this.onPickNewBarber,
  });

  final List<StaffMember> staff;
  final bool loading;
  final String? selectedStaffId;
  final bool useNewBarber;
  final ValueChanged<String> onStaffSelected;
  final VoidCallback onPickNewBarber;

  static const String _newBarberSentinel = '__new__';

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    if (loading) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            CupertinoActivityIndicator(color: gold, radius: 8),
            const SizedBox(width: 12),
            Text(
              'Cargando staff…',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final value = useNewBarber ? _newBarberSentinel : selectedStaffId;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: gold, size: 22),
          value: value,
          hint: Text(
            'Selecciona un barbero',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: [
            ...staff.map((m) => DropdownMenuItem<String>(
                  value: m.id,
                  child: _StaffOption(member: m),
                )),
            DropdownMenuItem<String>(
              value: _newBarberSentinel,
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, color: gold, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Agregar nuevo barbero',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) {
            if (val == null) return;
            HapticFeedback.selectionClick();
            if (val == _newBarberSentinel) {
              onPickNewBarber();
            } else {
              onStaffSelected(val);
            }
          },
        ),
      ),
    );
  }
}

class _StaffOption extends StatelessWidget {
  const _StaffOption({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: gold, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (member.specialty != null && member.specialty!.trim().isNotEmpty)
                Text(
                  member.specialty!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: gold.withValues(alpha: 0.8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CATEGORY PICKER
// ============================================================================

class GalleryCategoryPicker extends StatelessWidget {
  const GalleryCategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  final List<GalleryCategory> categories;
  final GalleryCategory? selected;
  final ValueChanged<GalleryCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          'No hay categorías. Crea una desde el panel admin.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected?.slug == c.slug;
        return GalleryPressable(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(c);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? gold : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? gold : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: gold.withValues(alpha: 0.30), blurRadius: 10)]
                  : null,
            ),
            child: Text(
              c.label.toUpperCase(),
              style: GoogleFonts.inter(
                color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// CTA BUTTONS — PICK + SUBMIT
// ============================================================================

class GalleryPickButton extends StatefulWidget {
  const GalleryPickButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<GalleryPickButton> createState() => _GalleryPickButtonState();
}

class _GalleryPickButtonState extends State<GalleryPickButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: gold.withValues(alpha: 0.40)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_rounded, color: gold, size: 15),
              const SizedBox(width: 8),
              Text(
                'AGREGAR FOTO',
                style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GallerySubmitButton extends StatefulWidget {
  const GallerySubmitButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<GallerySubmitButton> createState() => _GallerySubmitButtonState();
}

class _GallerySubmitButtonState extends State<GallerySubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final disabled = !widget.enabled;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: disabled ? Colors.white.withValues(alpha: 0.04) : null,
                gradient: disabled
                    ? null
                    : LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          gold,
                          Color.lerp(gold, Colors.white, 0.18) ?? gold,
                          gold,
                        ],
                        stops: [
                          (0.0 + _glow.value * 0.5).clamp(0.0, 1.0),
                          (0.4 + _glow.value * 0.4).clamp(0.0, 1.0),
                          (0.85 + _glow.value * 0.15).clamp(0.0, 1.0),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: disabled
                    ? null
                    : [
                        BoxShadow(
                          color: gold.withValues(alpha: 0.30 + 0.20 * _glow.value),
                          blurRadius: 16 + 8 * _glow.value,
                          spreadRadius: 0.5,
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_rounded,
                    size: 17,
                    color: disabled ? Colors.white.withValues(alpha: 0.3) : Colors.black,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: disabled
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
