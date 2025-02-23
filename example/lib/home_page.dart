import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/translation_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = TranslationLocalizations.of(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language, size: 100, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  translations.translate('welcome'),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  translations.translate('description'),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(translations.translate('dialog_title')),
                            content: Text(
                              translations.translate('dialog_content'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Text(translations.translate('show_dialog')),
                ),
              ],
            ),
          ),
        ),
        if (translations.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
