import 'dart:ui';

/// Represents a language with a code and name, compatible with Flutter locales.
class Language {
  /// ISO language code (e.g., 'en' for English).
  /// 
  /// see supported flutter codes https://api.flutter.dev/flutter/flutter_localizations/kMaterialSupportedLanguages.html
  final String code;

  /// Human-readable name (e.g., 'English').
  final String name;

  Language({required this.code, required this.name});

  /// Converts this language to a Flutter Locale.
  Locale toLocale() => Locale(code);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Language && code == other.code && name == other.name);

  @override
  int get hashCode => Object.hash(code, name);
}
