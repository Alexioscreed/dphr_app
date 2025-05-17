import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _error = '';

  List<Appointment> get appointments => [..._appointments];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get appointments by type (upcoming, past, cancelled)
  List<Appointment> getAppointmentsByType(String type) {
    final now = DateTime.now();

    switch (type) {
      case 'upcoming':
        return _appointments.where((appointment) =>
        appointment.date.isAfter(now) &&
            appointment.status != 'Cancelled'
        ).toList();
      case 'past':
        return _appointments.where((appointment) =>
        appointment.date.isBefore(now) &&
            appointment.status != 'Cancelled'
        ).toList();
      case 'cancelled':
        return _appointments.where((appointment) =>
        appointment.status == 'Cancelled'
        ).toList();
      default:
        return [..._appointments];
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

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _appointments = [
        Appointment(
          id: '1',
          doctorName: 'John Smith',
          department: 'Cardiology',
          hospital: 'General Hospital',
          date: DateTime.now().add(const Duration(days: 7)),
          time: const TimeOfDay(hour: 10, minute: 30),
          status: 'Confirmed',
          notes: 'Annual heart checkup',
        ),
        Appointment(
          id: '2',
          doctorName: 'Sarah Johnson',
          department: 'Dermatology',
          hospital: 'City Medical Center',
          date: DateTime.now().add(const Duration(days: 14)),
          time: const TimeOfDay(hour: 14, minute: 15),
          status: 'Confirmed',
          notes: 'Skin examination',
        ),
        Appointment(
          id: '3',
          doctorName: 'Michael Brown',
          department: 'Orthopedics',
          hospital: 'General Hospital',
          date: DateTime.now().subtract(const Duration(days: 10)),
          time: const TimeOfDay(hour: 9, minute: 0),
          status: 'Completed',
          notes: 'Follow-up for knee pain',
        ),
        Appointment(
          id: '4',
          doctorName: 'Emily Davis',
          department: 'Neurology',
          hospital: 'Neuroscience Center',
          date: DateTime.now().subtract(const Duration(days: 5)),
          time: const TimeOfDay(hour: 11, minute: 45),
          status: 'Cancelled',
          notes: 'Headache consultation',
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

  Future<bool> bookAppointment(Appointment appointment) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _appointments.add(appointment);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _appointments.indexWhere((appointment) => appointment.id == id);
      if (index != -1) {
        final appointment = _appointments[index];
        final updatedAppointment = Appointment(
          id: appointment.id,
          doctorName: appointment.doctorName,
          department: appointment.department,
          hospital: appointment.hospital,
          date: appointment.date,
          time: appointment.time,
          status: 'Cancelled',
          notes: appointment.notes,
        );

        _appointments[index] = updatedAppointment;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rescheduleAppointment(String id, DateTime newDate, TimeOfDay newTime) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _appointments.indexWhere((appointment) => appointment.id == id);
      if (index != -1) {
        final appointment = _appointments[index];
        final updatedAppointment = Appointment(
          id: appointment.id,
          doctorName: appointment.doctorName,
          department: appointment.department,
          hospital: appointment.hospital,
          date: newDate,
          time: newTime,
          status: 'Rescheduled',
          notes: appointment.notes,
        );

        _appointments[index] = updatedAppointment;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
