import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/domain/models/home_content.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_helpers.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';


class HomeSocialWizardSheet extends StatefulWidget {
  const HomeSocialWizardSheet({
    super.key,
    required this.socials,
    required this.initialContent,
    required this.onClose,
  });

  final List<HomeSocialSpec> socials;
  final HomeContent initialContent;
  final VoidCallback onClose;

  @override
  State<HomeSocialWizardSheet> createState() => _SocialWizardSheetState();
}

class _SocialWizardSheetState extends State<HomeSocialWizardSheet> {
  int _step = 0; // 0 = selección, 1 = URLs
  late final Set<String> _enabled;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _enabled = {
      for (final entry in widget.initialContent.socialLinks.entries)
        if (widget.socials.any((s) => s.key == entry.key)) entry.key,
    };
    _controllers = {
      for (final spec in widget.socials)
        spec.key: TextEditingController(
          text: widget.initialContent.socialLinks[spec.key] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final bloc = context.read<HomeBloc>();
    homeConfirmAndSave(
      context: context,
      message: '¿Guardar las redes sociales?',
      onConfirm: () {
        HapticFeedback.mediumImpact();
        for (final spec in widget.socials) {
          final active = _enabled.contains(spec.key);
          final url = active ? _controllers[spec.key]!.text : '';
          bloc.add(HomeEvent.updateSocialLink(spec.key, url));
        }
        widget.onClose();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12,
        right: 12,
        top: 140,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.58,
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // === Header con paso actual y close ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Step indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PASO ${_step + 1} / 2',
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: gold,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _step == 0 ? 'Elige tus redes' : 'Pega tus links',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _step == 0
                            ? 'Activa solo las que uses'
                            : '${_enabled.length} red${_enabled.length == 1 ? '' : 'es'} activa${_enabled.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.42),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // === Contenido con transición ===
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _step == 0
                    ? _buildStepSelection(gold)
                    : _buildStepUrls(gold),
              ),
            ),
            const SizedBox(height: 12),
            // === Footer: navegación ===
            Row(
              children: [
                if (_step == 1)
                  Expanded(
                    flex: 2,
                    child: HomePressable(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _step = 0);
                      },
                      pressedScale: 0.97,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ATRÁS',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_step == 1) const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: HomePressable(
                    onTap: _enabled.isEmpty && _step == 0
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            if (_step == 0) {
                              setState(() => _step = 1);
                            } else {
                              _save();
                            }
                          },
                    pressedScale: 0.97,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: (_step == 0 && _enabled.isEmpty)
                            ? Colors.white.withValues(alpha: 0.04)
                            : gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _step == 0 ? 'SIGUIENTE →' : 'GUARDAR',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: (_step == 0 && _enabled.isEmpty)
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.black,
                          letterSpacing: 1.4,
                        ),
                      ),
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

  /// PASO 1: chips compactos en grid, multi-select
  Widget _buildStepSelection(Color gold) {
    return SingleChildScrollView(
      key: const ValueKey('step0'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final spec in widget.socials)
            _SocialChip(
              spec: spec,
              selected: _enabled.contains(spec.key),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (_enabled.contains(spec.key)) {
                    _enabled.remove(spec.key);
                  } else {
                    _enabled.add(spec.key);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  /// PASO 2: lista compacta de URL fields para las redes activas
  Widget _buildStepUrls(Color gold) {
    final activeSpecs = widget.socials.where((s) => _enabled.contains(s.key)).toList();
    if (activeSpecs.isEmpty) {
      return Container(
        key: const ValueKey('step1-empty'),
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Text(
          'No hay redes activadas.\nVuelve al paso 1.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      child: Column(
        children: [
          for (var i = 0; i < activeSpecs.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _SocialUrlRow(
              spec: activeSpecs[i],
              controller: _controllers[activeSpecs[i].key]!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip compacto con icono brand. Selected → background brand color + check.
class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final HomeSocialSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomePressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? spec.brandColor.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? spec.brandColor.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            spec.builder(
              selected ? spec.brandColor : Colors.white.withValues(alpha: 0.55),
              14,
            ),
            const SizedBox(width: 7),
            Text(
              spec.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.55),
                letterSpacing: -0.1,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: spec.brandColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Row del paso 2: icono brand + URL input minimal.
class _SocialUrlRow extends StatelessWidget {
  const _SocialUrlRow({required this.spec, required this.controller});

  final HomeSocialSpec spec;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: spec.brandColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: spec.builder(spec.brandColor, 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              labelText: spec.label,
              labelStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 0.4,
              ),
              hintText: 'https://...',
              hintStyle: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: spec.brandColor.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

