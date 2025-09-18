import 'package:supabase_flutter/supabase_flutter.dart';

class DemoUserManager {
  static User? _currentDemoUser;
  static String? _currentLanguage;

  static User? get currentUser => _currentDemoUser;
  
  static void setUser(User user) {
    _currentDemoUser = user;
  }
  
  static void clearUser() {
    _currentDemoUser = null;
    _currentLanguage = null;
  }
  
  static void setLanguage(String language) {
    _currentLanguage = language;
  }
  
  static String? get currentLanguage => _currentLanguage;
  
  static Map<String, dynamic>? getUserProfile() {
    if (_currentDemoUser == null) return null;
    
    return {
      'id': _currentDemoUser!.id,
      'email': _currentDemoUser!.email,
      'language': _currentLanguage ?? 'English',
    };
  }
}
