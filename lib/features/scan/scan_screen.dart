import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/app/meal_analysis_scope.dart';
import 'package:nutrilens/features/meals/log_meal_sheet.dart';
import 'package:nutrilens/features/scan/scan_result_sheet.dart';
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
          const SnackBar(content: Text('Meal saved to your log')),
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
        SnackBar(content: Text('Unable to analyze meal photo: $error')),
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
        SnackBar(content: Text('Unable to pick image: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _showSourcePicker() async {
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
                title: const Text('Take photo'),
                subtitle: const Text('Use your camera to scan a meal'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Photo library'),
                subtitle: const Text('Choose an existing picture'),
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
    final accent = ThemePaletteScope.primary(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Scan meal', style: Theme.of(context).textTheme.headlineLarge),
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
                            const Text(
                              'Point at your food',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to take a photo or choose from library',
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
                              const Text(
                                'Analyzing meal...',
                                style: TextStyle(
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
            FilledButton.icon(
              onPressed: _isBusy ? null : _showSourcePicker,
              icon: _picking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _selectedImage == null ? 'Add meal photo' : 'Change photo',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: ThemePaletteScope.onPrimary(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : () => LogMealSheet.show(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Log manually'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
