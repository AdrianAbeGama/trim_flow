// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_offers_admin_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/organization_tab.dart';

class ProductAdminDashboardView extends StatefulWidget {
  const ProductAdminDashboardView({super.key});

  @override
  State<ProductAdminDashboardView> createState() => _ProductAdminDashboardViewState();
}

class _ProductAdminDashboardViewState extends State<ProductAdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _AdminHeader(),
              _AdminTabBar(controller: _tabController),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ProductsTab(),
                    _InventoryTab(),
                    OrganizationTab(),
                    ProductOffersBody(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumBackButton(onTap: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              const PremiumPill(icon: Icons.tune_rounded, label: 'PANEL ADMIN'),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 22),
          Text(
            'Panel',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
          ).animate().fadeIn(delay: 120.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 4),
          Text(
            'Administrativo',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.3, height: 1.05),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 16, height: 1.5, color: context.primaryGold),
              const SizedBox(width: 8),
              Text(
                'Gestiona tu tienda',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1),
              ),
            ],
          ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _AdminTabBar extends StatelessWidget {
  const _AdminTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(9),
          ),
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          labelStyle: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.4),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          tabs: const [
            Tab(text: 'PRODUCTOS', height: 34),
            Tab(text: 'STOCK', height: 34),
            Tab(text: 'ORGANIZAR', height: 34),
            Tab(text: 'OFERTAS', height: 34),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final pb = context.read<ProductBloc>();
        return Column(
          children: [
            _buildAddHeader(
              context,
              'NUEVO PRODUCTO',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(value: pb, child: const ProductFormView()),
                  ),
                );
              },
            ),
            Expanded(
              child: state.allProducts.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.allProducts.length,
                      itemBuilder: (context, index) {
                        final product = state.allProducts[index];
                        return _buildProductRow(context, product);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductRow(BuildContext context, Product product) {
    final pb = context.read<ProductBloc>();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BlocProvider.value(value: pb, child: ProductFormView(product: product))),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            _buildThumb(product.imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.toUpperCase(),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 10, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(color: context.primaryGold, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            PremiumPressable(
              pressedScale: 0.85,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BlocProvider.value(value: pb, child: ProductFormView(product: product))),
                );
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: context.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.primaryGold.withValues(alpha: 0.25)),
                ),
                child: Icon(Icons.edit_rounded, color: context.primaryGold, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SafeImage(
        url: url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  bool _showForm = false;
  final _nameController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildAddHeader(
              context,
              _showForm ? 'CANCELAR NUEVO STOCK' : 'NUEVO ÍTEM DE STOCK',
              () {
                setState(() {
                  _showForm = !_showForm;
                  _nameController.clear();
                  _stockController.text = '0';
                });
              },
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  if (_showForm) _buildInlineInventoryForm(context),
                  ...state.inventoryItems.map((item) => _buildInventoryCard(context, item)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInlineInventoryForm(BuildContext context) {
    final gold = context.primaryGold;
    final canSave = _nameController.text.trim().isNotEmpty && !_isSaving;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Registrar en almacén',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 14),
          const PremiumSectionLabel('Nombre del ítem'),
          const SizedBox(height: 8),
          _inventoryField(_nameController, 'Ej. Cera Mate', onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          const PremiumSectionLabel('Stock inicial'),
          const SizedBox(height: 8),
          _inventoryField(_stockController, 'Ej. 10', isNumber: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PremiumPressable(
                  onTap: _isSaving ? null : () => setState(() => _showForm = false),
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
                  onTap: canSave
                      ? () {
                          setState(() => _isSaving = true);
                          final qty = int.tryParse(_stockController.text) ?? 0;
                          final item = InventoryItem(
                            id: 'inv_${_nameController.text.trim().hashCode}',
                            name: _nameController.text.trim(),
                            quantity: qty,
                          );
                          context.read<ProductBloc>().add(ProductEvent.addInventoryItem(item));
                          setState(() {
                            _isSaving = false;
                            _showForm = false;
                            _nameController.clear();
                            _stockController.text = '0';
                          });
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canSave ? gold : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text('REGISTRAR', style: GoogleFonts.inter(color: canSave ? Colors.black : Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inventoryField(TextEditingController controller, String hint, {bool isNumber = false, ValueChanged<String>? onChanged}) {
    final gold = context.primaryGold;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  Widget _buildInventoryCard(BuildContext context, InventoryItem item) {
    return Dismissible(
      key: Key('inv_item_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDismissConfirmDialog(context, item);
      },
      onDismissed: (_) {
        context.read<ProductBloc>().add(ProductEvent.deleteInventoryItem(item.id));
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D4D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'STOCK DISPONIBLE',
                        style: GoogleFonts.inter(color: context.primaryGold.withValues(alpha: 0.6), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _invIconBtn(Icons.edit_rounded, context.primaryGold, () => _showQuickEditInventoryDialog(context, item)),
                const SizedBox(width: 8),
                _invIconBtn(Icons.delete_outline_rounded, const Color(0xFFFF8A95), () async {
                  final ok = await _showDismissConfirmDialog(context, item);
                  if (ok == true && context.mounted) {
                    context.read<ProductBloc>().add(ProductEvent.deleteInventoryItem(item.id));
                  }
                }),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CANTIDAD',
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  _buildStockControls(context, item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockControls(BuildContext context, InventoryItem item) {
    Color indicatorColor;
    if (item.quantity <= 3) {
      indicatorColor = const Color(0xFFE26F6F); // Terracota / Rojo premium
    } else if (item.quantity <= 10) {
      indicatorColor = const Color(0xFFE2B96F); // Ocre / Amarillo premium
    } else {
      indicatorColor = const Color(0xFF6FE29B); // Esmeralda / Verde premium
    }

    return Row(
      children: [
        _btn(Icons.remove_rounded, () {
          if (item.quantity > 0) {
            context.read<ProductBloc>().add(ProductEvent.updateInventoryItem(item.copyWith(quantity: item.quantity - 1)));
          }
        }),
        Container(
          constraints: const BoxConstraints(minWidth: 50),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: indicatorColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${item.quantity}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        _btn(Icons.add_rounded, () {
          context.read<ProductBloc>().add(ProductEvent.updateInventoryItem(item.copyWith(quantity: item.quantity + 1)));
        }),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return PremiumPressable(
      pressedScale: 0.82,
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }

  Widget _invIconBtn(IconData icon, Color color, VoidCallback onTap) {
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

  Future<bool?> _showDismissConfirmDialog(BuildContext context, InventoryItem item) {
    return PremiumConfirmDelete.show(
      context,
      title: 'Eliminar ítem de stock',
      message: '¿Eliminar "${item.name}" del inventario?',
    );
  }

  void _showQuickEditInventoryDialog(BuildContext context, InventoryItem item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: '${item.quantity}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'EDICIÓN RÁPIDA DE STOCK',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        content: RepaintBoundary(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOMBRE DEL ÍTEM',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  cursorColor: context.primaryGold,
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryGold)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'STOCK DISPONIBLE',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  cursorColor: context.primaryGold,
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryGold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('CANCELAR', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newQty = int.tryParse(quantityController.text.trim()) ?? item.quantity;
              if (newName.isNotEmpty) {
                context.read<ProductBloc>().add(
                  ProductEvent.updateInventoryItem(item.copyWith(name: newName, quantity: newQty)),
                );
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F3EC),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('GUARDAR', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

Widget _buildAddHeader(BuildContext context, String title, VoidCallback onTap) {
  final gold = context.primaryGold;
  final isCancel = title.startsWith('CANCELAR');
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCancel ? Colors.white.withValues(alpha: 0.05) : gold,
          borderRadius: BorderRadius.circular(14),
          border: isCancel ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
          boxShadow: isCancel ? null : [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 14, spreadRadius: 1)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isCancel ? Icons.close_rounded : Icons.add_rounded, color: isCancel ? Colors.white : Colors.black, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(color: isCancel ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    ),
  );
}


