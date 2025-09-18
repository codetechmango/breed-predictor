class PredictionResult {
  final String breed;
  final double confidence;
  final String imageUrl;

  PredictionResult({
    required this.breed,
    required this.confidence,
    required this.imageUrl,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      breed: json['breed'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breed': breed,
      'confidence': confidence,
      'imageUrl': imageUrl,
    };
  }
}
