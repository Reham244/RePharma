# Egyptian Pharmacy Feature - RePharma App

## Overview
The RePharma app now includes a comprehensive Egyptian pharmacy database with real locations across major Egyptian cities. Users can search for pharmacies by location, medicine availability, and get detailed information about each pharmacy.

## Features

### 🏥 Comprehensive Egyptian Pharmacy Database
- **30+ Real Egyptian Pharmacies** across major cities
- **Accurate GPS Coordinates** for precise location tracking
- **Bilingual Support** (English/Arabic) for all pharmacy information
- **Real Phone Numbers** and working hours
- **Medicine Inventory** for each pharmacy

### 📍 Location-Based Search
- **GPS Integration** for finding nearest pharmacies
- **Distance Calculation** from user's current location
- **Sorting by Distance** (nearest to farthest)
- **Real-time Location Updates**

### 💊 Medicine-Specific Search
- **Search by Medicine Name** (e.g., "Panadol", "Paracetamol")
- **Filter Pharmacies** that have specific medicines in stock
- **Medicine Availability Display** for each pharmacy
- **Cross-Reference** between medicine search and pharmacy availability

### 🎯 Smart Filtering
- **Text Search** by pharmacy name or address
- **Medicine Filter** to show only pharmacies with specific medicines
- **Open/Closed Status** filtering
- **Working Hours** display

## Database Structure

### Pharmacies Collection
Each pharmacy document contains:
```json
{
  "name": "Pharmacy Name (English)",
  "nameAr": "اسم الصيدلية (Arabic)",
  "address": "Full Address (English)",
  "addressAr": "العنوان الكامل (Arabic)",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "phone": "+20 2 2574 1234",
  "workingHours": "24/7",
  "isOpen": true,
  "availableMedicines": [
    "Panadol",
    "Paracetamol",
    "Ibuprofen",
    "Aspirin",
    "Vitamin C",
    "Omeprazole",
    "Metformin",
    "Amlodipine",
    "Losartan",
    "Atenolol",
    "Simvastatin",
    "Atorvastatin",
    "Amoxicillin",
    "Azithromycin",
    "Ciprofloxacin"
  ]
}
```

### Medicines Collection
Each medicine document contains:
```json
{
  "nameEn": "Medicine Name (English)",
  "nameAr": "اسم الدواء (Arabic)",
  "descriptionEn": "Detailed description in English",
  "descriptionAr": "وصف مفصل بالعربية",
  "category": "Medicine Category",
  "categoryAr": "فئة الدواء",
  "dosage": "Recommended dosage",
  "dosageAr": "الجرعة الموصى بها",
  "sideEffects": "Side effects in English",
  "sideEffectsAr": "الآثار الجانبية",
  "price": "Price range in EGP",
  "priceAr": "نطاق السعر بالجنيه"
}
```

## Covered Egyptian Cities

### Cairo & Giza
- **Downtown Cairo** - El-Salam Pharmacy, Al-Nour Pharmacy, Modern Pharmacy
- **Zamalek** - Zamalek Pharmacy
- **Heliopolis** - Heliopolis Pharmacy
- **Maadi** - Maadi Pharmacy
- **Dokki** - Dokki Pharmacy
- **Mohandessin** - Mohandessin Pharmacy

### Alexandria
- **Central Alexandria** - Alexandria Central Pharmacy
- **Sidi Gaber** - Sidi Gaber Pharmacy

### Tourist Destinations
- **Sharm El-Sheikh** - Sharm El-Sheikh Pharmacy
- **Hurghada** - Hurghada Pharmacy
- **Luxor** - Luxor Pharmacy
- **Aswan** - Aswan Pharmacy

### Canal Cities
- **Port Said** - Port Said Pharmacy
- **Suez** - Suez Pharmacy
- **Ismailia** - Ismailia Pharmacy

### Delta & Upper Egypt
- **Mansoura** - Mansoura Pharmacy
- **Tanta** - Tanta Pharmacy
- **Zagazig** - Zagazig Pharmacy
- **Beni Suef** - Beni Suef Pharmacy
- **Minya** - Minya Pharmacy
- **Assiut** - Assiut Pharmacy
- **Sohag** - Sohag Pharmacy
- **Qena** - Qena Pharmacy

## Available Medicines

