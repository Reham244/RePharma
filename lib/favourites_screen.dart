import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<String> _favourites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favourites = prefs.getStringList('favourite_medicines') ?? [];
      _loading = false;
    });
  }

  Future<void> _removeFavourite(String medicine) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favourites.remove(medicine);
      prefs.setStringList('favourite_medicines', _favourites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.blue[800],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favourites.isEmpty
              ? const Center(child: Text('No favourite medicines yet.'))
              : ListView.builder(
                  itemCount: _favourites.length,
                  itemBuilder: (context, index) {
                    final medicine = _favourites[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.redAccent),
                        title: Text(medicine),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFavourite(medicine),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 