import 'package:flutter/material.dart';
import 'package:nutrilens/models/schedule_event.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/pill_badge.dart';

class TodaysMatchCard extends StatelessWidget {
  const TodaysMatchCard({super.key, required this.match});

  final UserScheduleEvent match;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.scheduleTodaysMatch,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _formatShortDate(context, match.startAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.lime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8C42), Color(0xFFB85A1A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -10,
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        match.badge ?? l10n.scheduleEventGame.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    match.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLocationAndTime(context, match),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final hint in match.fuelingHints)
                        PillBadge(
                          label: '${hint.timing} ${hint.label}',
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
                          textColor: Colors.white,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatShortDate(BuildContext context, DateTime date) {
    final local = date.toLocal();
    return '${formatLocalizedMonth(context, local.month)} ${local.day}, ${local.year}';
  }

  String _formatLocationAndTime(BuildContext context, UserScheduleEvent match) {
    final parts = [
      if (match.location != null && match.location!.trim().isNotEmpty)
        match.location!.trim(),
      _formatTime(context, match.startAt),
    ];
    return parts.join(' · ');
  }

  String _formatTime(BuildContext context, DateTime time) {
    final local = time.toLocal();
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
  }
}
