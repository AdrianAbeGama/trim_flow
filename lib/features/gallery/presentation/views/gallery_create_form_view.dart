import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_crop_view.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_form_fields.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_form_header.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_shots_grid.dart';

/// Agregar fotos al portafolio. La foto se publica SIEMPRE en la cuenta del
/// barbero logueado (el backend la asocia por `auth.uid()`), por eso aquí solo
/// se elige el servicio y las fotos.
class GalleryCreateFormView extends StatefulWidget {
  const GalleryCreateFormView({super.key});

  @override
  State<GalleryCreateFormView> createState() => _GalleryCreateFormViewState();
}

class _GalleryCreateFormViewState extends State<GalleryCreateFormView> {
  final List<PendingShot> _shots = [];
  GalleryCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final cats = context.read<GalleryBloc>().state.categories;
    if (cats.isNotEmpty) _selectedCategory = cats.first;
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1280,
    );
    if (picked == null) return;
    await _cropPath(picked.path, isNew: true);
  }

  Future<void> _cropAt(int index) async {
    final shot = _shots[index];
    if (!shot.isLocal) return;
    await _cropPath(shot.path, replaceIndex: index);
  }

  Future<void> _cropPath(String path,
      {bool isNew = false, int? replaceIndex}) async {
    if (!mounted) return;
    // Recortador premium dentro de la app (estilo IG): marco fijo + arrastrar
    // y hacer zoom. Por defecto vertical (4:5), que luce mejor en el portafolio.
    final croppedPath = await PremiumCropView.show(
      context,
      sourcePath: path,
      initialAspect: 4 / 5,
    );
    if (!mounted) return;
    if (croppedPath == null) {
      if (isNew) {
        setState(() => _shots.add(PendingShot(path: path, isLocal: true)));
      }
      return;
    }
    setState(() {
      final newShot = PendingShot(path: croppedPath, isLocal: true);
      if (replaceIndex != null) {
        _shots[replaceIndex] = newShot;
      } else {
        _shots.add(newShot);
      }
    });
  }

  void _removeAt(int index) {
    HapticFeedback.lightImpact();
    setState(() => _shots.removeAt(index));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _shots.removeAt(oldIndex);
      _shots.insert(newIndex, item);
    });
  }

  Future<void> _submit() async {
    if (_shots.isEmpty || _selectedCategory == null) return;
    final bloc = context.read<GalleryBloc>();
    final overlay = Overlay.of(context, rootOverlay: true);
    final count = _shots.length;
    final now = DateTime.now();
    HapticFeedback.mediumImpact();
    for (var i = 0; i < _shots.length; i++) {
      final shot = _shots[i];
      bloc.add(GalleryEvent.itemAdded(GalleryItem(
        externalId: 'local_${now.microsecondsSinceEpoch}_$i',
        imageUrl: shot.path,
        isLocalAsset: shot.isLocal,
        categorySlug: _selectedCategory!.slug,
        categoryLabel: _selectedCategory!.label,
        createdAt: now.add(Duration(milliseconds: i)),
        displayOrder: i,
      )));
    }
    if (!mounted) return;
    Navigator.pop(context);
    AppToast.showOn(overlay,
        type: AppToastType.success,
        title: count > 1 ? '$count fotos agregadas' : 'Foto agregada',
        message: 'Ya están en tu portafolio.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            final canSubmit = _shots.isNotEmpty && _selectedCategory != null;
            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  GalleryFormHeader(
                    isEditing: false,
                    onBack: () => Navigator.pop(context),
                    onDelete: null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: _buildBody(state, canSubmit),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(GalleryState state, bool canSubmit) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GallerySectionLabel('Servicio'),
        const SizedBox(height: 10),
        GalleryCategoryPicker(
          categories: state.categories,
          selected: _selectedCategory,
          onChanged: (c) => setState(() => _selectedCategory = c),
        ),
        const SizedBox(height: 24),
        GallerySectionLabel('Fotos · ${_shots.length}'),
        const SizedBox(height: 10),
        GalleryShotsGrid(
          shots: _shots,
          onCrop: _cropAt,
          onRemove: _removeAt,
          onReorder: _reorder,
          onAdd: _pickFromGallery,
        ),
        if (_shots.isNotEmpty) ...[
          const SizedBox(height: 18),
          GalleryPickButton(onTap: _pickFromGallery),
        ],
        const SizedBox(height: 24),
        GallerySubmitButton(
          label: 'PUBLICAR EN PORTAFOLIO',
          enabled: canSubmit,
          onTap: _submit,
        ),
        if (!canSubmit) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: gold, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Elige un servicio y al menos una foto.',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
