import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';
import 'home_youtube_video_modal.dart';

class HomeAboutUsSection extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final VoidCallback onEditImage;
  final VoidCallback onEditText;
  final VoidCallback onEditVideo;

  const HomeAboutUsSection({
    super.key,
    required this.content,
    required this.isEditing,
    required this.onEditImage,
    required this.onEditText,
    required this.onEditVideo,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Description
            Text(
              content.aboutUsText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              _buildTextEditButton(onEditText, 'EDITAR DESCRIPCIÓN'),
            ],
            
            const SizedBox(height: 32),
            
            // Hero Card Image (Video Style)
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isEditing) {
                      onEditImage();
                    } else if (content.aboutUsVideoUrl.isNotEmpty) {
                      YoutubeVideoModal.show(context, content.aboutUsVideoUrl);
                    }
                  },
                  child: Container(
                    height: 350, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          content.aboutUsImageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: content.aboutUsImageUrl,
                                  fit: BoxFit.cover,
                                )
                              : (content.aboutUsImageUrl.startsWith('assets/')
                                  ? Image.asset(content.aboutUsImageUrl, fit: BoxFit.cover)
                                  : (content.aboutUsImageUrl.isNotEmpty && File(content.aboutUsImageUrl).existsSync() 
                                      ? Image.file(File(content.aboutUsImageUrl), fit: BoxFit.cover)
                                      : Container(color: Colors.white.withValues(alpha: 0.05)))),
                          
                          // Dark Overlay Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          
                          // Play Icon and Small Description at Bottom Right
                          Positioned(
                            bottom: 32,
                            right: 32,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'NUESTRA HISTORIA',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      content.aboutUsVideoUrl.isNotEmpty ? 'Ver video' : (isEditing ? 'Configurar video' : ''),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.primaryGold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                                ),
                              ],
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 32,
                              left: 32,
                              child: _buildTextEditButton(onEditVideo, 'EDITAR URL VIDEO'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isEditing)
                  const Positioned.fill(
                    child: Center(
                      child: IgnorePointer(
                        child: Text(
                          'TOCA LA IMAGEN PARA\nCAMBIARLA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextEditButton(VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
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
