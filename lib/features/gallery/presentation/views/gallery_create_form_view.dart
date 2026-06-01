import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class GalleryCreateFormView extends StatefulWidget {
  const GalleryCreateFormView({super.key, this.editingGroup});

  final List<GalleryItem>? editingGroup;

  @override
  State<GalleryCreateFormView> createState() => _GalleryCreateFormViewState();
}

class _GalleryCreateFormViewState extends State<GalleryCreateFormView> {
  final List<_PendingShot> _shots = [];
  final TextEditingController _newBarberNameCtrl = TextEditingController();
  final TextEditingController _newBarberSpecialtyCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  GalleryCategory? _selectedCategory;
  Future<List<StaffMember>>? _staffFuture;
  String? _selectedStaffId;
  bool _useNewBarber = false;

  bool get _isEditing => widget.editingGroup != null && widget.editingGroup!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    final blocState = context.read<GalleryBloc>().state;
    final group = widget.editingGroup;
    if (group != null && group.isNotEmpty) {
      for (final item in group) {
        _shots.add(_PendingShot(path: item.imageUrl, isLocal: item.isLocalAsset));
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
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 88);
    if (picked == null) return;
    _addShot(picked.path);
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (picked == null) return;
    _addShot(picked.path);
  }

  void _addShot(String path) {
    setState(() => _shots.add(_PendingShot(path: path, isLocal: true)));
  }

