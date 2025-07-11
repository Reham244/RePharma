import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'health_profile_model.dart';

class HealthProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId {
    final user = _auth.currentUser;
    print('Current user: ${user?.uid}'); // Debug log
    return user?.uid;
  }

  // Health Profile Operations
  static Future<UserHealthProfile?> getUserHealthProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('userHealthProfiles')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('Loaded health profile data: $data'); // Debug log
        return UserHealthProfile.fromFirestore(data, userId);
      } else {
        print('No health profile found, creating new one for user: $userId'); // Debug log
        // Create a new health profile if it doesn't exist
        final newProfile = UserHealthProfile(
          userId: userId,
          healthConditions: [],
          currentMedications: [],
          allergies: [],
          bloodType: '',
          weight: 0.0,
          age: 0,
          gender: '',
          emergencyContacts: [],
        );
        await saveUserHealthProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      print('Error getting user health profile: $e');
      return null;
    }
  }

  static Future<void> saveUserHealthProfile(UserHealthProfile profile) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('userHealthProfiles')
          .doc(userId)
          .set(profile.toMap());
    } catch (e) {
      print('Error saving user health profile: $e');
      rethrow;
    }
  }

  static Future<void> updateUserHealthProfile(UserHealthProfile profile) async {
    final userId = currentUserId;
    if (userId == null) {
      print('No user ID found, cannot save profile');
      throw Exception('User not authenticated');
    }

    try {
      final data = profile.toMap();
      print('Saving health profile for user: $userId'); // Debug log
      print('Profile data: $data'); // Debug log
      
      await _firestore
          .collection('userHealthProfiles')
          .doc(userId)
          .set(data, SetOptions(merge: true)); // Use merge to preserve existing data
      
      print('Health profile saved successfully for user: $userId'); // Debug log
    } catch (e) {
      print('Error updating user health profile: $e');
      rethrow;
    }
  }

  // Health Conditions Operations
  static Future<List<HealthCondition>> getAllHealthConditions() async {
    try {
      // First try to get from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('healthConditions')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => HealthCondition.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList();
      }

      // If no data in Firestore, return comprehensive local data
      return _getComprehensiveHealthConditions();
    } catch (e) {
      print('Error getting health conditions: $e');
      return _getComprehensiveHealthConditions();
    }
  }

  // Comprehensive health conditions data
  static List<HealthCondition> _getComprehensiveHealthConditions() {
    return [
      // Cardiovascular Conditions
      HealthCondition(
        id: 'hypertension',
        nameEn: 'Hypertension (High Blood Pressure)',
        nameAr: 'ارتفاع ضغط الدم',
        descriptionEn: 'Persistently elevated blood pressure',
        descriptionAr: 'ارتفاع مستمر في ضغط الدم',
        category: 'Cardiovascular',
        categoryAr: 'أمراض القلب والأوعية الدموية',
        conflictingMedicines: ['Ibuprofen', 'Naproxen', 'Decongestants', 'Caffeine'],
        symptoms: ['Headache', 'Dizziness', 'Chest pain', 'Shortness of breath'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'heart_disease',
        nameEn: 'Heart Disease',
        nameAr: 'أمراض القلب',
        descriptionEn: 'Various conditions affecting the heart',
        descriptionAr: 'حالات مختلفة تؤثر على القلب',
        category: 'Cardiovascular',
        categoryAr: 'أمراض القلب والأوعية الدموية',
        conflictingMedicines: ['Viagra', 'Nitrates', 'Beta-blockers'],
        symptoms: ['Chest pain', 'Shortness of breath', 'Fatigue', 'Swelling'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'arrhythmia',
        nameEn: 'Heart Arrhythmia',
        nameAr: 'عدم انتظام ضربات القلب',
        descriptionEn: 'Irregular heartbeat',
        descriptionAr: 'عدم انتظام ضربات القلب',
        category: 'Cardiovascular',
        categoryAr: 'أمراض القلب والأوعية الدموية',
        conflictingMedicines: ['Caffeine', 'Alcohol', 'Beta-blockers'],
        symptoms: ['Irregular heartbeat', 'Dizziness', 'Fainting', 'Chest pain'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'stroke_history',
        nameEn: 'Stroke History',
        nameAr: 'تاريخ السكتة الدماغية',
        descriptionEn: 'Previous stroke occurrence',
        descriptionAr: 'حدوث سكتة دماغية سابقة',
        category: 'Cardiovascular',
        categoryAr: 'أمراض القلب والأوعية الدموية',
        conflictingMedicines: ['Warfarin', 'Aspirin', 'NSAIDs'],
        symptoms: ['Weakness', 'Numbness', 'Speech problems', 'Vision changes'],
        severity: 'severe',
      ),

      // Endocrine Conditions
      HealthCondition(
        id: 'diabetes',
        nameEn: 'Diabetes',
        nameAr: 'مرض السكري',
        descriptionEn: 'High blood sugar levels',
        descriptionAr: 'ارتفاع مستويات السكر في الدم',
        category: 'Endocrine',
        categoryAr: 'أمراض الغدد الصماء',
        conflictingMedicines: ['Corticosteroids', 'Beta-blockers', 'Thiazide diuretics'],
        symptoms: ['Frequent urination', 'Increased thirst', 'Fatigue', 'Blurred vision'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'thyroid_disorder',
        nameEn: 'Thyroid Disorder',
        nameAr: 'اضطراب الغدة الدرقية',
        descriptionEn: 'Abnormal thyroid function',
        descriptionAr: 'وظيفة غير طبيعية للغدة الدرقية',
        category: 'Endocrine',
        categoryAr: 'أمراض الغدد الصماء',
        conflictingMedicines: ['Iron supplements', 'Calcium', 'Soy products'],
        symptoms: ['Fatigue', 'Weight changes', 'Mood changes', 'Temperature sensitivity'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'adrenal_disorder',
        nameEn: 'Adrenal Disorder',
        nameAr: 'اضطراب الغدة الكظرية',
        descriptionEn: 'Abnormal adrenal gland function',
        descriptionAr: 'وظيفة غير طبيعية للغدة الكظرية',
        category: 'Endocrine',
        categoryAr: 'أمراض الغدد الصماء',
        conflictingMedicines: ['Corticosteroids', 'Diuretics'],
        symptoms: ['Fatigue', 'Weight loss', 'Low blood pressure', 'Darkening skin'],
        severity: 'moderate',
      ),

      // Respiratory Conditions
      HealthCondition(
        id: 'asthma',
        nameEn: 'Asthma',
        nameAr: 'الربو',
        descriptionEn: 'Chronic respiratory condition',
        descriptionAr: 'حالة تنفسية مزمنة',
        category: 'Respiratory',
        categoryAr: 'أمراض الجهاز التنفسي',
        conflictingMedicines: ['Aspirin', 'NSAIDs', 'Beta-blockers'],
        symptoms: ['Wheezing', 'Coughing', 'Shortness of breath', 'Chest tightness'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'copd',
        nameEn: 'COPD',
        nameAr: 'مرض الانسداد الرئوي المزمن',
        descriptionEn: 'Chronic obstructive pulmonary disease',
        descriptionAr: 'مرض الانسداد الرئوي المزمن',
        category: 'Respiratory',
        categoryAr: 'أمراض الجهاز التنفسي',
        conflictingMedicines: ['Beta-blockers', 'Sedatives'],
        symptoms: ['Shortness of breath', 'Chronic cough', 'Wheezing', 'Chest tightness'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'bronchitis',
        nameEn: 'Chronic Bronchitis',
        nameAr: 'التهاب الشعب الهوائية المزمن',
        descriptionEn: 'Chronic inflammation of bronchial tubes',
        descriptionAr: 'التهاب مزمن في الشعب الهوائية',
        category: 'Respiratory',
        categoryAr: 'أمراض الجهاز التنفسي',
        conflictingMedicines: ['Beta-blockers', 'ACE inhibitors'],
        symptoms: ['Persistent cough', 'Mucus production', 'Shortness of breath'],
        severity: 'moderate',
      ),

      // Gastrointestinal Conditions
      HealthCondition(
        id: 'ulcer',
        nameEn: 'Peptic Ulcer',
        nameAr: 'قرحة المعدة',
        descriptionEn: 'Sores in the stomach lining',
        descriptionAr: 'قروح في بطانة المعدة',
        category: 'Gastrointestinal',
        categoryAr: 'أمراض الجهاز الهضمي',
        conflictingMedicines: ['NSAIDs', 'Aspirin', 'Corticosteroids'],
        symptoms: ['Abdominal pain', 'Nausea', 'Bloating', 'Heartburn'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'ibd',
        nameEn: 'Inflammatory Bowel Disease',
        nameAr: 'مرض التهاب الأمعاء',
        descriptionEn: 'Chronic inflammation of digestive tract',
        descriptionAr: 'التهاب مزمن في الجهاز الهضمي',
        category: 'Gastrointestinal',
        categoryAr: 'أمراض الجهاز الهضمي',
        conflictingMedicines: ['NSAIDs', 'Antibiotics'],
        symptoms: ['Abdominal pain', 'Diarrhea', 'Weight loss', 'Fatigue'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'gastritis',
        nameEn: 'Gastritis',
        nameAr: 'التهاب المعدة',
        descriptionEn: 'Inflammation of stomach lining',
        descriptionAr: 'التهاب بطانة المعدة',
        category: 'Gastrointestinal',
        categoryAr: 'أمراض الجهاز الهضمي',
        conflictingMedicines: ['NSAIDs', 'Aspirin', 'Alcohol'],
        symptoms: ['Abdominal pain', 'Nausea', 'Vomiting', 'Loss of appetite'],
        severity: 'moderate',
      ),

      // Neurological Conditions
      HealthCondition(
        id: 'epilepsy',
        nameEn: 'Epilepsy',
        nameAr: 'الصرع',
        descriptionEn: 'Neurological disorder causing seizures',
        descriptionAr: 'اضطراب عصبي يسبب نوبات',
        category: 'Neurological',
        categoryAr: 'أمراض عصبية',
        conflictingMedicines: ['Tramadol', 'Bupropion', 'Alcohol'],
        symptoms: ['Seizures', 'Loss of consciousness', 'Staring spells'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'migraine',
        nameEn: 'Migraine',
        nameAr: 'الصداع النصفي',
        descriptionEn: 'Severe recurring headaches',
        descriptionAr: 'صداع شديد متكرر',
        category: 'Neurological',
        categoryAr: 'أمراض عصبية',
        conflictingMedicines: ['Oral contraceptives', 'Vasodilators'],
        symptoms: ['Severe headache', 'Nausea', 'Sensitivity to light', 'Aura'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'parkinsons',
        nameEn: 'Parkinson\'s Disease',
        nameAr: 'مرض باركنسون',
        descriptionEn: 'Progressive nervous system disorder',
        descriptionAr: 'اضطراب تدريجي في الجهاز العصبي',
        category: 'Neurological',
        categoryAr: 'أمراض عصبية',
        conflictingMedicines: ['Antipsychotics', 'Metoclopramide'],
        symptoms: ['Tremors', 'Slow movement', 'Stiffness', 'Balance problems'],
        severity: 'severe',
      ),

      // Mental Health Conditions
      HealthCondition(
        id: 'depression',
        nameEn: 'Depression',
        nameAr: 'الاكتئاب',
        descriptionEn: 'Mental health condition',
        descriptionAr: 'حالة صحية نفسية',
        category: 'Mental Health',
        categoryAr: 'الصحة النفسية',
        conflictingMedicines: ['MAOIs', 'St. John\'s Wort', 'Alcohol'],
        symptoms: ['Sadness', 'Loss of interest', 'Fatigue', 'Sleep changes'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'anxiety',
        nameEn: 'Anxiety',
        nameAr: 'القلق',
        descriptionEn: 'Mental health condition with excessive worry',
        descriptionAr: 'حالة صحية نفسية مع قلق مفرط',
        category: 'Mental Health',
        categoryAr: 'الصحة النفسية',
        conflictingMedicines: ['Caffeine', 'Stimulants', 'Alcohol'],
        symptoms: ['Excessive worry', 'Restlessness', 'Rapid heartbeat', 'Sweating'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'bipolar',
        nameEn: 'Bipolar Disorder',
        nameAr: 'الاضطراب ثنائي القطب',
        descriptionEn: 'Mood disorder with extreme highs and lows',
        descriptionAr: 'اضطراب مزاجي مع تقلبات شديدة',
        category: 'Mental Health',
        categoryAr: 'الصحة النفسية',
        conflictingMedicines: ['Antidepressants', 'Stimulants'],
        symptoms: ['Mood swings', 'Energy changes', 'Sleep problems', 'Racing thoughts'],
        severity: 'severe',
      ),

      // Renal Conditions
      HealthCondition(
        id: 'kidney_disease',
        nameEn: 'Kidney Disease',
        nameAr: 'أمراض الكلى',
        descriptionEn: 'Impaired kidney function',
        descriptionAr: 'ضعف وظائف الكلى',
        category: 'Renal',
        categoryAr: 'أمراض الكلى',
        conflictingMedicines: ['NSAIDs', 'Aminoglycosides', 'Contrast dyes'],
        symptoms: ['Fatigue', 'Swelling', 'Changes in urination', 'Nausea'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'kidney_stones',
        nameEn: 'Kidney Stones',
        nameAr: 'حصوات الكلى',
        descriptionEn: 'Hard deposits in kidneys',
        descriptionAr: 'ترسبات صلبة في الكلى',
        category: 'Renal',
        categoryAr: 'أمراض الكلى',
        conflictingMedicines: ['Calcium supplements', 'Vitamin D'],
        symptoms: ['Severe pain', 'Blood in urine', 'Nausea', 'Frequent urination'],
        severity: 'moderate',
      ),

      // Hepatic Conditions
      HealthCondition(
        id: 'liver_disease',
        nameEn: 'Liver Disease',
        nameAr: 'أمراض الكبد',
        descriptionEn: 'Impaired liver function',
        descriptionAr: 'ضعف وظائف الكبد',
        category: 'Hepatic',
        categoryAr: 'أمراض الكبد',
        conflictingMedicines: ['Acetaminophen', 'Statins', 'Alcohol'],
        symptoms: ['Jaundice', 'Abdominal pain', 'Fatigue', 'Nausea'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'hepatitis',
        nameEn: 'Hepatitis',
        nameAr: 'التهاب الكبد',
        descriptionEn: 'Liver inflammation',
        descriptionAr: 'التهاب الكبد',
        category: 'Hepatic',
        categoryAr: 'أمراض الكبد',
        conflictingMedicines: ['Acetaminophen', 'Alcohol', 'Certain antibiotics'],
        symptoms: ['Jaundice', 'Fatigue', 'Abdominal pain', 'Loss of appetite'],
        severity: 'severe',
      ),

      // Ophthalmological Conditions
      HealthCondition(
        id: 'glaucoma',
        nameEn: 'Glaucoma',
        nameAr: 'الزرق',
        descriptionEn: 'Eye condition with increased pressure',
        descriptionAr: 'حالة في العين مع زيادة الضغط',
        category: 'Ophthalmological',
        categoryAr: 'أمراض العيون',
        conflictingMedicines: ['Anticholinergics', 'Corticosteroids'],
        symptoms: ['Vision loss', 'Eye pain', 'Headaches', 'Nausea'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'cataracts',
        nameEn: 'Cataracts',
        nameAr: 'إعتام عدسة العين',
        descriptionEn: 'Clouding of the eye lens',
        descriptionAr: 'تعتم عدسة العين',
        category: 'Ophthalmological',
        categoryAr: 'أمراض العيون',
        conflictingMedicines: ['Corticosteroids'],
        symptoms: ['Blurred vision', 'Sensitivity to light', 'Difficulty seeing at night'],
        severity: 'moderate',
      ),

      // Obstetric Conditions
      HealthCondition(
        id: 'pregnancy',
        nameEn: 'Pregnancy',
        nameAr: 'الحمل',
        descriptionEn: 'Pregnant state',
        descriptionAr: 'حالة الحمل',
        category: 'Obstetric',
        categoryAr: 'أمراض النساء والتوليد',
        conflictingMedicines: ['ACE inhibitors', 'Warfarin', 'Isotretinoin'],
        symptoms: ['Nausea', 'Fatigue', 'Breast tenderness', 'Frequent urination'],
        severity: 'moderate',
      ),
      HealthCondition(
        id: 'breastfeeding',
        nameEn: 'Breastfeeding',
        nameAr: 'الرضاعة الطبيعية',
        descriptionEn: 'Currently breastfeeding',
        descriptionAr: 'الرضاعة الطبيعية حالياً',
        category: 'Obstetric',
        categoryAr: 'أمراض النساء والتوليد',
        conflictingMedicines: ['Codeine', 'Lithium', 'Radioactive iodine'],
        symptoms: ['Breast tenderness', 'Milk production', 'Fatigue'],
        severity: 'moderate',
      ),

      // Allergic Conditions
      HealthCondition(
        id: 'drug_allergies',
        nameEn: 'Drug Allergies',
        nameAr: 'حساسية الأدوية',
        descriptionEn: 'Allergic reactions to medications',
        descriptionAr: 'ردود فعل تحسسية للأدوية',
        category: 'Allergic',
        categoryAr: 'الحساسية',
        conflictingMedicines: ['Penicillin', 'Sulfa drugs', 'Aspirin'],
        symptoms: ['Rash', 'Itching', 'Swelling', 'Difficulty breathing'],
        severity: 'severe',
      ),
      HealthCondition(
        id: 'food_allergies',
        nameEn: 'Food Allergies',
        nameAr: 'حساسية الطعام',
        descriptionEn: 'Allergic reactions to foods',
        descriptionAr: 'ردود فعل تحسسية للأطعمة',
        category: 'Allergic',
        categoryAr: 'الحساسية',
        conflictingMedicines: ['Certain supplements', 'Herbal medicines'],
        symptoms: ['Hives', 'Swelling', 'Difficulty breathing', 'Anaphylaxis'],
        severity: 'severe',
      ),
    ];
  }

  static Future<List<HealthCondition>> getHealthConditionsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('healthConditions')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => HealthCondition.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error getting health conditions by category: $e');
      return [];
    }
  }

  // Medicine Interactions
  static Future<List<MedicineInteraction>> getMedicineInteractions(String medicineName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('medicineInteractions')
          .where('medicineName', isEqualTo: medicineName)
          .get();

      return snapshot.docs
          .map((doc) => MedicineInteraction.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      print('Error getting medicine interactions: $e');
      return [];
    }
  }

  // Check for medicine conflicts with user's health conditions
  static Future<List<MedicineInteraction>> checkMedicineConflicts(
    String medicineName,
    List<String> userHealthConditions,
  ) async {
    try {
      List<MedicineInteraction> conflicts = [];

      for (String condition in userHealthConditions) {
        QuerySnapshot snapshot = await _firestore
            .collection('medicineInteractions')
            .where('medicineName', isEqualTo: medicineName)
            .where('healthCondition', isEqualTo: condition)
            .get();

        conflicts.addAll(
          snapshot.docs
              .map((doc) => MedicineInteraction.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                  ))
              .toList(),
        );
      }

      return conflicts;
    } catch (e) {
      print('Error checking medicine conflicts: $e');
      return [];
    }
  }

  // Get severity level for medicine interaction
  static String getInteractionSeverity(List<MedicineInteraction> interactions) {
    if (interactions.isEmpty) return 'none';

    bool hasHigh = interactions.any((i) => i.severity == 'high');
    bool hasModerate = interactions.any((i) => i.severity == 'moderate');

    if (hasHigh) return 'high';
    if (hasModerate) return 'moderate';
    return 'low';
  }

  // Add medicine to user's current medications
  static Future<void> addCurrentMedication(String medicineName) async {
    final userId = currentUserId;
    if (userId == null) {
      print('No user ID found, cannot add medication');
      throw Exception('User not authenticated');
    }

    try {
      print('Adding medication: $medicineName for user: $userId');
      
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> currentMedications = List<String>.from(
            data['currentMedications'] ?? [],
          );
          
          if (!currentMedications.contains(medicineName)) {
            currentMedications.add(medicineName);
            print('Updated medications: $currentMedications');
            transaction.update(docRef, {
              'currentMedications': currentMedications,
            });
          } else {
            print('Medication already exists: $medicineName');
          }
        } else {
          // Create new profile if it doesn't exist
          print('Creating new health profile with medication: $medicineName');
          transaction.set(docRef, {
            'currentMedications': [medicineName],
            'healthConditions': [],
            'allergies': [],
            'emergencyContacts': [],
            'bloodType': '',
            'weight': 0.0,
            'age': 0,
            'gender': '',
          });
        }
      });
      
      print('Medication added successfully: $medicineName');
    } catch (e) {
      print('Error adding current medication: $e');
      rethrow;
    }
  }

  // Remove medicine from user's current medications
  static Future<void> removeCurrentMedication(String medicineName) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> currentMedications = List<String>.from(
            data['currentMedications'] ?? [],
          );
          
          currentMedications.remove(medicineName);
          transaction.update(docRef, {
            'currentMedications': currentMedications,
          });
        }
      });
    } catch (e) {
      print('Error removing current medication: $e');
      rethrow;
    }
  }

  // Add health condition to user's profile
  static Future<void> addHealthCondition(String conditionName) async {
    final userId = currentUserId;
    if (userId == null) {
      print('No user ID found, cannot add health condition');
      throw Exception('User not authenticated');
    }

    try {
      print('Adding health condition: $conditionName for user: $userId');
      
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> healthConditions = List<String>.from(
            data['healthConditions'] ?? [],
          );
          print('Current health conditions before add: ' + healthConditions.toString());
          if (!healthConditions.contains(conditionName)) {
            healthConditions.add(conditionName);
            print('Updated health conditions: $healthConditions');
            transaction.update(docRef, {
              'healthConditions': healthConditions,
            });
          } else {
            print('Health condition already exists: $conditionName');
          }
        } else {
          // Create new profile if it doesn't exist
          print('Creating new health profile with condition: $conditionName');
          transaction.set(docRef, {
            'healthConditions': [conditionName],
            'currentMedications': [],
            'allergies': [],
            'emergencyContacts': [],
            'bloodType': '',
            'weight': 0.0,
            'age': 0,
            'gender': '',
          });
        }
      });
      
      print('Health condition added successfully: $conditionName');
    } catch (e) {
      print('Error adding health condition: $e');
      rethrow;
    }
  }

  // Remove health condition from user's profile
  static Future<void> removeHealthCondition(String conditionName) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> healthConditions = List<String>.from(
            data['healthConditions'] ?? [],
          );
          
          healthConditions.remove(conditionName);
          transaction.update(docRef, {
            'healthConditions': healthConditions,
          });
        }
      });
    } catch (e) {
      print('Error removing health condition: $e');
      rethrow;
    }
  }

  // Add allergy to user's profile
  static Future<void> addAllergy(String allergy) async {
    final userId = currentUserId;
    if (userId == null) {
      print('No user ID found, cannot add allergy');
      throw Exception('User not authenticated');
    }

    try {
      print('Adding allergy: $allergy for user: $userId');
      
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> allergies = List<String>.from(
            data['allergies'] ?? [],
          );
          
          if (!allergies.contains(allergy)) {
            allergies.add(allergy);
            print('Updated allergies: $allergies');
            transaction.update(docRef, {
              'allergies': allergies,
            });
          } else {
            print('Allergy already exists: $allergy');
          }
        } else {
          // Create new profile if it doesn't exist
          print('Creating new health profile with allergy: $allergy');
          transaction.set(docRef, {
            'allergies': [allergy],
            'healthConditions': [],
            'currentMedications': [],
            'emergencyContacts': [],
            'bloodType': '',
            'weight': 0.0,
            'age': 0,
            'gender': '',
          });
        }
      });
      
      print('Allergy added successfully: $allergy');
    } catch (e) {
      print('Error adding allergy: $e');
      rethrow;
    }
  }

  // Remove allergy from user's profile
  static Future<void> removeAllergy(String allergy) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> allergies = List<String>.from(
            data['allergies'] ?? [],
          );
          
          allergies.remove(allergy);
          transaction.update(docRef, {
            'allergies': allergies,
          });
        }
      });
    } catch (e) {
      print('Error removing allergy: $e');
      rethrow;
    }
  }

  // Add emergency contact to user's profile
  static Future<void> addEmergencyContact(String contact) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> emergencyContacts = List<String>.from(
            data['emergencyContacts'] ?? [],
          );
          
          if (!emergencyContacts.contains(contact)) {
            emergencyContacts.add(contact);
            transaction.update(docRef, {
              'emergencyContacts': emergencyContacts,
            });
          }
        } else {
          // Create new profile if it doesn't exist
          transaction.set(docRef, {
            'emergencyContacts': [contact],
            'healthConditions': [],
            'currentMedications': [],
            'allergies': [],
            'bloodType': '',
            'weight': 0.0,
            'age': 0,
            'gender': '',
          });
        }
      });
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  // Remove emergency contact from user's profile
  static Future<void> removeEmergencyContact(String contact) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      DocumentReference docRef = _firestore
          .collection('userHealthProfiles')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot doc = await transaction.get(docRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          List<String> emergencyContacts = List<String>.from(
            data['emergencyContacts'] ?? [],
          );
          
          emergencyContacts.remove(contact);
          transaction.update(docRef, {
            'emergencyContacts': emergencyContacts,
          });
        }
      });
    } catch (e) {
      print('Error removing emergency contact: $e');
      rethrow;
    }
  }
} 