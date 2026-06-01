import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';

class Phase5ConfirmationReceipt extends StatefulWidget {
  final Reservation reservation;
  final bool isConfirming;
  final bool isSuccess;
  final VoidCallback onConfirm;
  final VoidCallback onGoHome;

  const Phase5ConfirmationReceipt({
    super.key,
    required this.reservation,
    required this.isConfirming,
    required this.isSuccess,
    required this.onConfirm,
    required this.onGoHome,
  });

  @override
  State<Phase5ConfirmationReceipt> createState() =>
      _Phase5ConfirmationReceiptState();
}

class _Phase5ConfirmationReceiptState extends State<Phase5ConfirmationReceipt> {
  @override
  Widget build(BuildContext context) {
    if (widget.isSuccess) {
      return const SizedBox.shrink();
    }
    return _buildPreviewState(context);
  }

  Widget _buildPreviewState(BuildContext context) {
    final res = widget.reservation;
    final isDiscountActive = context.select((ReservationBloc bloc) => bloc.state.isDiscountActive);
    final basePrice = res.services.fold(0.0, (sum, item) => sum + item.price);
    
    final primaryService = res.services.isNotEmpty ? res.services.first.name : '—';
    final additionalServices = res.services.length > 1 
        ? res.services.skip(1).map((s) => s.name).join(', ')
        : 'Ninguno';

    final barberName = res.professional?.name ?? 'Máxima Disponibilidad';
    final dateStr = res.date != null
        ? DateFormat("EEEE d 'de' MMMM", 'es').format(res.date!)
        : '—';
    final timeStr = res.time ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5. CONFIRMA TU RESERVA',
          style: TextStyle(
            color: context.primaryGold,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('SERVICIO PRINCIPAL', primaryService, context),
              const SizedBox(height: 18),
              _buildDetailRow('ADICIONALES', additionalServices, context),
              const SizedBox(height: 18),
              _buildDetailRow('BARBERO', barberName.toUpperCase(), context),
              const SizedBox(height: 18),
              _buildDetailRow('FECHA Y HORA', '${dateStr.toUpperCase()}\n$timeStr', context, isMultiLine: true),
              
              const SizedBox(height: 28),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              const SizedBox(height: 24),
              if (isDiscountActive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SUBTOTAL',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'S/ ${basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DESCUENTO FIDELIDAD (50% OFF)',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '- S/ ${(basePrice * 0.5).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL A PAGAR',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'S/ ${res.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: context.primaryGold,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: widget.isConfirming ? null : widget.onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryGold,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: widget.isConfirming
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'CONFIRMAR RESERVACIÓN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
