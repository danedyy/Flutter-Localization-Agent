# Flutter Localization Agent

A powerful localization package for Flutter that utilizes LLM-based translation services to dynamically translate text while caching translations for offline use.

## ![Video demo](https://github.com/user-attachments/assets/a7537bc6-86b0-48df-98e8-19d00432b57a)




## Features
- Supports multiple languages dynamically
- Caches translations for offline use
- Uses LLM-based translators (e.g., Gemini)
- Provides automatic language switching
- Seamless integration with Flutter apps

## Installation

To use `flutter_localization_agent`, add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localization_agent: latest_version
  provider: latest_version # you can use any state management library of your choice
```

Then, run:

```sh
flutter pub get
```

## Usage

### 1. Initialize the Localization Service

In your `main.dart` file, set up the translation service before running the app:

```dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/flutter_localization_agent.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final translator = LLMTranslatorFactory.createTranslator(
    LLM.gemini,
    'YOUR_API_KEY_HERE',
  );

  final supportedLanguages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'es', name: 'Spanish'),
    Language(code: 'fr', name: 'French'),
    Language(code: 'it', name: 'Italian'),
    Language(code: 'ar', name: 'Arabic'),
  ];

  final initialLanguage = supportedLanguages[0];

  final translationService = TranslationService(
    translator: translator,
    supportedLanguages: supportedLanguages,
    initialLanguage: initialLanguage,
  );

  await translationService.loadBaseTranslations({
    'hello': 'Hello friend',
    'goodbye': 'Goodbye',
    'dangerous': 'Dangerous',
  });

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: translationService)],
      child: MyApp(),
    ),
  );
}
```

### 2. Create the Main Application

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TranslationService>(context);

    return MaterialApp(
      locale: service.currentLanguage.toLocale(),
      supportedLocales: service.supportedLocales,
      localizationsDelegates: [
        TranslationLocalizationsDelegate(service),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MyHomePage(),
    );
  }
}
```

### 3. Using Translations in the UI

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = TranslationLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(translations.translate('hello'))),
      body: Center(
        child: translations.isLoading
            ? CircularProgressIndicator()
            : Text(translations.translate('dangerous')),
      ),
      floatingActionButton: Consumer<TranslationService>(
        builder: (context, service, _) => DropdownButton<Language>(
          value: service.currentLanguage,
          items: service.supportedLanguages
              .map(
                (lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang.name),
                ),
              )
              .toList(),
          onChanged: (newLang) {
            if (newLang != null) {
              service.changeLanguage(newLang).then((context) => log('Changed'))
              .catchError((e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              });
            }
          },
        ),
      ),
    );
  }
}
```

## How the Package Works

### TranslationService
- Manages translations and caching using `SharedPreferences`
- Loads base translations and dynamically fetches new translations
- Detects language changes and updates the UI accordingly

### Caching Mechanism
- Stores translations locally for offline use
- Uses `_needsRefresh()` to determine if translations need to be updated

### Fetching Translations
- Calls the `LLMTranslator` to get translations dynamically
- Updates the `_cache` with new translations

## API Reference

### `TranslationService`
| Method                     | Description                                      |
|----------------------------|--------------------------------------------------|
| `loadBaseTranslations()`   | Loads the initial language's translations.      |
| `changeLanguage()`         | Changes the current language and updates UI.    |
| `getTranslation()`         | Fetches the translated string for a given key.  |
| `_fetchTranslations()`     | Calls the LLM API to fetch new translations.    |
| `_saveToCache()`           | Stores translations in `SharedPreferences`.     |
| `_loadFromCache()`         | Loads cached translations when the app starts.  |

### `TranslationLocalizations`
| Method                 | Description                        |
|------------------------|------------------------------------|
| `translate(key)`       | Retrieves the translated text.    |
| `isLoading`           | Returns whether translations are loading. |

### `Language`
| Property  | Description |
|-----------|-------------|
| `code`    | Language code (e.g., `en`). |
| `name`    | Human-readable name (e.g., `English`). |

## Contributing

Feel free to submit issues or contribute to the project by opening pull requests.

