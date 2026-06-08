import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/staff/domain/models/staff_member.dart';
import 'package:trim_flow/core/staff/domain/repositories/staff_repository.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_form_fields.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_form_header.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_shots_grid.dart';

/// Vista para crear/editar un portafolio (set de fotos del barbero).
/// Toda la UI vive en widgets/. Este archivo orquesta la lógica.
class GalleryCreateFormView extends StatefulWidget {
  const GalleryCreateFormView({super.key, this.editingGroup});

  final List<GalleryItem>? editingGroup;

  @override
  State<GalleryCreateFormView> createState() => _GalleryCreateFormViewState();
}

class _GalleryCreateFormViewState extends State<GalleryCreateFormView> {
  final List<PendingShot> _shots = [];
  final TextEditingController _newBarberNameCtrl = TextEditingController();
  final TextEditingController _newBarberSpecialtyCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  GalleryCategory? _selectedCategory;
  Future<List<StaffMember>>? _staffFuture;
  String? _selectedStaffId;
  bool _useNewBarber = false;

  bool get _isEditing =>
      widget.editingGroup != null && widget.editingGroup!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    final blocState = context.read<GalleryBloc>().state;
    final group = widget.editingGroup;
    if (group != null && group.isNotEmpty) {
      for (final item in group) {
        _shots.add(PendingShot(path: item.imageUrl, isLocal: item.isLocalAsset));
      }
      final editing = group.first;
      _selectedCategory = blocState.categories.firstWhere(
        (c) => c.slug == editing.categorySlug,
        orElse: () => blocState.categories.isNotEmpty
            ? blocState.categories.first
            : const GalleryCategory(slug: 'general', label: 'General'),
      );
      _newBarberNameCtrl.text = editing.barberFullName ?? '';
      _newBarberSpecialtyCtrl.text = editing.barberSpecialty ?? '';
      _descriptionCtrl.text = editing.description ?? '';
    } else if (blocState.categories.isNotEmpty) {
      _selectedCategory = blocState.categories.first;
    }
  }

  void _loadStaff() {
    final repo = getIt<StaffRepository>();
    final tenantId = getIt<TenantThemeBloc>().state.tenantId;
    final resolved = tenantId == kDefaultTenantId ? null : tenantId;
    _staffFuture = repo.listActiveBarbers(tenantId: resolved).then((list) {
      if (!mounted) return list;
      if (_selectedStaffId == null && list.isNotEmpty && !_useNewBarber) {
        final editingName = (widget.editingGroup != null && widget.editingGroup!.isNotEmpty)
            ? widget.editingGroup!.first.barberFullName
            : null;
        final match = editingName == null
            ? list.first
            : list.firstWhere(
                (m) => m.fullName.toLowerCase() == editingName.toLowerCase(),
                orElse: () => list.first,
              );
        setState(() {
          _selectedStaffId = match.id;
          if (widget.editingGroup == null || widget.editingGroup!.isEmpty) {
            _newBarberNameCtrl.text = match.fullName;
            _newBarberSpecialtyCtrl.text = match.specialty ?? '';
          }
        });
      }
      return list;
    });
  }

  @override
  void dispose() {
    _newBarberNameCtrl.dispose();
    _newBarberSpecialtyCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // === Image picker / crop ===

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2000,
    );
    if (picked == null) return;
    await _cropPath(picked.path, isNew: true);
  }

  Future<void> _cropAt(int index) async {
    final shot = _shots[index];
    if (!shot.isLocal) return;
    await _cropPath(shot.path, replaceIndex: index);
  }

  Future<void> _cropPath(String path, {bool isNew = false, int? replaceIndex}) async {
    final gold = context.primaryGold;
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 88,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar foto',
          toolbarColor: const Color(0xFF0A0A0A),
          toolbarWidgetColor: Colors.white,
          backgroundColor: const Color(0xFF0A0A0A),
          activeControlsWidgetColor: gold,
        ),
        IOSUiSettings(
          title: 'Recortar',
          doneButtonTitle: 'Listo',
          cancelButtonTitle: 'Cancelar',
        ),
      ],
    );
    if (cropped == null) {
      if (isNew) {
        setState(() => _shots.add(PendingShot(path: path, isLocal: true)));
      }
      return;
    }
    setState(() {
      final newShot = PendingShot(path: cropped.path, isLocal: true);
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

  String? _resolvedBarberName(List<StaffMember> staff) {
    if (_useNewBarber) {
      final raw = _newBarberNameCtrl.text.trim();
      return raw.isEmpty ? null : raw;
    }
    if (_selectedStaffId == null) return null;
    return staff
        .firstWhere(
          (m) => m.id == _selectedStaffId,
          orElse: () => StaffMember(id: '', fullName: '', role: 'barber'),
        )
        .fullName;
  }

  String? _resolvedSpecialty(List<StaffMember> staff) {
    if (_useNewBarber) {
      final raw = _newBarberSpecialtyCtrl.text.trim();
      return raw.isEmpty ? null : raw;
    }
    if (_selectedStaffId == null) return null;
    return staff
        .firstWhere(
          (m) => m.id == _selectedStaffId,
          orElse: () => StaffMember(id: '', fullName: '', role: 'barber'),
        )
        .specialty;
  }

  Future<void> _submit(List<StaffMember> staff) async {
    if (_shots.isEmpty || _selectedCategory == null) return;
    final barberName = _resolvedBarberName(staff);
    if (barberName == null || barberName.isEmpty) return;
    final specialty = _resolvedSpecialty(staff);
    final description = _descriptionCtrl.text.trim().isEmpty
        ? null
        : _descriptionCtrl.text.trim();
    final bloc = context.read<GalleryBloc>();
    final now = DateTime.now();
    final group = widget.editingGroup;

    HapticFeedback.mediumImpact();

    if (group != null && group.isNotEmpty) {
      for (final item in group) {
        if (item.id != null) bloc.add(GalleryEvent.itemDeleted(item.id!));
      }
      for (var i = 0; i < _shots.length; i++) {
        bloc.add(GalleryEvent.itemAdded(_buildItem(
          i: i,
          now: now,
          barberName: barberName,
          specialty: specialty,
          description: description,
          isFeatured: group.first.isFeatured,
        )));
      }
    } else {
      for (var i = 0; i < _shots.length; i++) {
        bloc.add(GalleryEvent.itemAdded(_buildItem(
          i: i,
          now: now,
          barberName: barberName,
          specialty: specialty,
          description: description,
        )));
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  GalleryItem _buildItem({
    required int i,
    required DateTime now,
    required String barberName,
    required String? specialty,
    required String? description,
    bool isFeatured = false,
  }) {
    final shot = _shots[i];
    return GalleryItem(
      externalId: 'local_${now.microsecondsSinceEpoch}_$i',
      imageUrl: shot.path,
      isLocalAsset: shot.isLocal,
      categorySlug: _selectedCategory!.slug,
      categoryLabel: _selectedCategory!.label,
      description: description,
      barberFullName: barberName,
      barberSpecialty: specialty,
      createdAt: now.add(Duration(milliseconds: i)),
      displayOrder: i,
      isFeatured: isFeatured,
    );
  }

  Future<void> _deletePortfolio() async {
    final group = widget.editingGroup;
    if (group == null || group.isEmpty) return;
    final ok = await GalleryConfirmDelete.show(
      context,
      title: 'Eliminar portafolio',
      message:
          'Se eliminarán todas las fotos de este portafolio. Esta acción no se puede deshacer.',
    );
    if (!ok || !mounted) return;
    final bloc = context.read<GalleryBloc>();
    for (final item in group) {
      if (item.id != null) bloc.add(GalleryEvent.itemDeleted(item.id!));
    }
    if (mounted) Navigator.pop(context);
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: FutureBuilder<List<StaffMember>>(
          future: _staffFuture,
          builder: (context, snap) {
            final staff = snap.data ?? const <StaffMember>[];
            final loadingStaff = snap.connectionState == ConnectionState.waiting;
            return BlocBuilder<GalleryBloc, GalleryState>(
              builder: (context, state) {
                final barberName = _resolvedBarberName(staff);
                final canSubmit = _shots.isNotEmpty &&
                    _selectedCategory != null &&
                    barberName != null &&
                    barberName.isNotEmpty;
                return SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      GalleryFormHeader(
                        isEditing: _isEditing,
                        onBack: () => Navigator.pop(context),
                        onDelete: _isEditing ? _deletePortfolio : null,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          child: _buildFormBody(state, staff, loadingStaff, canSubmit),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormBody(
    GalleryState state,
    List<StaffMember> staff,
    bool loadingStaff,
    bool canSubmit,
  ) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GallerySectionLabel('Barbero encargado'),
        const SizedBox(height: 10),
        GalleryBarberDropdown(
          staff: staff,
          loading: loadingStaff,
          selectedStaffId: _selectedStaffId,
          useNewBarber: _useNewBarber,
          onStaffSelected: (id) {
            setState(() {
              _useNewBarber = false;
              _selectedStaffId = id;
              final match = staff.firstWhere(
                (m) => m.id == id,
                orElse: () => StaffMember(id: '', fullName: '', role: 'barber'),
              );
              _newBarberNameCtrl.text = match.fullName;
              _newBarberSpecialtyCtrl.text = match.specialty ?? '';
            });
          },
          onPickNewBarber: () {
            setState(() {
              _useNewBarber = true;
              _selectedStaffId = null;
              _newBarberNameCtrl.clear();
              _newBarberSpecialtyCtrl.clear();
            });
          },
        ),
        if (_useNewBarber) ...[
          const SizedBox(height: 10),
          GalleryFormField(
            controller: _newBarberNameCtrl,
            hint: 'Nombre completo del barbero',
          ),
          const SizedBox(height: 8),
          GalleryFormField(
            controller: _newBarberSpecialtyCtrl,
            hint: 'Especialidad (ej. Experto en Fades)',
          ),
        ],
        const SizedBox(height: 24),
        const GallerySectionLabel('Categoría del corte'),
        const SizedBox(height: 10),
        GalleryCategoryPicker(
          categories: state.categories,
          selected: _selectedCategory,
          onChanged: (c) => setState(() => _selectedCategory = c),
        ),
        const SizedBox(height: 24),
        const GallerySectionLabel('Descripción corta'),
        const SizedBox(height: 10),
        GalleryFormField(
          controller: _descriptionCtrl,
          hint: 'Breve descripción del portafolio…',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        GallerySectionLabel(_isEditing ? 'Foto' : 'Fotos · ${_shots.length}'),
        const SizedBox(height: 10),
        GalleryShotsGrid(
          shots: _shots,
          onCrop: _cropAt,
          onRemove: _removeAt,
          onReorder: _reorder,
          onAdd: _pickFromGallery,
        ),
        // Botón "AGREGAR FOTO" SOLO aparece cuando ya hay al menos 1 shot.
        // Cuando está vacío, el grid ES el CTA (empty state tapable).
        if (_shots.isNotEmpty) ...[
          const SizedBox(height: 18),
          GalleryPickButton(onTap: _pickFromGallery),
        ],
        const SizedBox(height: 24),
        GallerySubmitButton(
          label: _isEditing ? 'GUARDAR CAMBIOS' : 'PUBLICAR EN PORTAFOLIO',
          enabled: canSubmit,
          onTap: () => _submit(staff),
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
                    'Selecciona barbero, categoría y al menos una foto.',
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
