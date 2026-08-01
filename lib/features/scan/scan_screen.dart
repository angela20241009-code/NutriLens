import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/app/meal_analysis_scope.dart';
import 'package:nutrilens/features/meals/log_meal_sheet.dart';
import 'package:nutrilens/features/scan/scan_previous_meals_sheet.dart';
import 'package:nutrilens/features/scan/scan_result_sheet.dart';
import 'package:nutrilens/features/scan/widgets/scan_action_tile.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/services/meal_analysis_client.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/theme/theme_palette_scope.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _picking = false;
  bool _analyzing = false;

  String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  Future<void> _analyzeSelectedImage() async {
    final image = _selectedImage;
    if (image == null || _analyzing) {
      return;
    }

    setState(() => _analyzing = true);

    try {
      final bytes = await image.readAsBytes();
      final analysis = await MealAnalysisScope.of(context).analyzeMealPhoto(
        imageBytes: bytes,
        mimeType: _mimeTypeForPath(image.path),
      );

      if (!mounted) {
        return;
      }

      final saved = await ScanResultSheet.show(context, analysis: analysis);
      if (!mounted) {
        return;
      }

      if (saved == true) {
        setState(() => _selectedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.scanMealSaved)),
        );
      }
    } on MealAnalysisException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.scanUnableAnalyze('$error'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _analyzing = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_picking || _analyzing) {
      return;
    }

    setState(() => _picking = true);

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImage = picked;
      });

      if (picked != null) {
        await _analyzeSelectedImage();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.scanUnablePickImage('$error'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _showSourcePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.scanTakePhoto),
                subtitle: Text(l10n.scanTakePhotoSubtitle),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.scanPhotoLibrary),
                subtitle: Text(l10n.scanPhotoLibrarySubtitle),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  bool get _isBusy => _picking || _analyzing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = ThemePaletteScope.primary(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.scanMeal, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: _isBusy ? null : _showSourcePicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardDarker),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_selectedImage == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 64,
                              color: accent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.scanPointAtFood,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.scanTapToCapture,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.72,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      else
                        Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      if (_selectedImage != null && !_analyzing)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: _isBusy
                                ? null
                                : () => setState(() {
                                    _selectedImage = null;
                                  }),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      if (_analyzing)
                        Container(
                          color: Colors.black54,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: accent),
                              const SizedBox(height: 16),
                              Text(
                                l10n.scanAnalyzing,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ScanActionTile(
                  label: l10n.scanPhoto,
                  icon: Icons.add_a_photo_outlined,
                  iconColor: AppColors.lime,
                  enabled: !_isBusy,
                  onTap: _showSourcePicker,
                ),
                const SizedBox(width: 10),
                ScanActionTile(
                  label: l10n.scanManual,
                  icon: Icons.edit_outlined,
                  iconColor: AppColors.orange,
                  enabled: !_isBusy,
                  onTap: () => LogMealSheet.show(context),
                ),
                const SizedBox(width: 10),
                ScanActionTile(
                  label: l10n.scanPrevious,
                  icon: Icons.history_rounded,
                  iconColor: AppColors.textPrimary,
                  enabled: !_isBusy,
                  onTap: () async {
                    final logged = await ScanPreviousMealsSheet.open(context);
                    if (logged == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.scanMealAdded),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
