import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String department;
  final String hospital;
  final DateTime date;
  final TimeOfDay time;
  final String status;
  final String notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.department,
    required this.hospital,
    required this.date,
    required this.time,
    required this.status,
    this.notes = '',
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'department': department,
      'hospital': hospital,
      'date': date.toIso8601String(),
      'time': {'hour': time.hour, 'minute': time.minute},
      'status': status,
      'notes': notes,
    };
  }

  // Create from Map for database retrieval
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorName: map['doctorName'],
      department: map['department'],
      hospital: map['hospital'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: map['time']['hour'],
        minute: map['time']['minute'],
      ),
      status: map['status'],
      notes: map['notes'] ?? '',
    );
  }
}
