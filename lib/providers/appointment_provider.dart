import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _error = '';

  List<Appointment> get appointments => [..._appointments];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get upcoming appointments
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) =>
    appointment.dateTime.isAfter(now) &&
        appointment.status == 'scheduled')
        .toList();
  }

  // Get past appointments
  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) =>
    appointment.dateTime.isBefore(now) ||
        appointment.status == 'completed' ||
        appointment.status == 'cancelled')
        .toList();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, this would be an API call to fetch appointments
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _appointments = [
        Appointment(
          id: '1',
          doctorName: 'Dr. John Smith',
          specialty: 'Cardiologist',
          dateTime: DateTime.now().add(const Duration(days: 7)),
          reason: 'Heart palpitations',
          location: 'City Hospital, Room 302',
          status: 'scheduled',
        ),
        Appointment(
          id: '2',
          doctorName: 'Dr. Sarah Johnson',
          specialty: 'Endocrinologist',
          dateTime: DateTime.now().add(const Duration(days: 14)),
          reason: 'Diabetes follow-up',
          location: 'Medical Center, Room 105',
          status: 'scheduled',
        ),
        Appointment(
          id: '3',
          doctorName: 'Dr. Michael Wong',
          specialty: 'Dermatologist',
          dateTime: DateTime.now().subtract(const Duration(days: 10)),
          reason: 'Skin rash',
          location: 'Dermatology Clinic',
          status: 'completed',
          notes: 'Prescribed topical cream for rash',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to add an appointment
      await Future.delayed(const Duration(seconds: 1));

      _appointments.add(appointment);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to update an appointment
      await Future.delayed(const Duration(seconds: 1));

      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index >= 0) {
        _appointments[index] = appointment;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to cancel an appointment
      await Future.delayed(const Duration(seconds: 1));

      final index = _appointments.indexWhere((a) => a.id == id);
      if (index >= 0) {
        _appointments[index] = _appointments[index].copyWith(status: 'cancelled');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((appointment) => appointment.id == id);
    } catch (e) {
      return null;
    }
  }
}