  Future<void> _cropAt(int index) async {
    final shot = _shots[index];
    if (!shot.isLocal) return;
    final accent = context.primaryGold;
    final cropped = await ImageCropper().cropImage(
      sourcePath: shot.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar foto',
          toolbarColor: const Color(0xFF111111),
          toolbarWidgetColor: accent,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: accent,
        ),
        IOSUiSettings(title: 'Recortar foto'),
      ],
    );
    if (cropped == null) return;
    setState(() => _shots[index] = _PendingShot(path: cropped.path, isLocal: true));
  }

  void _removeAt(int index) {
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
    final description = _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim();
    final bloc = context.read<GalleryBloc>();
    final now = DateTime.now();
    final group = widget.editingGroup;

    if (group != null && group.isNotEmpty) {
      // Delete old items
      for (final item in group) {
        if (item.id != null) {
          bloc.add(GalleryEvent.itemDeleted(item.id!));
        }
      }
      // Re-create new items
      for (var i = 0; i < _shots.length; i++) {
        final shot = _shots[i];
        final item = GalleryItem(
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
          isFeatured: group.first.isFeatured,
        );
        bloc.add(GalleryEvent.itemAdded(item));
      }
    } else {
      for (var i = 0; i < _shots.length; i++) {
        final shot = _shots[i];
        final item = GalleryItem(
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
        );
        bloc.add(GalleryEvent.itemAdded(item));
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isEditing
          ? 'Portafolio actualizado'
          : '${_shots.length} foto(s) agregada(s) al portafolio'),
      backgroundColor: context.primaryGold,
    ));
    Navigator.pop(context);
  }

  Future<void> _deletePortfolio() async {
    final group = widget.editingGroup;
    if (group == null || group.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Eliminar portafolio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta acción eliminará todas las fotos de este portafolio. ¿Continuar?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final bloc = context.read<GalleryBloc>();
    for (final item in group) {
      if (item.id != null) {
        bloc.add(GalleryEvent.itemDeleted(item.id!));
      }
    }
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'EDITAR PORTAFOLIO' : 'CREAR PORTAFOLIO',
          style: const TextStyle(
            color: Color(0xFFF5F5DC),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _deletePortfolio,
              child: const Text(
                'ELIMINAR',
                style: TextStyle(
                  color: Color(0xFFFF4D4D),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('BARBERO ENCARGADO'),
                      const SizedBox(height: 8),
                      _BarberDropdown(
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
                              orElse: () =>
                                  StaffMember(id: '', fullName: '', role: 'barber'),
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
                        const SizedBox(height: 12),
                        _Field(controller: _newBarberNameCtrl, hint: 'Nombre completo del barbero'),
                        const SizedBox(height: 8),
                        _Field(controller: _newBarberSpecialtyCtrl, hint: 'Especialidad (ej. Experto en Fades)'),
                      ],
                      const SizedBox(height: 22),
                      const _SectionLabel('CATEGORIA'),
                      const SizedBox(height: 8),
                      _CategoryPicker(
                        categories: state.categories,
                        selected: _selectedCategory,
                        onChanged: (c) => setState(() => _selectedCategory = c),
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('DESCRIPCION CORTA'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _descriptionCtrl,
                        hint: 'Breve descripción del portafolio...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(_isEditing
                          ? 'IMAGEN'
                          : 'IMAGENES (${_shots.length})'),
                      const SizedBox(height: 8),
                      _ShotsGrid(
                        shots: _shots,
                        onCrop: _cropAt,
                        onRemove: _removeAt,
                        onReorder: _reorder,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _CtaButton(
                              label: 'CAMARA',
                              iconBuilder: (color, size) =>
                                  FaIcon(FontAwesomeIcons.camera, color: color, size: size),
                              onTap: _pickFromCamera,
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CtaButton(
                              label: 'GALERÍA',
                              iconBuilder: (color, size) =>
                                  FaIcon(FontAwesomeIcons.image, color: color, size: size),
                              onTap: _pickFromGallery,
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _CtaButton(
                        label: _isEditing ? 'GUARDAR CAMBIOS' : 'PUBLICAR EN PORTAFOLIO',
                        iconBuilder: (color, size) => FaIcon(
                            _isEditing ? FontAwesomeIcons.check : FontAwesomeIcons.cloudArrowUp,
                            color: color,
                            size: size),
                        onTap: canSubmit ? () => _submit(staff) : null,
                        isPrimary: true,
                      ),
                      if (!canSubmit) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Selecciona barbero, categoria e imagen para continuar.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Container(width: 32, height: 2, color: gold),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PendingShot {
  final String path;
  final bool isLocal;
  const _PendingShot({required this.path, required this.isLocal});
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

class _BarberDropdown extends StatelessWidget {
  const _BarberDropdown({
    required this.staff,
    required this.loading,
    required this.selectedStaffId,
    required this.useNewBarber,
    required this.onStaffSelected,
    required this.onPickNewBarber,
  });

  final List<StaffMember> staff;
  final bool loading;
  final String? selectedStaffId;
  final bool useNewBarber;
  final ValueChanged<String> onStaffSelected;
  final VoidCallback onPickNewBarber;

  static const String _newBarberSentinel = '__new__';

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    if (loading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: gold, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cargando staff...',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final value = useNewBarber ? _newBarberSentinel : selectedStaffId;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: const Color(0xFF111111),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: gold),
          value: value,
          hint: const Text(
            'Selecciona un barbero',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          items: [
            ...staff.map(
              (m) => DropdownMenuItem<String>(
                value: m.id,
                child: _StaffOption(member: m),
              ),
            ),
            DropdownMenuItem<String>(
              value: _newBarberSentinel,
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: gold, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Nuevo barbero',
                    style: TextStyle(
                      color: gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) {
            if (val == null) return;
            if (val == _newBarberSentinel) {
              onPickNewBarber();
            } else {
              onStaffSelected(val);
            }
          },
        ),
      ),
    );
  }
}

class _StaffOption extends StatelessWidget {
  const _StaffOption({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Row(
      children: [
        Icon(Icons.person_rounded, color: gold, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (member.specialty != null && member.specialty!.trim().isNotEmpty)
                Text(
                  member.specialty!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF161616),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.55), width: 1.2),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  final List<GalleryCategory> categories;
  final GalleryCategory? selected;
  final ValueChanged<GalleryCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Text(
        'No hay categorias creadas.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 12,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected?.slug == c.slug;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? context.primaryGold : const Color(0xFF161616),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.primaryGold
                    : context.primaryGold.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              c.label.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ShotsGrid extends StatelessWidget {
  const _ShotsGrid({
    required this.shots,
    required this.onCrop,
    required this.onRemove,
    required this.onReorder,
  });

  final List<_PendingShot> shots;
  final ValueChanged<int> onCrop;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    if (shots.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        alignment: Alignment.center,
        child: Text(
          'AGREGA FOTOS DESDE CÁMARA O GALERÍA',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      );
    }
    return SizedBox(
      height: 130,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: shots.length,
        onReorder: onReorder,
        itemBuilder: (context, i) {
          final shot = shots[i];
          return _ShotTile(
            key: ValueKey('${shot.path}_$i'),
            shot: shot,
            index: i,
            onCrop: shot.isLocal ? () => onCrop(i) : null,
            onRemove: () => onRemove(i),
          );
        },
      ),
    );
  }
}

class _ShotTile extends StatelessWidget {
  const _ShotTile({
    super.key,
    required this.shot,
    required this.index,
    required this.onCrop,
    required this.onRemove,
  });

  final _PendingShot shot;
  final int index;
  final VoidCallback? onCrop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ReorderableDragStartListener(
        index: index,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _ShotPreview(shot: shot),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _MiniButton(icon: Icons.close_rounded, onTap: onRemove),
            ),
            if (onCrop != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: _MiniButton(icon: Icons.crop_rounded, onTap: onCrop!),
              ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShotPreview extends StatelessWidget {
  const _ShotPreview({required this.shot});
  final _PendingShot shot;

  @override
  Widget build(BuildContext context) {
    if (shot.isLocal) {
      return Image.file(
        File(shot.path),
        width: 110,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return Image.network(
      shot.path,
      width: 110,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: 110,
        height: 120,
        color: const Color(0xFF111111),
      );
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          border: Border.all(color: context.primaryGold.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: context.primaryGold, size: 14),
      ),
    );
  }
}

typedef _CtaIconBuilder = Widget Function(Color color, double size);

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.iconBuilder,
    required this.onTap,
    required this.isPrimary,
  });

  final String label;
  final _CtaIconBuilder iconBuilder;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final isEnabled = onTap != null;
    final iconColor = isPrimary
        ? (isEnabled ? Colors.black : Colors.white24)
        : gold;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary
              ? (isEnabled ? gold : Colors.white.withValues(alpha: 0.06))
              : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? Colors.transparent : gold.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(iconColor, 12),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
