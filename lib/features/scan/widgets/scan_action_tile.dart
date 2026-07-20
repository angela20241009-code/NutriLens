import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScanActionTile extends StatelessWidget {
  const ScanActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 96,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
