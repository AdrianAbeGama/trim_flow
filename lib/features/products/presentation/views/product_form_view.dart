// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'barcode_scanner_view.dart';

class ProductFormView extends StatefulWidget {
  final Product? product;
  const ProductFormView({super.key, this.product});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  
  String? _selectedCategory;
  String? _selectedInventory;
  String? _selectedCatalog;
  bool _isSaving = false;
  bool _isPicking = false;
  int _crossAxisCellCount = 1;
  int _mainAxisCellCount = 1;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.product?.id ?? '');
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageController = TextEditingController(text: widget.product?.imageUrl ?? '');
    
    _selectedCategory = widget.product?.categoryId.isEmpty == true ? null : widget.product?.categoryId;
    _selectedInventory = widget.product?.inventoryItemId;
    _selectedCatalog = widget.product?.catalogId;
    _crossAxisCellCount = widget.product?.crossAxisCellCount ?? 1;
    _mainAxisCellCount = widget.product?.mainAxisCellCount ?? 1;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _startBarcodeScan() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerView()),
    );
    if (scannedCode != null && mounted) {
      setState(() => _idController.text = scannedCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código escaneado: $scannedCode', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
      listener: (context, state) {
        if (_isSaving) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final showLoader = state.isLoading || _isSaving;
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              title: Text(
                widget.product == null ? 'NUEVO PRODUCTO' : 'EDITAR PRODUCTO',
                style: const TextStyle(color: Color(0xFFF5F5DC), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (widget.product != null)
                  TextButton(
                    onPressed: _confirmDeleteProduct,
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
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: RepaintBoundary(
                    child: Form(
                      key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ID / Código de barras'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _idController,
                                'Código de barras...',
                                isRequired: false,
                                enabled: widget.product == null,
                              ),
                            ),
                            if (widget.product == null) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _startBarcodeScan,
                                child: Container(
                                  height: 54, width: 54,
                                  decoration: BoxDecoration(
                                    color: context.primaryGold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: context.primaryGold.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'images/barcode.png',
                                      color: context.primaryGold,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Nombre del producto'),
                        _buildTextField(_nameController, 'Nombre del producto...'),
                        const SizedBox(height: 20),
                        _buildLabel('Descripción'),
                        _buildTextField(_descController, 'Descripción...', maxLines: 3),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Precio (S/)'),
                                  _buildTextField(_priceController, 'Precio...', isNumber: true),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Categoría'),
                                  _buildCategoryDropdown(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Inventario'),
                        _buildInventoryDropdown(),
                        const SizedBox(height: 20),
                        _buildLabel('Catálogo'),
                        _buildCatalogDropdown(),
                        const SizedBox(height: 24),
                        _buildLabel('Imagen del producto'),
                        _buildImageSelector(),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: showLoader ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryGold,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.product == null ? 'CREAR PRODUCTO' : 'GUARDAR CAMBIOS',
                            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
                if (showLoader)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
    bool isRequired = true,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white10),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.primaryGold)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'Requerido' : null : null,
    );
  }

  Widget _buildImageSelector() {
    final img = _imageController.text;
    return Column(
      children: [
        if (_isPicking)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ),
          )
        else if (img.isNotEmpty)
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: img.startsWith('http')
                      ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.white10), errorWidget: (context, url, error) => const Icon(Icons.error))
                      : Image.file(File(img), fit: BoxFit.cover),
                ),
              ),
              if (!img.startsWith('http'))
                Positioned(
                  bottom: 26,
                  right: 10,
                  child: ElevatedButton.icon(
                    onPressed: _cropImage,
                    icon: const Icon(Icons.crop_rounded, color: Colors.black, size: 14),
                    label: const Text(
                      'RECORTAR IMAGEN',
                      style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryGold,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            _imgBtn(Icons.camera_alt_rounded, 'CÁMARA', () => _pick(ImageSource.camera)),
            const SizedBox(width: 8),
            _imgBtn(Icons.photo_library_rounded, 'GALERÍA', () => _pick(ImageSource.gallery)),
            const SizedBox(width: 8),
            _imgBtn(Icons.link_rounded, 'URL', _showUrlDialog),
          ],
        ),
      ],
    );
  }

  Widget _imgBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: context.primaryGold, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource s) async {
    setState(() => _isPicking = true);
    try {
      final picker = ImagePicker();
      final p = await picker.pickImage(
        source: s,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (p != null) {
        setState(() => _imageController.text = p.path);
      }
    } catch (_) {
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Future<void> _cropImage() async {
    final imgPath = _imageController.text;
    if (imgPath.isEmpty || imgPath.startsWith('http')) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: imgPath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'RECORTAR PRODUCTO',
          toolbarColor: Colors.black,
          toolbarWidgetColor: const Color(0xFFD4AF37),
          activeControlsWidgetColor: const Color(0xFFD4AF37),
          hideBottomControls: true,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'RECORTAR PRODUCTO',
          aspectRatioLockEnabled: false,
          aspectRatioPickerButtonHidden: true,
          resetButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
        ),
      ],
    );

    if (cropped != null) {
      try {
        final bytes = await File(cropped.path).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final width = frame.image.width;
        final height = frame.image.height;
        final ratio = width / height;

        int cross = 1;
        int main = 1;

        if (ratio < 0.85) {
          // Vertical Pinterest Rectangle (1x2)
          cross = 1;
          main = 2;
        } else {
          // Square Pinterest Tile (1x1)
          cross = 1;
          main = 1;
        }

        setState(() {
          _imageController.text = cropped.path;
          _crossAxisCellCount = cross;
          _mainAxisCellCount = main;
        });
      } catch (e) {
        // Fallback if image parsing fails
        setState(() => _imageController.text = cropped.path);
      }
    }
  }

  void _showUrlDialog() {
    final c = TextEditingController(text: _imageController.text.startsWith('http') ? _imageController.text : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PEGAR URL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: Colors.white10),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              setState(() => _imageController.text = c.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ACEPTAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final items = state.categories;
        final hasSelected = items.any((c) => c.id.toString() == _selectedCategory?.toString());
        final safeValue = hasSelected 
            ? items.firstWhere((c) => c.id.toString() == _selectedCategory?.toString()).id 
            : null;
        return _dropdown(
          value: safeValue,
          items: items.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
          hint: 'Seleccionar...',
        );
      },
    );
  }

  Widget _buildInventoryDropdown() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final items = state.inventoryItems;
        final hasSelected = items.any((i) => i.id.toString() == _selectedInventory?.toString());
        final safeValue = hasSelected 
            ? items.firstWhere((i) => i.id.toString() == _selectedInventory?.toString()).id 
            : null;
        return _dropdown(
          value: safeValue,
          items: items.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.quantity} u)'))).toList(),
          onChanged: (v) => setState(() => _selectedInventory = v),
          hint: 'Inventario...',
        );
      },
    );
  }

  Widget _buildCatalogDropdown() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final items = state.catalogs;
        final hasSelected = items.any((c) => c.id.toString() == _selectedCatalog?.toString());
        final safeValue = hasSelected 
            ? items.firstWhere((c) => c.id.toString() == _selectedCatalog?.toString()).id 
            : null;
        return _dropdown(
          value: safeValue,
          items: items.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
          onChanged: (v) => setState(() => _selectedCatalog = v),
          hint: 'Ninguno...',
        );
      },
    );
  }

  Widget _dropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF111111),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ),
      ),
    );
  }



  void _confirmDeleteProduct() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ELIMINAR PRODUCTO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?', style: TextStyle(color: Colors.white38, fontSize: 11)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCELAR', style: TextStyle(color: Colors.white38, fontSize: 11))),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(ProductEvent.deleteProduct(widget.product!.id));
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Go back to products view
            },
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final idText = _idController.text.trim();
      final finalId = idText.isNotEmpty ? idText : 'TF-${100000 + Random().nextInt(900000)}';

      final p = Product(
        id: widget.product?.id ?? finalId,
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageController.text,
        categoryId: _selectedCategory ?? '',
        inventoryItemId: _selectedInventory,
        catalogId: _selectedCatalog,
        barcode: widget.product?.barcode ?? finalId,
        crossAxisCellCount: _crossAxisCellCount,
        mainAxisCellCount: _mainAxisCellCount,
      );

      setState(() => _isSaving = true);
      context.read<ProductBloc>().add(ProductEvent.addProduct(p));
    }
  }
}
