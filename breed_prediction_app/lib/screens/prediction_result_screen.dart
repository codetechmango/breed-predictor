import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/supabase_service.dart';
import '../services/voice_service.dart';
import '../utils/app_localizations.dart';

class PredictionResultScreen extends StatefulWidget {
  final String imagePath;
  final String imageUrl;
  final String breed;
  final double confidence;
  final String language;

  const PredictionResultScreen({
    super.key,
    required this.imagePath,
    required this.imageUrl,
    required this.breed,
    required this.confidence,
    required this.language,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  String? _feedbackType;
  final _feedbackController = TextEditingController();
  bool _isSubmittingFeedback = false;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    VoiceService.stopListening();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    bool available = await VoiceService.initialize();
    setState(() {
      _speechEnabled = available;
    });
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    await VoiceService.startListening((recognizedWords) {
      setState(() {
        _feedbackController.text = recognizedWords;
      });
    });

    // Auto-stop after a delay
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isListening) {
        _stopListening();
      }
    });
  }

  Future<void> _stopListening() async {
    await VoiceService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  String _translate(String key) {
    return AppLocalizations.translate(key, widget.language);
  }

  Future<void> _submitFeedback() async {
    if (_feedbackType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select if the prediction is correct or incorrect'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        await SupabaseService.submitFeedback(
          userId: user.id,
          imageUrl: widget.imageUrl,
          predictedBreed: widget.breed,
          confidence: widget.confidence,
          feedback: '$_feedbackType: ${_feedbackController.text}',
        );
      } else {
        // Demo mode - simulate feedback submission
        print('Demo mode: Feedback - $_feedbackType: ${_feedbackController.text}');
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translate('success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to home screen
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      // Continue anyway for demo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translate('success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to home screen
      }
    }

    if (mounted) {
      setState(() {
        _isSubmittingFeedback = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('prediction_result')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Display
            Center(
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Prediction Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _translate('prediction_result'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Breed
                    Row(
                      children: [
                        Text(
                          '${_translate('breed')}: ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.breed,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Confidence
                    Row(
                      children: [
                        Text(
                          '${_translate('confidence')}: ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(widget.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.confidence > 0.8 
                                ? Colors.green 
                                : widget.confidence > 0.6 
                                    ? Colors.orange 
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confidence Indicator
                    LinearProgressIndicator(
                      value: widget.confidence,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.confidence > 0.8 
                            ? Colors.green 
                            : widget.confidence > 0.6 
                                ? Colors.orange 
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Feedback Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: Colors.blue[700],
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _translate('submit_feedback'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Was this prediction correct?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Feedback Type Selection
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(_translate('correct')),
                            value: 'correct',
                            groupValue: _feedbackType,
                            onChanged: (value) {
                              setState(() {
                                _feedbackType = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(_translate('incorrect')),
                            value: 'incorrect',
                            groupValue: _feedbackType,
                            onChanged: (value) {
                              setState(() {
                                _feedbackType = value;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Additional Comments with Voice Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with better mobile layout
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.comment, color: Colors.blue[700], size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Share your feedback',
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Help us improve by sharing your thoughts (optional)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Voice input section - mobile optimized
                        if (_speechEnabled)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isListening 
                                    ? [Colors.red[50]!, Colors.red[100]!]
                                    : [Colors.blue[50]!, Colors.blue[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isListening ? Colors.red[200]! : Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _isListening ? Colors.red : Colors.blue[600],
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isListening ? Colors.red : Colors.blue).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isListening ? Icons.mic : Icons.mic_none,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isListening ? 'Listening...' : 'Voice Input',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _isListening ? Colors.red[700] : Colors.blue[700],
                                            ),
                                          ),
                                          Text(
                                            _isListening 
                                                ? 'Speak your feedback now'
                                                : 'Tap to record your voice',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Voice control button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: IconButton(
                                        onPressed: _isListening ? _stopListening : _startListening,
                                        icon: Icon(
                                          _isListening ? Icons.stop : Icons.play_arrow,
                                          color: _isListening ? Colors.red : Colors.blue[600],
                                        ),
                                        tooltip: _isListening ? 'Stop Recording' : 'Start Voice Input',
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (_isListening) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SpinKitWave(
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Recording in progress...',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        
                        if (_speechEnabled) const SizedBox(height: 16),
                        
                        // Text input field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _feedbackController,
                            decoration: InputDecoration(
                              hintText: _speechEnabled 
                                  ? 'Type here or use voice input above...' 
                                  : 'Tell us more about the prediction...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              suffixIcon: _feedbackController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _feedbackController.clear();
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                                    )
                                  : null,
                            ),
                            maxLines: 4,
                            style: const TextStyle(fontSize: 16),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        
                        // Info message for devices without voice support
                        if (!_speechEnabled)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, 
                                     size: 20, 
                                     color: Colors.amber[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Voice input not available on this device',
                                    style: TextStyle(
                                      fontSize: 13, 
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Submit Feedback Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingFeedback ? null : _submitFeedback,
                        child: _isSubmittingFeedback
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                _translate('submit_feedback'),
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
