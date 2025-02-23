import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/models/language.dart';
import 'package:flutter_localization_agent/services/translation_service.dart';
import 'package:flutter_localization_agent/translation_localizations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = TranslationLocalizations.of(context);
    final service = Provider.of<TranslationService>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translations.translate('settings_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text(
                translations.translate('select_language'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              DropdownButton<Language>(
                value: service.currentLanguage,
                items:
                    service.supportedLanguages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang.name),
                          ),
                        )
                        .toList(),
                onChanged: (newLang) {
                  if (newLang != null) {
                    service.changeLanguage(newLang);
                  }
                },
              ),
            ],
          ),
        ),
        if (translations.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
