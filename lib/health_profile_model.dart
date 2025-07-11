class HealthCondition {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String category;
  final String categoryAr;
  final List<String> conflictingMedicines;
  final List<String> symptoms;
  final String severity; // mild, moderate, severe

  HealthCondition({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.category,
    required this.categoryAr,
    required this.conflictingMedicines,
    required this.symptoms,
    required this.severity,
  });

  factory HealthCondition.fromFirestore(Map<String, dynamic> data, String id) {
    return HealthCondition(
      id: id,
      nameEn: data['nameEn'] ?? '',
      nameAr: data['nameAr'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      category: data['category'] ?? '',
      categoryAr: data['categoryAr'] ?? '',
      conflictingMedicines: List<String>.from(data['conflictingMedicines'] ?? []),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      severity: data['severity'] ?? 'mild',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameAr': nameAr,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'category': category,
      'categoryAr': categoryAr,
      'conflictingMedicines': conflictingMedicines,
      'symptoms': symptoms,
      'severity': severity,
    };
  }
}

class UserHealthProfile {
  final String userId;
  final List<String> healthConditions;
  final List<String> currentMedications;
  final List<String> allergies;
  final String bloodType;
  final double weight;
  final int age;
  final String gender;
  final List<String> emergencyContacts;

  UserHealthProfile({
    required this.userId,
    required this.healthConditions,
    required this.currentMedications,
    required this.allergies,
    required this.bloodType,
    required this.weight,
    required this.age,
    required this.gender,
    required this.emergencyContacts,
  });

  factory UserHealthProfile.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserHealthProfile(
      userId: userId,
      healthConditions: List<String>.from(data['healthConditions'] ?? []),
      currentMedications: List<String>.from(data['currentMedications'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      bloodType: data['bloodType'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      emergencyContacts: List<String>.from(data['emergencyContacts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'healthConditions': healthConditions,
      'currentMedications': currentMedications,
      'allergies': allergies,
      'bloodType': bloodType,
      'weight': weight,
      'age': age,
      'gender': gender,
      'emergencyContacts': emergencyContacts,
    };
  }

  UserHealthProfile copyWith({
    List<String>? healthConditions,
    List<String>? currentMedications,
    List<String>? allergies,
    String? bloodType,
    double? weight,
    int? age,
    String? gender,
    List<String>? emergencyContacts,
  }) {
    return UserHealthProfile(
      userId: userId,
      healthConditions: healthConditions ?? this.healthConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      allergies: allergies ?? this.allergies,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}

class MedicineInteraction {
  final String medicineName;
  final String healthCondition;
  final String severity; // low, moderate, high
  final String descriptionEn;
  final String descriptionAr;
  final String recommendationEn;
  final String recommendationAr;

  MedicineInteraction({
    required this.medicineName,
    required this.healthCondition,
    required this.severity,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.recommendationEn,
    required this.recommendationAr,
  });

  factory MedicineInteraction.fromFirestore(Map<String, dynamic> data) {
    return MedicineInteraction(
      medicineName: data['medicineName'] ?? '',
      healthCondition: data['healthCondition'] ?? '',
      severity: data['severity'] ?? 'low',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      recommendationEn: data['recommendationEn'] ?? '',
      recommendationAr: data['recommendationAr'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'healthCondition': healthCondition,
      'severity': severity,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'recommendationEn': recommendationEn,
      'recommendationAr': recommendationAr,
    };
  }
} 