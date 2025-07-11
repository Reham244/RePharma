import 'package:cloud_firestore/cloud_firestore.dart';

class Pharmacy {
  final String id;
  final String name;
  final String nameAr;
  final String address;
  final String addressAr;
  final double latitude;
  final double longitude;
  final String phone;
  final String workingHours;
  final bool isOpen;
  final List<String> availableMedicines;
  final double? distance; // Distance from user's location

  Pharmacy({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.address,
    required this.addressAr,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.workingHours,
    required this.isOpen,
    required this.availableMedicines,
    this.distance,
  });

  factory Pharmacy.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pharmacy(
      id: doc.id,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      address: data['address'] ?? '',
      addressAr: data['addressAr'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      phone: data['phone'] ?? '',
      workingHours: data['workingHours'] ?? '',
      isOpen: data['isOpen'] ?? false,
      availableMedicines: List<String>.from(data['availableMedicines'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'address': address,
      'addressAr': addressAr,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'workingHours': workingHours,
      'isOpen': isOpen,
      'availableMedicines': availableMedicines,
    };
  }

  Pharmacy copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? address,
    String? addressAr,
    double? latitude,
    double? longitude,
    String? phone,
    String? workingHours,
    bool? isOpen,
    List<String>? availableMedicines,
    double? distance,
  }) {
    return Pharmacy(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      workingHours: workingHours ?? this.workingHours,
      isOpen: isOpen ?? this.isOpen,
      availableMedicines: availableMedicines ?? this.availableMedicines,
      distance: distance ?? this.distance,
    );
  }
} 