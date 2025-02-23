import 'package:example/details_page.dart';
import 'package:example/home_page.dart';
import 'package:example/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization_agent/translation_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomePage(), DetailsPage(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = TranslationLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(translations.translate('title'))),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: translations.translate('nav_bar_home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: translations.translate('nav_bar_details'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: translations.translate('nav_bar_settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
