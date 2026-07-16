import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/account_settings_screen.dart';
import 'package:nutrilens/features/profile/link_email_dialog.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserRepository _repository;
  late String _uid;
  bool _hasUserScope = false;
  UserProfile? _profile;
  UserAccount? _account;
  bool _loading = true;
  bool _busy = false;
  XFile? _pickedAvatar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    final scopeChanged =
        !_hasUserScope || _repository != scope.repository || _uid != scope.uid;

    _repository = scope.repository;
    _uid = scope.uid;
    _hasUserScope = true;

    if (scopeChanged) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final loadedProfile = await _repository.getProfile(_uid);
      final loadedAccount = await _repository.getAccount(_uid);
      if (mounted) {
        setState(() {
          _profile = loadedProfile ??
              UserProfile.emptyShell(
                userId: _uid,
                now: DateTime.now().toUtc(),
                timezone: 'America/Los_Angeles',
              );
          _account = loadedAccount;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load profile: $error')),
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      setState(() => _pickedAvatar = picked);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const AccountSettingsScreen(),
      ),
    );
    if (mounted) await _loadProfile();
  }

  bool get _isGuest => _account?.isAnonymous ?? true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: _loading ? null : _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isGuest
              ? _GuestPrompt(
                  account: _account,
                  repository: _repository,
                  busy: _busy,
                  onLinkEmail: () async {
                    if (_account == null) return;
                    setState(() => _busy = true);
                    final updated = await showLinkEmailDialog(
                      context: context,
                      repository: _repository,
                      uid: _account!.uid,
                    );
                    if (mounted) {
                      setState(() => _busy = false);
                      if (updated != null) await _loadProfile();
                    }
                  },
                )
              : _ProfileContent(
                  profile: _profile!,
                  account: _account,
                  pickedAvatar: _pickedAvatar,
                  onPickAvatar: _pickAvatar,
                  onOpenSettings: _openSettings,
                ),
    );
  }
}

