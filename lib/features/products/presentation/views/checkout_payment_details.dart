import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';

void showPremiumFeedback(BuildContext context, String message) {
  AppToast.success(context, 'Copiado', message: 'Pégalo donde lo necesites.');
}

class CopyBadgeButton extends StatelessWidget {
  final String value;
  final String label;

  const CopyBadgeButton({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        showPremiumFeedback(context, '$label COPIADO');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryGold.withValues(alpha: 0.15),
              context.primaryGold.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.primaryGold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: context.primaryGold.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.primaryGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.copy_rounded,
                color: context.primaryGold,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'COPIAR $label',
              style: TextStyle(
                color: context.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YapePaymentDetails extends StatelessWidget {
  const YapePaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'https://yape.pe/pay?to=987654321',
                  version: QrVersions.auto,
                  size: 96,
                  gapless: false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAGO INSTANTÁNEO YAPE',
                      style: TextStyle(
                        color: context.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TITULAR',
                      style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const Text(
                      'Carlos',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'NÚMERO DE TELÉFONO',
                      style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const Text(
                      '987654321',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: double.infinity,
            child: CopyBadgeButton(value: '987654321', label: 'NÚMERO DE YAPE'),
          ),
        ],
      ),
    );
  }
}

class BcpPaymentDetails extends StatelessWidget {
  const BcpPaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSFERENCIA BANCARIA BCP',
            style: TextStyle(
              color: context.primaryGold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'TITULAR',
            style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const Text(
            'Carlos',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'NÚMERO DE CUENTA CORRIENTE',
            style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const Text(
            '191-98765432-1-01',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: double.infinity,
            child: CopyBadgeButton(value: '191-98765432-1-01', label: 'CUENTA BCP'),
          ),
        ],
      ),
    );
  }
}

class EfectivoPaymentDetails extends StatelessWidget {
  const EfectivoPaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.primaryGold.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.primaryGold.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: context.primaryGold, size: 24),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Por favor, acércate a recepción para confirmar tu pago.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
