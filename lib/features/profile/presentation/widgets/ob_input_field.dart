import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ObInputField extends StatelessWidget {
  const ObInputField({
    required this.label,
    required this.controller,
    this.prefix,
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.maxLength,
    this.errorText,
    this.showCounter = false,
    this.hasPrefixDivider = false,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? prefix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? errorText;
  final bool showCounter;
  final bool hasPrefixDivider;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: errorText != null ? Colors.redAccent : context.primaryGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (showCounter && maxLength != null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return Text(
                    '${value.text.length} / $maxLength',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 10,
                    ),
                  );
                },
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          cursorColor: context.primaryGold,
          decoration: InputDecoration(
            counterText: "", 
            prefixIcon: prefix != null
                ? Container(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(prefix!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        if (hasPrefixDivider) ...[
                          const SizedBox(width: 12),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.15)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : context.primaryGold,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
