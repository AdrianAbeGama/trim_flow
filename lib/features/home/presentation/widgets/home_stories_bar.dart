import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:story_view/story_view.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';

class HomeStoriesBar extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final StoryController storyController;
  final Function(int) onRemove;
  final VoidCallback onAdd;

  const HomeStoriesBar({
    super.key,
    required this.content,
    required this.isEditing,
    required this.storyController,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 130,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: content.stories.length + (isEditing ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == content.stories.length) {
              return _buildAddButton(context);
            }
            final story = content.stories[index];
            return _buildStoryItem(context, story, index);
          },
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: onAdd,
        child: Column(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Center(
                child: Icon(Icons.add_rounded, color: context.primaryGold, size: 24),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AGREGAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, Map<String, String> story, int index) {
    final isVideo = _isVideoUrl(story['image'] ?? '');
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _openStory(context, index),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        context.primaryGold,
                        const Color(0xFF8A6D3B),
                        context.primaryGold,
                      ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(color: context.backgroundBlack, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      backgroundImage: isVideo
                          ? null
                          : (story['image']!.startsWith('http')
                              ? ResizeImage(
                                  CachedNetworkImageProvider(story['image']!),
                                  width: 200)
                              : FileImage(File(story['image']!)) as ImageProvider),
                      child: isVideo
                          ? Icon(Icons.play_circle_fill_rounded, color: context.primaryGold, size: 40)
                          : null,
                    ),
                  ),
                ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  story['label']?.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            Positioned(
              top: 0,
              right: 0,
              child: _buildRemoveIcon(context, () => onRemove(index)),
            ),
        ],
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v');
  }

  void _openStory(BuildContext context, int initialIndex) {
    final items = content.stories.map((s) {
      final url = s['image']!;
      final caption = Text(
        s['label']!,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      );
      if (_isVideoUrl(url)) {
        return StoryItem.pageVideo(
          url,
          controller: storyController,
          caption: caption,
          duration: const Duration(seconds: 15),
        );
      }
      return StoryItem.pageImage(
        url: url,
        controller: storyController,
        caption: caption,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              StoryView(
                storyItems: items,
                controller: storyController,
                onComplete: () => Navigator.pop(context),
              ),
              Positioned(
                top: 60,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveIcon(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161616),
            title: const Text('ELIMINAR HISTORIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            content: const Text('¿Quieres eliminar esta historia?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO', style: TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('SÍ, ELIMINAR', style: TextStyle(color: Color(0xFFFF4D4D), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (confirm == true) onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D4D),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
      ),
    );
  }
}
