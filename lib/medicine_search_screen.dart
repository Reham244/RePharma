import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'medicine_detail_screen.dart'; // 🔗 Import your detail screen

class MedicineSearchScreen extends StatefulWidget {
  const MedicineSearchScreen({super.key});

  @override
  State<MedicineSearchScreen> createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool searchByName = true;
  List<DocumentSnapshot> results = [];

  void _performSearch(String query) async {
    final collection = FirebaseFirestore.instance.collection('medicines');
    QuerySnapshot snapshot;

    if (searchByName) {
      snapshot = await collection
          .where('name', isGreaterThanOrEqualTo: query.toUpperCase())
          .where('name', isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
          .get();
    } else {
      snapshot = await collection
          .where('pharmacology', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('pharmacology', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .get();
    }

    setState(() {
      results = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Medicines"),
        actions: [
          Switch(
            value: searchByName,
            onChanged: (value) {
              setState(() {
                searchByName = value;
                results.clear();
                _searchController.clear();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(searchByName ? "Name" : "Ingredient"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                labelText: searchByName ? 'Search by name' : 'Search by active ingredient',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text.trim()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("No results yet"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final med = results[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(med['name'] ?? 'Unnamed'),
                            subtitle: Text(med['pharmacology'] ?? 'No description'),
                            onTap: () {
                              print("📦 Tapped medicine: $med"); // 🧠 Debug print
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicineDetailScreen(med: med),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
