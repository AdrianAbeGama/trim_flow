import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import '../views/profile_settings_view.dart';

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
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person Icon at the top
            Icon(Icons.person_rounded, color: context.primaryGold, size: 28),
            const SizedBox(height: 8),
            
            // Row with Header Title & Configuration Settings Button (Perfect vertical alignment!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'PERFIL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<ProfileBloc>()),
                            BlocProvider.value(value: context.read<AppModeBloc>()),
                          ],
                          child: ProfileSettingsView(user: user, isBarber: false),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.settings_outlined, size: 22, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(width: 40, height: 3, color: context.primaryGold),
            
            const SizedBox(height: 24),
            
            // Centered Info & Avatar with modern Pencil Overlay & ID Badge below email
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatarWithEdit(context),
                  const SizedBox(height: 20),
                  _buildIdentity(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithEdit(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1.5),
          ),
          padding: const EdgeInsets.all(5),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.photoUrl,
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
        ),
        // Modern circular floating pencil edit button overlapping the avatar
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primaryGold,
                shape: BoxShape.circle,
                border: Border.all(color: context.backgroundBlack, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.black, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity(BuildContext context) {
    return Column(
      children: [
        Text(
          '${user.firstName} ${user.lastName}'.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        // ID Badge relocated right below the email (centered & extremely unified!)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: context.primaryGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.primaryGold.withValues(alpha: 0.2)),
          ),
          child: Text(
            'ID: ${user.customerId?.substring(0, 8) ?? user.id.substring(0, 8)}',
            style: TextStyle(
              color: context.primaryGold, 
              fontSize: 10, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
