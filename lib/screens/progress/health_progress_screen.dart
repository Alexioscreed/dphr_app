import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vital_measurements_provider.dart';
import '../../models/vital_measurement.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthProgressScreen extends StatefulWidget {
  const HealthProgressScreen({Key? key}) : super(key: key);

  @override
  State<HealthProgressScreen> createState() => _HealthProgressScreenState();
}

class _HealthProgressScreenState extends State<HealthProgressScreen> {
  String _selectedMetric = 'Blood Pressure';
  String _selectedTimeRange = '1 Month';
  bool _isLoading = false;

  final List<String> _metrics = [
    'Blood Pressure',
    'Heart Rate',
    'Blood Glucose',
    'Weight',
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
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vitalMeasurementsProvider = Provider.of<VitalMeasurementsProvider>(context, listen: false);
      await vitalMeasurementsProvider.fetchMeasurements();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch measurements: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            _buildSelectors(),
            const SizedBox(height: 16),
            _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Metric',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMetric,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _metrics.map((metric) {
                      return DropdownMenuItem<String>(
                        value: metric,
                        child: Text(metric),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMetric = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time Range',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeRange,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _timeRanges.map((range) {
                      return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeRange = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final vitalMeasurementsProvider = Provider.of<VitalMeasurementsProvider>(context);
    final measurements = vitalMeasurementsProvider.getMeasurementsByType(_selectedMetric);

    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    // Sort measurements by date
    measurements.sort((a, b) => a.date.compareTo(b.date));

    if (_selectedMetric == 'Blood Pressure') {
      return _buildBloodPressureChart(measurements);
    } else {
      return _buildSingleMetricChart(measurements);
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMetricIcon(_selectedMetric),
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No $_selectedMetric data available',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log measurements to see your progress',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to log vitals screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('Log Measurement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart(List<VitalMeasurement> measurements) {
    // Generate sample data for blood pressure
    // In a real app, you would parse the actual values from measurements
    final now = DateTime.now();
    final dates = List.generate(30, (index) =>
        now.subtract(Duration(days: 29 - index))
    );

    // Sample systolic data (red line)
    final systolicSpots = List.generate(30, (index) {
      final baseValue = 120.0;
      final variation = (index % 7 == 0) ? 10.0 : 0.0;
      final decline = (index % 7) * 1.5;
      return FlSpot(index.toDouble(), baseValue + variation - decline);
    });

    // Sample diastolic data (blue line)
    final diastolicSpots = List.generate(30, (index) {
      final baseValue = 80.0;
      final variation = (index % 7 == 0) ? 5.0 : 0.0;
      final decline = (index % 7) * 0.7;
      return FlSpot(index.toDouble(), baseValue + variation - decline);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 10,
                verticalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 5 != 0) return const Text('');
                      final date = dates[value.toInt() >= dates.length ? dates.length - 1 : value.toInt()];
                      return Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              minX: 0,
              maxX: 29,
              minY: 60,
              maxY: 180,
              lineBarsData: [
                // Systolic line (red)
                LineChartBarData(
                  spots: systolicSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
                // Diastolic line (blue)
                LineChartBarData(
                  spots: diastolicSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Systolic', Colors.red),
            const SizedBox(width: 24),
            _buildLegendItem('Diastolic', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleMetricChart(List<VitalMeasurement> measurements) {
    // Generate sample data
    final now = DateTime.now();
    final dates = List.generate(30, (index) =>
        now.subtract(Duration(days: 29 - index))
    );

    // Sample data
    final spots = List.generate(30, (index) {
      double baseValue;
      switch (_selectedMetric) {
        case 'Heart Rate':
          baseValue = 72.0;
          break;
        case 'Blood Glucose':
          baseValue = 95.0;
          break;
        case 'Weight':
          baseValue = 75.0;
          break;
        case 'Oxygen Saturation':
          baseValue = 98.0;
          break;
        default:
          baseValue = 100.0;
      }

      final variation = (index % 5 == 0) ? (baseValue * 0.05) : 0.0;
      final randomFactor = (index % 3 - 1) * (baseValue * 0.01);

      return FlSpot(index.toDouble(), baseValue + variation + randomFactor);
    });

    Color lineColor;
    switch (_selectedMetric) {
      case 'Heart Rate':
        lineColor = Colors.red;
        break;
      case 'Blood Glucose':
        lineColor = Colors.purple;
        break;
      case 'Weight':
        lineColor = Colors.green;
        break;
      case 'Oxygen Saturation':
        lineColor = Colors.blue;
        break;
      default:
        lineColor = const Color(0xFF2196F3);
    }

    double minY, maxY;
    switch (_selectedMetric) {
      case 'Heart Rate':
        minY = 50;
        maxY = 100;
        break;
      case 'Blood Glucose':
        minY = 70;
        maxY = 150;
        break;
      case 'Weight':
        minY = 60;
        maxY = 90;
        break;
      case 'Oxygen Saturation':
        minY = 90;
        maxY = 100;
        break;
      default:
        minY = 50;
        maxY = 150;
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 5 != 0) return const Text('');
                  final date = dates[value.toInt() >= dates.length ? dates.length - 1 : value.toInt()];
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: 29,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getMetricIcon(String metricType) {
    switch (metricType) {
      case 'Blood Pressure':
        return Icons.favorite;
      case 'Heart Rate':
        return Icons.monitor_heart;
      case 'Blood Glucose':
        return Icons.bloodtype;
      case 'Weight':
        return Icons.monitor_weight;
      case 'Oxygen Saturation':
        return Icons.air;
      default:
        return Icons.medical_services;
    }
  }
}
