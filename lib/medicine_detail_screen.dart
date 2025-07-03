import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> med;

  const MedicineDetailScreen({super.key, required this.med});

  @override
  Widget build(BuildContext context) {
    final String name = med['name'] ?? 'Unnamed';
    final String form = med['form'] ?? '';
    final String pharmacology = med['pharmacology'] ?? 'No description';
    final dynamic rawSubs = med['substitutes'];

    final List<String> substitutes = (rawSubs is List)
        ? List<String>.from(rawSubs.whereType<String>())
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              form,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (med['price'] != null) ...[
              const SizedBox(height: 8),
              Text("💵 Price: ${med['price']}"),
            ],
            const SizedBox(height: 16),
            const Text("🧪 Pharmacology:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(pharmacology),
            const SizedBox(height: 20),
            const Text("🔁 Substitutes:", style: TextStyle(fontWeight: FontWeight.bold)),
            if (substitutes.isEmpty)
              const Text("No substitutes listed.")
            else
              Column(
                children: substitutes.map((subName) {
                  if (subName.trim().isEmpty) {
                    return const ListTile(
                      title: Text("⚠️ Invalid substitute entry"),
                    );
                  }

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('medicines')
                        .where('name', isEqualTo: subName.toUpperCase())
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const ListTile(title: Text("⏳ Loading..."));
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return ListTile(
                          title: Text("❌ Not found: $subName"),
                          subtitle: const Text("This medicine may not exist in the database."),
                        );
                      }

                      final data = docs.first.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? subName),
                        subtitle: Text(data['form'] ?? ''),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineDetailScreen(med: data),
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
