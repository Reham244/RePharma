import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';
import 'medicine_detail_screen.dart';
import 'pharmacy_search_screen.dart';
import 'pharmacy_search_screen.dart';

class Medicine {
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  Medicine({
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
  });
}

final List<Medicine> sampleMedicines = [
  Medicine(
    nameEn: 'Paracetamol',
    nameAr: 'باراسيتامول',
    descriptionEn: 'Pain reliever and fever reducer.',
    descriptionAr: 'مسكن للألم وخافض للحرارة.',
  ),
  Medicine(
    nameEn: 'Ibuprofen',
    nameAr: 'ايبوبروفين',
    descriptionEn: 'Nonsteroidal anti-inflammatory drug.',
    descriptionAr: 'دواء مضاد للالتهابات غير ستيرويدي.',
  ),
  Medicine(
    nameEn: 'Amoxicillin',
    nameAr: 'أموكسيسيلين',
    descriptionEn: 'Antibiotic used to treat infections.',
    descriptionAr: 'مضاد حيوي لعلاج العدوى.',
  ),
  Medicine(
    nameEn: 'Aspirin',
    nameAr: 'أسبرين',
    descriptionEn: 'Used to reduce pain, fever, or inflammation.',
    descriptionAr: 'يستخدم لتقليل الألم أو الحمى أو الالتهاب.',
  ),
];

class MedicineSearchScreen extends StatelessWidget {
  const MedicineSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Medicines (Test)'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No medicine data found in the database.', style: TextStyle(fontSize: 18, color: Colors.red)));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};
              final nameEn = data['nameEn'] ?? '';
              final nameAr = data['nameAr'] ?? '';
              final isArabic = Localizations.localeOf(context).languageCode == 'ar';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.blue),
                  title: Text(isArabic ? nameAr : nameEn),
                  subtitle: Text(isArabic ? nameEn : nameAr),
                  trailing: IconButton(
                    icon: const Icon(Icons.local_pharmacy),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PharmacySearchScreen(
                            medicineName: isArabic ? nameAr : nameEn,
                          ),
                        ),
                      );
                    },
                    tooltip: isArabic ? 'البحث عن الصيدليات' : 'Find Pharmacies',
                  ),
                  onTap: () {
                    // Navigate to medicine details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicineDetailScreen(med: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