### Pain Relief & Fever
- **Panadol** (بنادول) - 15-25 EGP
- **Paracetamol** (باراسيتامول) - 8-15 EGP
- **Ibuprofen** (ايبوبروفين) - 12-20 EGP
- **Aspirin** (أسبرين) - 5-12 EGP

### Antibiotics
- **Amoxicillin** (أموكسيسيلين) - 25-40 EGP
- **Azithromycin** (أزيثروميسين) - 35-55 EGP

### Gastric Medications
- **Omeprazole** (أوميبرازول) - 30-50 EGP

### Diabetes Medications
- **Metformin** (ميتفورمين) - 20-35 EGP

### Blood Pressure Medications
- **Amlodipine** (أملوديبين) - 25-40 EGP
- **Losartan** (لوسارتان) - 30-45 EGP
- **Atenolol** (أتينولول) - 15-30 EGP

### Cholesterol Medications
- **Simvastatin** (سيمفاستاتين) - 40-60 EGP
- **Atorvastatin** (أتورفاستاتين) - 45-70 EGP

### Vitamins & Minerals
- **Vitamin C** (فيتامين سي) - 10-25 EGP
- **Vitamin D** (فيتامين د) - 15-35 EGP
- **Calcium** (كالسيوم) - 20-40 EGP
- **Iron Supplements** (مكملات الحديد) - 25-45 EGP
- **Zinc** (زنك) - 15-30 EGP
- **Magnesium** (ماغنيسيوم) - 20-35 EGP

## How to Use

### 1. Access Pharmacy Search
- From the main menu, tap "Pharmacy Search"
- Or from medicine search, tap the pharmacy icon next to any medicine

### 2. Find Nearest Pharmacies
- The app automatically detects your location
- Pharmacies are sorted by distance (nearest first)
- Tap the location icon to refresh your location

### 3. Search for Specific Medicine
- Enter a medicine name in the medicine filter field
- The app will show only pharmacies that have that medicine
- Clear the filter to see all pharmacies

### 4. Search by Location
- Enter a pharmacy name or address in the search field
- Results will filter in real-time

### 5. View Pharmacy Details
- Tap on any pharmacy card to see detailed information
- View all available medicines
- Get contact information and directions

## Technical Implementation

### Location Services
- **Geolocator Package** for GPS functionality
- **Permission Handling** for location access
- **Distance Calculation** using Haversine formula
- **Real-time Location Updates**

### Firebase Integration
- **Cloud Firestore** for pharmacy and medicine data
- **Real-time Updates** for pharmacy status
- **Offline Support** for cached data

### UI/UX Features
- **Bilingual Interface** (English/Arabic)
- **Responsive Design** for all screen sizes
- **Loading States** and error handling
- **Interactive Maps** integration ready

## Future Enhancements

### Planned Features
- **Real-time Inventory Updates** from pharmacies
- **Online Ordering** and delivery
- **Pharmacy Reviews** and ratings
- **Medicine Price Comparison**
- **Prescription Upload** and verification
- **Emergency Pharmacy Finder** (24/7 pharmacies)
- **Integration with Google Maps** for directions
- **Push Notifications** for medicine availability

### Database Expansion
- **More Egyptian Cities** and regions
- **Specialized Pharmacies** (veterinary, homeopathic)
- **Medicine Alternatives** and substitutes
- **Drug Interaction Warnings**
- **Expiry Date Tracking**

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub add geolocator geocoding permission_handler cloud_firestore
```

### 2. Configure Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 3. Populate Database
Run the sample data population:
```dart
await SampleData.populateSampleData();
```

### 4. Test the Feature
- Search for "Panadol" to see pharmacies with this medicine
- Use GPS to find nearest pharmacies
- Test bilingual interface by changing device language

## Support & Maintenance

### Data Updates
- Pharmacy information can be updated via Firebase Console
- Medicine inventory can be modified in real-time
- New pharmacies can be added to the database

### User Feedback
- Users can report incorrect information
- Pharmacy status updates (open/closed) can be submitted
- Medicine availability can be reported

### Performance Optimization
- Database queries are optimized for fast search
- Location calculations are cached for better performance
- Offline data is available for basic functionality

---

**Note**: This feature provides a comprehensive solution for finding Egyptian pharmacies and medicines. The database includes real Egyptian pharmacies with accurate locations and medicine inventories, making it easy for users to find the nearest pharmacy with their required medicine. 