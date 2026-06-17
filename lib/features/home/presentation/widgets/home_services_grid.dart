import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';

class HomeServicesGrid extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final bool showMoreServices;
  final VoidCallback onToggleMore;
  final Function(int, Map<String, String>) onEdit;
  final Function(int) onRemove;
  final VoidCallback onAdd;
  final void Function(Map<String, String>)? onServiceTap;

  const HomeServicesGrid({
    super.key,
    required this.content,
    required this.isEditing,
    required this.showMoreServices,
    required this.onToggleMore,
    required this.onEdit,
    required this.onRemove,
    required this.onAdd,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    int itemCount;
    if (isEditing) {
      itemCount = content.services.length < 6 ? content.services.length + 1 : 6;
    } else {
      itemCount = showMoreServices ? content.services.length : (content.services.length > 4 ? 4 : content.services.length);
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (isEditing && index == content.services.length) {
                    return _buildAddCard(context);
                  }
                  final s = content.services[index];
                  return _buildServiceCard(context, index, s);
                },
              ),
            ),
          ),
          
          if (!isEditing && content.services.length > 4) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSecondaryButton(
                context, 
                showMoreServices ? 'MOSTRAR MENOS' : 'VER MÁS SERVICIOS', 
                showMoreServices ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, 
                onToggleMore
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF111111),
          border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.primaryGold.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_circle_outline_rounded, color: context.primaryGold, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'AÑADIR SERVICIO',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              'MÁXIMO 6',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.03),
        foregroundColor: context.primaryGold,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.primaryGold.withValues(alpha: 0.1)),
        ),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(width: 8),
          Icon(icon, color: context.primaryGold, size: 16),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, int index, Map<String, String> s) {
    final card = Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: s['img']!.isNotEmpty ? DecorationImage(
              image: s['img']!.startsWith('http')
                  ? ResizeImage(CachedNetworkImageProvider(s['img']!), width: 480)
                  : (s['img']!.startsWith('assets/')
                      ? AssetImage(s['img']!) as ImageProvider
                      : FileImage(File(s['img']!))),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.65), BlendMode.darken),
            ) : null,
            color: s['img']!.isEmpty ? const Color(0xFF1A1A1A) : null,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: context.primaryGold, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    s['price']!,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s['title']!.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.3, height: 1.1),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white38, size: 9),
                    const SizedBox(width: 4),
                    Text(s['time']!, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                _buildMiniEditButton(() => onEdit(index, s)),
                const SizedBox(width: 6),
                _buildMiniRemoveIcon(context, () => onRemove(index)),
              ],
            ),
          ),
      ],
    );

    if (isEditing || onServiceTap == null) return card;
    return GestureDetector(
      onTap: () => onServiceTap!(s),
      child: card,
    );
  }

  Widget _buildMiniEditButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Text(
          'EDITAR',
          style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildMiniRemoveIcon(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161616),
            title: const Text('ELIMINAR SERVICIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            content: const Text('¿Quieres eliminar este servicio?', style: TextStyle(color: Colors.white70)),
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFF4D4D), width: 1),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4D4D), size: 10),
      ),
    );
  }
}
