class PredictionResult {
  final String breed;
  final String breedName; // Alternative name for compatibility
  final double confidence;
  final String imageUrl;
  final Map<String, double>? allPredictions; // Top predictions with scores

  PredictionResult({
    required this.breed,
    required this.confidence,
    this.imageUrl = '',
    this.allPredictions,
  }) : breedName = breed;

  // Named constructor for local ML predictions
  PredictionResult.fromLocalML({
    required String breedName,
    required this.confidence,
    this.allPredictions,
  }) : breed = breedName,
        breedName = breedName,
        imageUrl = '';

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      breed: json['breed'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      allPredictions: json['allPredictions'] != null 
          ? Map<String, double>.from(json['allPredictions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breed': breed,
      'breedName': breedName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'allPredictions': allPredictions,
    };
  }

  /// Get formatted confidence percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Get a user-friendly breed name (capitalize first letter)
  String get displayName {
    if (breedName.isEmpty) return 'Unknown';
    return breedName.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
    ).join(' ');
  }
}
