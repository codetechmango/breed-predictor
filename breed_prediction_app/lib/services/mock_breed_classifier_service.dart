import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/prediction_result.dart';

class MockBreedClassifierService {
  static List<String>? _labels;
  static bool _isInitialized = false;

  /// Mock breed classifier that simulates TensorFlow Lite functionality
  /// This is a fallback when TensorFlow Lite isn't available
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Load labels
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();

      _isInitialized = true;
      print('Mock BreedClassifier initialized successfully');
      print('Loaded ${_labels?.length} breed labels');
      
      return true;
    } catch (e) {
      print('Error initializing Mock BreedClassifier: $e');
      return false;
    }
  }

  /// Mock prediction that returns random but realistic results
  static Future<PredictionResult?> predictFromFile(File imageFile) async {
    try {
      if (!_isInitialized || _labels == null) {
        await initialize();
      }

      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 1500));

      return _generateMockPrediction();
    } catch (e) {
      print('Error in mock prediction: $e');
      return null;
    }
  }

  /// Mock prediction from bytes
  static Future<PredictionResult?> predictFromBytes(Uint8List imageBytes) async {
    try {
      if (!_isInitialized || _labels == null) {
        await initialize();
      }

      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 1500));

      return _generateMockPrediction();
    } catch (e) {
      print('Error in mock prediction: $e');
      return null;
    }
  }

  /// Generate a mock prediction with realistic confidence scores
  static PredictionResult _generateMockPrediction() {
    if (_labels == null || _labels!.isEmpty) {
      return PredictionResult.fromLocalML(
        breedName: 'Holstein Friesian',
        confidence: 0.85,
      );
    }

    final random = Random();
    
    // Generate realistic confidence scores
    final topConfidence = 0.6 + random.nextDouble() * 0.35; // 0.6 to 0.95
    final secondConfidence = topConfidence - 0.1 - random.nextDouble() * 0.2;
    final thirdConfidence = secondConfidence - 0.05 - random.nextDouble() * 0.15;
    
    // Randomly select breeds
    final shuffledLabels = List<String>.from(_labels!)..shuffle(random);
    
    final topBreed = shuffledLabels[0];
    final predictions = <String, double>{
      topBreed: topConfidence,
      if (shuffledLabels.length > 1) shuffledLabels[1]: secondConfidence.clamp(0.0, 1.0),
      if (shuffledLabels.length > 2) shuffledLabels[2]: thirdConfidence.clamp(0.0, 1.0),
    };

    return PredictionResult.fromLocalML(
      breedName: topBreed,
      confidence: topConfidence,
      allPredictions: predictions,
    );
  }

  /// Get available breed labels
  static List<String> getAvailableBreeds() {
    return _labels ?? [];
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Dispose resources
  static void dispose() {
    _labels = null;
    _isInitialized = false;
  }
}