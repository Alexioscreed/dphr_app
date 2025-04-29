import 'package:flutter/material.dart';
import 'symptoms/log_symptoms_screen.dart';
import 'vitals/log_vitals_screen.dart';

class LogSectionScreen extends StatefulWidget {
  const LogSectionScreen({Key? key}) : super(key: key);

  @override
  State<LogSectionScreen> createState() => _LogSectionScreenState();
}

class _LogSectionScreenState extends State<LogSectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Logging'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Symptoms'),
            Tab(text: 'Vitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LogSymptomsScreen(),
          LogVitalsScreen(),
        ],
      ),
    );
  }
}
