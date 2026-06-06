import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

String adminMoney(double v) => 'S/ ${NumberFormat('#,##0.00', 'es').format(v)}';

/// Snackbar oscuro estándar del panel admin (un solo lugar para el estilo).
void adminSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A1A1A),
      content: Text(text, style: GoogleFonts.inter(color: Colors.white)),
    ),
  );
}

/// Loader centrado con el acento del tenant.
class AdminLoader extends StatelessWidget {
  const AdminLoader({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: CupertinoActivityIndicator(color: context.primaryGold, radius: 14),
      );
}

/// Pildora seleccionable (chip/toggle) con acento del tenant cuando está activa.
/// `expand: true` la envuelve en Expanded para repartir el ancho por igual.
class AdminChoiceChip extends StatelessWidget {
  const AdminChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    final chip = PremiumPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: expand
            ? const EdgeInsets.symmetric(vertical: 11)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: selected ? gold : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? gold : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: expand ? 13 : 12,
            fontWeight: FontWeight.w800,
            color: selected ? onAccent : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
    return expand ? Expanded(child: chip) : chip;
  }
}

/// Campo de texto dark estándar del panel (con label opcional encima).
class AdminTextField extends StatelessWidget {
  const AdminTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.number = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool number;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final field = TextField(
      controller: controller,
      cursorColor: gold,
      autofocus: autofocus,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon,
                color: Colors.white.withValues(alpha: 0.35), size: 20),
        filled: true,
        fillColor: const Color(0xFF141414),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.5)),
        ),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}

/// Botón principal crema (#F7F3EC) del design system, con estado de carga.
class AdminPrimaryButton extends StatelessWidget {
  const AdminPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: loading ? const Color(0xFFBDBAB2) : const Color(0xFFF7F3EC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.black),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}

/// Abre un bottom-sheet con la config estándar del panel (transparente + scroll).
Future<T?> showAdminSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => child,
  );
}

/// Andamiaje de bottom-sheet premium: grabber + contenedor 0E0E0E + título.
class AdminSheetScaffold extends StatelessWidget {
  const AdminSheetScaffold({
    super.key,
    this.title,
    required this.child,
    this.scrollable = true,
  });

  final String? title;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (title != null) ...[
          Text(
            title!,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),
        ],
        child,
      ],
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: scrollable ? SingleChildScrollView(child: content) : content,
          ),
        ),
      ),
    );
  }
}

class AdminScreenHeader extends StatelessWidget {
  const AdminScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          PremiumBackButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: gold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPeriodChips extends StatelessWidget {
  const AdminPeriodChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AdminChoiceChip(
            label: labels[i],
            selected: i == selected,
            expand: true,
            onTap: () => onSelected(i),
          ),
        ],
      ],
    );
  }
}

class AdminStatTile extends StatelessWidget {
  const AdminStatTile({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? gold.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: highlight ? gold : Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBreakdownRow extends StatelessWidget {
  const AdminBreakdownRow({
    super.key,
    required this.title,
    required this.amount,
    this.note,
  });

  final String title;
  final String amount;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: -0.3,
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 1),
                Text(
                  note!,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AdminEmptyHint extends StatelessWidget {
  const AdminEmptyHint({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class AdminErrorView extends StatelessWidget {
  const AdminErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              color: Colors.white.withValues(alpha: 0.3), size: 40),
          const SizedBox(height: 14),
          Text(
            'No se pudo cargar',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revisa tu conexión o permisos',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 18),
          PremiumPressable(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
