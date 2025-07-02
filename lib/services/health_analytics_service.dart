import '../models/vital_measurement.dart';
import '../models/symptom.dart';

class HealthRisk {
  final String type;
  final String severity; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String title;
  final String description;
  final String recommendation;
  final DateTime detectedAt;
  final List<String> triggerData;

  HealthRisk({
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.detectedAt,
    required this.triggerData,
  });
}

class HealthAnalyticsService {
  static const int _analysisWindowDays = 30;
  static const int _trendDataPoints = 5;

  // Analyze vital measurements for risks
  static List<HealthRisk> analyzeVitalMeasurements(
      List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];

    // Group measurements by type
    Map<String, List<VitalMeasurement>> groupedMeasurements = {};
    for (var measurement in measurements) {
      if (!groupedMeasurements.containsKey(measurement.type)) {
        groupedMeasurements[measurement.type] = [];
      }
      groupedMeasurements[measurement.type]!.add(measurement);
    }

    // Analyze each vital type
    for (var entry in groupedMeasurements.entries) {
      final type = entry.key;
      final typeMeasurements = entry.value;

      // Sort by date (most recent first)
      typeMeasurements.sort((a, b) => b.date.compareTo(a.date));

      // Get recent measurements within analysis window
      final recentMeasurements = typeMeasurements
          .where((m) =>
              DateTime.now().difference(m.date).inDays <= _analysisWindowDays)
          .toList();

      if (recentMeasurements.isNotEmpty) {
        // Analyze individual values
        risks.addAll(_analyzeIndividualValues(type, recentMeasurements));

        // Analyze trends if we have enough data points
        if (recentMeasurements.length >= _trendDataPoints) {
          risks.addAll(_analyzeTrends(type, recentMeasurements));
        }
      }
    }

