import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.localImage,
    required this.onTap,
    this.enabled = true,
  });

  final String displayName;
  final String? avatarUrl;
  final File? localImage;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final imageProvider = localImage != null
        ? FileImage(localImage!) as ImageProvider
        : (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? NetworkImage(avatarUrl!)
            : null;

    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((part) => part.isEmpty ? '' : part[0]).take(2).join().toUpperCase()
        : 'A';

    return Column(
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lime, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.cardDarker,
              foregroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: enabled ? onTap : null,
          icon: const Icon(Icons.camera_alt, color: AppColors.lime),
          label: const Text(
            'Edit photo',
            style: TextStyle(color: AppColors.lime),
          ),
        ),
      ],
    );
  }
}
