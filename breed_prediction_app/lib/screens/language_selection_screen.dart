import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/supabase_service.dart';
import '../utils/app_localizations.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isLoading = false;

  Future<void> _saveLanguageAndContinue() async {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a language'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        await SupabaseService.updateUserProfile(
          userId: user.id,
          email: user.email ?? '',
          language: _selectedLanguage!,
        );
      } else {
        // No user signed in, continue anyway for demo
        print('No user signed in, continuing with demo mode');
        await Future.delayed(const Duration(seconds: 1)); // Simulate save
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('Error saving language: $e');
      // Continue anyway for demo purposes
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate('select_language', _selectedLanguage ?? 'English'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Text(
              AppLocalizations.translate('select_language', _selectedLanguage ?? 'English'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Choose your preferred language for the app interface.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Language Options
            Expanded(
              child: ListView.builder(
                itemCount: AppLocalizations.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final language = AppLocalizations.supportedLanguages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      title: Text(
                        language,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.translate('app_title', language),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      value: language,
                      groupValue: _selectedLanguage,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLanguageAndContinue,
                child: _isLoading
                    ? const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        AppLocalizations.translate('continue', _selectedLanguage ?? 'English'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
