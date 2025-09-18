import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'demo_user_manager.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient? get client => _client;
  
  static Future<void> initialize() async {
    try {
      await dotenv.load();
      
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      
      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        print('Warning: Supabase credentials not configured');
        return;
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      
      _client = Supabase.instance.client;
      print('Supabase initialized successfully');
    } catch (e) {
      print('Failed to initialize Supabase: $e');
      // Continue without Supabase for demo purposes
    }
  }
  
  // Auth methods
  static User? get currentUser {
    try {
      return _client?.auth.currentUser ?? DemoUserManager.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return DemoUserManager.currentUser;
    }
  }
  
  static Stream<AuthState> get authStateChanges {
    try {
      return _client?.auth.onAuthStateChange ?? const Stream.empty();
    } catch (e) {
      print('Error getting auth state changes: $e');
      return const Stream.empty();
    }
  }
  
  static Future<AuthResponse> signUp(String email, String password) async {
    if (_client == null) {
      // Create a mock successful response for demo mode
      print('Demo mode: Mock signup for $email');
      final user = User(
        id: 'demo-user-${email.hashCode}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        email: email,
        phone: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isAnonymous: false,
        identities: [],
        factors: [],
      );
      DemoUserManager.setUser(user);
      return AuthResponse(user: user, session: null);
    }
    try {
      return await _client!.auth.signUp(email: email, password: password);
    } catch (e) {
      print('Error signing up: $e');
      // Fallback to demo mode on error
      final user = User(
        id: 'demo-user-${email.hashCode}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        email: email,
        phone: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isAnonymous: false,
        identities: [],
        factors: [],
      );
      DemoUserManager.setUser(user);
      return AuthResponse(user: user, session: null);
    }
  }
  
  static Future<AuthResponse> signIn(String email, String password) async {
    if (_client == null) {
      // Create a mock successful response for demo mode
      print('Demo mode: Mock signin for $email');
      final user = User(
        id: 'demo-user-${email.hashCode}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        email: email,
        phone: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isAnonymous: false,
        identities: [],
        factors: [],
      );
      DemoUserManager.setUser(user);
      return AuthResponse(user: user, session: null);
    }
    try {
      return await _client!.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      // Fallback to demo mode on error
      final user = User(
        id: 'demo-user-${email.hashCode}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        email: email,
        phone: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        isAnonymous: false,
        identities: [],
        factors: [],
      );
      DemoUserManager.setUser(user);
      return AuthResponse(user: user, session: null);
    }
  }
  
  static Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Ignore sign out errors
    }
    DemoUserManager.clearUser();
  }
  
  // Profile methods
  static Future<void> updateUserProfile({
    required String userId,
    required String email,
    required String language,
  }) async {
    if (_client == null) {
      print('Demo mode: Saving language preference locally');
      DemoUserManager.setLanguage(language);
      return;
    }
    try {
      await _client!.from('profiles').upsert({
        'id': userId,
        'email': email,
        'language': language,
      });
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      // Fallback to demo mode
      DemoUserManager.setLanguage(language);
    }
  }
  
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (_client == null) {
      print('Demo mode: Using local profile');
      return DemoUserManager.getUserProfile();
    }
    try {
      final response = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      // Fallback to demo mode
      return DemoUserManager.getUserProfile();
    }
  }
  
  // Storage methods
  static Future<String> uploadImage(String filePath, String fileName) async {
    if (_client == null) {
      throw Exception('Storage service not available');
    }
    try {
      await _client!.storage.from('images').upload(fileName, File(filePath));
      final publicUrl = _client!.storage.from('images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }
  
  // Feedback methods
  static Future<void> submitFeedback({
    required String userId,
    required String imageUrl,
    required String predictedBreed,
    required double confidence,
    required String feedback,
  }) async {
    if (_client == null) {
      print('Feedback submission skipped - Supabase not available');
      return;
    }
    try {
      await _client!.from('feedbacks').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'predicted_breed': predictedBreed,
        'confidence': confidence,
        'feedback': feedback,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Feedback submitted successfully');
    } catch (e) {
      print('Error submitting feedback: $e');
      throw Exception('Failed to submit feedback');
    }
  }
}
