import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'pharmacy_model.dart';
import 'location_service.dart';
import 'l10n/app_localizations.dart';
import 'sample_data.dart';

class PharmacySearchScreen extends StatefulWidget {
  final String? medicineName; // Optional medicine to search for

  const PharmacySearchScreen({super.key, this.medicineName});

  @override
  State<PharmacySearchScreen> createState() => _PharmacySearchScreenState();
}

class _PharmacySearchScreenState extends State<PharmacySearchScreen> {
  Position? _currentPosition;
  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedMedicine;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMedicine = widget.medicineName;
    _searchController.text = _selectedMedicine ?? '';
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentPosition = await LocationService.getCurrentLocation();
      await _loadPharmacies();
    } catch (e) {
      print('Error initializing location: $e');
      // Load pharmacies without location if GPS fails
      await _loadPharmacies();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPharmacies() async {
    try {
      print('🔍 Loading pharmacies from Firestore...');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('pharmacies')
          .get();

      print('📊 Found ${snapshot.docs.length} pharmacy documents');
      
      List<Pharmacy> pharmacies = snapshot.docs
          .map((doc) => Pharmacy.fromFirestore(doc))
          .toList();

      print('🏥 Loaded ${pharmacies.length} pharmacies');

      // Calculate distances if we have current position
      if (_currentPosition != null) {
        print('📍 Calculating distances from current position...');
        for (var pharmacy in pharmacies) {
          double distance = LocationService.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            pharmacy.latitude,
            pharmacy.longitude,
          );
          pharmacy = pharmacy.copyWith(distance: distance);
        }
        // Sort by distance
        pharmacies.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
        print('📏 Sorted pharmacies by distance');
      }

      setState(() {
        _pharmacies = pharmacies;
        _filterPharmacies();
      });
      
      print('✅ Pharmacy loading completed. Total: ${_pharmacies.length}, Filtered: ${_filteredPharmacies.length}');
    } catch (e) {
      print('❌ Error loading pharmacies: $e');
      setState(() {
        _pharmacies = [];
        _filteredPharmacies = [];
      });
    }
  }

  void _filterPharmacies() {
    print('🔍 Filtering pharmacies...');
    print('📊 Total pharmacies: ${_pharmacies.length}');
    print('🔎 Search query: "$_searchQuery"');
    print('💊 Selected medicine: "$_selectedMedicine"');
    
    List<Pharmacy> filtered = _pharmacies;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((pharmacy) {
        return pharmacy.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               pharmacy.nameAr.contains(_searchQuery) ||
               pharmacy.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               pharmacy.addressAr.contains(_searchQuery);
      }).toList();
      print('🔍 After search filter: ${filtered.length} pharmacies');
    }

    // Filter by medicine if specified
    if (_selectedMedicine != null && _selectedMedicine!.isNotEmpty) {
      filtered = filtered.where((pharmacy) {
        bool hasMedicine = pharmacy.availableMedicines.any((medicine) =>
            medicine.toLowerCase().contains(_selectedMedicine!.toLowerCase()) ||
            medicine.toLowerCase().contains('panadol') && _selectedMedicine!.toLowerCase().contains('panadol') ||
            medicine.toLowerCase().contains('paracetamol') && _selectedMedicine!.toLowerCase().contains('paracetamol'));
        
        if (hasMedicine) {
          print('✅ Pharmacy "${pharmacy.name}" has medicine "$_selectedMedicine"');
        }
        
        return hasMedicine;
      }).toList();
      print('💊 After medicine filter: ${filtered.length} pharmacies');
    }

    setState(() {
      _filteredPharmacies = filtered;
    });
    
    print('🎯 Final filtered results: ${_filteredPharmacies.length} pharmacies');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'البحث عن الصيدليات' : 'Pharmacy Search'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initializeLocation,
            tooltip: isArabic ? 'تحديث الموقع' : 'Update Location',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              print('🐛 DEBUG INFO:');
              print('📊 Total pharmacies loaded: ${_pharmacies.length}');
              print('🎯 Filtered pharmacies: ${_filteredPharmacies.length}');
              print('🔎 Search query: "$_searchQuery"');
              print('💊 Selected medicine: "$_selectedMedicine"');
              print('📍 Current position: $_currentPosition');
              
              if (_pharmacies.isNotEmpty) {
                print('🏥 Sample pharmacy data:');
                print('Name: ${_pharmacies.first.name}');
                print('Available medicines: ${_pharmacies.first.availableMedicines}');
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Debug info printed to console. Check logs.'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Debug Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isArabic ? 'البحث عن صيدلية...' : 'Search pharmacies...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterPharmacies();
                  },
                ),
                const SizedBox(height: 12),
                // Medicine filter
                TextField(
                  decoration: InputDecoration(
                    hintText: isArabic ? 'اسم الدواء (اختياري)' : 'Medicine name (optional)',
                    prefixIcon: const Icon(Icons.medication),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedMedicine = value.isEmpty ? null : value;
                    });
                    _filterPharmacies();
                  },
                ),
              ],
            ),
          ),
          // Medicine filter indicator
          if (_selectedMedicine != null && _selectedMedicine!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.medication, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'عرض الصيدليات التي تحتوي على:' : 'Showing pharmacies with:',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _selectedMedicine!,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.green.shade700),
                    onPressed: () {
                      setState(() {
                        _selectedMedicine = null;
                        _searchController.clear();
                      });
                      _filterPharmacies();
                    },
                  ),
                ],
              ),
            ),
          // Results section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPharmacies.isEmpty
                    ? _buildEmptyState(isArabic)
                    : ListView.builder(
                        itemCount: _filteredPharmacies.length,
                        itemBuilder: (context, index) {
                          return _buildPharmacyCard(_filteredPharmacies[index], isArabic);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_pharmacy_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد صيدليات متاحة' : 'No pharmacies available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic 
                ? 'جرب تغيير معايير البحث أو تأكد من تحميل البيانات'
                : 'Try adjusting your search criteria or ensure data is loaded',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          if (_pharmacies.isEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.data_usage),
              label: Text(isArabic ? 'تحميل البيانات التجريبية' : 'Load Sample Data'),
              onPressed: () async {
                try {
                  await SampleData.populateSampleData();
                  await _loadPharmacies();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic ? 'تم تحميل البيانات بنجاح' : 'Data loaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy, bool isArabic) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: pharmacy.isOpen ? Colors.green : Colors.red,
          child: Icon(
            Icons.local_pharmacy,
            color: Colors.white,
          ),
        ),
        title: Text(
          isArabic ? pharmacy.nameAr : pharmacy.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isArabic ? pharmacy.addressAr : pharmacy.address,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  pharmacy.workingHours,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: pharmacy.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pharmacy.isOpen 
                        ? (isArabic ? 'مفتوح' : 'Open')
                        : (isArabic ? 'مغلق' : 'Closed'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (pharmacy.distance != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    LocationService.formatDistance(pharmacy.distance!),
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (pharmacy.availableMedicines.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                isArabic ? 'الأدوية المتوفرة:' : 'Available medicines:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: pharmacy.availableMedicines.take(3).map((medicine) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      medicine,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (pharmacy.availableMedicines.length > 3)
                Text(
                  isArabic 
                      ? '+${pharmacy.availableMedicines.length - 3} أكثر'
                      : '+${pharmacy.availableMedicines.length - 3} more',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _callPharmacy(pharmacy.phone),
              tooltip: isArabic ? 'اتصال' : 'Call',
            ),
            IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () => _openDirections(pharmacy),
              tooltip: isArabic ? 'الاتجاهات' : 'Directions',
            ),
          ],
        ),
        onTap: () => _showPharmacyDetails(pharmacy, isArabic),
      ),
    );
  }

  void _callPharmacy(String phone) {
    // Implement phone call functionality
    print('Calling pharmacy: $phone');
  }

  void _openDirections(Pharmacy pharmacy) {
    // Implement directions functionality
    print('Opening directions to: ${pharmacy.name}');
  }

  void _showPharmacyDetails(Pharmacy pharmacy, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPharmacyDetails(pharmacy, isArabic),
    );
  }

  Widget _buildPharmacyDetails(Pharmacy pharmacy, bool isArabic) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: pharmacy.isOpen ? Colors.green : Colors.red,
                child: const Icon(Icons.local_pharmacy, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? pharmacy.nameAr : pharmacy.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isArabic ? pharmacy.addressAr : pharmacy.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(Icons.phone, isArabic ? 'الهاتف' : 'Phone', pharmacy.phone),
          _buildDetailRow(Icons.access_time, isArabic ? 'ساعات العمل' : 'Working Hours', pharmacy.workingHours),
          if (pharmacy.distance != null)
            _buildDetailRow(Icons.location_on, isArabic ? 'المسافة' : 'Distance', LocationService.formatDistance(pharmacy.distance!)),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'الأدوية المتوفرة:' : 'Available Medicines:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: pharmacy.availableMedicines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(pharmacy.availableMedicines[index]),
                  dense: true,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callPharmacy(pharmacy.phone),
                  icon: const Icon(Icons.phone),
                  label: Text(isArabic ? 'اتصال' : 'Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(pharmacy),
                  icon: const Icon(Icons.directions),
                  label: Text(isArabic ? 'الاتجاهات' : 'Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
} 