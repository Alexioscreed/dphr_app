import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import '../models/patient_health_records.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Generate a PDF for a specific visit record
  Future<String> generateVisitPdf({
    required VisitRecord visit,
    required PatientDemographics demographics,
    required String appName,
  }) async {
    // Generate the PDF document using the shared helper method
    final pdf = await _generatePdfDocument(
      visit: visit,
      demographics: demographics,
      appName: appName,
    );

    // Save the PDF file
    final bytes = await pdf.save();

    // Generate a filename for the PDF
    final String visitDate = _getVisitDateForFilename(visit);
    final String fileName =
        'visit_summary_${visitDate}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    try {
      // Try to save to documents directory (mobile devices)
      try {
        final output = await getApplicationDocumentsDirectory();
        final file = File('${output.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      } catch (e) {
        print('Could not access application documents directory: $e');
        // Fall back to temporary directory or in-memory for web
        throw e; // Let the next catch handle it
      }
    } catch (e) {
      // Keep PDF bytes in memory for later use
      print('Storing PDF in memory due to platform limitations: $e');
      // Return a pseudo-path for the in-memory PDF
      return 'memory://pdf/$fileName';
    }
  }

  // Open the generated PDF
  Future<void> openPdf(String filePath) async {
    try {
      // Check if this is an in-memory PDF (we couldn't save to disk)
      if (filePath.startsWith('memory://')) {
        print(
            'PDF is stored in memory. Printing is available but saving to disk is not supported on this platform.');

        // On web, we could launch a new tab with the PDF data
        // For now, we'll just notify that the PDF was generated
        return;
      }

      // Standard file opening for mobile/desktop
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  // A unified method to generate and view PDF across all platforms
  Future<void> generateAndViewPdf({
    required VisitRecord visit,
    required PatientDemographics demographics,
    required String appName,
  }) async {
    try {
      // First generate the PDF and get the path
      final String pdfPath = await generateVisitPdf(
        visit: visit,
        demographics: demographics,
        appName: appName,
      );

      // Check if we're dealing with an in-memory PDF (web or unsupported platform)
      if (pdfPath.startsWith('memory://')) {
        // For web or platforms where we couldn't save to disk
        // Generate the PDF document again (it wasn't saved to disk)
        final pdf = await _generatePdfDocument(
          visit: visit,
          demographics: demographics,
          appName: appName,
        );

        // Use the printing package to show a preview dialog
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Visit Summary - ${visit.visitType ?? 'Medical Visit'}',
        );
      } else {
        // For platforms where we could save to disk (mobile, desktop)
        await openPdf(pdfPath);
      }
    } catch (e) {
      print('Error generating or viewing PDF: $e');
      // In a real app, you would show an error dialog or notification to the user
    }
  }

  // Helper method to generate the PDF document
  Future<pw.Document> _generatePdfDocument({
    required VisitRecord visit,
    required PatientDemographics demographics,
    required String appName,
  }) async {
    // Create PDF document
    final pdf = pw.Document();

    // Create a DPHR logo as provided by the user - embedding it directly in the code
    // This blue circular logo with a medical kit icon and DPHR text
    final Uint8List dphrLogoBytes = _getDphrLogoBytes();

    // Create the logo widget using the embedded logo bytes
    pw.Widget logoWidget;
    try {
      // Use the embedded logo bytes
      logoWidget = pw.Image(pw.MemoryImage(dphrLogoBytes));
      print('Using embedded DPHR logo');
    } catch (e) {
      // Fallback to a text-based logo if there's any issue with the embedded logo
      print('Using text-based logo fallback: $e');
      logoWidget = pw.Container(
        width: 80,
        height: 80,
        decoration: pw.BoxDecoration(
          color: PdfColor(0, 157 / 255, 249 / 255), // #009DF9 - DPHR blue color
          borderRadius: pw.BorderRadius.circular(40),
        ),
        alignment: pw.Alignment.center,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColor(1, 1, 1),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                '+',
                style: pw.TextStyle(
                  color: PdfColor(0, 157 / 255, 249 / 255),
                  fontSize: 20,
                  font: pw.Font.helveticaBold(),
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'DPHR',
              style: pw.TextStyle(
                color: PdfColor(1, 1, 1),
                fontSize: 10,
                font: pw.Font.helveticaBold(),
              ),
            ),
          ],
        ),
      );
    }

    // Theme colors
    final primaryColor = PdfColor(0, 121 / 255, 107 / 255); // #00796B
    final secondaryColor = PdfColor(0, 150 / 255, 136 / 255); // #009688
    final accentColor = PdfColor(1.0, 64 / 255, 129 / 255); // #FF4081
    final textColor = PdfColor(33 / 255, 33 / 255, 33 / 255); // #212121
    final lightTextColor = PdfColor(117 / 255, 117 / 255, 117 / 255); // #757575
    final backgroundColor =
        PdfColor(250 / 255, 250 / 255, 250 / 255); // #FAFAFA

    // Header style
    final headerStyle = pw.TextStyle(
      font: pw.Font.helveticaBold(),
      fontSize: 18,
      color: primaryColor,
    );

    final sectionHeaderStyle = pw.TextStyle(
      font: pw.Font.helveticaBold(),
      fontSize: 14,
      color: secondaryColor,
    );

    final normalTextStyle = pw.TextStyle(
      font: pw.Font.helvetica(),
      fontSize: 12,
      color: textColor,
    );

    final smallTextStyle = pw.TextStyle(
      font: pw.Font.helvetica(),
      fontSize: 10,
      color: lightTextColor,
    );

    // Format dates
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final DateTime date = DateTime.parse(dateStr);
        return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    // Build PDF content
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
            boldItalic: pw.Font.helveticaBoldOblique(),
          ),
          buildBackground: (pw.Context context) {
            return pw.Container(
              color: backgroundColor,
              padding: const pw.EdgeInsets.all(0),
            );
          },
        ),
        build: (pw.Context context) => [
          // Header with logo
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(10),
                bottomRight: pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Visit Summary',
                      style: pw.TextStyle(
                        font: pw.Font.helveticaBold(),
                        fontSize: 24,
                        color: PdfColor(1, 1, 1),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${visit.visitType ?? 'Medical Visit'} - ${formatDate(visit.startDatetime ?? visit.startDate)}',
                      style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontSize: 14,
                        color: PdfColor(0.9, 0.9, 0.9),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  width: 80,
                  height: 80,
                  child: logoWidget,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Patient Demographics Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor(1, 1, 1),
              borderRadius: pw.BorderRadius.circular(10),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColor(0, 0, 0, 0.1),
                  blurRadius: 3,
                  offset: const PdfPoint(0, 2),
                ),
              ],
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'Patient Information',
                      style: headerStyle,
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow(
                    'Name',
                    demographics.fullName ??
                        '${demographics.firstName ?? ''} ${demographics.lastName ?? ''}',
                    normalTextStyle),
                _buildInfoRow('Gender', demographics.gender ?? 'Not specified',
                    normalTextStyle),
                _buildInfoRow('Date of Birth',
                    demographics.birthdate ?? 'Not specified', normalTextStyle),
                _buildInfoRow(
                    'Age',
                    demographics.age?.toString() ?? 'Not specified',
                    normalTextStyle),
                _buildInfoRow('MRN', demographics.mrn ?? 'Not specified',
                    normalTextStyle),
                if (demographics.phoneNumber != null)
                  _buildInfoRow(
                      'Phone', demographics.phoneNumber!, normalTextStyle),
                if (demographics.address != null)
                  _buildInfoRow(
                      'Address', demographics.address!, normalTextStyle),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Visit Details Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor(1, 1, 1),
              borderRadius: pw.BorderRadius.circular(10),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColor(0, 0, 0, 0.1),
                  blurRadius: 3,
                  offset: const PdfPoint(0, 2),
                ),
              ],
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      decoration: pw.BoxDecoration(
                        color: secondaryColor,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'Visit Details',
                      style: headerStyle,
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow('Visit Type', visit.visitType ?? 'Not specified',
                    normalTextStyle),
                _buildInfoRow('Location', visit.location ?? 'Not specified',
                    normalTextStyle),
                _buildInfoRow(
                    'Start Date',
                    formatDate(visit.startDatetime ?? visit.startDate),
                    normalTextStyle),
                if (visit.stopDatetime != null || visit.endDate != null)
                  _buildInfoRow(
                      'End Date',
                      formatDate(visit.stopDatetime ?? visit.endDate),
                      normalTextStyle),
                _buildInfoRow(
                    'Status', visit.status ?? 'Not specified', normalTextStyle),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Medications Section
          _buildMedicationsSection(visit, sectionHeaderStyle, normalTextStyle,
              smallTextStyle, accentColor),
          pw.SizedBox(height: 16),

          // Diagnoses Section
          _buildDiagnosesSection(
              visit, sectionHeaderStyle, normalTextStyle, accentColor),
          pw.SizedBox(height: 16),

          // Footer
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Column(
              children: [
                pw.Divider(color: lightTextColor),
                pw.SizedBox(height: 4),
                pw.Text(
                  '$appName - Printed on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: smallTextStyle,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'This document contains confidential health information',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaOblique(),
                    fontSize: 8,
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  String _getVisitDateForFilename(VisitRecord visit) {
    try {
      final String? dateStr = visit.startDatetime ?? visit.startDate;
      if (dateStr != null && dateStr.isNotEmpty) {
        final DateTime date = DateTime.parse(dateStr);
        return DateFormat('yyyyMMdd').format(date);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 'unknown';
  }

  // Helper methods for building PDF sections
  pw.Widget _buildInfoRow(String label, String value, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: style.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationsSection(
    VisitRecord visit,
    pw.TextStyle sectionHeaderStyle,
    pw.TextStyle normalTextStyle,
    pw.TextStyle smallTextStyle,
    PdfColor accentColor,
  ) {
    // Extract medications from encounters
    final medications = <OrderRecord>[];
    if (visit.encounters != null) {
      for (var encounter in visit.encounters!) {
        if (encounter.prescriptions != null) {
          medications.addAll(encounter.prescriptions!);
        }
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(1, 1, 1),
        borderRadius: pw.BorderRadius.circular(10),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor(0, 0, 0, 0.1),
            blurRadius: 3,
            offset: const PdfPoint(0, 2),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  color: accentColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                'Medications',
                style: sectionHeaderStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          medications.isEmpty
              ? pw.Text('No medications recorded for this visit.',
                  style: normalTextStyle)
              : pw.Column(
                  children: medications
                      .map(
                        (med) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 12),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor(0.97, 0.97, 0.97),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                med.conceptDisplay ?? 'Unknown Medication',
                                style: normalTextStyle.copyWith(
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              if (med.dosage != null)
                                pw.Text('Dosage: ${med.dosage}',
                                    style: normalTextStyle),
                              if (med.drugStrength != null)
                                pw.Text('Strength: ${med.drugStrength}',
                                    style: normalTextStyle),
                              if (med.frequency != null)
                                pw.Text('Frequency: ${med.frequency}',
                                    style: normalTextStyle),
                              if (med.dateActivated != null)
                                pw.Text(
                                    'Start Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(med.dateActivated!))}',
                                    style: normalTextStyle),
                              if (med.duration != null)
                                pw.Text('Duration: ${med.duration}',
                                    style: normalTextStyle),
                              if (med.instructions != null)
                                pw.Text('Instructions: ${med.instructions}',
                                    style: normalTextStyle),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  pw.Widget _buildDiagnosesSection(
    VisitRecord visit,
    pw.TextStyle sectionHeaderStyle,
    pw.TextStyle normalTextStyle,
    PdfColor accentColor,
  ) {
    // Extract diagnoses from encounters
    final List<String> diagnosisList = [];
    if (visit.encounters != null) {
      for (var encounter in visit.encounters!) {
        if (encounter.diagnoses != null) {
          diagnosisList.addAll(encounter.diagnoses!);
        }
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(1, 1, 1),
        borderRadius: pw.BorderRadius.circular(10),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor(0, 0, 0, 0.1),
            blurRadius: 3,
            offset: const PdfPoint(0, 2),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  color: accentColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                'Diagnoses',
                style: sectionHeaderStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          diagnosisList.isEmpty
              ? pw.Text('No diagnoses recorded for this visit.',
                  style: normalTextStyle)
              : pw.Column(
                  children: diagnosisList
                      .map(
                        (diagnosis) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 12),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor(0.97, 0.97, 0.97),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            diagnosis,
                            style: normalTextStyle.copyWith(
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  // Helper method to get the DPHR logo bytes (embedded as base64)
  Uint8List _getDphrLogoBytes() {
    // This is a base64 encoded PNG of the DPHR logo (blue circular logo with a medical kit icon)
    const String base64Logo =
        'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIzLTA2LTE0VDE1OjA2OjEzKzAzOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMy0wNi0xNFQxNTowNzoxNiswMzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wNi0xNFQxNTowNzoxNiswMzowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpiZmJiM2JjNi05ZWEyLTQ1NGEtOWI2OS05ODQ0ZmZkZjg3MTQiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDo0ZjU1YzQwMi1mYzNiLWYyNGYtODE2OS0zNjc2MzVhNjA1ZjkiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkOTRhMzZiNS0yOTY1LTk2NDItOWIwOC1iYWNlMzIyNGYzYTYiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmQ5NGEzNmI1LTI5NjUtOTY0Mi05YjA4LWJhY2UzMjI0ZjNhNiIgc3RFdnQ6d2hlbj0iMjAyMy0wNi0xNFQxNTowNjoxMyswMzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTggKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpiZmJiM2JjNi05ZWEyLTQ1NGEtOWI2OS05ODQ0ZmZkZjg3MTQiIHN0RXZ0OndoZW49IjIwMjMtMDYtMTRUMTU6MDc6MTYrMDM6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE4IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6K7/U+AAAOwklEQVR4nO2deXRU1RnAf/fNTDJJSEIIBAJhE0RBQFnEpRZX1AO2VtRWW1u1VuuCtfW4a4un1VOtimvdqNalWo8L1eqpCCiLyqIisoRFsrAkJJCF7DNz+8fvvmSSzJJk5s0k+H7n5GQyb7n3u9/97nfvd+99T4iihyCE8ACTgXFAf+B4YJD+6w+0An8CXtXH7wCuBcYAA4FsIA1IAkQPmdkwHl9PoIoAhBAJwCrgTO1KARJjOKUZqNU0lwAfAf8GGoIpHCUQIUQqcB9wCTDMgnMeAeqA/wJrgWVAQzSBuEogoQ2EEDcCDwKZIX+1AiuBdUAFUA1s0H/rQjsB+Ah4Adgc+mci4ALGAqfqv6HADGA2kB6mEJVADTAf+LvTLcgRgQghhgFrgRztUgNnRnvYvVCpB2MJsF5KWdfTAnGFQIQQk4DFQIaUsk0I4QWmadcE7WUdsAx4CbjaSTFEpDuFI0IXKmxN0UJIBCZp1ynAf4DzOjshUvccYQI5CvgQeNBCGqcC/wLudrAcEXFcIO3oHIFDfXCYI2kQQnQMJ3q/D3hOH0f1sV7GsUZ9lEB6AFMI5AjCCCRGPMB5QogT7U6ot0a5riBvzxJCTI6B5nDgeeBqu+w+wnRxA0IIL8o4TAGGQJvPvgCoBhYRh3YkXgWhBJIGZKEMvAx9nIqKCueBClFvACMI/O8e4GHgb8DrxGGIHO+CsA0pZStQBWxHeQgD9V864NU+bwF+Aiyx8n7xLgh7EUIkA9uAalQ43QRIVBdWglJ+CnA5qgv7eyjB2NiTxbUgbEVK2YQKs1ehBLIFZV98KAHlA4OBi4ClKDszpKfKHNeCcAQp5VZgJvC8djUDbcAW4ATgb8Ap4a6Ld0E4hpSyGrgAeALoUshxLwhHiXtB9Aj0cCjuC8IN9LggXEY8wHEvCDfg0YJYKaW01d+PN4QQnnjq1uKJuBeEW4h7QbiFuBeEW4h7QbiFuBeEW+hVBRFTt6YQdvr78YbHrjviShARkEIIPzAGFZLnAGlAEWrS6DPU6tVu49GCcMXsrnxUwRQAeaiJI7+UMvygQM/h6VUFEbNATqcT9+vU66AXWa1AXc06FtXVnaU/96CWtHwKPAWsIvxiLFfQ6wqiW10WcBbwO9SyrBTdovaixu3LCCzZeR+1nOd74C5Ul+Ymel1BxCwQbReeAM7WrhbgM+Bl1AarXwIXA48SWJ31O+BT1FKfAm3AbUOvK4iYWogQYhzwmHZtBm5BbZk9BhgPXIna5nM3asvBWSgDnyql3KzPeVCf6xp6XUF0dVAmEdhmcDswE1gfOkYQQrwDnA/8ArgT+GnIOSOllJVCiDHASGALgb2ujtPrCqJLTVEIkQe8hFpbWw38HHgnkqekhbABtQPkLgL7WLOEEDlSyrUoD+t0Ahn2qoLoclclhJiAGmmXAp8C46SUn3d2npSyRm95+Bi1OGoYahnqJlS3d0HIz72uILolECFEEmrXxWygHrhCSll0KDpSyiohxDTgEeBq1FhkP1BEeI/LtlHvSHQl05cCR6PG/7dKKT+MlZa2F/cSaLE79fEoKeXuWOleAixGrYcNR6PVaR2Kbj3MUUK1jFx93KmdXcKjW8lfgUu0qxD4i3ZfCGwFWqSUJbHS7iqxzg8tQg0/vKgH5BWrC9QZfv3/x2nXKKvrHCu9pSASwrjSbKA9hVjXOdvBZ3RI5GYkgQC0SSmbtHcVa3e0BTiIw0Y6UUEIY0FWOV1gB3ByLCIqIq7r6oJ6iZTyEdTCqJBrWlDdmC3EZYuSUm4RQlyHWq0LalXW6w6XywfgZm8qLPHUZTmOl0MvlgJsQ41LAD6SUs51oEyOC8LNNsQB2g3mfVLKmVLKD6WUF0spc4UQI4UQTzoZrNIWpJRu3q8Vlg6xm9uAp7UgXpNSrtX+yajpgKNRo3EnMbcbLAfOZzlOCEKgVp1/iVp5OwE1n5GvP5uCWuF1AXAq0CClLLK7XNpOLEMN0/yhtIbZ/ZGUssymMh2KUNsxIIxPpJSTDzXxIoRoQi2GKhFCDANeQo1BAG6SUm60sbwmoZsEwHApZUXYL3ZdEG7tsiLVu4DA+KQZODGcMPQ13UXZgspHC7DFrmC7UJsRSihFoZ+HOlhxLwg3EVIQPwF+0Ol3Q4j5dJvQgqi2rYTtiHtBuAw3jTTjXhBuwqMFMdNBo90W4l4QbiLuBeEm4l4QbiHuBeEm4l4QbiLuBeEW4l4QbqJXFYRt87LxTNwLwk3EvSDcQtwLwk3EvSDcRNwLwi3EvSDcRNwLwi3EvSDcRNwLwi1YVRAJoLZc6+OHgMv3TcUoiERwfP+Tm+l1BeGxoKJVQojzUPvXOuBKKWVLhO+lA2/qj0uklFd18t0pwCtAgv68WgjxW6Au9HtSypZIF1lxb9wLohN4UMJoQG2rbUbt1TUL+CnqDRw+4Fop5c4I9B5HvZvxdSnlhDDf+RyYBqRq10IppRBC1ADXA5fpazRIKSNubNYVQcS9ILqAB7URzIfaslyK2r9agJpAStRlqUBtej1fSnlBGFqm0XYDb4X57jxgr5SyWQhRQeDVJ8V6D+9sKeWDnRU01jHIEdQes+6o91zU2GKF/jwTWE7gXRy5QoiXhRApYUgkoYTyP+3vj3o75RTUi63m6s/vAXp0I4p7QXQRHtTLnipQW2cNQVQBX6K6LR/qJaAtqJdS/S0MjWwCL0Y+HrgWWKQFMlYI8SRKgC0E3oN+SBsS94LoBuq1a6P+a5RSFqCEU4B6C24e8AvUy6dCN83OJtDdHQ3MA/6JeoHzB8DV+jPzsw7pWsS9ILrYQsI1+qG6m/Gg3sl+OcpIGyRLKV/Vf/UIIa5GjUEeBOZLKef4/f4RQJ7+/w+kFUZ7IbYahDaF2x0uEk4KYgPKJrQKIV6QUp4DrEK1kjIhxHTUW8Z9wEngBuBMKWU5IISQfaHLgljfMSKlbBRC3Ina7LpICPG9lHKRlPJTIcTXKG9qOcqoP4AanO9HvZYvZsS9ILrZQnZrV4OUcgnwohDiQ9Q74PKllNsBhBBJQJou2zOoLisZlQ+PUU+vK4guCcTosrQRXgsgpZwHzBNCXAmsFEJcI6VcJqVsA+qEEO8BbwBTUV1WNcqwHzJWKppeVxBdqrSUcpcQ4nYg1HsS+rMdQojrgA+EECP0YqqvUM8nGN3VHqJE3AvCbfS6grBiXdYWIcTFqMmfG1CZbQFeA46TUlbr790NXADcjuryzgXWAOOklJ1uvIp7QbiJXlcQsQhkEXA/MCLEa7oMJYyLpZSrtHuwlHKXEOJ3qDdnXKvPWaDP6ZReVxCxCmS/lHJOqEMIMRzlaR0HXCGlnC+lrNOf5QMbtY1YIYRoBt41j7tSiF5XEBYYdQFgjD/0CPs+4Gntrwbm6NbyCvAaaif8t1LKOgvyHBZxLwgLaQJqfJGqXTuBd6SUt+uXWxnMQ71X/EHgHOCfUsqHzKDgSIF6XUHE6mW1CCEmohZLnaw/TwJ+JYSY389PqZTyPX1cK4T4I3CrECINtdLrsdD3bztEryuIWAWyHzhLSrkn1CmE+BAYqT8ejhJEkvZ+GnRQLpRHNg616dcWxL0g3ESvK4hYvcw6YCKAECJdCDFRCJGCCskbUI/DKEAJsQb4o56BSEEJ5H1Uy0lA7X3tFF0RRNwLoo87kFI2CiGq9ceFqBH5GNCvKzHmK14QQpwMPAVcjVqM9biUco8Q4lPgYaBTD6urgohmEM41XhFwaFwQu0DygMeAG7UrGdgDPCqlnC+E2KDdXinlDiHEFOAXwA2oRVOvCSHmogYHPtT4xFZ6XUFYMECvQ6028AOPhLzacyOBlf/XCiH+gvKoxgJ/QHVZbcASKeUyIcRE/f8X2ZbrcPS6gohlXpYHdeLHoOYrjkP5+3v1KYDPUE9uX4bq6qaj5ixq9TkA3wO3ofbvThBCTES1lrOllI9Fzn33EfeCcBO9riC60mUN1cF1BvrzmcDRqO3JI1FdVQ1q2LEdlb8a1DxGK2ryqB7YLqV8TAiRgOpCfcDNQog6KeUqW3LXgbgXhJvoVQXRla7qPtQa2rEoQexCbeaoB75BbTUYgnJVD6K8rRaU+K5GraLdIYQYhurW0tAL+aSUT9iQr7DEvSDcRK8qiM4E0g+V0TuAEahXSK1FzcHuJxDwN7qsFl2mAuCXqBH4HlR3JlCLp14TQlRLKb+yOlORiHtBuIleVRCRLCrwFvA9MAbVCl5FvQ/kA+AtlK0ws7oX5VnVAf+VUp6tFzdNQY3e64DRqHmPm1DD+Vbg05ByHqZFHeOOIHpdQURaF1ckpbxHb/S4DPiPlLKEgBDMN0yMAKYBz6OE8SnwXW+ZQY/Ygro/cSKEGIdaNOVFDWvvkFJ+fKhzpJRVer3V08AFwGUoIf5VStkdtzcm9LqCiNRCvEYEI6VcDiw/1DkA+trLUC/VuB71PI+tQoizpZSxPuQtJsS9INxEryuISONxRxghhEjQLwMdDOxDPdKoT6DXFYRbxuMO0+sKwi3j8R6m1xWEW8bjbqbXFYRbxuM9TK8rCLeMx3uYXlcQbhmP9zC9riDcMh7vYXpdQbhlPN7DxL0g3ETcC8ItxL0g3ETcC8ItxL0g3ETcC8ItxL0g3ETcC8It6IKY7OQDPnsbcS8ItxD3gnALcS8IN2FdQQhbyhFHCCF+RACeUAc9hlcL4jMp5XQnyni4IIT4kU64tUGfLojPpJRTnChj1AePuZV4E0gf8Ue8CaQP6KPPiPcBffQBffQBffQBffQBffQBffQBffQBcYwQ4v8wJK1hSzF5mgAAAABJRU5ErkJggg==';

    try {
      // Decode the base64 logo to bytes
      return base64Decode(base64Logo);
    } catch (e) {
      print('Error decoding logo: $e');
      // Return an empty Uint8List in case of error
      return Uint8List(0);
    }
  }
}
