import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'language_selection_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    if (!mounted) return;
    
    try {
      final user = SupabaseService.currentUser;
      
      if (user == null) {
        // No user logged in - go to auth screen
        print('No user logged in, showing auth screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        // User logged in, check if language is selected
        final profile = await SupabaseService.getUserProfile(user.id);
        
        if (!mounted) return;
        
        if (profile == null || profile['language'] == null) {
          // No language selected, go to language selection
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
          );
        } else {
          // Everything is set up, go to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // Fallback to auth screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.pets,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // App Title
            const Text(
              'Breed Prediction',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            const Text(
              'AI-Powered Pet Breed Recognition',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            
            // Loading Indicator
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
