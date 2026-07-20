import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MealCaptureCard extends StatelessWidget {
  const MealCaptureCard({
    super.key,
    required this.onManualTap,
    required this.onPreferencesTap,
    required this.onFavoritesTap,
  });

  final VoidCallback onManualTap;
  final VoidCallback onPreferencesTap;
  final VoidCallback onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 340;
          final imageStackWidth = isCompact ? 88.0 : 112.0;
          final imageStackHeight = isCompact ? 142.0 : 172.0;
          final separatorMargin = isCompact ? 12.0 : 18.0;
          final actionSize = isCompact ? 52.0 : 64.0;

          return Row(
            children: [
              SizedBox(
                width: imageStackWidth,
                height: imageStackHeight,
                child: _MealImageStack(isCompact: isCompact),
              ),
              Container(
                width: 1,
                height: imageStackHeight,
                margin: EdgeInsets.symmetric(horizontal: separatorMargin),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Meal capture',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 18 : 24),
                    Text(
                      'Ready to log?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isCompact ? 23 : 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manual, preferences, or favorites',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: isCompact ? 13 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isCompact ? 18 : 22),
                    Row(
                      children: [
                        Expanded(
                          child: _CaptureAction(
                            label: 'Manual',
                            icon: Icons.add,
                            color: AppColors.lime,
                            foregroundColor: AppColors.onLime,
                            size: actionSize,
                            onTap: onManualTap,
                          ),
                        ),
                        Expanded(
                          child: _CaptureAction(
                            label: 'Prefs',
                            icon: Icons.tune_rounded,
                            color: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: AppColors.textMuted,
                            size: actionSize,
                            onTap: onPreferencesTap,
                          ),
                        ),
                        Expanded(
                          child: _CaptureAction(
                            label: 'Favorites',
                            icon: Icons.favorite_border_rounded,
                            color: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: AppColors.orange,
                            size: actionSize,
                            onTap: onFavoritesTap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MealImageStack extends StatelessWidget {
  const _MealImageStack({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final thumbnailSize = isCompact ? 72.0 : 90.0;
    final secondLeft = isCompact ? 16.0 : 22.0;
    final secondTop = isCompact ? 70.0 : 82.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: _MealThumbnail(
            imagePath: 'assets/images/meal_capture_salmon.png',
            size: thumbnailSize,
          ),
        ),
        Positioned(
          left: secondLeft,
          top: secondTop,
          child: _MealThumbnail(
            imagePath: 'assets/images/meal_capture_yogurt.png',
            size: thumbnailSize,
          ),
        ),
      ],
    );
  }
}

class _MealThumbnail extends StatelessWidget {
  const _MealThumbnail({required this.imagePath, required this.size});

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}

class _CaptureAction extends StatelessWidget {
  const _CaptureAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.size,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: size * 0.53, color: foregroundColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foregroundColor,
              fontSize: size < 60 ? 12 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
