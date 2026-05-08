import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Si se está borrando, no interferimos
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i == 1 || i == 3) && i != digitsOnly.length - 1) {
        buffer.write(' / ');
      }
    }

    final resultText = buffer.toString();
    
    // Limitar a DD / MM / AAAA
    if (digitsOnly.length > 8) {
      return oldValue;
    }

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );
  }
}
