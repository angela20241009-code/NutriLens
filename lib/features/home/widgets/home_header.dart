import 'package:flutter/material.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.profile,
    required this.onProfileTap,
  });

  final UserProfile profile;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final name = _displayName(profile);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_greetingFor(DateTime.now()) case final greeting?) ...[
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '$name 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onProfileTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lime, width: 2),
              color: AppColors.cardDark,
            ),
            clipBehavior: Clip.antiAlias,
            child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    color: AppColors.textMuted,
                    size: 28,
                  )
                : Image.network(
                    profile.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: AppColors.textMuted,
                      size: 28,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _displayName(UserProfile profile) {
    final firstName = profile.firstName?.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    final displayName = profile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    return 'Athlete';
  }

  String? _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    }
    return null;
  }
}
