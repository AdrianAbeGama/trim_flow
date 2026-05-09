import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/auth/presentation/widgets/qr_scanner_facade.dart';

class AccessCodeView extends StatefulWidget {
  const AccessCodeView({super.key, required this.onCodeValidated});

  final Function(String code) onCodeValidated;

  @override
  State<AccessCodeView> createState() => _AccessCodeViewState();
}

class _AccessCodeViewState extends State<AccessCodeView> {
  String _code = "";

  void _onNumberPressed(String number) {
    if (_code.length < 10) {
      setState(() => _code += number);
    }
  }

  void _onDelete() {
    if (_code.isNotEmpty) {
      setState(() => _code = _code.substring(0, _code.length - 1));
    }
  }

  void _onConfirm() {
    if (_code == "1" || _code == "2") {
      widget.onCodeValidated(_code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido. Usa 1 o 2.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            const Text(
              'TRIMFLOW',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w200, letterSpacing: 8),
            ),
            const Spacer(),
            
            // Visualizador de Código
            const Text('Identifícate', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 50),
            _buildCodeDisplay(),
            const Spacer(),
            
            // Teclado Numérico Compacto
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((n) => _buildKey(n)),
                  const SizedBox.shrink(),
                  _buildKey('0'),
                  _buildKey('back', isIcon: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botones de Acción Abajo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QrScannerFacade()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded, color: context.primaryGold, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _code.isNotEmpty ? _onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryGold,
                        foregroundColor: context.backgroundBlack,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                        elevation: 0,
                      ),
                      child: const Text('CONFIRMAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(10, (index) {
          final hasChar = index < _code.length;
          return Container(
            width: 25,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: hasChar ? context.primaryGold : Colors.white10,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              hasChar ? _code[index] : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.primaryGold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKey(String label, {bool isIcon = false}) {
    return GestureDetector(
      onTap: () => isIcon ? _onDelete() : _onNumberPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: isIcon
              ? const Icon(Icons.backspace_outlined, color: Colors.white24, size: 18)
              : Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }
}
