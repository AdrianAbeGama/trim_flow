// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ProductSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ProductSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF161616), // Dark premium background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        cursorColor: context.primaryGold,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.primaryGold.withValues(alpha: 0.8),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
