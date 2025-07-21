import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/health_records_service.dart';
import '../../services/api_service.dart';
import '../../widgets/formatted_visit_summary_widget.dart';

class FormattedVisitScreen extends StatefulWidget {
  final String? visitUuid;
  final String? patientUuid;
  final Map<String, dynamic>? visitData;

  const FormattedVisitScreen({
    Key? key,
    this.visitUuid,
    this.patientUuid,
    this.visitData,
  }) : super(key: key);

  @override
  State<FormattedVisitScreen> createState() => _FormattedVisitScreenState();
}

class _FormattedVisitScreenState extends State<FormattedVisitScreen> {
  String? _formattedSummary;
  bool _isLoading = true;
  String? _error;
  HealthRecordsService? _healthRecordsService;

  @override
  void initState() {
    super.initState();
    // Initialize in didChangeDependencies instead
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_healthRecordsService == null) {
      _healthRecordsService = HealthRecordsService(
        context.read<ApiService>(),
      );
      _loadFormattedSummary();
    }
  }

  Future<void> _loadFormattedSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // If we have the formatted summary in visitData, use it
      if (widget.visitData != null &&
          widget.visitData!['formattedSummary'] != null) {
        _formattedSummary = widget.visitData!['formattedSummary'] as String;
      }
      // Otherwise fetch from backend
      else if (widget.patientUuid != null && _healthRecordsService != null) {
        if (widget.visitUuid != null) {
          // Get specific visit
          _formattedSummary = await _healthRecordsService!
              .getFormattedVisitByUuid(widget.patientUuid!, widget.visitUuid!);
        } else {
          // Get all formatted visits and use the first one
          final response = await _healthRecordsService!
              .getFormattedVisitSummary(widget.patientUuid!);

          final formattedVisits = response['formattedVisits'] as List?;
          if (formattedVisits != null && formattedVisits.isNotEmpty) {
            _formattedSummary =
                formattedVisits.first['formattedSummary'] as String?;
          }
        }
      }

      _formattedSummary ??= _getDefaultFormattedSummary();
    } catch (e) {
      _error = e.toString();
      _formattedSummary = _getDefaultFormattedSummary();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDefaultFormattedSummary() {
    return '''Visit was stopped at 12:37:53

Cetirizine Tablet 10mg prescribed on 18-02-2025 12:49:57 by Rosemary Gabriel Wakolela

1 (tablet) od 5 Days Oral

Paracetamol 500mg Tablet(s) prescribed on 18-02-2025 12:49:41 by Rosemary Gabriel Wakolela

2 (tablet) tds / 8 hrly 3 Days Oral

Confirmed Diagnoses

(J00) Acute Nasopharyngitis [Common Cold]

Started new visit at 12:37:47''';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visit Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _loadFormattedSummary,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading visit summary...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading visit summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFormattedSummary,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_formattedSummary != null)
            FormattedVisitSummaryWidget(
              formattedSummary: _formattedSummary!,
              visitUuid: widget.visitUuid ?? 'unknown',
            ),
          const SizedBox(height: 20),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'About This Format',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This visit summary is formatted according to iCare system standards, '
              'showing prescription details with exact dosage, frequency, duration, '
              'and administration route as prescribed by healthcare providers.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
