// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // SECCIÓN: CATÁLOGOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CATÁLOGOS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    _buildNewCatalogButton(context),
                  ],
                ),
                const SizedBox(height: 12),
                if (_showCatalogForm) _buildInlineCatalogForm(context),
                if (state.catalogs.isEmpty)
                  const SizedBox.shrink()
                else
                  ...state.catalogs.map((catalog) => _buildCatalogCard(context, catalog)),

                const SizedBox(height: 36),

                // SECCIÓN: CATEGORÍAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CATEGORÍAS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    _buildNewCategoryButton(context),
                  ],
                ),
                const SizedBox(height: 12),
                if (_showCategoryForm) _buildInlineCategoryForm(context, state.catalogs),
                if (state.categories.isEmpty)
                  const SizedBox.shrink()
                else
                  ...state.categories.map((category) {
                    final associatedCatalog = state.catalogs.firstWhere(
                      (c) => c.id == category.catalogId,
                      orElse: () => const ProductCatalog(id: '', name: 'SIN CATÁLOGO', isActive: false),
                    );
                    return _buildCategoryCard(context, category, associatedCatalog);
                  }),
              ],
            ),
            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNewCatalogButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCatalogForm = !_showCatalogForm;
          _editingCatalog = null;
          _catalogNameController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.primaryGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              _showCatalogForm && _editingCatalog == null
                  ? Icons.close_rounded
                  : Icons.add_rounded,
              color: Colors.black,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              _showCatalogForm && _editingCatalog == null
                  ? 'CANCELAR'
                  : 'NUEVO CATÁLOGO',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewCategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCategoryForm = !_showCategoryForm;
          _editingCategory = null;
          _categoryNameController.clear();
          _selectedCatalogIdForCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.primaryGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              _showCategoryForm && _editingCategory == null
                  ? Icons.close_rounded
                  : Icons.add_rounded,
              color: Colors.black,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              _showCategoryForm && _editingCategory == null
                  ? 'CANCELAR'
                  : 'NUEVA CATEGORÍA',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineCatalogForm(BuildContext context) {
    final title = _editingCatalog == null ? 'NUEVO CATÁLOGO' : 'EDITAR CATÁLOGO';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryGold.withOpacity(0.3)),
      ),
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _catalogNameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Nombre del catálogo',
                hintStyle: TextStyle(color: Colors.white10),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCatalogForm = false;
                      _editingCatalog = null;
                      _catalogNameController.clear();
                    });
                  },
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _catalogNameController.text.trim();
                    if (name.isNotEmpty) {
                      final updated = _editingCatalog?.copyWith(name: name) ??
                          ProductCatalog(
                            id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            isActive: false,
                          );
                      context.read<ProductBloc>().add(ProductEvent.addCatalog(updated));
                      setState(() {
                        _showCatalogForm = false;
                        _editingCatalog = null;
                        _catalogNameController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('GUARDAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context, ProductCatalog catalog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: catalog.isActive
            ? context.primaryGold.withOpacity(0.03)
            : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: catalog.isActive
              ? context.primaryGold.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: catalog.isActive ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalog.name.toUpperCase(),
                  style: TextStyle(
                    color: catalog.isActive ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                _activeIndicator(catalog.isActive),
              ],
            ),
          ),
          Row(
            children: [
              const Text(
                'ACTIVO:',
                style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: catalog.isActive,
                  activeTrackColor: context.primaryGold.withOpacity(0.3),
                  activeThumbColor: context.primaryGold,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white10,
                  onChanged: (_) {
                    context.read<ProductBloc>().add(ProductEvent.toggleCatalogActive(catalog.id));
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCatalogForm = true;
                    _editingCatalog = catalog;
                    _catalogNameController.text = catalog.name;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: context.primaryGold.withOpacity(0.3)),
                  ),
                  child: Text(
                    'EDITAR',
                    style: TextStyle(
                      color: context.primaryGold,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context, 'ELIMINAR CATÁLOGO', () {
                  context.read<ProductBloc>().add(ProductEvent.deleteCatalog(catalog.id));
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D4D).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFFF4D4D).withOpacity(0.3)),
                  ),
                  child: const Text(
                    'ELIMINAR',
                    style: TextStyle(
                      color: Color(0xFFFF4D4D),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ProductCategory category, ProductCatalog associatedCatalog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: associatedCatalog.id.isNotEmpty
                        ? context.primaryGold.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    associatedCatalog.name.toUpperCase(),
                    style: TextStyle(
                      color: associatedCatalog.id.isNotEmpty ? context.primaryGold : Colors.white30,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: context.primaryGold.withOpacity(0.5),
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCategoryForm = true;
                    _editingCategory = category;
                    _categoryNameController.text = category.name;
                    _selectedCatalogIdForCategory = category.catalogId;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: context.primaryGold.withOpacity(0.3)),
                  ),
                  child: Text(
                    'EDITAR',
                    style: TextStyle(
                      color: context.primaryGold,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context, 'ELIMINAR CATEGORÍA', () {
                  context.read<ProductBloc>().add(ProductEvent.deleteCategory(category.id));
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D4D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFFF4D4D).withOpacity(0.4)),
                  ),
                  child: const Text(
                    'ELIMINAR',
                    style: TextStyle(
                      color: Color(0xFFFF4D4D),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineCategoryForm(BuildContext context, List<ProductCatalog> catalogs) {
    final title = _editingCategory == null ? 'NUEVA CATEGORÍA' : 'EDITAR CATEGORÍA';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryGold.withOpacity(0.3)),
      ),
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryNameController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Nombre de la categoría',
                hintStyle: TextStyle(color: Colors.white10),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'CATÁLOGO ASOCIADO',
              style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCatalogIdForCategory,
                  dropdownColor: const Color(0xFF111111),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  isExpanded: true,
                  hint: const Text('Sin catálogo (General)', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Sin catálogo (General)'),
                    ),
                    ...catalogs.map((catalog) => DropdownMenuItem<String>(
                          value: catalog.id,
                          child: Text(catalog.name.toUpperCase()),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCatalogIdForCategory = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCategoryForm = false;
                      _editingCategory = null;
                      _categoryNameController.clear();
                      _selectedCatalogIdForCategory = null;
                    });
                  },
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _categoryNameController.text.trim();
                    if (name.isNotEmpty) {
                      final updated = _editingCategory?.copyWith(
                            name: name,
                            catalogId: _selectedCatalogIdForCategory,
                          ) ??
                          ProductCategory(
                            id: 'category_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            icon: 'category',
                            catalogId: _selectedCatalogIdForCategory,
                          );
                      context.read<ProductBloc>().add(ProductEvent.addCategory(updated));
                      setState(() {
                        _showCategoryForm = false;
                        _editingCategory = null;
                        _categoryNameController.clear();
                        _selectedCatalogIdForCategory = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('GUARDAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeIndicator(bool isActive) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isActive ? 'ACTIVO' : 'INACTIVO',
          style: TextStyle(
            color: isActive ? const Color(0xFFD4AF37) : Colors.white24,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext parentContext, String title, VoidCallback onConfirm) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        content: const Text('Esta acción purgará el elemento de forma permanente y sus relaciones.', style: TextStyle(color: Colors.white38, fontSize: 11)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11))),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
