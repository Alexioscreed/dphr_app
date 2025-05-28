import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/doctors/doctor_list_screen.dart';
import '../screens/doctors/doctor_detail_screen.dart';
import '../screens/doctors/add_edit_doctor_screen.dart';
import '../screens/prescriptions/prescription_list_screen.dart';
import '../screens/prescriptions/add_edit_prescription_screen.dart';
import '../models/doctor.dart';
import '../models/prescription.dart';

class AppRoutes {
  static const String home = '/';
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctor-detail';
  static const String addEditDoctor = '/add-edit-doctor';
  static const String prescriptions = '/prescriptions';
  static const String addEditPrescription = '/add-edit-prescription';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const SplashScreen(),
    doctors: (context) => const DoctorListScreen(),
    // Other routes handled in onGenerateRoute for parameters
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case doctorDetail:
        final doctor = settings.arguments as Doctor;
        return MaterialPageRoute(
          builder: (context) => DoctorDetailScreen(doctor: doctor),
          settings: settings,
        );

      case addEditDoctor:
        final doctor = settings.arguments as Doctor?;
        return MaterialPageRoute(
          builder: (context) => AddEditDoctorScreen(doctor: doctor),
          settings: settings,
        );

      case prescriptions:
        final args = settings.arguments as Map<String, dynamic>;
        final patientId = args['patientId'] as int;
        return MaterialPageRoute(
          builder: (context) => PrescriptionListScreen(patientId: patientId),
          settings: settings,
        );

      case addEditPrescription:
        final args = settings.arguments as Map<String, dynamic>;
        final prescription = args['prescription'] as Prescription?;
        final patientId = args['patientId'] as int;
        final encounterId = args['encounterId'] as int?;
        return MaterialPageRoute(
          builder: (context) => AddEditPrescriptionScreen(
            prescription: prescription,
            patientId: patientId,
            encounterId: encounterId,
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
