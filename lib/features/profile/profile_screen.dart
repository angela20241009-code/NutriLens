import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/account_settings_screen.dart';
import 'package:nutrilens/features/profile/link_email_dialog.dart';
import 'package:nutrilens/features/profile/widgets/profile_avatar_picker.dart';
import 'package:nutrilens/features/profile/widgets/profile_field_card.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _schoolController = TextEditingController();
  final _graduationController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergensController = TextEditingController();
  final _restrictionsController = TextEditingController();

  UserProfile? _profile;
  UserAccount? _account;
  bool _saving = false;
  bool _loading = true;
  int _selectedSection = 0;
  XFile? _pickedAvatar;
  String? _genderValue;
  String? _activityLevelValue;
  int? _trainingDaysValue;

  static const _genderOptions = {
    'female': 'Female',
    'male': 'Male',
    'non_binary': 'Non-binary',
    'prefer_not_to_say': 'Prefer not to say',
  };

  static const _activityOptions = {
    'low': 'Low',
    'moderate': 'Moderate',
    'high': 'High',
    'very_high': 'Very high',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _graduationController.dispose();
    _birthYearController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergensController.dispose();
    _restrictionsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final scope = UserScope.of(context);
    final repository = scope.repository;
    final uid = scope.uid;

    try {
      final loadedProfile = await repository.getProfile(uid);
      final loadedAccount = await repository.getAccount(uid);
      final profile = loadedProfile ?? UserProfile.emptyShell(
        userId: uid,
        now: DateTime.now().toUtc(),
        timezone: 'America/Los_Angeles',
      );

      _profile = profile;
      _account = loadedAccount;
      _displayNameController.text = profile.displayName;
      _phoneNumberController.text = profile.phoneNumber ?? '';
      _emailController.text = loadedAccount?.email ?? '';
      _schoolController.text = profile.schoolName ?? '';
      _graduationController.text = profile.graduationYear?.toString() ?? '';
      _birthYearController.text = profile.birthYear?.toString() ?? '';
      _heightController.text = profile.heightCm?.toString() ?? '';
      _weightController.text = profile.weightKg?.toString() ?? '';
      _allergensController.text = profile.dietaryProfile.allergens.join('\n');
      _restrictionsController.text = profile.dietaryProfile.restrictions.join('\n');
      _genderValue = profile.sex;
      _activityLevelValue = profile.activityLevel;
      _trainingDaysValue = profile.trainingDaysPerWeek;
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load profile: $error')),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      setState(() {
        _pickedAvatar = picked;
      });
    }
  }

  List<String> _splitList(String input) {
    return input
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim());
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _profile == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final repository = UserScope.of(context).repository;
    final updated = _profile!.copyWith(
      displayName: _displayNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim().isEmpty
          ? null
          : _phoneNumberController.text.trim(),
      sex: _genderValue,
      schoolName: _schoolController.text.trim().isEmpty
          ? null
          : _schoolController.text.trim(),
      graduationYear: _parseInt(_graduationController.text),
      birthYear: _parseInt(_birthYearController.text),
      heightCm: _parseDouble(_heightController.text),
      weightKg: _parseDouble(_weightController.text),
      trainingDaysPerWeek: _trainingDaysValue,
      activityLevel: _activityLevelValue,
      dietaryProfile: _profile!.dietaryProfile.copyWith(
        allergens: _splitList(_allergensController.text),
        restrictions: _splitList(_restrictionsController.text),
      ),
    );

    try {
      await repository.saveProfile(updated);
      if (mounted) {
        setState(() {
          _profile = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showLinkEmailDialog() async {
    if (_account == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final repository = UserScope.of(context).repository;
    final updated = await showLinkEmailDialog(
      context: context,
      repository: repository,
      uid: _account!.uid,
    );

    if (mounted) {
      setState(() {
        _saving = false;
        if (updated != null) {
          _account = updated;
          _emailController.text = updated.email ?? '';
        }
      });
      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email linked successfully')),
        );
      }
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const AccountSettingsScreen(),
      ),
    );
    if (mounted) {
      await _loadProfile();
    }
  }

  bool get _isProfileDisabled => _account?.isAnonymous ?? true;

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
          : _isProfileDisabled
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_outlined, size: 56),
                        SizedBox(height: 20),
                        Text(
                          'Create an account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sign up to set up your profile and save your data.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileAvatarPicker(
                          displayName: _displayNameController.text,
                          avatarUrl: _profile?.avatarUrl,
                          localImage: _pickedAvatar != null
                              ? File(_pickedAvatar!.path)
                              : null,
                          onTap: _pickAvatar,
                          enabled: !_isProfileDisabled,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _displayNameController.text.isEmpty
                                    ? 'Add your name to personalize NutriLens'
                                    : 'Hi, ${_displayNameController.text}!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Personal')),
                        ButtonSegment(value: 1, label: Text('Athlete')),
                        ButtonSegment(value: 2, label: Text('Diet')),
                      ],
                      selected: {_selectedSection},
                      onSelectionChanged: _isProfileDisabled
                          ? null
                          : (selection) {
                              setState(() {
                                _selectedSection = selection.first;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: switch (_selectedSection) {
                          0 => ProfileFieldCard(
                              title: 'Personal info',
                              child: Column(
                                children: [
                                  ProfileTextField(
                                    label: 'Full name',
                                    controller: _displayNameController,
                                    enabled: !_isProfileDisabled,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Full name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'Phone number',
                                    controller: _phoneNumberController,
                                    keyboardType: TextInputType.phone,
                                    enabled: !_isProfileDisabled,
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'Email',
                                    controller: _emailController,
                                    enabled: false,
                                    helperText: _account?.isAnonymous == true
                                        ? 'Link your email to keep your account if the app is reinstalled.'
                                        : 'Email linked to this account.',
                                  ),
                                  if (_account?.isAnonymous == true &&
                                      !_isProfileDisabled) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _saving ? null : _showLinkEmailDialog,
                                        child: const Text('Link email'),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    initialValue: _genderValue,
                                    items: _genderOptions.entries
                                        .map(
                                          (entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value),
                                          ),
                                        )
                                        .toList(),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.cardDarker,
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                        borderSide: BorderSide(color: AppColors.cardDark),
                                      ),
                                    ),
                                    onChanged: _isProfileDisabled
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _genderValue = value;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ),
                          1 => ProfileFieldCard(
                              title: 'Athlete info',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Primary sport',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardDarker,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _profile?.primarySportName.isNotEmpty == true
                                          ? _profile!.primarySportName
                                          : 'No sport selected',
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'School',
                                    controller: _schoolController,
                                    enabled: !_isProfileDisabled,
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'Graduation year',
                                    controller: _graduationController,
                                    keyboardType: TextInputType.number,
                                    enabled: !_isProfileDisabled,
                                    validator: (value) {
                                      if (value != null && value.trim().isNotEmpty && int.tryParse(value.trim()) == null) {
                                        return 'Enter a valid year';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'Birth year',
                                    controller: _birthYearController,
                                    keyboardType: TextInputType.number,
                                    enabled: !_isProfileDisabled,
                                    validator: (value) {
                                      if (value != null && value.trim().isNotEmpty && int.tryParse(value.trim()) == null) {
                                        return 'Enter a valid year';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ProfileTextField(
                                          label: 'Height (cm)',
                                          controller: _heightController,
                                          keyboardType: TextInputType.number,
                                          allowDecimal: true,
                                          enabled: !_isProfileDisabled,
                                          validator: (value) {
                                            if (value != null && value.trim().isNotEmpty && double.tryParse(value.trim()) == null) {
                                              return 'Enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ProfileTextField(
                                          label: 'Weight (kg)',
                                          controller: _weightController,
                                          keyboardType: TextInputType.number,
                                          allowDecimal: true,
                                          enabled: !_isProfileDisabled,
                                          validator: (value) {
                                            if (value != null && value.trim().isNotEmpty && double.tryParse(value.trim()) == null) {
                                              return 'Enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<int>(
                                    initialValue: _trainingDaysValue,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.cardDarker,
                                      labelText: 'Training days per week',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                        borderSide: BorderSide(color: AppColors.cardDark),
                                      ),
                                    ),
                                    items: List.generate(8, (index) => index)
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text('$value days'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _isProfileDisabled
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _trainingDaysValue = value;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    initialValue: _activityLevelValue,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.cardDarker,
                                      labelText: 'Activity level',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                        borderSide: BorderSide(color: AppColors.cardDark),
                                      ),
                                    ),
                                    items: _activityOptions.entries
                                        .map(
                                          (entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _isProfileDisabled
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _activityLevelValue = value;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ),
                          _ => ProfileFieldCard(
                              title: 'Dietary notes',
                              subtitle: 'Use commas or new lines to add multiple values.',
                              child: Column(
                                children: [
                                  ProfileTextField(
                                    label: 'Allergies',
                                    controller: _allergensController,
                                    maxLines: 3,
                                    enabled: !_isProfileDisabled,
                                  ),
                                  const SizedBox(height: 16),
                                  ProfileTextField(
                                    label: 'Restrictions',
                                    controller: _restrictionsController,
                                    maxLines: 3,
                                    enabled: !_isProfileDisabled,
                                  ),
                                ],
                              ),
                            ),
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isProfileDisabled || _saving ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.lime,
                          foregroundColor: AppColors.onLime,
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: AppColors.onLime,
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
