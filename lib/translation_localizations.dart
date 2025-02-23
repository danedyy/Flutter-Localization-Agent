import 'package:flutter/material.dart';

import 'services/translation_service.dart';

/// Localized translations provided by the TranslationService.
class TranslationLocalizations {
  final TranslationService service;

  TranslationLocalizations(this.service);

  /// Access the instance from BuildContext.
  static TranslationLocalizations of(BuildContext context) {
    return Localizations.of<TranslationLocalizations>(
      context,
      TranslationLocalizations,
    )!;
  }

  /// Get a translated string by key.
  String translate(String key) => service.getTranslation(key);

  /// Check if translations are currently loading.
  bool get isLoading => service.isLoading;
}

/// Delegate to integrate TranslationService with Flutter's localization system.
class TranslationLocalizationsDelegate
    extends LocalizationsDelegate<TranslationLocalizations> {
  final TranslationService service;

  TranslationLocalizationsDelegate(this.service);

  @override
  bool isSupported(Locale locale) {
    return service.supportedLocales.contains(locale);
  }

  @override
  Future<TranslationLocalizations> load(Locale locale) async {
    final targetLanguage = service.supportedLanguages.firstWhere(
      (lang) => lang.code == locale.languageCode,
      orElse: () => service.initialLanguage,
    );
    await service.changeLanguage(targetLanguage);
    return TranslationLocalizations(service);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<TranslationLocalizations> old,
  ) => false;
}
