import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';
import 'add_edit_doctor_screen.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  static const routeName = '/doctors';

  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _isLoading = true;
  List<Doctor> _doctors = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final doctorService = Provider.of<DoctorService>(context, listen: false);
      final doctors = await doctorService.getAllDoctors();

      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load doctors: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditDoctorScreen(),
            ),
          );
          if (result == true) {
            _loadDoctors();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No doctors found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                doctor.firstName[0] + doctor.lastName[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(doctor.fullName),
            subtitle: Text(doctor.specialization ?? 'General Practitioner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(doctor: doctor),
                ),
              );
              if (result == true) {
                _loadDoctors();
              }
            },
          ),
        );
      },
    );
  }
}
