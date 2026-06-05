import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';

class OrganizationTab extends StatefulWidget {
  const OrganizationTab({super.key});

  @override
  State<OrganizationTab> createState() => _OrganizationTabState();
}

class _OrganizationTabState extends State<OrganizationTab> {
  bool _showCatalogForm = false;
  ProductCatalog? _editingCatalog;
  final _catalogNameController = TextEditingController();

  bool _showCategoryForm = false;
  ProductCategory? _editingCategory;
  final _categoryNameController = TextEditingController();
  String? _selectedCatalogIdForCategory;

  static const Color _danger = Color(0xFFFF8A95);

  @override
  void dispose() {
    _catalogNameController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Stack(
          children: [
            ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _sectionHeader(
                  'Catálogos',
                  isOpen: _showCatalogForm && _editingCatalog == null,
                  onTap: () => setState(() {
                    _showCatalogForm = !_showCatalogForm;
                    _editingCatalog = null;
                    _catalogNameController.clear();
                  }),
                ),
                const SizedBox(height: 12),
                if (_showCatalogForm) _buildCatalogForm(context),
                ...state.catalogs.map((c) => _buildCatalogCard(context, c)),
                const SizedBox(height: 32),
                _sectionHeader(
                  'Categorías',
                  isOpen: _showCategoryForm && _editingCategory == null,
                  onTap: () => setState(() {
                    _showCategoryForm = !_showCategoryForm;
                    _editingCategory = null;
                    _categoryNameController.clear();
                    _selectedCatalogIdForCategory = null;
                  }),
                ),
                const SizedBox(height: 12),
                if (_showCategoryForm) _buildCategoryForm(context, state.catalogs),
                ...state.categories.map((category) {
                  final catalog = state.catalogs.firstWhere(
                    (c) => c.id == category.catalogId,
                    orElse: () => const ProductCatalog(id: '', name: 'SIN CATÁLOGO', isActive: false),
                  );
                  return _buildCategoryCard(context, category, catalog);
                }),
              ],
            ),
            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(child: CircularProgressIndicator(color: context.primaryGold, strokeWidth: 2)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title, {required bool isOpen, required VoidCallback onTap}) {
    final gold = context.primaryGold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PremiumSectionLabel(title),
        PremiumPressable(
          pressedScale: 0.92,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isOpen ? Icons.close_rounded : Icons.add_rounded, color: gold, size: 13),
                const SizedBox(width: 5),
                Text(
                  isOpen ? 'CANCELAR' : 'NUEVO',
                  style: GoogleFonts.inter(color: gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogForm(BuildContext context) {
    final isEditing = _editingCatalog != null;
    final canSave = _catalogNameController.text.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Editar catálogo' : 'Nuevo catálogo',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 14),
          _field(_catalogNameController, 'Nombre del catálogo', onChanged: (_) => setState(() {})),
          const SizedBox(height: 16),
          _formActions(
            canSave: canSave,
            onCancel: () => setState(() {
              _showCatalogForm = false;
              _editingCatalog = null;
              _catalogNameController.clear();
            }),
            onSave: () {
              final name = _catalogNameController.text.trim();
              final updated = _editingCatalog?.copyWith(name: name) ??
                  ProductCatalog(id: 'cat_${name.hashCode}_${context.read<ProductBloc>().state.catalogs.length}', name: name, isActive: false);
              context.read<ProductBloc>().add(ProductEvent.addCatalog(updated));
              setState(() {
                _showCatalogForm = false;
                _editingCatalog = null;
                _catalogNameController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context, ProductCatalog catalog) {
    final gold = context.primaryGold;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: catalog.isActive ? gold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          width: catalog.isActive ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalog.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                ),
                const SizedBox(height: 6),
                _activeBadge(catalog.isActive),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: catalog.isActive,
              activeTrackColor: gold.withValues(alpha: 0.35),
              activeThumbColor: gold,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white10,
              onChanged: (_) => context.read<ProductBloc>().add(ProductEvent.toggleCatalogActive(catalog.id)),
            ),
          ),
          const SizedBox(width: 4),
          _iconBtn(Icons.edit_rounded, gold, () {
            setState(() {
              _showCatalogForm = true;
              _editingCatalog = catalog;
              _catalogNameController.text = catalog.name;
            });
          }),
          const SizedBox(width: 8),
          _iconBtn(Icons.delete_outline_rounded, _danger, () => _confirmDelete(
                context,
                'Eliminar catálogo',
                '¿Eliminar "${catalog.name}"? Las categorías asociadas quedarán sin catálogo.',
                () => context.read<ProductBloc>().add(ProductEvent.deleteCatalog(catalog.id)),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryForm(BuildContext context, List<ProductCatalog> catalogs) {
    final isEditing = _editingCategory != null;
    // Valor seguro: evita el crash de "exactly one item" si el catalogId
    // ya no existe en la lista de catálogos.
    final safeCatalogId =
        catalogs.any((c) => c.id == _selectedCatalogIdForCategory) ? _selectedCatalogIdForCategory : null;
    final canSave = _categoryNameController.text.trim().isNotEmpty && safeCatalogId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Editar categoría' : 'Nueva categoría',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 14),
          _field(_categoryNameController, 'Nombre de la categoría', onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          const PremiumSectionLabel('Catálogo (requerido)'),
          const SizedBox(height: 8),
          if (catalogs.isEmpty)
            _notice('Crea un catálogo primero para poder asignarlo.')
          else
            _catalogDropdown(catalogs, safeCatalogId),
          const SizedBox(height: 16),
          _formActions(
            canSave: canSave,
            onCancel: () => setState(() {
              _showCategoryForm = false;
              _editingCategory = null;
              _categoryNameController.clear();
              _selectedCatalogIdForCategory = null;
            }),
            onSave: () {
              final name = _categoryNameController.text.trim();
              final updated = _editingCategory?.copyWith(name: name, catalogId: safeCatalogId) ??
                  ProductCategory(
                    id: 'category_${name.hashCode}_${context.read<ProductBloc>().state.categories.length}',
                    name: name,
                    icon: 'category',
                    catalogId: safeCatalogId,
                  );
              context.read<ProductBloc>().add(ProductEvent.addCategory(updated));
              setState(() {
                _showCategoryForm = false;
                _editingCategory = null;
                _categoryNameController.clear();
                _selectedCatalogIdForCategory = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _catalogDropdown(List<ProductCatalog> catalogs, String? safeValue) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          icon: Icon(Icons.expand_more_rounded, color: gold.withValues(alpha: 0.8), size: 20),
          hint: Text(
            'Selecciona un catálogo',
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3), fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          items: catalogs
              .map((c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedCatalogIdForCategory = val),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ProductCategory category, ProductCatalog catalog) {
    final gold = context.primaryGold;
    final hasCatalog = catalog.id.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasCatalog ? gold.withValues(alpha: 0.1) : _danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    catalog.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: hasCatalog ? gold : _danger,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: gold.withValues(alpha: 0.5), size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(Icons.edit_rounded, gold, () {
            setState(() {
              _showCategoryForm = true;
              _editingCategory = category;
              _categoryNameController.text = category.name;
              _selectedCatalogIdForCategory = category.catalogId;
            });
          }),
          const SizedBox(width: 8),
          _iconBtn(Icons.delete_outline_rounded, _danger, () => _confirmDelete(
                context,
                'Eliminar categoría',
                '¿Eliminar la categoría "${category.name}"?',
                () => context.read<ProductBloc>().add(ProductEvent.deleteCategory(category.id)),
              )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, {ValueChanged<String>? onChanged}) {
    final gold = context.primaryGold;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: gold,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFF0E0E0E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: gold, width: 1.2)),
      ),
    );
  }

  Widget _formActions({required bool canSave, required VoidCallback onCancel, required VoidCallback onSave}) {
    final gold = context.primaryGold;
    return Row(
      children: [
        Expanded(
          child: PremiumPressable(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text('CANCELAR', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PremiumPressable(
            onTap: canSave ? onSave : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: canSave ? gold : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('GUARDAR', style: GoogleFonts.inter(color: canSave ? Colors.black : Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _activeBadge(bool isActive) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? gold.withValues(alpha: 0.15) : Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'ACTIVO' : 'INACTIVO',
        style: GoogleFonts.inter(color: isActive ? gold : Colors.white24, fontSize: 7.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
      ),
    );
  }

  Widget _notice(String text) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String title, String message, VoidCallback onConfirm) async {
    final ok = await PremiumConfirmDelete.show(context, title: title, message: message);
    if (ok) onConfirm();
  }
}
