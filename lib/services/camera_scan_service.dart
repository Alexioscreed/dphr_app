import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScanService {
  static final CameraScanService _instance = CameraScanService._internal();
  factory CameraScanService() => _instance;
  CameraScanService._internal();

  static const List<String> vitalTypes = [
    'Blood Pressure',
    'Heart Rate',
    'Temperature',
    'Blood Glucose',
    'Weight',
    'Oxygen Saturation',
  ];

  // Extract numerical values from text using regex patterns
  static String? extractVitalValue(String text, String vitalType) {
    final cleanText = text.replaceAll(RegExp(r'[^\d./°\s]'), ' ').trim();
    
    switch (vitalType) {
      case 'Blood Pressure':
        // Look for patterns like "120/80", "120 / 80", "120 80"
        final bpPattern = RegExp(r'(\d{2,3})\s*[/\s]\s*(\d{2,3})');
        final match = bpPattern.firstMatch(cleanText);
        if (match != null) {
          return '${match.group(1)}/${match.group(2)}';
        }
        break;
        
      case 'Heart Rate':
        // Look for patterns like "72", "72 bpm", "HR: 72"
        final hrPattern = RegExp(r'(\d{2,3})(?:\s*bpm)?');
        final match = hrPattern.firstMatch(cleanText);
        if (match != null) {
          final value = int.tryParse(match.group(1)!);
          if (value != null && value >= 30 && value <= 220) {
            return match.group(1);
          }
        }
        break;
        
      case 'Temperature':
        // Look for patterns like "37.5", "98.6°F", "37°C"
        final tempPattern = RegExp(r'(\d{2,3}\.?\d?)(?:\s*[°CF])?');
        final match = tempPattern.firstMatch(cleanText);
        if (match != null) {
          final value = double.tryParse(match.group(1)!);
          if (value != null) {
            // Convert Fahrenheit to Celsius if needed
            if (value > 50) {
              // Likely Fahrenheit
              final celsius = (value - 32) * 5 / 9;
              return celsius.toStringAsFixed(1);
            } else {
              // Likely Celsius
              return value.toStringAsFixed(1);
            }
          }
        }
        break;
        
      case 'Blood Glucose':
        // Look for patterns like "95", "95 mg/dL", "5.3 mmol/L"
        final glucosePattern = RegExp(r'(\d{2,3}\.?\d?)(?:\s*(?:mg/dL|mmol/L))?');
        final match = glucosePattern.firstMatch(cleanText);
        if (match != null) {
          final value = double.tryParse(match.group(1)!);
          if (value != null) {
            // Convert mmol/L to mg/dL if needed
            if (value < 30) {
              // Likely mmol/L
              final mgDl = value * 18;
              return mgDl.round().toString();
            } else {
              // Likely mg/dL
              return value.round().toString();
            }
          }
        }
        break;
        
      case 'Weight':
        // Look for patterns like "70", "70 kg", "154 lbs"
        final weightPattern = RegExp(r'(\d{2,3}\.?\d?)(?:\s*(?:kg|lbs?))?');
        final match = weightPattern.firstMatch(cleanText);
        if (match != null) {
          final value = double.tryParse(match.group(1)!);
          if (value != null) {
            // Convert lbs to kg if needed
            if (value > 50 && text.toLowerCase().contains('lb')) {
              final kg = value * 0.453592;
              return kg.toStringAsFixed(1);
            } else {
              return value.toStringAsFixed(1);
            }
          }
        }
        break;
        
      case 'Oxygen Saturation':
        // Look for patterns like "98", "98%", "SpO2: 98"
        final oxygenPattern = RegExp(r'(\d{2,3})(?:\s*%)?');
        final match = oxygenPattern.firstMatch(cleanText);
        if (match != null) {
          final value = int.tryParse(match.group(1)!);
          if (value != null && value >= 70 && value <= 100) {
            return match.group(1);
          }
        }
        break;
    }
    
    return null;
  }

  // Scan text from image using ML Kit
  static Future<String?> scanTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();
      
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error scanning text from image: $e');
      return null;
    }
  }

  // Show camera scan dialog
  static Future<String?> showScanDialog(BuildContext context, String vitalType) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan $vitalType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose how to capture the $vitalType reading:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final value = await _captureFromCamera(context, vitalType);
                      if (value != null) {
                        Navigator.of(context).pop(value);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final value = await _pickFromGallery(context, vitalType);
                      if (value != null) {
                        Navigator.of(context).pop(value);
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Capture image from camera and extract vital value
  static Future<String?> _captureFromCamera(BuildContext context, String vitalType) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        return await _processImage(context, File(image.path), vitalType);
      }
    } catch (e) {
      debugPrint('Error capturing from camera: $e');
      _showErrorDialog(context, 'Error capturing image from camera');
    }
    return null;
  }

  // Pick image from gallery and extract vital value
  static Future<String?> _pickFromGallery(BuildContext context, String vitalType) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        return await _processImage(context, File(image.path), vitalType);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      _showErrorDialog(context, 'Error picking image from gallery');
    }
    return null;
  }

  // Process image and extract vital value
  static Future<String?> _processImage(BuildContext context, File imageFile, String vitalType) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Scanning...'),
              ],
            ),
          );
        },
      );

      // Scan text from image
      final scannedText = await scanTextFromImage(imageFile);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (scannedText != null && scannedText.isNotEmpty) {
        // Extract vital value from scanned text
        final extractedValue = extractVitalValue(scannedText, vitalType);
        
        if (extractedValue != null) {
          // Show confirmation dialog
          final confirmed = await _showConfirmationDialog(
            context, 
            vitalType, 
            extractedValue, 
            scannedText
          );
          
          if (confirmed == true) {
            return extractedValue;
          }
        } else {
          _showErrorDialog(context, 'Could not extract $vitalType value from the image. Please try again or enter manually.');
        }
      } else {
        _showErrorDialog(context, 'No text detected in the image. Please ensure the reading is clearly visible.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      debugPrint('Error processing image: $e');
      _showErrorDialog(context, 'Error processing image. Please try again.');
    }
    return null;
  }

  // Show confirmation dialog for extracted value
  static Future<bool?> _showConfirmationDialog(
    BuildContext context, 
    String vitalType, 
    String extractedValue, 
    String fullText
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $vitalType Reading'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Extracted value: $extractedValue'),
              const SizedBox(height: 8),
              const Text('Full scanned text:'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fullText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Is this value correct?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, try again'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, use this value'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
