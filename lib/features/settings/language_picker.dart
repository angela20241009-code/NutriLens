import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<AppLanguage?> showLanguagePicker({
  required BuildContext context,
  required AppLanguage current,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<AppLanguage>(
    context: context,
    backgroundColor: AppColors.cardDark,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.languagePickerTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            for (final language in AppLanguage.supported)
              _LanguageOption(
                title: language.label(l10n),
                selected: current == language,
                onTap: () => Navigator.of(context).pop(language),
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Future<void> pickAndApplyLanguage({
  required BuildContext context,
  UserRepository? repository,
  String? uid,
}) async {
  final localeScope = AppLocaleScope.of(context);
  final selected = await showLanguagePicker(
    context: context,
    current: localeScope.language,
  );
  if (selected == null || selected == localeScope.language) {
    return;
  }

  await localeScope.setLanguage(
    selected,
    repository: repository,
    uid: uid,
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check, color: AppColors.lime) : null,
      onTap: onTap,
    );
  }
}
