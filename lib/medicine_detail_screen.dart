import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> med;
  const MedicineDetailScreen({super.key, required this.med});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  // Removed conflict checking functionality

  @override
  Widget build(BuildContext context) {
    final String nameEn = widget.med['nameEn'] ?? '';
    final String nameAr = widget.med['nameAr'] ?? '';
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String queryField = isArabic ? 'nameAr' : 'nameEn';
    final String queryValue = isArabic ? nameAr : nameEn;
    // Debug print to show the medicine data
    // ignore: avoid_print
    print('MedicineDetailScreen data: ' + widget.med.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? (nameAr.isNotEmpty ? nameAr : nameEn) : (nameEn.isNotEmpty ? nameEn : nameAr)),
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
          // Find the main medicine
          Map<String, dynamic>? med = docs.map((d) => d.data() as Map<String, dynamic>).firstWhere(
            (m) => (m[queryField]?.toString()?.trim()?.toLowerCase() ?? '') == (queryValue.trim().toLowerCase()),
            orElse: () => widget.med,
          );
          final String form = med['form'] ?? '';
          final String pharmacology = med['pharmacology'] ?? med['descriptionEn'] ?? med['descriptionAr'] ?? 'No description';
          final dynamic rawSubs = med['substitutes'];
          final List<String> substitutes = (rawSubs is List)
              ? List<String>.from(rawSubs.whereType<String>())
              : [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                form,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (med['price'] != null) ...[
                const SizedBox(height: 8),
                Text("💵 Price: \\${med['price']}", style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 16),
              const Text("🧪 Pharmacology:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(pharmacology),
              const SizedBox(height: 20),
              const Text("🔁 Substitutes:", style: TextStyle(fontWeight: FontWeight.bold)),
              if (substitutes.isEmpty)
                const Text("No substitutes listed.")
              else
                ...substitutes.map((subName) {
                  final trimmedSub = subName.trim().toLowerCase();
                  if (trimmedSub.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  // Try to find a match in all medicines
                  final match = docs.map((d) => d.data() as Map<String, dynamic>).firstWhere(
                    (m) => (m['nameEn']?.toString()?.trim()?.toLowerCase() ?? '') == trimmedSub ||
                           (m['nameAr']?.toString()?.trim()?.toLowerCase() ?? '') == trimmedSub,
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    return ListTile(
                      title: Text(match['nameEn'] ?? match['nameAr'] ?? subName),
                      subtitle: Text(match['form'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineDetailScreen(med: match),
                          ),
                        );
                      },
                    );
                  } else {
                    // Show the name as plain text if not found
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(subName, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    );
                  }
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}
