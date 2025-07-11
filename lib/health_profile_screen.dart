import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_profile_model.dart';
import 'health_profile_service.dart';
import 'l10n/app_localizations.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  _HealthProfileScreenState createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  UserHealthProfile? _healthProfile;
  List<HealthCondition> _allHealthConditions = [];
  bool _isLoading = true;
  bool _isEditing = false;
  String? _error;

  // Controllers for editing
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _genderController = TextEditingController();
  final _allergyController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _bloodTypeController.dispose();
    _genderController.dispose();
    _allergyController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load user's health profile
      _healthProfile = await HealthProfileService.getUserHealthProfile();
      
      // Load all available health conditions
      _allHealthConditions = await HealthProfileService.getAllHealthConditions();

      // Initialize controllers with current values
      if (_healthProfile != null) {
        _ageController.text = _healthProfile!.age.toString();
        _weightController.text = _healthProfile!.weight.toString();
        _bloodTypeController.text = _healthProfile!.bloodType;
        _genderController.text = _healthProfile!.gender;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHealthProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Saving health profile...'); // Debug log
      print('Age: ${_ageController.text}'); // Debug log
      print('Weight: ${_weightController.text}'); // Debug log
      print('Blood Type: ${_bloodTypeController.text}'); // Debug log
      print('Gender: ${_genderController.text}'); // Debug log
      
      final updatedProfile = UserHealthProfile(
        userId: _healthProfile?.userId ?? HealthProfileService.currentUserId ?? '',
        age: int.tryParse(_ageController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        bloodType: _bloodTypeController.text,
        gender: _genderController.text,
        healthConditions: _healthProfile?.healthConditions ?? [],
        currentMedications: _healthProfile?.currentMedications ?? [],
        allergies: _healthProfile?.allergies ?? [],
        emergencyContacts: _healthProfile?.emergencyContacts ?? [],
      );

      print('Updated profile: ${updatedProfile.toMap()}'); // Debug log
      await HealthProfileService.updateUserHealthProfile(updatedProfile);
      
      setState(() {
        _healthProfile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving health profile: $e'); // Debug log
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addHealthCondition(HealthCondition condition) async {
    try {
      await HealthProfileService.addHealthCondition(condition.nameEn);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${condition.nameEn} added to your health conditions'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeHealthCondition(String conditionName) async {
    try {
      await HealthProfileService.removeHealthCondition(conditionName);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$conditionName removed from your health conditions'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addCurrentMedication(String medicineName) async {
    try {
      await HealthProfileService.addCurrentMedication(medicineName);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$medicineName added to your current medications'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeCurrentMedication(String medicineName) async {
    try {
      await HealthProfileService.removeCurrentMedication(medicineName);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$medicineName removed from your current medications'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addAllergy(String allergy) async {
    try {
      await HealthProfileService.addAllergy(allergy);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$allergy added to your allergies'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeAllergy(String allergy) async {
    try {
      await HealthProfileService.removeAllergy(allergy);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$allergy removed from your allergies'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addEmergencyContact(String contact) async {
    try {
      await HealthProfileService.addEmergencyContact(contact);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$contact added to your emergency contacts'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeEmergencyContact(String contact) async {
    try {
      await HealthProfileService.removeEmergencyContact(contact);
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$contact removed from your emergency contacts'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Test function to verify data saving
  Future<void> _testDataSaving() async {
    try {
      print('Testing data saving...');
      
      // Create a test profile with sample data
      final testProfile = UserHealthProfile(
        userId: HealthProfileService.currentUserId ?? 'test_user',
        age: 25,
        weight: 70.0,
        bloodType: 'A+',
        gender: 'Male',
        healthConditions: ['Hypertension (High Blood Pressure)', 'Diabetes'],
        currentMedications: ['Aspirin', 'Metformin'],
        allergies: ['Penicillin', 'Peanuts'],
        emergencyContacts: ['John Doe: +1234567890'],
      );

      print('Test profile: ${testProfile.toMap()}');
      
      await HealthProfileService.updateUserHealthProfile(testProfile);
      
      // Reload to verify
      await _loadHealthProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test data saved successfully! Check console for details.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Test save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test save failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddHealthConditionDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إضافة حالة صحية' : 'Add Health Condition'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _allHealthConditions.length,
            itemBuilder: (context, index) {
              final condition = _allHealthConditions[index];
              final isSelected = _healthProfile?.healthConditions.contains(condition.nameEn) ?? false;
              
              return ListTile(
                title: Text(isArabic ? condition.nameAr : condition.nameEn),
                subtitle: Text(isArabic ? condition.categoryAr : condition.category),
                trailing: isSelected 
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.add_circle_outline),
                onTap: isSelected 
                    ? null 
                    : () {
                        Navigator.pop(context);
                        _addHealthCondition(condition);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final TextEditingController medicineController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إضافة دواء حالي' : 'Add Current Medication'),
        content: TextField(
          controller: medicineController,
          decoration: InputDecoration(
            labelText: isArabic ? 'اسم الدواء' : 'Medicine Name',
            hintText: isArabic ? 'أدخل اسم الدواء' : 'Enter medicine name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (medicineController.text.isNotEmpty) {
                Navigator.pop(context);
                _addCurrentMedication(medicineController.text.trim());
              }
            },
            child: Text(isArabic ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAllergyDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    // Comprehensive list of common allergies
    final List<Map<String, String>> commonAllergies = [
      // Drug Allergies
      {'en': 'Penicillin', 'ar': 'البنسلين'},
      {'en': 'Amoxicillin', 'ar': 'أموكسيسيلين'},
      {'en': 'Sulfa Drugs', 'ar': 'أدوية السلفا'},
      {'en': 'Aspirin', 'ar': 'الأسبرين'},
      {'en': 'Ibuprofen', 'ar': 'الإيبوبروفين'},
      {'en': 'Codeine', 'ar': 'الكودين'},
      {'en': 'Morphine', 'ar': 'المورفين'},
      {'en': 'Tetracycline', 'ar': 'التتراسيكلين'},
      {'en': 'Cephalosporins', 'ar': 'السيفالوسبورينات'},
      {'en': 'Sulfonamides', 'ar': 'السلفوناميدات'},
      
      // Food Allergies
      {'en': 'Peanuts', 'ar': 'الفول السوداني'},
      {'en': 'Tree Nuts', 'ar': 'المكسرات'},
      {'en': 'Milk', 'ar': 'الحليب'},
      {'en': 'Eggs', 'ar': 'البيض'},
      {'en': 'Soy', 'ar': 'فول الصويا'},
      {'en': 'Wheat', 'ar': 'القمح'},
      {'en': 'Fish', 'ar': 'الأسماك'},
      {'en': 'Shellfish', 'ar': 'المحار'},
      {'en': 'Sesame', 'ar': 'السمسم'},
      {'en': 'Mustard', 'ar': 'الخردل'},
      
      // Environmental Allergies
      {'en': 'Dust Mites', 'ar': 'عث الغبار'},
      {'en': 'Pollen', 'ar': 'حبوب اللقاح'},
      {'en': 'Mold', 'ar': 'العفن'},
      {'en': 'Pet Dander', 'ar': 'وبر الحيوانات'},
      {'en': 'Grass', 'ar': 'العشب'},
      {'en': 'Ragweed', 'ar': 'الأمبروسيا'},
      {'en': 'Birch', 'ar': 'البيرش'},
      {'en': 'Oak', 'ar': 'البلوط'},
      {'en': 'Cedar', 'ar': 'الأرز'},
      
      // Insect Allergies
      {'en': 'Bee Stings', 'ar': 'لسعات النحل'},
      {'en': 'Wasp Stings', 'ar': 'لسعات الدبابير'},
      {'en': 'Fire Ants', 'ar': 'النمل الناري'},
      {'en': 'Mosquito Bites', 'ar': 'لدغات البعوض'},
      
      // Latex Allergies
      {'en': 'Latex', 'ar': 'اللاتكس'},
      {'en': 'Rubber', 'ar': 'المطاط'},
      
      // Other Allergies
      {'en': 'Iodine', 'ar': 'اليود'},
      {'en': 'Contrast Dye', 'ar': 'صبغة التباين'},
      {'en': 'Nickel', 'ar': 'النيكل'},
      {'en': 'Wool', 'ar': 'الصوف'},
      {'en': 'Perfume', 'ar': 'العطور'},
      {'en': 'Detergents', 'ar': 'المنظفات'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إضافة حساسية' : 'Add Allergy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text(
                isArabic ? 'اختر من القائمة أو أدخل حساسية مخصصة' : 'Choose from list or enter custom allergy',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: commonAllergies.length + 1, // +1 for custom option
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Custom allergy option
                      return ListTile(
                        leading: Icon(Icons.add_circle_outline),
                        title: Text(isArabic ? 'إضافة حساسية مخصصة' : 'Add Custom Allergy'),
                        subtitle: Text(isArabic ? 'أدخل حساسية غير مدرجة' : 'Enter allergy not in list'),
                        onTap: () {
                          Navigator.pop(context);
                          _showCustomAllergyDialog();
                        },
                      );
                    }
                    
                    final allergy = commonAllergies[index - 1];
                    final allergyName = isArabic ? allergy['ar']! : allergy['en']!;
                    final isSelected = _healthProfile?.allergies.contains(allergyName) ?? false;
                    
                    return ListTile(
                      title: Text(allergyName),
                      trailing: isSelected 
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.add_circle_outline),
                      onTap: isSelected 
                          ? null 
                          : () {
                              Navigator.pop(context);
                              _addAllergy(allergyName);
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCustomAllergyDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final TextEditingController allergyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إضافة حساسية مخصصة' : 'Add Custom Allergy'),
        content: TextField(
          controller: allergyController,
          decoration: InputDecoration(
            labelText: isArabic ? 'نوع الحساسية' : 'Allergy Type',
            hintText: isArabic ? 'أدخل نوع الحساسية' : 'Enter allergy type',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (allergyController.text.isNotEmpty) {
                Navigator.pop(context);
                _addAllergy(allergyController.text.trim());
              }
            },
            child: Text(isArabic ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showAddEmergencyContactDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final TextEditingController contactController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إضافة جهة اتصال طارئة' : 'Add Emergency Contact'),
        content: TextField(
          controller: contactController,
          decoration: InputDecoration(
            labelText: isArabic ? 'معلومات الاتصال' : 'Contact Information',
            hintText: isArabic ? 'أدخل اسم ورقم الهاتف' : 'Enter name and phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contactController.text.isNotEmpty) {
                Navigator.pop(context);
                _addEmergencyContact(contactController.text.trim());
              }
            },
            child: Text(isArabic ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الملف الصحي' : 'Health Profile'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: isArabic ? 'تعديل' : 'Edit',
            ),
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _testDataSaving,
            tooltip: isArabic ? 'اختبار الحفظ' : 'Test Save',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHealthProfile,
                        child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader(
                        isArabic ? 'المعلومات الأساسية' : 'Basic Information',
                        Icons.person,
                      ),
                      SizedBox(height: 8),
                      _buildBasicInfoSection(isArabic),
                      SizedBox(height: 24),

                      // Health Conditions Section
                      _buildSectionHeader(
                        isArabic ? 'الحالات الصحية' : 'Health Conditions',
                        Icons.medical_services,
                      ),
                      SizedBox(height: 8),
                      _buildHealthConditionsSection(isArabic),
                      SizedBox(height: 24),

                      // Current Medications Section
                      _buildSectionHeader(
                        isArabic ? 'الأدوية الحالية' : 'Current Medications',
                        Icons.medication,
                      ),
                      SizedBox(height: 8),
                      _buildCurrentMedicationsSection(isArabic),
                      SizedBox(height: 24),

                      // Allergies Section
                      _buildSectionHeader(
                        isArabic ? 'الحساسية' : 'Allergies',
                        Icons.warning,
                      ),
                      SizedBox(height: 8),
                      _buildAllergiesSection(isArabic),
                      SizedBox(height: 24),

                      // Emergency Contacts Section
                      _buildSectionHeader(
                        isArabic ? 'جهات الاتصال في الطوارئ' : 'Emergency Contacts',
                        Icons.emergency,
                      ),
                      SizedBox(height: 8),
                      _buildEmergencyContactsSection(isArabic),
                      SizedBox(height: 24),

                      // Save/Cancel Buttons
                      if (_isEditing) ...[
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveHealthProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(isArabic ? 'حفظ' : 'Save'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() => _isEditing = false);
                                  _loadHealthProfile(); // Reset to original values
                                },
                                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'العمر' : 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _genderController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الجنس' : 'Gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الوزن (كجم)' : 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bloodTypeController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'فصيلة الدم' : 'Blood Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConditionsSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الحالات الصحية الحالية' : 'Current Health Conditions',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: _showAddHealthConditionDialog,
                    icon: Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة' : 'Add'),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (_healthProfile?.healthConditions.isEmpty ?? true)
              Text(
                isArabic ? 'لا توجد حالات صحية مسجلة' : 'No health conditions recorded',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healthProfile!.healthConditions.map((condition) {
                  return Chip(
                    label: Text(condition),
                    deleteIcon: _isEditing ? Icon(Icons.close, size: 18) : null,
                    onDeleted: _isEditing ? () => _removeHealthCondition(condition) : null,
                    backgroundColor: Colors.blue[50],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMedicationsSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الأدوية الحالية' : 'Current Medications',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: _showAddMedicationDialog,
                    icon: Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة' : 'Add'),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (_healthProfile?.currentMedications.isEmpty ?? true)
              Text(
                isArabic ? 'لا توجد أدوية حالية مسجلة' : 'No current medications recorded',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healthProfile!.currentMedications.map((medication) {
                  return Chip(
                    label: Text(medication),
                    deleteIcon: _isEditing ? Icon(Icons.close, size: 18) : null,
                    onDeleted: _isEditing ? () => _removeCurrentMedication(medication) : null,
                    backgroundColor: Colors.green[50],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'الحساسية' : 'Allergies',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: _showAddAllergyDialog,
                    icon: Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة' : 'Add'),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (_healthProfile?.allergies.isEmpty ?? true)
              Text(
                isArabic ? 'لا توجد حساسية مسجلة' : 'No allergies recorded',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healthProfile!.allergies.map((allergy) {
                  return Chip(
                    label: Text(allergy),
                    deleteIcon: _isEditing ? Icon(Icons.close, size: 18) : null,
                    onDeleted: _isEditing ? () => _removeAllergy(allergy) : null,
                    backgroundColor: Colors.orange[50],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsSection(bool isArabic) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'جهات الاتصال في الطوارئ' : 'Emergency Contacts',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: _showAddEmergencyContactDialog,
                    icon: Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة' : 'Add'),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (_healthProfile?.emergencyContacts.isEmpty ?? true)
              Text(
                isArabic ? 'لا توجد جهات اتصال طارئة مسجلة' : 'No emergency contacts recorded',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              )
            else
              Column(
                children: _healthProfile!.emergencyContacts.map((contact) {
                  return ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(contact),
                    trailing: _isEditing ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeEmergencyContact(contact),
                    ) : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
} 