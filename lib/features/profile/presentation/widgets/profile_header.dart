import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_rounded, color: context.primaryGold, size: 28),
          const SizedBox(height: 10),
          const Text(
            'PERFIL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          Container(width: 40, height: 2, color: context.primaryGold),
          const SizedBox(height: 32),
          
          // ID and Edit Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'ID: ${user.customerId?.substring(0, 8) ?? user.id.substring(0, 8)}',
                  style: TextStyle(color: context.primaryGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white60),
                label: const Text(
                  'EDITAR PERFIL',
                  style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Centered Info
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(context, user.photoUrl),
                const SizedBox(height: 24),
                _buildIdentity(context, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.all(5),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.white10,
            child: const Center(child: CupertinoActivityIndicator(radius: 10)),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white24, size: 40),
        ),
      ),
    );
  }

  Widget _buildIdentity(BuildContext context, UserProfile user) {
    return Column(
      children: [
        Text(
          '${user.firstName} ${user.lastName}'.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
