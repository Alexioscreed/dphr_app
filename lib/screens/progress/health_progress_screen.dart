import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/vital_measurement.dart';

class HealthProgressScreen extends StatefulWidget {
  const HealthProgressScreen({Key? key}) : super(key: key);

  @override
  State<HealthProgressScreen> createState() => _HealthProgressScreenState();
}

class _HealthProgressScreenState extends State<HealthProgressScreen> {
  String _selectedMetric = 'Blood Pressure';
  String _selectedTimeRange = '1 Month';
  bool _isLoading = true;
  List<VitalMeasurement> _vitalData = [];

  final List<String> _metrics = [
    'Blood Pressure',
    'Heart Rate',
    'Blood Glucose',
    'Weight',
    'Temperature',
    'Oxygen Saturation',
  ];

  final List<String> _timeRanges = [
    '1 Week',
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate sample data based on selected metric and time range
    final now = DateTime.now();
    final data = <VitalMeasurement>[];

    if (_selectedMetric == 'Blood Pressure') {
      // Generate blood pressure data
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        data.add(
          VitalMeasurement(
            type: 'Blood Pressure',
            value: '${120 + (i % 10)}/${80 + (i % 5)} mmHg',
            date: date,
            notes: '',
          ),
        );
      }
    } else if (_selectedMetric == 'Heart Rate') {
      // Generate heart rate data
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        data.add(
          VitalMeasurement(
            type: 'Heart Rate',
            value: '${70 + (i % 15)} bpm',
            date: date,
            notes: '',
          ),
        );
      }
    } else if (_selectedMetric == 'Blood Glucose') {
      // Generate blood glucose data
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        data.add(
          VitalMeasurement(
            type: 'Blood Glucose',
            value: '${90 + (i % 20)} mg/dL',
            date: date,
            notes: '',
          ),
        );
      }
    } else if (_selectedMetric == 'Weight') {
      // Generate weight data
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        data.add(
          VitalMeasurement(
            type: 'Weight',
            value: '${70 + (i % 5)} kg',
            date: date,
            notes: '',
          ),
        );
      }
    }

    setState(() {
      _vitalData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Progress'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProgressChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMetric,
                  decoration: const InputDecoration(
                    labelText: 'Metric',
                    border: OutlineInputBorder(),
                  ),
                  items: _metrics.map((metric) {
                    return DropdownMenuItem<String>(
                      value: metric,
                      child: Text(metric),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMetric = value!;
                      _loadData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeRange,
                  decoration: const InputDecoration(
                    labelText: 'Time Range',
                    border: OutlineInputBorder(),
                  ),
                  items: _timeRanges.map((range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                      _loadData();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    if (_vitalData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_selectedMetric == 'Blood Pressure') {
      return _buildBloodPressureChart();
    } else {
      return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < _vitalData.length; i++) {
      final vital = _vitalData[i];
      double value = 0;

      if (_selectedMetric == 'Heart Rate') {
        value = double.parse(vital.value.split(' ')[0]);
      } else if (_selectedMetric == 'Blood Glucose') {
        value = double.parse(vital.value.split(' ')[0]);
      } else if (_selectedMetric == 'Weight') {
        value = double.parse(vital.value.split(' ')[0]);
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 == 0 && value.toInt() < _vitalData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatDate(_vitalData[value.toInt()].date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: (_vitalData.length - 1).toDouble(),
                minY: _getMinY(),
                maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildBloodPressureChart() {
    final List<FlSpot> systolicSpots = [];
    final List<FlSpot> diastolicSpots = [];

    for (int i = 0; i < _vitalData.length; i++) {
      final vital = _vitalData[i];
      final parts = vital.value.split('/');
      final systolic = double.parse(parts[0]);
      final diastolic = double.parse(parts[1].split(' ')[0]);

      systolicSpots.add(FlSpot(i.toDouble(), systolic));
      diastolicSpots.add(FlSpot(i.toDouble(), diastolic));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 == 0 && value.toInt() < _vitalData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatDate(_vitalData[value.toInt()].date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: (_vitalData.length - 1).toDouble(),
                minY: 60,
                maxY: 180,
                lineBarsData: [
                  LineChartBarData(
                    spots: systolicSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                  LineChartBarData(
                    spots: diastolicSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBloodPressureLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          _selectedMetric,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodPressureLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        const Text(
          'Systolic',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 24),
        Container(
          width: 16,
          height: 16,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        const Text(
          'Diastolic',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _getMinY() {
    if (_selectedMetric == 'Heart Rate') {
      return 50;
    } else if (_selectedMetric == 'Blood Glucose') {
      return 70;
    } else if (_selectedMetric == 'Weight') {
      return 60;
    }
    return 0;
  }

  double _getMaxY() {
    if (_selectedMetric == 'Heart Rate') {
      return 120;
    } else if (_selectedMetric == 'Blood Glucose') {
      return 200;
    } else if (_selectedMetric == 'Weight') {
      return 100;
    }
    return 100;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

