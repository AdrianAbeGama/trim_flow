import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_helpers.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_list_form_editors.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeEditSheets {
  static const int _maxItems = 5;

  static void showServicesList(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (_, state) {
              return HomeListEditorSheet(
                title: 'Servicios',
                subtitle: '${state.content.services.length} / $_maxItems · máx 5',
                addLabel: '+ AGREGAR SERVICIO',
                items: state.content.services,
                titleKey: 'title',
                subtitleKey: 'price',
                imageKey: 'img',
                maxItems: _maxItems,
                onAdd: () {
                  Navigator.pop(sheetCtx);
                  _showServiceForm(context);
                },
                onEdit: (i, data) {
                  Navigator.pop(sheetCtx);
                  _showServiceForm(context, index: i, initialData: data);
                },
                onRemove: (i) async {
                  final ok = await confirmDelete(sheetCtx, 'este servicio');
                  if (ok) {
                    HapticFeedback.lightImpact();
                    bloc.add(HomeEvent.removeService(i));
                  }
                },
                onClose: () => Navigator.pop(sheetCtx),
              );
            },
          ),
        );
      },
    );
  }

  static void showProductsList(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (_, state) {
              return HomeListEditorSheet(
                title: 'Productos',
                subtitle: '${state.content.products.length} / $_maxItems · máx 5',
                addLabel: '+ AGREGAR PRODUCTO',
                items: state.content.products,
                titleKey: 'name',
                subtitleKey: 'price',
                imageKey: 'img',
                maxItems: _maxItems,
                onAdd: () {
                  Navigator.pop(sheetCtx);
                  _showProductForm(context);
                },
                onEdit: (i, data) {
                  Navigator.pop(sheetCtx);
                  _showProductForm(context, index: i, initialData: data);
                },
                onRemove: (i) async {
                  final ok = await confirmDelete(sheetCtx, 'este producto');
                  if (ok) {
                    HapticFeedback.lightImpact();
                    bloc.add(HomeEvent.removeProduct(i));
                  }
                },
                onClose: () => Navigator.pop(sheetCtx),
              );
            },
          ),
        );
      },
    );
  }

  static Future<bool> confirmDelete(BuildContext context, String label) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        const danger = Color(0xFFFF8A95);
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
                      color: danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: danger, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Eliminar item',
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
                '¿Seguro que quieres eliminar $label? Esta acción no se puede deshacer.',
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
                      onTap: () => Navigator.pop(ctx, false),
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
                      onTap: () => Navigator.pop(ctx, true),
                      pressedScale: 0.97,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ELIMINAR',
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
    return res == true;
  }

  static void _showServiceForm(
    BuildContext context, {
    int? index,
    Map<String, String>? initialData,
  }) {
    final nameCtrl = TextEditingController(text: initialData?['title'] ?? '');
    final priceCtrl = TextEditingController(
      text: (initialData?['price'] ?? '').replaceAll('S/', '').replaceAll(' ', ''),
    );
    final durationCtrl = TextEditingController(
      text: (initialData?['time'] ?? '').replaceAll(' min', ''),
    );
    final bloc = context.read<HomeBloc>();
    String imgPath = initialData?['img'] ?? '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheet) {
            return HomeFormEditorSheet(
              title: index == null ? 'Nuevo servicio' : 'Editar servicio',
              onClose: () => Navigator.pop(sheetCtx),
              onSave: () {
                homeConfirmAndSave(
                  context: innerCtx,
                  message: index == null
                      ? '¿Agregar este servicio?'
                      : '¿Guardar los cambios del servicio?',
                  onConfirm: () {
                    HapticFeedback.mediumImpact();
                    final data = {
                      'title': nameCtrl.text,
                      'price': priceCtrl.text.isEmpty ? '' : 'S/ ${priceCtrl.text}',
                      'time': durationCtrl.text.isEmpty ? '' : '${durationCtrl.text} min',
                      'img': imgPath,
                    };
                    if (index == null) {
                      bloc.add(HomeEvent.addService(data));
                    } else {
                      bloc.add(HomeEvent.updateService(index, data));
                    }
                    Navigator.pop(sheetCtx);
                  },
                );
              },
              fields: [
                HomeEditField(label: 'NOMBRE', controller: nameCtrl),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: HomeEditField(label: 'PRECIO (S/)', controller: priceCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: HomeEditField(label: 'TIEMPO (MIN)', controller: durationCtrl)),
                  ],
                ),
                const SizedBox(height: 10),
                HomeImageFieldPicker(
                  label: 'IMAGEN',
                  path: imgPath,
                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                  onPicked: (p) => setSheet(() => imgPath = p),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showProductForm(
    BuildContext context, {
    int? index,
    Map<String, String>? initialData,
  }) {
    final nameCtrl = TextEditingController(text: initialData?['name'] ?? '');
    final descCtrl = TextEditingController(text: initialData?['desc'] ?? '');
    final priceCtrl = TextEditingController(
      text: (initialData?['price'] ?? '').replaceAll('S/', '').replaceAll(' ', ''),
    );
    final bloc = context.read<HomeBloc>();
    String imgPath = initialData?['img'] ?? '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheet) {
            return HomeFormEditorSheet(
              title: index == null ? 'Nuevo producto' : 'Editar producto',
              onClose: () => Navigator.pop(sheetCtx),
              onSave: () {
                homeConfirmAndSave(
                  context: innerCtx,
                  message: index == null
                      ? '¿Agregar este producto?'
                      : '¿Guardar los cambios del producto?',
                  onConfirm: () {
                    HapticFeedback.mediumImpact();
                    final data = {
                      'name': nameCtrl.text,
                      'desc': descCtrl.text,
                      'price': priceCtrl.text.isEmpty ? '' : 'S/ ${priceCtrl.text}',
                      'img': imgPath,
                    };
                    if (index == null) {
                      bloc.add(HomeEvent.addProduct(data));
                    } else {
                      bloc.add(HomeEvent.updateProduct(index, data));
                    }
                    Navigator.pop(sheetCtx);
                  },
                );
              },
              fields: [
                HomeEditField(label: 'NOMBRE', controller: nameCtrl),
                const SizedBox(height: 10),
                HomeEditField(label: 'DESCRIPCIÓN', controller: descCtrl, maxLines: 3),
                const SizedBox(height: 10),
                HomeEditField(label: 'PRECIO (S/)', controller: priceCtrl),
                const SizedBox(height: 10),
                HomeImageFieldPicker(
                  label: 'IMAGEN',
                  path: imgPath,
                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                  onPicked: (p) => setSheet(() => imgPath = p),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Sheet genérico que muestra una lista de items con botones edit/remove
/// y un CTA para agregar uno nuevo. Compacto (sheet pequeño, scroll interno).
