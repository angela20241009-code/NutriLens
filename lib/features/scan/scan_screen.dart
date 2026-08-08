import 'dart:io';

import 'package:camera/camera.dart';
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
  const ScanScreen({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final _picker = ImagePicker();
  CameraController? _cameraController;
  XFile? _selectedImage;
  bool _picking = false;
  bool _analyzing = false;
  bool _initializingCamera = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _initCamera();
    }
  }

  @override
  void didUpdateWidget(covariant ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initCamera();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed &&
        widget.isActive &&
        _selectedImage == null) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _cameraController;
    _cameraController = null;
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (!widget.isActive ||
        _initializingCamera ||
        _cameraController != null ||
        _selectedImage != null) {
      return;
    }

    setState(() {
      _initializingCamera = true;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = AppLocalizations.of(context)!.scanCameraUnavailable;
          _initializingCamera = false;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (device) => device.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _initializingCamera = false;
        _cameraError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraError = AppLocalizations.of(context)!.scanCameraUnavailable;
        _initializingCamera = false;
      });
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      await controller.dispose();
    }
    if (mounted) {
      setState(() => _initializingCamera = false);
    }
  }

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
        await _initCamera();
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

  Future<void> _pickImageFromLibrary() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_picking || _analyzing) {
      return;
    }

    setState(() => _picking = true);

    try {
      await _disposeCamera();
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
      } else if (widget.isActive) {
        await _initCamera();
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
      if (widget.isActive && _selectedImage == null) {
        await _initCamera();
      }
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _captureFromPreview() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _picking ||
        _analyzing) {
      return;
    }

    try {
      final captured = await controller.takePicture();
      if (!mounted) {
        return;
      }
      await _disposeCamera();
      setState(() => _selectedImage = captured);
      await _analyzeSelectedImage();
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
    }
  }

  Future<void> _clearSelectedImage() async {
    setState(() => _selectedImage = null);
    if (widget.isActive) {
      await _initCamera();
    }
  }

  bool get _isBusy => _picking || _analyzing;

  Widget _buildPreviewContent(AppLocalizations l10n, Color accent) {
    final selectedImage = _selectedImage;
    if (selectedImage != null) {
      return Image.file(File(selectedImage.path), fit: BoxFit.cover);
    }

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.previewSize?.height ?? 1,
              height: controller.value.previewSize?.width ?? 1,
              child: CameraPreview(controller),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Column(
              children: [
                Text(
                  l10n.scanPointAtFood,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.scanTapToCapture,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.88),
                    fontSize: 13,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isBusy ? null : _captureFromPreview,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: accent.withValues(alpha: 0.35),
                      ),
                      child: Icon(Icons.camera_alt_rounded, color: accent, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_initializingCamera) {
      return Center(
        child: CircularProgressIndicator(color: accent),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, size: 64, color: accent),
            const SizedBox(height: 16),
            Text(
              _cameraError ?? l10n.scanPointAtFood,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.scanPhotoLibrarySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.72),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                    _buildPreviewContent(l10n, accent),
                    if (_selectedImage != null && !_analyzing)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: _isBusy ? null : _clearSelectedImage,
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
            const SizedBox(height: 16),
            Row(
              children: [
                ScanActionTile(
                  label: l10n.scanPhoto,
                  icon: Icons.photo_library_outlined,
                  iconColor: AppColors.lime,
                  enabled: !_isBusy,
                  onTap: _pickImageFromLibrary,
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
