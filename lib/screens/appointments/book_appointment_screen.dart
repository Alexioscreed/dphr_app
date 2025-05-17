import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? recommendedSpecialty;
  final String? symptomReason;

  const BookAppointmentScreen({
    Key? key,
    this.recommendedSpecialty,
    this.symptomReason,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String _selectedDepartment = 'Cardiology';
  String _selectedDoctor = 'John Smith';
  String _selectedHospital = 'General Hospital';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  bool _bookingSuccess = false;

  final List<String> _departments = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Ophthalmology',
    'Gynecology',
  ];

  final Map<String, List<String>> _doctorsByDepartment = {
    'Cardiology': ['John Smith', 'Emily Johnson', 'Robert Williams'],
    'Dermatology': ['Sarah Brown', 'Michael Davis', 'Jennifer Wilson'],
    'Neurology': ['David Miller', 'Lisa Moore', 'James Taylor'],
    'Orthopedics': ['Patricia Anderson', 'Thomas Jackson', 'Barbara White'],
    'Pediatrics': ['Charles Harris', 'Susan Martin', 'Joseph Thompson'],
    'Psychiatry': ['Nancy Clark', 'Daniel Lewis', 'Karen Lee'],
    'Ophthalmology': ['Paul Hall', 'Betty Young', 'Edward Walker'],
    'Gynecology': ['Linda Allen', 'Mark Wright', 'Sandra King'],
  };

  final List<String> _hospitals = [
    'General Hospital',
    'City Medical Center',
    'Community Health Hospital',
    'University Medical Center',
    'Memorial Hospital',
  ];

  @override
  void initState() {
    super.initState();

    // Set recommended specialty if provided
    if (widget.recommendedSpecialty != null && _departments.contains(widget.recommendedSpecialty)) {
      _selectedDepartment = widget.recommendedSpecialty!;
      _selectedDoctor = _doctorsByDepartment[_selectedDepartment]![0];
    }

    // Set notes if symptom reason provided
    if (widget.symptomReason != null) {
      _notesController.text = 'Reason: ${widget.symptomReason}';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

        // Create appointment object
        final appointment = Appointment(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
          doctorName: _selectedDoctor,
          department: _selectedDepartment,
          hospital: _selectedHospital,
          date: _selectedDate,
          time: _selectedTime,
          status: 'Confirmed',
          notes: _notesController.text,
        );

        // Book appointment
        final success = await appointmentProvider.bookAppointment(appointment);

        setState(() {
          _isLoading = false;
          _bookingSuccess = success;
        });

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to book appointment: ${appointmentProvider.error}')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: _bookingSuccess ? _buildSuccessScreen() : _buildBookingForm(),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              items: _departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
                  _selectedDoctor = _doctorsByDepartment[_selectedDepartment]![0];
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDoctor,
              decoration: const InputDecoration(
                labelText: 'Doctor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _doctorsByDepartment[_selectedDepartment]!.map((doctor) {
                return DropdownMenuItem<String>(
                  value: doctor,
                  child: Text('Dr. $doctor'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDoctor = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedHospital,
              decoration: const InputDecoration(
                labelText: 'Hospital',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _hospitals.map((hospital) {
                return DropdownMenuItem<String>(
                  value: hospital,
                  child: Text(hospital),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHospital = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectDate(context),
                ),
              ),
              controller: TextEditingController(
                text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Time',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () => _selectTime(context),
                ),
              ),
              controller: TextEditingController(
                text: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2196F3),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Appointment Booked',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully booked an appointment with Dr. $_selectedDoctor',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hospital: $_selectedHospital',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Back to Appointments'),
            ),
          ],
        ),
      ),
    );
  }
}
