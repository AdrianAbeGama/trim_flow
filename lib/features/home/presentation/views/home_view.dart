import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_view/story_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

import '../bloc/home_bloc.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_stories_bar.dart';
import '../widgets/home_smart_notification.dart';
import '../widgets/home_services_grid.dart';
import '../widgets/home_products_carousel.dart';
import '../widgets/home_about_us_section.dart';
import '../widgets/home_location_section.dart';
import '../widgets/home_footer_social.dart';
import '../widgets/home_section_header.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onNavigateToProducts;
  final VoidCallback? onNavigateToAppointments;

  const HomeView({
    super.key,
    this.onNavigateToServices,
    this.onNavigateToProducts,
    this.onNavigateToAppointments,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final StoryController _storyController = StoryController();
  bool _showMoreServices = false;

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, Function(String) onPicked) async {
    final picker = ImagePicker();
    
    await showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('CAMBIAR IMAGEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: context.primaryGold),
              title: const Text('GALERÍA DEL CELULAR', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) onPicked(pickedFile.path);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: context.primaryGold),
              title: const Text('USAR CÁMARA', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) onPicked(pickedFile.path);
              },
            ),
            ListTile(
              leading: Icon(Icons.link_rounded, color: context.primaryGold),
              title: const Text('URL DE INTERNET', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showUrlInput(context, onPicked);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showUrlInput(BuildContext context, Function(String) onPicked) {
    final controller = TextEditingController();
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PEGAR URL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  hintText: 'https://...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Builder(builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) onPicked(controller.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.w900)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceForm(BuildContext context, {int? index, Map<String, String>? initialData}) {
    final titleController = TextEditingController(text: initialData?['title'] ?? '');
    final priceController = TextEditingController(text: initialData?['price']?.replaceAll('S/ ', '') ?? '');
    final timeController = TextEditingController(text: initialData?['time']?.replaceAll(' min', '') ?? '');
    String currentImg = initialData?['img'] ?? '';

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(index == null ? 'AÑADIR SERVICIO' : 'EDITAR SERVICIO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  _buildFormField(context, 'NOMBRE DEL SERVICIO', titleController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildFormField(context, 'PRECIO (S/)', priceController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFormField(context, 'TIEMPO (MIN)', timeController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildImagePreview(currentImg, () => _pickImage(context, (path) => setModalState(() => currentImg = path))),
                  const SizedBox(height: 32),
                  _buildSaveButton(context, () {
                    final data = {
                      'title': titleController.text,
                      'price': 'S/ ${priceController.text}',
                      'time': '${timeController.text} min',
                      'img': currentImg,
                    };
                    if (index == null) {
                      context.read<HomeBloc>().add(HomeEvent.addService(data));
                    } else {
                      context.read<HomeBloc>().add(HomeEvent.updateService(index, data));
                    }
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, {int? index, Map<String, String>? initialData}) {
    final nameController = TextEditingController(text: initialData?['name'] ?? '');
    final descController = TextEditingController(text: initialData?['desc'] ?? '');
    final priceController = TextEditingController(text: initialData?['price']?.replaceAll('S/ ', '') ?? '');
    String currentImg = initialData?['img'] ?? '';

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(index == null ? 'AÑADIR PRODUCTO' : 'EDITAR PRODUCTO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  _buildFormField(context, 'NOMBRE DEL PRODUCTO', nameController),
                  const SizedBox(height: 16),
                  _buildFormField(context, 'DESCRIPCIÓN', descController, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildFormField(context, 'PRECIO (S/)', priceController, keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  _buildImagePreview(currentImg, () => _pickImage(context, (path) => setModalState(() => currentImg = path))),
                  const SizedBox(height: 32),
                  _buildSaveButton(context, () {
                    final data = {
                      'name': nameController.text,
                      'desc': descController.text,
                      'price': 'S/ ${priceController.text}',
                      'img': currentImg,
                    };
                    if (index == null) {
                      context.read<HomeBloc>().add(HomeEvent.addProduct(data));
                    } else {
                      context.read<HomeBloc>().add(HomeEvent.updateProduct(index, data));
                    }
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStoryAdd(BuildContext context) {
    final labelController = TextEditingController();
    String currentImg = '';

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('AÑADIR HISTORIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 24),
                _buildFormField(context, 'ETIQUETA (E.G. TENDENCIA)', labelController),
                const SizedBox(height: 24),
                _buildImagePreview(currentImg, () => _pickImage(context, (path) => setModalState(() => currentImg = path))),
                const SizedBox(height: 32),
                _buildSaveButton(context, () {
                  if (currentImg.isNotEmpty) {
                    context.read<HomeBloc>().add(HomeEvent.addStory({
                      'label': labelController.text.isEmpty ? 'NUEVO' : labelController.text,
                      'image': currentImg,
                    }));
                    Navigator.pop(context);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(BuildContext context, String label, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.primaryGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: path.isEmpty 
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(builder: (context) => Icon(Icons.add_circle_outline_rounded, color: context.primaryGold, size: 40)),
                  SizedBox(height: 12),
                  Text(
                    'SUBIR IMAGEN',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: path.startsWith('http') 
                    ? CachedNetworkImage(imageUrl: path, fit: BoxFit.cover)
                    : (path.startsWith('assets/') ? Image.asset(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover)),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black45,
                  ),
                  child: const Center(
                    child: Text(
                      'CAMBIAR IMAGEN',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primaryGold,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  void _showTextEdit(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                maxLines: null,
                style: const TextStyle(color: Colors.white, height: 1.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Builder(builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.w900)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationForm(BuildContext context, int index, Map<String, String> initialData) {
    final labelController = TextEditingController(text: initialData['label'] ?? '');
    final addressController = TextEditingController(text: initialData['address'] ?? '');

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('EDITAR SEDE Y DIRECCIÓN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              _buildFormField(context, 'TÍTULO DE LA SEDE', labelController),
              const SizedBox(height: 16),
              _buildFormField(context, 'DIRECCIÓN FÍSICA', addressController, maxLines: 2),
              const SizedBox(height: 32),
              _buildSaveButton(context, () {
                final newData = {
                  ...initialData,
                  'label': labelController.text,
                  'address': addressController.text,
                };
                context.read<HomeBloc>().add(HomeEvent.updateLocation(index, newData));
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return Center(child: CircularProgressIndicator(color: context.primaryGold, strokeWidth: 2));
        }

        return Container(
          color: context.backgroundBlack,
          child: RefreshIndicator(
            onRefresh: () async => context.read<HomeBloc>().add(const HomeEvent.load()),
            color: context.primaryGold,
            backgroundColor: const Color(0xFF1A1A1A),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                HomeHeroSection(
                  content: state.content,
                  isEditing: state.isEditing,
                  onEditTitle: () => _showTextEdit(context, 'Título Principal', state.content.heroTitle, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateHero(title: v))),
                  onEditImage: () => _pickImage(context, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateHero(imageUrl: v))),
                  onEditTag: (tag) => _showTextEdit(context, 'Etiqueta', tag, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateHero(tag1: v))),
                ),

                const HomeSectionHeader(
                  title: 'Nuestros Estilos', 
                  subtitle: 'Descubre las últimas tendencias de hoy.'
                ),
                HomeStoriesBar(
                  content: state.content,
                  isEditing: state.isEditing,
                  storyController: _storyController,
                  onRemove: (i) => context.read<HomeBloc>().add(HomeEvent.removeStory(i)),
                  onAdd: () => _showStoryAdd(context),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const HomeSectionHeader(
                  title: 'Tu Próxima Cita', 
                  subtitle: 'No pierdas el rastro de tu estilo.'
                ),
                HomeSmartNotification(
                  isEditing: state.isEditing,
                  onNavigateToAppointments: widget.onNavigateToAppointments,
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const HomeSectionHeader(
                  title: 'Servicios Estrella', 
                  subtitle: 'Lo mejor de nuestra barbería para ti.',
                ),
                HomeServicesGrid(
                  content: state.content,
                  isEditing: state.isEditing,
                  showMoreServices: _showMoreServices,
                  onToggleMore: () => setState(() => _showMoreServices = !_showMoreServices),
                  onEdit: (i, s) => _showServiceForm(context, index: i, initialData: s),
                  onRemove: (i) => context.read<HomeBloc>().add(HomeEvent.removeService(i)),
                  onAdd: () => _showServiceForm(context),
                  onServiceTap: widget.onNavigateToServices == null
                      ? null
                      : (service) {
                          HomePage.requestedService.value = service;
                          widget.onNavigateToServices!();
                        },
                ),
                if (widget.onNavigateToServices != null && !state.isEditing)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24, top: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildSmallNavButton(context, 'Ir a servicios', widget.onNavigateToServices!),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const HomeSectionHeader(
                  title: 'Productos Destacados', 
                  subtitle: 'Cuida tu look con lo mejor del mercado.',
                ),
                HomeProductsCarousel(
                  content: state.content,
                  isEditing: state.isEditing,
                  onEdit: (i, p) => _showProductForm(context, index: i, initialData: p),
                  onRemove: (i) => context.read<HomeBloc>().add(HomeEvent.removeProduct(i)),
                  onAdd: () => _showProductForm(context),
                  onProductTap: widget.onNavigateToProducts == null
                      ? null
                      : (product) {
                          HomePage.requestedProductId.value = product['id'] ?? product['name'];
                          widget.onNavigateToProducts!();
                        },
                ),
                if (widget.onNavigateToProducts != null && !state.isEditing)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24, top: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildSmallNavButton(context, 'Ir a productos', widget.onNavigateToProducts!),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const HomeSectionHeader(
                  title: 'Sobre Nosotros', 
                  subtitle: 'Pasión por el detalle y respeto por la tradición.',
                ),
                HomeAboutUsSection(
                  content: state.content,
                  isEditing: state.isEditing,
                  onEditImage: () => _pickImage(context, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateAboutUs(imageUrl: v))),
                  onEditText: () => _showTextEdit(context, 'Sobre Nosotros', state.content.aboutUsText, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateAboutUs(text: v))),
                  onEditVideo: () => _showTextEdit(context, 'URL Video Youtube', state.content.aboutUsVideoUrl, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateAboutUs(videoUrl: v))),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const HomeSectionHeader(
                  title: 'Visítanos', 
                  subtitle: 'Encuentra tu sucursal más cercana.'
                ),
                HomeLocationSection(
                  content: state.content,
                  isEditing: state.isEditing,
                  onEditLocation: (i, data) => _showLocationForm(context, i, data),
                  onEditMap: (i, v) => _showTextEdit(context, 'URL Google Maps', v, 
                    (newVal) => context.read<HomeBloc>().add(HomeEvent.updateLocation(i, {...state.content.locations[i], 'mapUrl': newVal}))),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                HomeFooterSocial(
                  content: state.content,
                  isEditing: state.isEditing,
                  onEdit: (p, u) => _showTextEdit(context, 'Red Social ($p)', u, 
                    (v) => context.read<HomeBloc>().add(HomeEvent.updateSocialLink(p, v))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallNavButton(BuildContext context, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.primaryGold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: context.primaryGold, size: 16),
        ],
      ),
    );
  }
}
