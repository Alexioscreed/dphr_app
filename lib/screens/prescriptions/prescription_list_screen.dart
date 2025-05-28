import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/prescription.dart';
import '../../services/prescription_service.dart';

class PrescriptionListScreen extends StatefulWidget {
  static const routeName = '/prescriptions';
  final int patientId;

  const PrescriptionListScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Prescription> _prescriptions = [];
  String _error = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prescriptionService =
          Provider.of<PrescriptionService>(context, listen: false);
      final prescriptions =
          await prescriptionService.getPrescriptionsByPatient(widget.patientId);

      setState(() {
        _prescriptions = prescriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load prescriptions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Prescription> get _activePrescriptions =>
      _prescriptions.where((prescription) => prescription.isActive).toList();

  List<Prescription> get _completedPrescriptions =>
      _prescriptions.where((prescription) => prescription.isCompleted).toList();

  List<Prescription> get _discontinuedPrescriptions => _prescriptions
      .where((prescription) => prescription.isDiscontinued)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Discontinued'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrescriptions,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add prescription screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add prescription feature coming soon')),
          );
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
              onPressed: _loadPrescriptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No prescriptions found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPrescriptions,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPrescriptionList(_activePrescriptions),
        _buildPrescriptionList(_completedPrescriptions),
        _buildPrescriptionList(_discontinuedPrescriptions),
      ],
    );
  }

  Widget _buildPrescriptionList(List<Prescription> prescriptions) {
    if (prescriptions.isEmpty) {
      return const Center(
        child: Text('No prescriptions in this category'),
      );
    }

    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Prescription #${prescription.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Dosage: ${prescription.dosage}, Frequency: ${prescription.frequency}'),
                if (prescription.duration != null)
                  Text('Duration: ${prescription.duration}'),
                if (prescription.daysRemaining != null)
                  Text(
                    'Days remaining: ${prescription.daysRemaining}',
                    style: TextStyle(
                      color: prescription.daysRemaining! < 5
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to prescription detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Prescription details coming soon')),
              );
            },
          ),
        );
      },
    );
  }
}
