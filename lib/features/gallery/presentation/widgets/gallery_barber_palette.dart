import 'package:flutter/material.dart';

class GalleryBarberPalette {
  const GalleryBarberPalette._();

  static const List<Color> _palette = [
    Color(0xFFD4AF37),
    Color(0xFFB87333),
    Color(0xFFE6B89C),
    Color(0xFF7B9E89),
    Color(0xFF456A8A),
    Color(0xFFA85D5D),
    Color(0xFFC8A2C8),
    Color(0xFF8AB6D6),
  ];

  static Color forBarber(String? name) {
    if (name == null || name.trim().isEmpty) return _palette.first;
    final key = name.toLowerCase().trim();
    final hash = key.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    return _palette[hash % _palette.length];
  }
}
