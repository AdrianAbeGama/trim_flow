import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _PaymentNotConfigured extends StatelessWidget {
  const _PaymentNotConfigured({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: Colors.white.withValues(alpha: 0.25), size: 32),
            const SizedBox(height: 12),
            Text(
              '$method no configurado',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'El negocio aún no ha registrado sus datos de $method.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
                height: 1.4,
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
    return const _PaymentNotConfigured(method: 'Yape');
  }
}

class BcpPaymentDetails extends StatelessWidget {
  const BcpPaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PaymentNotConfigured(method: 'BCP');
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
