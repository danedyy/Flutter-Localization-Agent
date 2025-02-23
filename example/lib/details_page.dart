import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/translation_localizations.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = TranslationLocalizations.of(context);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              translations.translate('details_title'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.blue),
                title: Text(translations.translate('feature1_title')),
                subtitle: Text(translations.translate('feature1_description')),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(translations.translate('feature2_title')),
                subtitle: Text(translations.translate('feature2_description')),
              ),
            ),
            // Add more features as needed
          ],
        ),
        if (translations.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
