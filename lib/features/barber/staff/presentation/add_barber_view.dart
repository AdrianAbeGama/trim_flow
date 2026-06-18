import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/staff/data/staff_admin_repository.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';

/// Formulario premium para que el admin agregue un barbero a su barberia. Llama
/// a la Edge Function `create-barber` y, al crear, muestra el enlace de
/// activacion para compartir por WhatsApp (el barbero pone su contraseña).
class AddBarberView extends StatefulWidget {
  const AddBarberView({
    super.key,
    required this.tenantId,
    required this.branches,
  });

  final String tenantId;
  final List<BranchOption> branches;

  @override
  State<AddBarberView> createState() => _AddBarberViewState();
}

class _AddBarberViewState extends State<AddBarberView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _repo = StaffAdminRepository(Supabase.instance.client);

  String? _branchId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.branches.length == 1) _branchId = widget.branches.first.id;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_branchId == null) {
      AppToast.warning(context, 'Falta la sucursal',
          message: 'Elige en qué sucursal trabajará.');
      return;
    }
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    try {
      final result = await _repo.createBarber(
        email: _emailCtrl.text,
        fullName: _nameCtrl.text,
        branchId: _branchId!,
        specialty: _specialtyCtrl.text,
        phone: _phoneCtrl.text,
      );
      if (!mounted) return;
      await _AddBarberResultSheet.show(context, result);
      if (mounted) Navigator.pop(context, true);
    } on CreateBarberException catch (e) {
      if (mounted) setState(() => _busy = false);
      if (mounted) {
        AppToast.error(context, 'No se pudo crear', message: e.message);
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      if (mounted) {
        AppToast.error(context, 'No se pudo crear',
            message: 'Revisa tu conexión e intenta de nuevo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PremiumBackButton(onTap: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Agregar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barbero',
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.4,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Le crearemos su cuenta y un enlace para que active su contraseña.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ObInputField(
                        label: 'Correo',
                        controller: _emailCtrl,
                        hintText: 'barbero@correo.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Campo requerido';
                          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                          return ok ? null : 'Correo no válido';
                        },
                      ),
                      ObInputField(
                        label: 'Nombre completo',
                        controller: _nameCtrl,
                        maxLength: 40,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                      ),
                      _BranchPicker(
                        branches: widget.branches,
                        selectedId: _branchId,
                        gold: gold,
                        onSelect: (id) => setState(() => _branchId = id),
                      ),
                      const SizedBox(height: 20),
                      ObInputField(
                        label: 'Especialidad (opcional)',
                        controller: _specialtyCtrl,
                        hintText: 'Ej. Fade, barba, diseño',
                        maxLength: 30,
                      ),
                      ObInputField(
                        label: 'WhatsApp (opcional)',
                        controller: _phoneCtrl,
                        prefix: '+51',
                        hasPrefixDivider: true,
                        maxLength: 9,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _SubmitBar(busy: _busy, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({
    required this.branches,
    required this.selectedId,
    required this.gold,
    required this.onSelect,
  });

  final List<BranchOption> branches;
  final String? selectedId;
  final Color gold;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUCURSAL',
          style: TextStyle(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        if (branches.isEmpty)
          Text(
            'No hay sucursales activas. Crea una primero.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final b in branches)
                _BranchChip(
                  label: b.name,
                  selected: b.id == selectedId,
                  gold: gold,
                  onTap: () => onSelect(b.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({
    required this.label,
    required this.selected,
    required this.gold,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? gold.withValues(alpha: 0.14) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? gold.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.storefront_outlined,
              size: 16,
              color: selected ? gold : Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewPadding.bottom + 14),
      decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
      child: PremiumPressable(
        pressedScale: 0.98,
        onTap: busy ? () {} : onTap,
        child: Opacity(
          opacity: busy ? 0.7 : 1,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: Colors.black),
                  )
                : Text(
                    'CREAR BARBERO',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Resultado: muestra el enlace de activacion para compartir (camino principal
/// por WhatsApp, como indica el contrato del backend).
class _AddBarberResultSheet extends StatelessWidget {
  const _AddBarberResultSheet({required this.result});
  final CreateBarberResult result;

  static Future<void> show(BuildContext context, CreateBarberResult result) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBarberResultSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final link = result.activationLink;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.check_rounded, color: gold, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${result.fullName} fue creado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  link != null
                      ? 'Comparte este enlace para que active su cuenta y ponga su contraseña.'
                      : 'El barbero fue creado. Reenvía la invitación desde el panel web.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (link != null) ...[
                _LinkChip(link: link, gold: gold),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _ResultButton(
                    icon: null,
                    label: 'COMPARTIR POR WHATSAPP',
                    filled: true,
                    gold: gold,
                    onTap: () {
                      SharePlus.instance.share(ShareParams(
                        text:
                            'Hola ${result.fullName}, activa tu cuenta de barbero en TrimFlow y pon tu contraseña aquí: $link',
                      ));
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'LISTO',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enlace de activacion: compacto en una linea; con opcion de ver el link
/// completo (expandir) y de copiarlo.
class _LinkChip extends StatefulWidget {
  const _LinkChip({required this.link, required this.gold});
  final String link;
  final Color gold;

  @override
  State<_LinkChip> createState() => _LinkChipState();
}

class _LinkChipState extends State<_LinkChip> {
  bool _expanded = false;

  void _copy() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.link));
    AppToast.success(context, 'Enlace copiado',
        message: 'Pégalo o compártelo con el barbero.');
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final gold = widget.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.link_rounded, color: gold, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enlace de activación',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _expanded ? 'Toca para ocultar' : widget.link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _ChipIcon(icon: Icons.copy_rounded, onTap: _copy),
              _ChipIcon(
                icon: _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                onTap: _toggle,
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            Container(
              height: 0.6,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 12),
            SelectableText(
              widget.link,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 18),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.gold,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool filled;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFF7F3EC) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16, color: filled ? Colors.black : Colors.white70),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: filled ? Colors.black : Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