// ─── Guest state ─────────────────────────────────────────────────────────────

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt({
    required this.account,
    required this.repository,
    required this.busy,
    required this.onLinkEmail,
  });

  final UserAccount? account;
  final UserRepository repository;
  final bool busy;
  final VoidCallback onLinkEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lime, width: 2.5),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 44,
                color: AppColors.lime,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create an account',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign up to save your profile, nutrition goals, and training data.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: busy ? null : onLinkEmail,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.onLime,
                ),
                child: busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.onLime,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile content ──────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.account,
    required this.pickedAvatar,
    required this.onPickAvatar,
    required this.onOpenSettings,
  });

  final UserProfile profile;
  final UserAccount? account;
  final XFile? pickedAvatar;
  final VoidCallback onPickAvatar;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageProvider = pickedAvatar != null
        ? FileImage(File(pickedAvatar!.path)) as ImageProvider
        : (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
            ? NetworkImage(profile.avatarUrl!)
            : null;

    final initials = profile.displayName.trim().split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar & name ─────────────────────────────────────────────────
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lime, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.cardDarker,
                    foregroundImage: imageProvider,
                    child: imageProvider == null
                        ? Text(
                            initials.isEmpty ? '?' : initials,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: onPickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: AppColors.onLime,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName.isEmpty ? 'No name set' : profile.displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          if (profile.primarySportName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.lime.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  profile.primarySportName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (profile.schoolName != null && profile.schoolName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              profile.schoolName!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
            ),
          ],

          // ── Nutrition quick stats ─────────────────────────────────────────
          const SizedBox(height: 28),
          Row(
            children: [
              _StatTile(
                value: '${profile.dailyTargets.caloriesKcal}',
                unit: 'kcal',
                label: 'Calories',
              ),
              const SizedBox(width: 8),
              _StatTile(
                value: '${profile.dailyTargets.proteinG}g',
                unit: 'Protein',
                label: 'protein',
              ),
              const SizedBox(width: 8),
              _StatTile(
                value: '${profile.dailyTargets.carbsG}g',
                unit: 'Carbs',
                label: 'carbs',
              ),
              const SizedBox(width: 8),
              _StatTile(
                value: '${profile.dailyTargets.fatsG}g',
                unit: 'Fats',
                label: 'fats',
              ),
            ],
          ),

          // ── Personal ─────────────────────────────────────────────────────
          const SizedBox(height: 28),
          _InfoSection(
            title: 'Personal',
            icon: Icons.person_outline_rounded,
            rows: [
              _InfoRow(
                label: 'Email',
                value: account?.email ?? '—',
              ),
              _InfoRow(
                label: 'Phone',
                value: profile.phoneNumber?.isNotEmpty == true
                    ? profile.phoneNumber!
                    : '—',
              ),
              _InfoRow(
                label: 'Gender',
                value: _genderLabel(profile.sex),
              ),
              _InfoRow(
                label: 'Birth year',
                value: profile.birthYear?.toString() ?? '—',
                isLast: true,
              ),
            ],
          ),

          // ── Athlete ───────────────────────────────────────────────────────
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Athlete',
            icon: Icons.sports_rounded,
            rows: [
              _InfoRow(
                label: 'Sport',
                value: profile.primarySportName.isEmpty
                    ? '—'
                    : profile.primarySportName,
              ),
              _InfoRow(
                label: 'School',
                value: profile.schoolName?.isNotEmpty == true
                    ? profile.schoolName!
                    : '—',
              ),
              _InfoRow(
                label: 'Graduation year',
                value: profile.graduationYear?.toString() ?? '—',
              ),
              _InfoRow(
                label: 'Height',
                value: profile.heightCm != null
                    ? '${profile.heightCm} cm'
                    : '—',
              ),
              _InfoRow(
                label: 'Weight',
                value: profile.weightKg != null
                    ? '${profile.weightKg} kg'
                    : '—',
              ),
              _InfoRow(
                label: 'Training days',
                value: profile.trainingDaysPerWeek != null
                    ? '${profile.trainingDaysPerWeek} / week'
                    : '—',
              ),
              _InfoRow(
                label: 'Activity level',
                value: _activityLabel(profile.activityLevel),
                isLast: true,
              ),
            ],
          ),

          // ── Nutrition Goals ───────────────────────────────────────────────
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Nutrition Goals',
            icon: Icons.local_fire_department_rounded,
            rows: [
              _InfoRow(
                label: 'Calories',
                value: '${profile.dailyTargets.caloriesKcal} kcal',
              ),
              _InfoRow(
                label: 'Protein',
                value: '${profile.dailyTargets.proteinG} g',
              ),
              _InfoRow(
                label: 'Carbs',
                value: '${profile.dailyTargets.carbsG} g',
              ),
              _InfoRow(
                label: 'Fats',
                value: '${profile.dailyTargets.fatsG} g',
              ),
              _InfoRow(
                label: 'Hydration',
                value: '${profile.dailyTargets.hydrationLiters} L',
              ),
              _InfoRow(
                label: 'Sleep target',
                value: '${profile.dailyTargets.sleepHours} hrs',
                isLast: true,
              ),
            ],
          ),

          // ── Dietary ───────────────────────────────────────────────────────
          if (profile.dietaryProfile.allergens.isNotEmpty ||
              profile.dietaryProfile.restrictions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Dietary',
              icon: Icons.no_food_rounded,
              rows: [
                if (profile.dietaryProfile.allergens.isNotEmpty)
                  _InfoRow(
                    label: 'Allergens',
                    value: profile.dietaryProfile.allergens.join(', '),
                    isLast: profile.dietaryProfile.restrictions.isEmpty,
                  ),
                if (profile.dietaryProfile.restrictions.isNotEmpty)
                  _InfoRow(
                    label: 'Restrictions',
                    value: profile.dietaryProfile.restrictions.join(', '),
                    isLast: true,
                  ),
              ],
            ),
          ],

          // ── Edit button ───────────────────────────────────────────────────
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit profile & settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lime,
              side: const BorderSide(color: AppColors.lime),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _genderLabel(String? sex) => switch (sex) {
        'female' => 'Female',
        'male' => 'Male',
        'non_binary' => 'Non-binary',
        'prefer_not_to_say' => 'Prefer not to say',
        _ => '—',
      };

  static String _activityLabel(String? level) => switch (level) {
        'low' => 'Low',
        'moderate' => 'Moderate',
        'high' => 'High',
        'very_high' => 'Very high',
        _ => '—',
      };
}

// ─── Stat tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.lime.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lime.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              unit,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 13, color: AppColors.lime),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.lime,
                ),
              ),
            ],
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.cardDarker,
                    indent: 16,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
