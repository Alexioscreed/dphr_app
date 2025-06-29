import 'package:flutter/material.dart';
import '../../widgets/visit_details_widget.dart';

class VisitDetailsDemoScreen extends StatelessWidget {
  const VisitDetailsDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visit Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : Colors.grey.shade50,
        child: SingleChildScrollView(
          child: Column(
            children: [
              VisitDetailsWidget(
                visitData: _getSampleVisitData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getSampleVisitData() {
    return {
      'startTime': '12:37:47',
      'stopTime': '12:37:53',
      'medications': [
        {
          'name': 'Cetirizine Tablet 10mg',
          'prescribedDate': '18-02-2025 12:49:57',
          'prescriber': 'Rosemary Gabriel Wakolela',
          'dosage': '1 (tablet)',
          'frequency': 'od',
          'duration': '5 Days',
          'route': 'Oral',
        },
        {
          'name': 'Paracetamol 500mg Tablet(s)',
          'prescribedDate': '18-02-2025 12:49:41',
          'prescriber': 'Rosemary Gabriel Wakolela',
          'dosage': '2 (tablet)',
          'frequency': 'tds / 8 hrly',
          'duration': '3 Days',
          'route': 'Oral',
        },
      ],
      'diagnoses': [
        '(J00) Acute Nasopharyngitis [Common Cold]',
      ],
    };
  }
}
