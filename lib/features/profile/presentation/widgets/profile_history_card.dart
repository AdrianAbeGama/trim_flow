import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../bloc/profile_state.dart';

class ProfileHistoryCard extends StatelessWidget {
  final List<PastAppointment> history;
  final bool isExpanded;
  final VoidCallback onTap;

  const ProfileHistoryCard({
    super.key,
    required this.history,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expandable Header Row with Golden Vertical Indicator (TAREA 5)
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Elegant Vertical Gold Indicator + Weighty Title
                Row(
                  children: [
                    Container(
                      width: 3.0,
                      height: 13,
                      decoration: BoxDecoration(
                        color: context.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HISTORIAL DE CORTES',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // Rotating chevron
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.primaryGold.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Timeline Feed layout wrapped in AnimatedCrossFade
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: history.isEmpty
                ? _buildEmptyState()
                : _buildTimelineFeed(context),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: Text(
          'No tienes citas en el historial.',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // TAREA 4: REDISEÑO ULTRA-MINIMALISTA DEL HISTORIAL DE CORTES
  Widget _buildTimelineFeed(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
        final isLast = index == history.length - 1;
        final isCompleted = record.status == 'completed';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Dotted or solid vertical line + sutil node
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.greenAccent : Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.0,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              
              // Right: Content fully unboxed, continuous and minimal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila 1: Título y Precio cobrado en la misma línea
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              record.serviceName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/ ${(record.paidPrice ?? 40.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: record.wasDiscounted ? Colors.greenAccent : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Fila 2: Sub-info (Profesional / Sede) + Fecha
                      Text(
                        '${record.professionalName} · ${record.centerName} · ${record.dateStr}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Fila 3: Estado & Motivo o Valoración en Estrellas alineado y compacto
                      if (isCompleted && record.rating > 0) ...[
                        _buildStarRating(context, record.rating),
                      ] else if (record.status == 'cancelled' && record.cancellationReason != null) ...[
                        Text(
                          'Cancelado: "${record.cancellationReason}"',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else ...[
                        Text(
                          isCompleted ? 'Completado' : 'Cancelado',
                          style: TextStyle(
                            color: isCompleted ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarRating(BuildContext context, int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isSelected = index < rating;
        return Icon(
          Icons.star_rounded,
          color: isSelected ? context.primaryGold : Colors.white10,
          size: 11,
        );
      }),
    );
  }
}
