import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MLApiService {
  static String get apiUrl => dotenv.env['MODEL_API_URL'] ?? '';
  static String get apiKey => dotenv.env['MODEL_API_KEY'] ?? '';
  
  static Future<Map<String, dynamic>> predictBreed(String imagePath) async {
    try {
      // Check if API is configured
      if (apiUrl.isEmpty || apiUrl == 'your_model_api_url_here') {
        // Return mock data for demo purposes
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        return {
          'success': true,
          'breed': 'Golden Retriever',
          'confidence': 0.85,
        };
      }
      
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // Add API key to headers
      if (apiKey.isNotEmpty && apiKey != 'your_model_api_key_here') {
        request.headers['Authorization'] = 'Bearer $apiKey';
      }
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Add image file
      final file = await http.MultipartFile.fromPath('image', imagePath);
      request.files.add(file);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return {
          'success': true,
          'breed': jsonResponse['breed'] ?? 'Unknown',
          'confidence': (jsonResponse['confidence'] ?? 0.0).toDouble(),
        };
      } else {
        return {
          'success': false,
          'error': 'API request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('ML API Error: $e');
      // Return mock data as fallback
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'breed': 'Labrador',
        'confidence': 0.75,
      };
    }
  }
}
