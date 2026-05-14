import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';

class HomeFooterSocial extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final Function(String, String) onEdit;

  const HomeFooterSocial({
    super.key,
    required this.content,
    required this.isEditing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
        child: Column(
          children: [
            Container(width: 40, height: 2, decoration: BoxDecoration(color: context.primaryGold, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 32),
            Text(
              'ÚNETE A LA COMUNIDAD'.toUpperCase(),
              style: TextStyle(
                color: Colors.white, 
                fontSize: 14, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 4
              ),
            ),
            const SizedBox(height: 48),
            
            // Grouped Icons (Yellow/Gold)
            Wrap(
              spacing: 30,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildPremiumSocial(context, FontAwesomeIcons.instagram, 'instagram'),
                _buildPremiumSocial(context, FontAwesomeIcons.tiktok, 'tiktok'),
                _buildPremiumSocial(context, FontAwesomeIcons.whatsapp, 'whatsapp'),
                _buildPremiumSocial(context, FontAwesomeIcons.facebook, 'facebook'),
              ],
            ),
            
            const SizedBox(height: 80),
            Text(
              'TRIMFLOW OS © 2026',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.05), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSocial(BuildContext context, dynamic icon, String platform) {
    final url = content.socialLinks[platform] ?? '';
    final bool hasUrl = url.isNotEmpty;
    
    return GestureDetector(
      onTap: isEditing
          ? () => onEdit(platform, url)
          : (hasUrl ? () => launchUrl(Uri.parse(url)) : null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasUrl ? context.primaryGold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasUrl ? context.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
                  ),
                ),
                child: FaIcon(
                  icon as dynamic, 
                  color: hasUrl ? context.primaryGold : Colors.white24, 
                  size: 22,
                ),
              ),
              if (isEditing)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.mode_edit_outline_rounded, color: Colors.black, size: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            platform.toUpperCase(),
            style: TextStyle(
              color: hasUrl ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.1),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
