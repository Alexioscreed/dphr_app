import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vital_measurements_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vital_measurement.dart';
import '../../services/api_service.dart';
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
  List<VitalMeasurement> _chartData = [];

  final List<String> _metrics = [
    'Blood Pressure',
    'Heart Rate',
    'Blood Glucose',
    'Weight',
    'Oxygen Saturation',
    'Temperature',
  ];

  final List<String> _timeRanges = [
    '1 Day',
    '1 Week',
    '1 Month',
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (authProvider.currentUser?.patientUuid != null) {
        final vitalProvider =
            Provider.of<VitalMeasurementsProvider>(context, listen: false);

        // Calculate date range based on selection
        final DateTime endDate = DateTime.now();
        DateTime startDate;

        switch (_selectedTimeRange) {
          case '1 Day':
            startDate = endDate.subtract(const Duration(days: 1));
            break;
          case '1 Week':
            startDate = endDate.subtract(const Duration(days: 7));
            break;
          case '1 Month':
            startDate = endDate.subtract(const Duration(days: 30));
            break;
          case '6 Months':
            startDate = endDate.subtract(const Duration(days: 180));
            break;
          case '1 Year':
            startDate = endDate.subtract(const Duration(days: 365));
            break;
          default:
            startDate = endDate.subtract(const Duration(days: 30));
        }

        // Fetch measurements for the selected metric and time range
        _chartData = await vitalProvider.fetchMeasurementsByTypeAndDateRange(
          authProvider.currentUser!.patientUuid!,
          _selectedMetric,
          startDate,
          endDate,
          apiService,
        );
      }

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
                      _fetchMeasurements(); // Refresh data when metric changes
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
                      _fetchMeasurements(); // Refresh data when time range changes
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
    if (_chartData.isEmpty) {
      return _buildEmptyState();
    }

    // Sort measurements by date
    _chartData.sort((a, b) => a.date.compareTo(b.date));

    if (_selectedMetric == 'Blood Pressure') {
      return _buildBloodPressureChart(_chartData);
    } else {
      return _buildSingleMetricChart(_chartData);
    }
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your vitals to see your health progress here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMetricChart(List<VitalMeasurement> measurements) {
    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    // Create spots from actual measurements data
    final spots = <FlSpot>[];
    final values = <double>[];
    for (int i = 0; i < measurements.length; i++) {
      final measurement = measurements[i];
      double value = _parseValueFromMeasurement(measurement.value);
      spots.add(FlSpot(i.toDouble(), value));
      values.add(value);
    }

    Color lineColor;
    double minY, maxY;

    // Calculate actual min and max from data
    double dataMin =
        values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0;
    double dataMax =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 100;

    switch (_selectedMetric) {
      case 'Heart Rate':
        lineColor = Colors.red;
        minY = (dataMin - 10).clamp(40, double.infinity);
        maxY = (dataMax + 10).clamp(60, double.infinity);
        break;
      case 'Blood Glucose':
        lineColor = Colors.purple;
        minY = (dataMin - 10).clamp(60, double.infinity);
        maxY = (dataMax + 20).clamp(80, double.infinity);
        break;
      case 'Weight':
        lineColor = Colors.green;
        minY = (dataMin - 5).clamp(40, double.infinity);
        maxY = (dataMax + 10).clamp(60, double.infinity);
        break;
      case 'Temperature':
        lineColor = Colors.orange;
        minY = (dataMin - 1).clamp(34, double.infinity);
        maxY = (dataMax + 1).clamp(36, double.infinity);
        break;
      case 'Oxygen Saturation':
        lineColor = Colors.blue;
        // For oxygen saturation, ensure we have a reasonable range
        minY = (dataMin - 2).clamp(85, double.infinity);
        maxY = (dataMax + 2).clamp(dataMin + 5, double.infinity);
        // Ensure we have at least a 5-point range for better visualization
        if (maxY - minY < 5) {
          maxY = minY + 5;
        }
        break;
      default:
        lineColor = const Color(0xFF2196F3);
        minY = (dataMin - 10).clamp(0, double.infinity);
        maxY = (dataMax + 20).clamp(dataMin + 10, double.infinity);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedMetric,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  clipData: FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 5,
                    getDrawingHorizontalLine: (value) {
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
                        interval: measurements.length > 10
                            ? measurements.length / 5
                            : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= measurements.length)
                            return const Text('');
                          final measurement = measurements[value.toInt()];
                          return Text(
                            '${measurement.date.day}/${measurement.date.month}',
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
                        interval: (maxY - minY) / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (measurements.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total measurements: ${measurements.length}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart(List<VitalMeasurement> measurements) {
    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    final allValues = <double>[];

    for (int i = 0; i < measurements.length; i++) {
      final measurement = measurements[i];
      final bpValues = _parseBloodPressureValue(measurement.value);
      if (bpValues != null) {
        systolicSpots.add(FlSpot(i.toDouble(), bpValues['systolic']!));
        diastolicSpots.add(FlSpot(i.toDouble(), bpValues['diastolic']!));
        allValues.add(bpValues['systolic']!);
        allValues.add(bpValues['diastolic']!);
      }
    }

    // Calculate dynamic bounds for blood pressure
    double minY = 60; // Default minimum
    double maxY = 180; // Default maximum

    if (allValues.isNotEmpty) {
      double dataMin = allValues.reduce((a, b) => a < b ? a : b);
      double dataMax = allValues.reduce((a, b) => a > b ? a : b);
      minY = (dataMin - 10).clamp(50, double.infinity);
      maxY = (dataMax + 10).clamp(minY + 20, double.infinity);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Pressure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  clipData: FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 5,
                    getDrawingHorizontalLine: (value) {
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
                        interval: measurements.length > 10
                            ? measurements.length / 5
                            : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= measurements.length)
                            return const Text('');
                          final measurement = measurements[value.toInt()];
                          return Text(
                            '${measurement.date.day}/${measurement.date.month}',
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
                        interval: (maxY - minY) / 5,
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
                  maxX: (measurements.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    // Systolic line (red)
                    LineChartBarData(
                      spots: systolicSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
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
                      dotData: FlDotData(show: true),
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
            const SizedBox(height: 8),
            Text(
              'Total measurements: ${measurements.length}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Helper method to parse numeric value from measurement string
  double _parseValueFromMeasurement(String value) {
    // Remove units and extract numeric value
    final regex = RegExp(r'[\d.]+');
    final match = regex.firstMatch(value);
    if (match != null) {
      return double.tryParse(match.group(0)!) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to parse blood pressure values
  Map<String, double>? _parseBloodPressureValue(String value) {
    // Parse "120/80" format
    final regex = RegExp(r'(\d+)/(\d+)');
    final match = regex.firstMatch(value);
    if (match != null) {
      final systolic = double.tryParse(match.group(1)!) ?? 0.0;
      final diastolic = double.tryParse(match.group(2)!) ?? 0.0;
      return {'systolic': systolic, 'diastolic': diastolic};
    }
    return null;
  }
}
