import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../presentation/providers/language_provider.dart';

/// A stateless widget representing the profile screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECEC),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.profile,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Language selection
            Text(
              'Язык / Language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Language toggle button
            ElevatedButton.icon(
              onPressed: () {
                languageProvider.toggleLanguage();
              },
              icon: const Icon(Icons.language),
              label: Text(
                languageProvider.locale.languageCode == 'ru' 
                    ? 'English' 
                    : 'Русский',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, 
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
