import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:core/core.dart';
import '../../domain/models/home_content.dart';

class HomeHeroSection extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final VoidCallback onEditTitle;
  final VoidCallback onEditImage;
  final Function(String) onEditTag;

  const HomeHeroSection({
    super.key,
    required this.content,
    required this.isEditing,
    required this.onEditTitle,
    required this.onEditImage,
    required this.onEditTag,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<AppModeBloc, AppModeState>(
        builder: (context, modeState) {
          final isBarber = modeState.mode == AppMode.barber;

          return Stack(
            children: [
              Container(
                height: 480,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: content.heroImageUrl.startsWith('http')
                        ? CachedNetworkImageProvider(content.heroImageUrl)
                        : FileImage(File(content.heroImageUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.35), BlendMode.darken),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.7, 1.0],
                            colors: [
                              Colors.transparent,
                              context.backgroundBlack.withValues(alpha: 0.8),
                              context.backgroundBlack,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroTag(context, content.heroTag1, isEditing, onEditTag),
                          const SizedBox(height: 20),
                          Text(
                            content.heroTitle.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              height: 0.85,
                              letterSpacing: -2,
                            ),
                          ),
                          if (isEditing) ...[
                            const SizedBox(height: 12),
                            _buildEditButton(onEditTitle, label: 'TÍTULO'),
                          ],
                          const SizedBox(height: 16),
                          Container(width: 50, height: 4, decoration: BoxDecoration(color: context.primaryGold, borderRadius: BorderRadius.circular(10))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditing)
                Positioned(
                  top: 110,
                  left: 32,
                  child: _buildEditButton(onEditImage, label: 'PORTADA'),
                ),
              if (isBarber)
                Positioned(
                  top: 60,
                  left: 32,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: BarberHomePage.showBarberBadge,
                        builder: (context, showBadge, child) {
                          if (!showBadge) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.primaryGold.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'MODO BARBERO',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () => context.read<HomeBloc>().add(const HomeEvent.toggleEditMode()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isEditing ? Colors.white : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.primaryGold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            isEditing ? 'LISTO' : 'EDITAR INICIO',
                            style: TextStyle(
                              color: isEditing ? Colors.black : context.primaryGold,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroTag(BuildContext context, String text, bool isEditing, Function(String) onSave) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.primaryGold, 
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: context.primaryGold.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)],
          ),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(width: 12),
          _buildEditButton(() => onEditTag(text), label: 'ETIQUETA'),
        ],
      ],
    );
  }

  Widget _buildEditButton(VoidCallback onTap, {required String label}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
