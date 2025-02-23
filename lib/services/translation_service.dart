import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/language.dart';
import 'llm_translator.dart';

/// Manages translations with caching and state management for Flutter localization.
class TranslationService extends ChangeNotifier {
  final LLMTranslator translator;
  final List<Language> supportedLanguages;
  final Language initialLanguage;
  Language _currentLanguage;
  Language? _previousLanguage;
  final Map<String, Map<String, String>> _cache = {};
  bool _isLoading = false;
  late SharedPreferences _prefs;
  int _baseVersion = 0;

  /// Constructs the service with required parameters.
  ///
  /// [translator] - The translator service to use for fetching translations.
  ///
  /// [supportedLanguages] - The list of languages supported by the application.
  ///
  /// [initialLanguage] - The initial language to use when the app starts.
  TranslationService({
    required this.translator,
    required this.supportedLanguages,
    required this.initialLanguage,
  }) : _currentLanguage = initialLanguage {
    final unsupportedLanguages =
        supportedLanguages
            .where(
              (element) =>
                  !GlobalMaterialLocalizations.delegate.isSupported(
                    Locale(element.code),
                  ),
            )
            .toList();

    if (unsupportedLanguages.isNotEmpty) {
      throw UnsupportedError('''
      Unsupported language codes: ${unsupportedLanguages.map((e) => e.code).join(', ')}.
      Supported language codes: $kMaterialSupportedLanguages
      ''');
    }
  }

  /// Initializes SharedPreferences and loads cached translations.
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _baseVersion = _prefs.getInt('base_version') ?? 0;
    _loadFromCache();
    notifyListeners();
  }

  /// Loads base translations for the initial language.
  Future<void> loadBaseTranslations(
    Map<String, String> baseTranslations,
  ) async {
    await _init();

    // Check if base translations have changed
    final currentBaseJson = jsonEncode(baseTranslations);
    final cachedBaseJson = _prefs.getString('base_translations');

    if (cachedBaseJson != currentBaseJson) {
      _baseVersion++;
      await _prefs.setInt('base_version', _baseVersion);
      await _prefs.setString('base_translations', currentBaseJson);
      _cache[initialLanguage.code] = Map.from(baseTranslations);
      await _saveToCache(initialLanguage.code, baseTranslations);
      notifyListeners();
    }
    if (_currentLanguage != initialLanguage &&
        _needsRefresh(_currentLanguage.code)) {
      await _refreshCurrentLanguage();
    }
  }

  /// Changes the current language, fetching translations if necessary.
  Future<void> changeLanguage(Language newLanguage) async {
    if (_currentLanguage == newLanguage) {
      return;
    }
    _previousLanguage = _currentLanguage;
    _currentLanguage = newLanguage;
    notifyListeners();

    if (_needsRefresh(newLanguage.code)) {
      log('Refreshing translations for ${newLanguage.code}');
      await _refreshCurrentLanguage();
    } else {
      await _saveToCache(
        newLanguage.code,
        _cache[newLanguage.code]!,
        version: _baseVersion,
      );
    }
  }

  /// Determines if the translations for the given language code need to be refreshed.
  /// Returns `true` if the cached version is older than the base version, indicating that
  /// the translations should be updated. The base language is always considered up-to-date.
  bool _needsRefresh(String languageCode) {
    if (languageCode == initialLanguage.code) {
      return false; // Base language is updated directly
    }
    final cachedVersion = _prefs.getInt('version_$languageCode') ?? 0;
    return cachedVersion < _baseVersion;
  }

  Future<void> _refreshCurrentLanguage() async {
    final langCode = _currentLanguage.code;
    if (langCode == initialLanguage.code) {
      return; // Base language is always up-to-date
    }

    final cachedVersion = _prefs.getInt('version_$langCode') ?? 0;
    if (cachedVersion < _baseVersion) {
      _isLoading = true;
      notifyListeners();
      Map<String, String> translations = {};
      try {
        translations = await _fetchTranslations(_currentLanguage);
        _cache[langCode] = translations;
        await _saveToCache(langCode, translations, version: _baseVersion);
      } catch (e) {
        translations = _cache[_previousLanguage?.code ?? initialLanguage.code]!;
        _currentLanguage = _previousLanguage ?? initialLanguage;
        await _saveToCache(langCode, translations);
        _isLoading = false;
        notifyListeners();
        rethrow;
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches translations using the LLM for a target language.
  Future<Map<String, String>> _fetchTranslations(Language language) async {
    final baseTranslations = _cache[initialLanguage.code]!;
    Map<String, String> translations = {};
    try {
      translations = await translator.processTranslation(
        input: baseTranslations,
        targetLanguage: language,
      );
      return translations;
    } catch (e) {
      rethrow;
    }
  }

  /// Saves translations to SharedPreferences.
  Future<void> _saveToCache(
    String languageCode,
    Map<String, String> translations, {
    int? version,
  }) async {
    await _prefs.setString(
      'translations_$languageCode',
      jsonEncode(translations),
    );
    if (version != null) {
      await _prefs.setInt('version_$languageCode', version);
    }
    await _prefs.setString('current_translation_code', languageCode);
  }

  /// Loads translations from SharedPreferences into memory.
  void _loadFromCache() {
    final keys = _prefs.getKeys().where((k) => k.startsWith('translations_'));
    final currentTransalation = _prefs.getString('current_translation_code');
    for (final key in keys) {
      final langCode = key.replaceFirst('translations_', '');
      final json = _prefs.getString(key);
      if (json != null) {
        _cache[langCode] = Map<String, String>.from(jsonDecode(json));
      }
    }
    _currentLanguage = supportedLanguages.firstWhere(
      (l) => l.code == currentTransalation,
      orElse: () => initialLanguage,
    );
  }

  /// Gets the translation for a key in the current language.
  String getTranslation(String key) {
    if (isLoading) {
      return _cache[_previousLanguage?.code]?[key] ?? key;
    }
    return _cache[_currentLanguage.code]?[key] ?? key;
  }

  /// Getter for supported locales.
  List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => l.toLocale()).toList();

  /// Getter for the current language.
  Language get currentLanguage => _currentLanguage;

  /// Getter for the loading state.
  bool get isLoading => _isLoading;
}
