import 'package:example/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/flutter_localization_agent.dart';
import 'package:provider/provider.dart';

Map<String, String> baseLanguageEnglishJson = {
  'title': 'Flutter Localization Agent',
  'welcome': 'Welcome to our app!',
  'description': 'This app demonstrates dynamic translations using LLMs.',
  'nav_bar_home': 'Home',
  'nav_bar_details': 'Details',
  'nav_bar_settings': 'Settings',
  'show_dialog': 'Show More Info',
  'dialog_title': 'More Information',
  'dialog_content':
      'This is additional information about our app, showcasing how translations work with more text.',
  'details_title': 'App Features',
  'feature1_title': 'Dynamic Translations',
  'feature1_description':
      'Translate your app dynamically using advanced language models.',
  'feature2_title': 'Efficient Caching',
  'feature2_description':
      'Cache translations locally to improve performance and reduce load times.',
  'settings_title': 'App Settings',
  'select_language': 'Choose your preferred language',
};
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the translator and service
  final translator = LLMTranslatorFactory.createTranslator(
    LLM.gemini,
    'YOUR_API_KEY',
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

  // Load base translations
  await translationService.loadBaseTranslations(baseLanguageEnglishJson);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: translationService)],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TranslationService>(context);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      locale: service.currentLanguage.toLocale(),
      supportedLocales: service.supportedLocales,
      localizationsDelegates: [
        TranslationLocalizationsDelegate(service),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainPage(),
    );
  }
}
