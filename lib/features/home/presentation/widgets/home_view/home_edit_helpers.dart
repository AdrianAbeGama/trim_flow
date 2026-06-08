import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

// ============================================================================
// EDIT FIELD — campo de texto premium para edit sheets
// ============================================================================

class HomeEditField extends StatelessWidget {
  const HomeEditField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.primaryGold.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}


// ============================================================================
// CONFIRM & SAVE — sheet de confirmación para guardar cambios
// ============================================================================

Future<void> homeConfirmAndSave({
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) async {
  final gold = context.primaryGold;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.help_outline_rounded, color: gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirmar cambios',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: HomePressable(
                    onTap: () => Navigator.pop(sheetCtx, false),
                    pressedScale: 0.97,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CANCELAR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HomePressable(
                    onTap: () => Navigator.pop(sheetCtx, true),
                    pressedScale: 0.97,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'GUARDAR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  if (confirmed == true) onConfirm();
}

// ============================================================================
// 3. PRÓXIMA CITA
// ============================================================================


// ============================================================================
// IMAGE PICKER — pickAndCrop + ImageFieldPicker (galería + recorte)
// ============================================================================

class HomeImagePicker {
  static Future<String?> pickAndCrop(
    BuildContext context, {
    CropAspectRatio? aspectRatio,
    // ignore: unused_element_parameter
    String title = 'Cambiar imagen',
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) return null;

      final cropper = ImageCropper();
      final cropped = await cropper.cropImage(
        sourcePath: picked.path,
        aspectRatio: aspectRatio,
        compressQuality: 88,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar',
            toolbarColor: const Color(0xFF0A0A0A),
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFF0A0A0A),
            activeControlsWidgetColor: const Color(0xFFD4AF37),
            hideBottomControls: false,
            lockAspectRatio: aspectRatio != null,
          ),
          IOSUiSettings(
            title: 'Recortar',
            doneButtonTitle: 'Listo',
            cancelButtonTitle: 'Cancelar',
            aspectRatioLockEnabled: aspectRatio != null,
          ),
        ],
      );
      if (cropped == null) return null;
      return cropped.path;
    } catch (_) {
      return null;
    }
  }
}

/// Preview de imagen tocable que abre el image picker + crop.
class HomeImageFieldPicker extends StatelessWidget {
  const HomeImageFieldPicker({
    super.key,
    required this.label,
    required this.path,
    required this.onPicked,
    this.aspectRatio,
    this.height = 110,
  });

  final String label;
  final String path;
  final ValueChanged<String> onPicked;
  final CropAspectRatio? aspectRatio;
  final double height;

  bool get _hasImage => path.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        HomePressable(
          onTap: () async {
            final picked = await HomeImagePicker.pickAndCrop(
              context,
              aspectRatio: aspectRatio,
            );
            if (picked != null) onPicked(picked);
          },
          pressedScale: 0.99,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: gold.withValues(alpha: 0.25),
                style: _hasImage ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: _hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: path.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: path,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) =>
                                    Container(color: const Color(0xFF181818)),
                              )
                            : Image.file(File(path), fit: BoxFit.cover),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded, color: gold, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'CAMBIAR IMAGEN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded, color: gold, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        'ELEGIR DE GALERÍA',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Podrás recortar después',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EDIT SHEETS — Servicios y Productos CRUD inline
// ============================================================================

/// Helper que muestra sheets de gestión (lista + form) para servicios y
/// productos. Toca state.content vía HomeBloc, así que los cambios se reflejan
