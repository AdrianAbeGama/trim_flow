// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PANEL DE CONTROL',
          style: TextStyle(color: Color(0xFFF5F5DC), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.primaryGold,
          dividerColor: Colors.transparent,
          labelColor: context.primaryGold,
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          tabs: const [
            Tab(text: 'PRODUCTOS', icon: Icon(Icons.shopping_bag_outlined, size: 18)),
            Tab(text: 'INVENTARIO', icon: Icon(Icons.inventory_2_outlined, size: 18)),
            Tab(text: 'ORGANIZACIÓN', icon: Icon(Icons.auto_awesome_mosaic_outlined, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProductsTab(),
          _InventoryTab(),
          OrganizationTab(),
        ],
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
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
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(color: Colors.white30, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: context.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: context.primaryGold, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BlocProvider.value(value: pb, child: ProductFormView(product: product))),
                );
              },
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
            if (_showForm) _buildInlineInventoryForm(context),
            Expanded(
              child: state.inventoryItems.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.inventoryItems.length,
                      itemBuilder: (context, index) {
                        final item = state.inventoryItems[index];
                        return _buildInventoryCard(context, item);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInlineInventoryForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'REGISTRAR EN ALMACÉN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NOMBRE DEL ÍTEM',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Nombre del ítem (ej. Cera Mate)',
              hintStyle: TextStyle(color: Colors.white10),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'STOCK INICIAL',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          TextField(
            controller: _stockController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Cantidad inicial (ej. 10)',
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
                onPressed: _isSaving ? null : () => setState(() => _showForm = false),
                child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (_nameController.text.trim().isNotEmpty) {
                          setState(() => _isSaving = true);
                          final qty = int.tryParse(_stockController.text) ?? 0;
                          final item = InventoryItem(
                            id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
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
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('REGISTRAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'STOCK DISPONIBLE',
                    style: TextStyle(color: context.primaryGold.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showQuickEditInventoryDialog(context, item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.primaryGold.withOpacity(0.3), width: 0.8),
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
            const SizedBox(width: 12),
            _buildStockControls(context, item),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Future<bool?> _showDismissConfirmDialog(BuildContext context, InventoryItem item) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ELIMINAR ÍTEM DE STOCK',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${item.name}" del inventario?',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
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
        title: const Text(
          'EDICIÓN RÁPIDA DE STOCK',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        content: RepaintBoundary(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOMBRE DEL ÍTEM',
                  style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'STOCK DISPONIBLE',
                  style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11)),
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
              backgroundColor: context.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('GUARDAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

Widget _buildAddHeader(BuildContext context, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      height: 50,
      decoration: BoxDecoration(
        color: context.primaryGold,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            title.startsWith('CANCELAR') ? Icons.close : Icons.add,
            color: Colors.black,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    ),
  );
}


