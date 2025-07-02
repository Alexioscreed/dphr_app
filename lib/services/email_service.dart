import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class EmailService {
  final AuthService _authService;
  final bool _isTestMode = false; // Set to false in production

  EmailService(this._authService);

  // Send email with PDF attachment
  Future<bool> sendEmailWithAttachment({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String message,
    required String pdfFilePath,
    required String purpose,
  }) async {
    // In test mode, use simulation
    if (_isTestMode) {
      return _simulateSendEmail(
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        subject: subject,
        message: message,
        pdfFilePath: pdfFilePath,
        purpose: purpose,
      );
    }

    try {
      final url = '${AppConfig.baseApiUrl}/sharing/send-email';
      debugPrint('Sending email to $recipientEmail with PDF: $pdfFilePath');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization headers
      request.headers.addAll(_authService.getAuthHeaders());

      // Add text fields
      request.fields['recipientEmail'] = recipientEmail;
      request.fields['recipientName'] = recipientName;
      request.fields['subject'] = subject;
      request.fields['message'] = message;
      request.fields['purpose'] = purpose;

      // Add file attachment
      final file = await http.MultipartFile.fromPath(
        'attachment',
        pdfFilePath,
        filename: pdfFilePath.split('/').last,
      );
      request.files.add(file);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Email sent successfully to $recipientEmail');
        return true;
      } else {
        // Handle error response
        debugPrint('Failed to send email: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to send email: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      throw Exception('Error sending email: $e');
    }
  }

  // For testing purposes - simulates email sending without actual API call
  Future<bool> _simulateSendEmail({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String message,
    required String pdfFilePath,
    required String purpose,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('SIMULATION: Email would be sent to $recipientEmail');
      debugPrint('SIMULATION: PDF path: $pdfFilePath');
      debugPrint('SIMULATION: Subject: $subject');
      debugPrint('SIMULATION: Message: $message');

      // Always return success in simulation mode
      return true;
    } catch (e) {
      debugPrint('SIMULATION: Error sending email: $e');
      throw Exception('Error simulating email: $e');
    }
  }
}