    return risks;
  }

  // Analyze symptoms for risks
  static List<HealthRisk> analyzeSymptoms(List<Symptom> symptoms) {
    List<HealthRisk> risks = [];

    // Get recent symptoms
    final recentSymptoms = symptoms
        .where((s) =>
            DateTime.now().difference(s.date).inDays <= _analysisWindowDays)
        .toList();

    if (recentSymptoms.isEmpty) return risks;

    // Analyze high severity symptoms
    risks.addAll(_analyzeHighSeveritySymptoms(recentSymptoms));

    // Analyze symptom patterns
    risks.addAll(_analyzeSymptomPatterns(recentSymptoms));

    // Analyze symptom frequency
    risks.addAll(_analyzeSymptomFrequency(recentSymptoms));

    return risks;
  }

  // Analyze individual vital values for immediate risks
  static List<HealthRisk> _analyzeIndividualValues(
      String type, List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];
    final latest = measurements.first;

    switch (type) {
      case 'Blood Pressure':
        risks.addAll(_analyzeBloodPressure(latest));
        break;
      case 'Heart Rate':
        risks.addAll(_analyzeHeartRate(latest));
        break;
      case 'Temperature':
        risks.addAll(_analyzeTemperature(latest));
        break;
      case 'Blood Glucose':
        risks.addAll(_analyzeBloodGlucose(latest));
        break;
      case 'Oxygen Saturation':
        risks.addAll(_analyzeOxygenSaturation(latest));
        break;
    }

    return risks;
  }

  // Analyze trends for progressive risks
  static List<HealthRisk> _analyzeTrends(
      String type, List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];

    // Take most recent data points for trend analysis
    final trendData = measurements.take(_trendDataPoints).toList();

    switch (type) {
      case 'Blood Pressure':
        risks.addAll(_analyzeBloodPressureTrend(trendData));
        break;
      case 'Heart Rate':
        risks.addAll(_analyzeHeartRateTrend(trendData));
        break;
      case 'Weight':
        risks.addAll(_analyzeWeightTrend(trendData));
        break;
    }

    return risks;
  }

  // Blood pressure analysis
  static List<HealthRisk> _analyzeBloodPressure(VitalMeasurement measurement) {
    List<HealthRisk> risks = [];

    try {
      final parts = measurement.value.split(' ')[0].split('/');
      final systolic = int.parse(parts[0]);
      final diastolic = int.parse(parts[1]);

      if (systolic >= 180 || diastolic >= 120) {
        risks.add(HealthRisk(
          type: 'HYPERTENSIVE_CRISIS',
          severity: 'CRITICAL',
          title: 'Hypertensive Crisis Detected',
          description:
              'Your blood pressure reading of ${measurement.value} indicates a hypertensive crisis.',
          recommendation:
              'Seek immediate medical attention. This is a medical emergency.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (systolic >= 140 || diastolic >= 90) {
        risks.add(HealthRisk(
          type: 'HIGH_BLOOD_PRESSURE',
          severity: 'HIGH',
          title: 'High Blood Pressure Detected',
          description:
              'Your blood pressure reading of ${measurement.value} indicates hypertension.',
          recommendation:
              'Consult your healthcare provider to discuss blood pressure management.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (systolic < 90 || diastolic < 60) {
        risks.add(HealthRisk(
          type: 'LOW_BLOOD_PRESSURE',
          severity: 'MEDIUM',
          title: 'Low Blood Pressure Detected',
          description:
              'Your blood pressure reading of ${measurement.value} is below normal range.',
          recommendation:
              'Monitor your symptoms. If you experience dizziness or fainting, consult your healthcare provider.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      }
    } catch (e) {
      // Invalid blood pressure format
    }

    return risks;
  }

  // Heart rate analysis
  static List<HealthRisk> _analyzeHeartRate(VitalMeasurement measurement) {
    List<HealthRisk> risks = [];

    try {
      final heartRate = int.parse(measurement.value.split(' ')[0]);

      if (heartRate > 100) {
        String severity = heartRate > 120 ? 'HIGH' : 'MEDIUM';
        risks.add(HealthRisk(
          type: 'TACHYCARDIA',
          severity: severity,
          title: 'Elevated Heart Rate',
          description:
              'Your heart rate of $heartRate bpm is above the normal resting range.',
          recommendation: heartRate > 120
              ? 'Consider consulting with your healthcare provider if this persists or you experience symptoms.'
              : 'Monitor your heart rate and consider lifestyle factors that may contribute to elevation.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (heartRate < 60) {
        risks.add(HealthRisk(
          type: 'BRADYCARDIA',
          severity: 'MEDIUM',
          title: 'Low Heart Rate',
          description:
              'Your heart rate of $heartRate bpm is below the normal resting range.',
          recommendation:
              'Unless you are an athlete, consider consulting with your healthcare provider.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      }
    } catch (e) {
      // Invalid heart rate format
    }

    return risks;
  }

  // Temperature analysis
  static List<HealthRisk> _analyzeTemperature(VitalMeasurement measurement) {
    List<HealthRisk> risks = [];

    try {
      final temp = double.parse(measurement.value.split(' ')[0]);

      if (temp >= 38.0) {
        String severity = temp >= 39.0 ? 'HIGH' : 'MEDIUM';
        risks.add(HealthRisk(
          type: 'FEVER',
          severity: severity,
          title: 'Fever Detected',
          description: 'Your temperature of ${temp}°C indicates a fever.',
          recommendation: temp >= 39.0
              ? 'High fever detected. Consider seeking medical attention if symptoms persist or worsen.'
              : 'Monitor your symptoms and ensure adequate rest and hydration.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (temp < 36.1) {
        risks.add(HealthRisk(
          type: 'HYPOTHERMIA',
          severity: 'MEDIUM',
          title: 'Low Body Temperature',
          description: 'Your temperature of ${temp}°C is below normal range.',
          recommendation:
              'Monitor for symptoms and consider consulting with your healthcare provider if this persists.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      }
    } catch (e) {
      // Invalid temperature format
    }

    return risks;
  }

  // Blood glucose analysis
  static List<HealthRisk> _analyzeBloodGlucose(VitalMeasurement measurement) {
    List<HealthRisk> risks = [];

    try {
      final glucose = int.parse(measurement.value.split(' ')[0]);

      if (glucose >= 200) {
        risks.add(HealthRisk(
          type: 'SEVERE_HYPERGLYCEMIA',
          severity: 'CRITICAL',
          title: 'Severely High Blood Sugar',
          description:
              'Your blood glucose of $glucose mg/dL is critically high.',
          recommendation:
              'Seek immediate medical attention. This requires urgent treatment.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (glucose >= 126) {
        risks.add(HealthRisk(
          type: 'HYPERGLYCEMIA',
          severity: 'HIGH',
          title: 'High Blood Sugar',
          description:
              'Your blood glucose of $glucose mg/dL is above normal range.',
          recommendation:
              'Consult with your healthcare provider about blood sugar management.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (glucose < 70) {
        String severity = glucose < 54 ? 'CRITICAL' : 'HIGH';
        risks.add(HealthRisk(
          type: 'HYPOGLYCEMIA',
          severity: severity,
          title: 'Low Blood Sugar',
          description:
              'Your blood glucose of $glucose mg/dL is below normal range.',
          recommendation: glucose < 54
              ? 'Severe hypoglycemia detected. Treat immediately and seek medical attention.'
              : 'Consider consuming a fast-acting carbohydrate and monitor closely.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      }
    } catch (e) {
      // Invalid glucose format
    }

    return risks;
  }

  // Oxygen saturation analysis
  static List<HealthRisk> _analyzeOxygenSaturation(
      VitalMeasurement measurement) {
    List<HealthRisk> risks = [];

    try {
      final saturation = int.parse(measurement.value.split(' ')[0]);

      if (saturation < 90) {
        risks.add(HealthRisk(
          type: 'SEVERE_HYPOXEMIA',
          severity: 'CRITICAL',
          title: 'Critically Low Oxygen Saturation',
          description:
              'Your oxygen saturation of $saturation% is critically low.',
          recommendation:
              'Seek immediate medical attention. This is a medical emergency.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      } else if (saturation < 95) {
        risks.add(HealthRisk(
          type: 'HYPOXEMIA',
          severity: 'HIGH',
          title: 'Low Oxygen Saturation',
          description:
              'Your oxygen saturation of $saturation% is below normal range.',
          recommendation:
              'Consider consulting with your healthcare provider, especially if you experience breathing difficulties.',
          detectedAt: DateTime.now(),
          triggerData: [measurement.value],
        ));
      }
    } catch (e) {
      // Invalid saturation format
    }

    return risks;
  }

  // Trend analysis methods
  static List<HealthRisk> _analyzeBloodPressureTrend(
      List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];

    try {
      List<int> systolicValues = [];
      List<int> diastolicValues = [];

      for (var measurement in measurements) {
        final parts = measurement.value.split(' ')[0].split('/');
        systolicValues.add(int.parse(parts[0]));
        diastolicValues.add(int.parse(parts[1]));
      }

      // Check for consistent upward trend
      if (_isIncreasingTrend(systolicValues) ||
          _isIncreasingTrend(diastolicValues)) {
        risks.add(HealthRisk(
          type: 'BP_INCREASING_TREND',
          severity: 'MEDIUM',
          title: 'Rising Blood Pressure Trend',
          description:
              'Your blood pressure has been consistently increasing over recent measurements.',
          recommendation:
              'Monitor your blood pressure closely and consider lifestyle changes. Consult your healthcare provider if the trend continues.',
          detectedAt: DateTime.now(),
          triggerData: measurements.map((m) => m.value).toList(),
        ));
      }
    } catch (e) {
      // Error parsing blood pressure values
    }

    return risks;
  }

  static List<HealthRisk> _analyzeHeartRateTrend(
      List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];

    try {
      List<int> heartRates = [];

      for (var measurement in measurements) {
        heartRates.add(int.parse(measurement.value.split(' ')[0]));
      }

      // Check for consistent upward trend
      if (_isIncreasingTrend(heartRates)) {
        risks.add(HealthRisk(
          type: 'HR_INCREASING_TREND',
          severity: 'MEDIUM',
          title: 'Rising Heart Rate Trend',
          description:
              'Your resting heart rate has been consistently increasing over recent measurements.',
          recommendation:
              'Consider factors that may be affecting your heart rate such as stress, caffeine, or physical activity. Consult your healthcare provider if concerned.',
          detectedAt: DateTime.now(),
          triggerData: measurements.map((m) => m.value).toList(),
        ));
      }
    } catch (e) {
      // Error parsing heart rate values
    }

    return risks;
  }

  static List<HealthRisk> _analyzeWeightTrend(
      List<VitalMeasurement> measurements) {
    List<HealthRisk> risks = [];

    try {
      List<double> weights = [];

      for (var measurement in measurements) {
        weights.add(double.parse(measurement.value.split(' ')[0]));
      }

      if (weights.length < 3) return risks;

      // Calculate weight change percentage
      final latestWeight = weights.first;
      final earliestWeight = weights.last;
      final weightChangePercent =
          ((latestWeight - earliestWeight) / earliestWeight) * 100;

      if (weightChangePercent.abs() > 5) {
        String type =
            weightChangePercent > 0 ? 'RAPID_WEIGHT_GAIN' : 'RAPID_WEIGHT_LOSS';
        String title =
            weightChangePercent > 0 ? 'Rapid Weight Gain' : 'Rapid Weight Loss';
        String description =
            'You have ${weightChangePercent > 0 ? 'gained' : 'lost'} ${weightChangePercent.abs().toStringAsFixed(1)}% of your body weight recently.';

        risks.add(HealthRisk(
          type: type,
          severity: 'MEDIUM',
          title: title,
          description: description,
          recommendation:
              'Significant weight changes should be discussed with your healthcare provider to rule out underlying conditions.',
          detectedAt: DateTime.now(),
          triggerData: measurements.map((m) => m.value).toList(),
        ));
      }
    } catch (e) {
      // Error parsing weight values
    }

    return risks;
  }

  // Symptom analysis methods
  static List<HealthRisk> _analyzeHighSeveritySymptoms(List<Symptom> symptoms) {
    List<HealthRisk> risks = [];

    final highSeveritySymptoms =
        symptoms.where((s) => s.severity >= 4).toList();

    for (var symptom in highSeveritySymptoms) {
      risks.add(HealthRisk(
        type: 'HIGH_SEVERITY_SYMPTOM',
        severity: symptom.severity == 5 ? 'HIGH' : 'MEDIUM',
        title: 'High Severity ${symptom.name}',
        description:
            'You reported experiencing ${symptom.name} with severity ${symptom.severity}/5.',
        recommendation:
            _getSymptomRecommendation(symptom.name, symptom.severity),
        detectedAt: DateTime.now(),
        triggerData: ['${symptom.name} (${symptom.severity}/5)'],
      ));
    }

    return risks;
  }

  static List<HealthRisk> _analyzeSymptomPatterns(List<Symptom> symptoms) {
    List<HealthRisk> risks = [];

    // Group symptoms by name
    Map<String, List<Symptom>> groupedSymptoms = {};
    for (var symptom in symptoms) {
      if (!groupedSymptoms.containsKey(symptom.name)) {
        groupedSymptoms[symptom.name] = [];
      }
      groupedSymptoms[symptom.name]!.add(symptom);
    }

    // Check for recurring symptoms
    for (var entry in groupedSymptoms.entries) {
      final symptomName = entry.key;
      final symptomList = entry.value;

      if (symptomList.length >= 3) {
        risks.add(HealthRisk(
          type: 'RECURRING_SYMPTOM',
          severity: 'MEDIUM',
          title: 'Recurring $symptomName',
          description:
              'You have reported $symptomName ${symptomList.length} times in the past month.',
          recommendation:
              'Recurring symptoms should be evaluated by a healthcare provider to identify potential underlying causes.',
          detectedAt: DateTime.now(),
          triggerData:
              symptomList.map((s) => '${s.name} (${s.severity}/5)').toList(),
        ));
      }
    }

    return risks;
  }

  static List<HealthRisk> _analyzeSymptomFrequency(List<Symptom> symptoms) {
    List<HealthRisk> risks = [];

    // Check for high frequency of any symptoms
    if (symptoms.length >= 10) {
      risks.add(HealthRisk(
        type: 'HIGH_SYMPTOM_FREQUENCY',
        severity: 'MEDIUM',
        title: 'Frequent Symptom Reporting',
        description:
            'You have reported ${symptoms.length} symptoms in the past month.',
        recommendation:
            'Frequent symptoms may indicate an underlying health condition. Consider scheduling a comprehensive health evaluation.',
        detectedAt: DateTime.now(),
        triggerData:
            symptoms.map((s) => '${s.name} (${s.severity}/5)').toList(),
      ));
    }

    return risks;
  }

  // Helper methods
  static bool _isIncreasingTrend(List<int> values) {
    if (values.length < 3) return false;

    int increasingCount = 0;
    for (int i = 1; i < values.length; i++) {
      if (values[i - 1] > values[i]) {
        // Note: values are in reverse chronological order
        increasingCount++;
      }
    }

    return increasingCount >=
        (values.length - 1) * 0.7; // 70% of comparisons show increase
  }

  static String _getSymptomRecommendation(String symptomName, int severity) {
    final urgentSymptoms = [
      'Chest Pain',
      'Difficulty Breathing',
      'Severe Headache',
      'Vision Changes',
      'Sudden Numbness',
      'Severe Abdominal Pain'
    ];

    if (urgentSymptoms.any(
        (urgent) => symptomName.toLowerCase().contains(urgent.toLowerCase()))) {
      return 'This symptom can be serious. Consider seeking immediate medical attention.';
    } else if (severity == 5) {
      return 'Severe symptoms should be evaluated by a healthcare provider promptly.';
    } else {
      return 'Consider consulting with a healthcare provider about this symptom, especially if it persists or worsens.';
    }
  }
}
