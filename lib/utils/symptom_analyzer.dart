class SymptomAnalyzer {
  // Map common symptoms to medical specialties
  static Map<String, String> symptomToSpecialty = {
    // Cardiovascular symptoms
    'Chest Pain': 'Cardiologist',
    'Heart Palpitations': 'Cardiologist',
    'Shortness of Breath': 'Cardiologist',
    'High Blood Pressure': 'Cardiologist',

    // Respiratory symptoms
    'Cough': 'Pulmonologist',
    'Wheezing': 'Pulmonologist',
    'Difficulty Breathing': 'Pulmonologist',

    // Gastrointestinal symptoms
    'Abdominal Pain': 'Gastroenterologist',
    'Nausea': 'Gastroenterologist',
    'Vomiting': 'Gastroenterologist',
    'Diarrhea': 'Gastroenterologist',
    'Constipation': 'Gastroenterologist',

    // Neurological symptoms
    'Headache': 'Neurologist',
    'Dizziness': 'Neurologist',
    'Numbness': 'Neurologist',
    'Tingling': 'Neurologist',
    'Seizures': 'Neurologist',

    // Musculoskeletal symptoms
    'Joint Pain': 'Orthopedist',
    'Muscle Pain': 'Orthopedist',
    'Back Pain': 'Orthopedist',
    'Swelling': 'Orthopedist',

    // Dermatological symptoms
    'Rash': 'Dermatologist',
    'Itching': 'Dermatologist',
    'Skin Lesions': 'Dermatologist',

    // ENT symptoms
    'Sore Throat': 'Otolaryngologist',
    'Ear Pain': 'Otolaryngologist',
    'Hearing Loss': 'Otolaryngologist',
    'Nasal Congestion': 'Otolaryngologist',

    // Ophthalmological symptoms
    'Eye Pain': 'Ophthalmologist',
    'Vision Changes': 'Ophthalmologist',
    'Red Eye': 'Ophthalmologist',

    // Urological symptoms
    'Urinary Problems': 'Urologist',
    'Flank Pain': 'Urologist',

    // Endocrine symptoms
    'Fatigue': 'Endocrinologist',
    'Weight Changes': 'Endocrinologist',
    'Excessive Thirst': 'Endocrinologist',
    'Excessive Hunger': 'Endocrinologist',

    // General symptoms
    'Fever': 'General Practitioner',
    'Loss of Taste/Smell': 'General Practitioner',
  };

  // Determine if a symptom requires urgent attention based on severity and type
  static bool isUrgent(String symptom, int severity) {
    // High severity symptoms (4-5) are generally considered urgent
    if (severity >= 4) {
      return true;
    }

    // Specific symptoms that are urgent regardless of severity
    List<String> urgentSymptoms = [
      'Chest Pain',
      'Shortness of Breath',
      'Difficulty Breathing',
      'Seizures',
      'Severe Headache',
      'Vision Changes',
      'Sudden Numbness',
      'Severe Abdominal Pain'
    ];

    return urgentSymptoms.contains(symptom);
  }

  // Get recommended specialist based on symptom
  static String getRecommendedSpecialist(String symptom) {
    return symptomToSpecialty[symptom] ?? 'General Practitioner';
  }

  // Get recommendation message based on symptom and severity
  static String getRecommendationMessage(String symptom, int severity) {
    String specialist = getRecommendedSpecialist(symptom);

    if (isUrgent(symptom, severity)) {
      return 'Your $symptom symptom requires prompt attention. We recommend seeing a $specialist as soon as possible.';
    } else if (severity >= 3) {
      return 'Based on your $symptom symptom, we recommend consulting a $specialist.';
    } else {
      return 'Consider consulting a $specialist about your $symptom if it persists or worsens.';
    }
  }
}
