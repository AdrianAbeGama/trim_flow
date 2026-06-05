import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/widgets/premium/premium_quick_action_card.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_admin_dashboard_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';

/// Sliver con 2 quick action cards (NUEVO PORTAFOLIO + PANEL ADMIN).
/// Solo se muestra en barber mode.
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
        child: Row(
          children: [
            Expanded(
              child: PremiumQuickActionCard(
                icon: Icons.add_photo_alternate_rounded,
                label: 'NUEVO\nPORTAFOLIO',
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
            const SizedBox(width: 10),
            Expanded(
              child: PremiumQuickActionCard(
                icon: Icons.tune_rounded,
                label: 'PANEL\nADMIN',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: gb,
                      child: const GalleryAdminDashboardView(),
                    ),
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
