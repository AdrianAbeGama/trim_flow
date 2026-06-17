import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/widgets/premium/premium_quick_action_card.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';

/// Sliver con la acción de crear un nuevo portafolio. Solo en barber mode.
class GalleryQuickActionsSliver extends StatelessWidget {
  const GalleryQuickActionsSliver({super.key, required this.isBarberMode});
  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    if (!isBarberMode) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final gb = context.read<GalleryBloc>();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: PremiumQuickActionCard(
          icon: Icons.add_photo_alternate_rounded,
          label: 'AGREGAR FOTOS AL PORTAFOLIO',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: gb,
                child: const GalleryCreateFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
