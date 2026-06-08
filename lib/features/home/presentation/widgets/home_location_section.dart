import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';

class HomeLocationSection extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
   final Function(int, Map<String, String>) onEditLocation;
   final Function(int, String) onEditMap;

  const HomeLocationSection({
    super.key,
    required this.content,
    required this.isEditing,
    required this.onEditLocation,
    required this.onEditMap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
        child: Column(
          children: content.locations.asMap().entries.map((entry) {
            final isLast = entry.key == content.locations.length - 1;
            return Column(
              children: [
                _buildLocationRow(context, entry.value, entry.key),
                if (!isLast) 
                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 32, thickness: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, Map<String, String> location, int index) {
    return Row(
      children: [
        Image.asset(
          'images/location_pin.png',
          width: 32,
          height: 32,
          color: context.primaryGold,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location['label']!.toUpperCase(),
                style: TextStyle(
                  color: context.primaryGold, 
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location['address']!,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 13, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                _buildSmallEditIcon(() => onEditLocation(index, location), label: 'EDITAR SEDE Y DIRECCIÓN'),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            TextButton(
              onPressed: () {
                if (isEditing) {
                  onEditMap(index, location['mapUrl']!);
                } else {
                  launchUrl(Uri.parse(location['mapUrl']!));
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: context.primaryGold.withValues(alpha: isEditing ? 0.05 : 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.primaryGold.withValues(alpha: 0.3)),
                ),
              ),
              child: Text(
                isEditing ? 'EDITAR LINK' : 'IR A MAPA',
                style: TextStyle(
                  color: context.primaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallEditIcon(VoidCallback onTap, {String? label}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
        ),
        child: label != null 
          ? Text(label, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900))
          : const Icon(Icons.mode_edit_outline_rounded, color: Colors.white, size: 8),
      ),
    );
  }
}
