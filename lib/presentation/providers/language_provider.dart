import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  
  Locale _locale = const Locale('ru'); // Default to Russian
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  // Load the saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  // Change the language and save it to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    
    notifyListeners();
  }
  
  // Toggle between Russian and English
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'ru' 
        ? const Locale('en') 
        : const Locale('ru');
    
    await changeLanguage(newLocale);
  }
}