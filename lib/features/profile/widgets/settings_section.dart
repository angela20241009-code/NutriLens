import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
    this.labelColor,
    this.showChevron = true,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final Color? labelColor;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: labelColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
            if (showChevron) const SizedBox(width: 6),
          ],
          ?trailing,
          if (showChevron && onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navInactive,
              size: 22,
            ),
        ],
      ),
    );

    return Column(
      children: [
        if (onTap != null) InkWell(onTap: onTap, child: content) else content,
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.cardDarker,
            indent: 16,
          ),
      ],
    );
  }
}
