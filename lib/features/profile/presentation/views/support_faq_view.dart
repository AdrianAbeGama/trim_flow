import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

const List<_FaqItem> _faqs = [
  _FaqItem(
    question: 'Como reservo una cita?',
    answer:
        'Entra a la pestana Reservar, elige la barberia, el servicio y al '
        'profesional, selecciona el dia y la hora que prefieras y confirma. '
        'Recibiras tu ticket con todos los detalles.',
  ),
  _FaqItem(
    question: 'Como funcionan los puntos?',
    answer:
        'Ganas puntos cada vez que reservas y completas una cita desde la app. '
        'Acumulalos y canjealos por cupones y descuentos en tu barberia.',
  ),
  _FaqItem(
    question: 'Como agrego otra barberia?',
    answer:
        'Con el codigo TRF que te dan al reservar en la web, lo pegas en '
        'Perfil > Cambiar de negocio. La nueva barberia aparecera en tu lista '
        'y podras alternar entre ellas cuando quieras.',
  ),
  _FaqItem(
    question: 'Como invito a un amigo?',
    answer:
        'En tu perfil encontraras tu codigo de referido. Compartelo con quien '
        'quieras: cuando tu amigo lo use, ambos reciben beneficios.',
  ),
  _FaqItem(
    question: 'Como cambio mis datos?',
    answer:
        'Abre tu perfil y toca editar. Puedes actualizar tu nombre, foto y '
        'datos de contacto. Algunos datos como la fecha de nacimiento no se '
        'pueden modificar una vez guardados.',
  ),
  _FaqItem(
    question: 'Puedo cancelar una cita?',
    answer:
        'Si. Entra a la cita desde tu historial y elige cancelar. Te '
        'recomendamos hacerlo con anticipacion para liberar el horario a otros '
        'clientes.',
  ),
  _FaqItem(
    question: 'Como activo las notificaciones?',
    answer:
        'Ve a Perfil > Configuracion y activa el interruptor de notificaciones. '
        'Te avisaremos sobre tus citas, recordatorios y ofertas.',
  ),
  _FaqItem(
    question: 'Como contacto a la barberia?',
    answer:
        'En el detalle de cada barberia veras sus datos de contacto. Tambien '
        'puedes escribirles directamente desde la informacion de tu cita.',
  ),
];

class SupportFaqView extends StatefulWidget {
  const SupportFaqView({super.key});

  @override
  State<SupportFaqView> createState() => _SupportFaqViewState();
}

class _SupportFaqViewState extends State<SupportFaqView> {
  int? _openIndex;

  void _toggle(int index) {
    HapticFeedback.selectionClick();
    setState(() => _openIndex = _openIndex == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            for (int i = 0; i < _faqs.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FaqCard(
                  item: _faqs[i],
                  expanded: _openIndex == i,
                  onTap: () => _toggle(i),
                )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 400.ms)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: (60 * i).ms,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PremiumBackButton(onTap: () => Navigator.pop(context)),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Preguntas frecuentes',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Resolvemos tus dudas',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: -0.2,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final _FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      onTap: onTap,
      pressedScale: 0.99,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expanded
                ? gold.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: 13,
                    color: expanded
                        ? gold
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: expanded ? double.infinity : 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: Text(
                    item.answer,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
