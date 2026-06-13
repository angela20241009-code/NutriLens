import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SleepDashboardScreen extends StatelessWidget {
  const SleepDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = UserScope.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<UserProfile?>(
            future: scope.repository.getProfile(scope.uid),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingFor(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_displayName(profile)} 👋',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Sleep mode',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.sleepAccent.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sleepAccentMuted,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.sleepAccent.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.sleepAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bedtime_rounded,
                    color: AppColors.sleepAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sleep insights coming soon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Track rest and recovery to improve performance on and off the court. '
                  'Sleep duration, quality scores, and bedtime routines will appear here.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sleepAccent,
                side: const BorderSide(color: AppColors.sleepAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Log sleep',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(UserProfile? profile) {
    final firstName = profile?.firstName?.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    final displayName = profile?.displayName.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    return 'Athlete';
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}
