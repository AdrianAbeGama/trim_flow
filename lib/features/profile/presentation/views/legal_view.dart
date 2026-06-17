import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';

class LegalView extends StatelessWidget {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PremiumBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Terminos y privacidad',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 22),
              _IntroCard(gold: gold)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms)
                  .slideY(
                    begin: 0.1, end: 0,
                    delay: 80.ms, duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 28),
              _SectionTitle(
                icon: FontAwesomeIcons.fileContract,
                title: 'Terminos y condiciones',
                gold: gold,
                index: 0,
              ),
              const SizedBox(height: 16),
              ..._buildBlocks(_terms, startIndex: 1),
              const SizedBox(height: 32),
              _SectionTitle(
                icon: FontAwesomeIcons.userShield,
                title: 'Politica de privacidad',
                gold: gold,
                index: 0,
              ),
              const SizedBox(height: 16),
              ..._buildBlocks(_privacy, startIndex: 1),
              const SizedBox(height: 28),
              _FooterMark(gold: gold)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBlocks(List<_LegalBlock> blocks, {required int startIndex}) {
    final widgets = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      widgets.add(
        _LegalParagraph(
          number: block.number,
          heading: block.heading,
          body: block.body,
        )
            .animate()
            .fadeIn(
              delay: (60 * (startIndex + i)).ms,
              duration: 400.ms,
            )
            .slideY(
              begin: 0.1, end: 0,
              delay: (60 * (startIndex + i)).ms,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
      );
      if (i != blocks.length - 1) {
        widgets.add(const SizedBox(height: 18));
      }
    }
    return widgets;
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.gold});

  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: FaIcon(FontAwesomeIcons.scroll, size: 15, color: gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ultima actualizacion: junio 2026',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lee con calma estos documentos. Describen como usas TrimFlow '
            'para reservar en tu barberia, como tratamos tus datos y que '
            'puedes esperar de nosotros. Este es un borrador editable y no '
            'constituye asesoria legal.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.65,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.gold,
    required this.index,
  });

  final FaIconData icon;
  final String title;
  final Color gold;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: 16, color: gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 400.ms)
        .slideY(
          begin: 0.1, end: 0,
          delay: (index * 60).ms, duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _LegalParagraph extends StatelessWidget {
  const _LegalParagraph({
    required this.number,
    required this.heading,
    required this.body,
  });

  final String number;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number  $heading',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.2,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.65,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _FooterMark extends StatelessWidget {
  const _FooterMark({required this.gold});

  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TrimflowLogo(color: gold.withValues(alpha: 0.5), size: 34),
          const SizedBox(height: 12),
          Text(
            'TRIMFLOW',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.22),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Borrador editable. No es asesoria legal.',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.15),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalBlock {
  const _LegalBlock(this.number, this.heading, this.body);

  final String number;
  final String heading;
  final String body;
}

const List<_LegalBlock> _terms = [
  _LegalBlock(
    '1.',
    'Aceptacion',
    'Al crear tu cuenta, reservar o usar TrimFlow aceptas estos terminos. '
        'Si no estas de acuerdo, no utilices la aplicacion. El uso continuado '
        'tras una actualizacion implica que aceptas la version vigente.',
  ),
  _LegalBlock(
    '2.',
    'Descripcion del servicio',
    'TrimFlow es una plataforma multi-tenant que conecta clientes con '
        'barberias en Peru. Permite reservar citas, acumular puntos de '
        'fidelidad y canjear cupones. Cada barberia gestiona de forma '
        'independiente sus horarios, servicios y promociones.',
  ),
  _LegalBlock(
    '3.',
    'Cuenta del usuario',
    'Tu cuenta nace de una reserva realizada en la web de la barberia. El '
        'codigo de acceso es personal y privado: no lo compartas. Eres '
        'responsable de la actividad realizada desde tu cuenta y de mantener '
        'tus datos de contacto actualizados.',
  ),
  _LegalBlock(
    '4.',
    'Uso aceptable',
    'Te comprometes a usar TrimFlow de buena fe, sin suplantar a terceros, '
        'sin crear reservas falsas y sin intentar vulnerar la seguridad de la '
        'plataforma. Podemos suspender cuentas que incumplan estas reglas.',
  ),
  _LegalBlock(
    '5.',
    'Reservas y cancelaciones',
    'Una reserva confirmada es un compromiso con la barberia. Puedes '
        'cancelar o reprogramar dentro de los plazos que cada local defina. '
        'Las inasistencias reiteradas pueden afectar tu acceso a futuras '
        'reservas o promociones.',
  ),
  _LegalBlock(
    '6.',
    'Puntos y recompensas',
    'Los puntos de fidelidad y cupones son beneficios promocionales sin '
        'valor monetario. No son transferibles ni canjeables por dinero, '
        'pueden caducar y la barberia puede modificar o retirar sus '
        'condiciones en cualquier momento.',
  ),
  _LegalBlock(
    '7.',
    'Propiedad intelectual',
    'La marca TrimFlow, su diseno, codigo y contenidos estan protegidos. No '
        'puedes copiarlos, distribuirlos ni crear obras derivadas sin '
        'autorizacion. Las marcas de cada barberia pertenecen a sus '
        'respectivos titulares.',
  ),
  _LegalBlock(
    '8.',
    'Limitacion de responsabilidad',
    'TrimFlow es una herramienta de intermediacion. El servicio de barberia '
        'lo presta cada local de forma directa. No respondemos por la calidad '
        'del corte ni por disputas entre cliente y barberia, salvo lo que '
        'exija la ley. El servicio se ofrece tal cual, sin garantias de '
        'disponibilidad ininterrumpida.',
  ),
  _LegalBlock(
    '9.',
    'Cambios en los terminos',
    'Podemos actualizar estos terminos para reflejar mejoras o cambios '
        'legales. Te avisaremos dentro de la app cuando haya cambios '
        'relevantes y la fecha de actualizacion siempre estara visible arriba.',
  ),
  _LegalBlock(
    '10.',
    'Ley aplicable',
    'Estos terminos se rigen por las leyes de la Republica del Peru. '
        'Cualquier controversia se somete a los jueces y tribunales '
        'competentes del Peru.',
  ),
  _LegalBlock(
    '11.',
    'Contacto',
    'Para consultas sobre estos terminos escribenos desde la seccion de '
        'soporte de la app o al correo de atencion al cliente de TrimFlow.',
  ),
];

const List<_LegalBlock> _privacy = [
  _LegalBlock(
    '1.',
    'Que datos recogemos',
    'Recogemos tu nombre, correo electronico, telefono o WhatsApp, fecha de '
        'nacimiento y el historial de tus citas. Tambien guardamos tus puntos '
        'y cupones para que tu experiencia sea continua entre barberias.',
  ),
  _LegalBlock(
    '2.',
    'Para que usamos tus datos',
    'Usamos tus datos para gestionar reservas, recordarte tus citas, '
        'aplicar tu programa de fidelidad y mejorar el servicio. La fecha de '
        'nacimiento nos permite enviarte beneficios de cumpleanos.',
  ),
  _LegalBlock(
    '3.',
    'Base legal y consentimiento',
    'Tratamos tus datos sobre la base de tu consentimiento y de la '
        'ejecucion del servicio que solicitas al reservar. Puedes retirar tu '
        'consentimiento cuando quieras, sin afectar tratamientos previos.',
  ),
  _LegalBlock(
    '4.',
    'No vendemos tus datos',
    'Nunca vendemos ni alquilamos tus datos personales a terceros con fines '
        'publicitarios. Tu informacion no es un producto.',
  ),
  _LegalBlock(
    '5.',
    'Con quien compartimos',
    'Compartimos tus datos unicamente con la barberia donde reservas, para '
        'que pueda atenderte, y con proveedores tecnicos que nos ayudan a '
        'operar la app bajo estrictos acuerdos de confidencialidad.',
  ),
  _LegalBlock(
    '6.',
    'Seguridad',
    'Aplicamos medidas tecnicas y organizativas para proteger tu '
        'informacion: cifrado en transito, accesos restringidos y registros '
        'de actividad. Ningun sistema es infalible, pero trabajamos para '
        'minimizar riesgos.',
  ),
  _LegalBlock(
    '7.',
    'Tus derechos',
    'Tienes derecho a acceder, corregir y solicitar la eliminacion de tus '
        'datos. Para ejercerlos contacta a soporte desde la app y atenderemos '
        'tu solicitud dentro de los plazos que indique la ley.',
  ),
  _LegalBlock(
    '8.',
    'Permisos del dispositivo',
    'Pedimos permiso de notificaciones para recordarte tus citas y avisarte '
        'de promociones, y permiso de camara unicamente para escanear el '
        'codigo QR al validar tu visita. Puedes revocarlos desde los ajustes '
        'de tu telefono.',
  ),
  _LegalBlock(
    '9.',
    'Retencion',
    'Conservamos tus datos mientras tu cuenta este activa y durante el plazo '
        'necesario para cumplir obligaciones legales. Despues los eliminamos o '
        'anonimizamos de forma segura.',
  ),
  _LegalBlock(
    '10.',
    'Responsable del tratamiento',
    'El responsable del tratamiento de tus datos es TrimFlow. Para cualquier '
        'duda sobre privacidad puedes escribirnos desde la seccion de soporte '
        'de la app.',
  ),
];
