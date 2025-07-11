# Pharmacy Search Feature

## Overview
The RePharma app now includes a comprehensive pharmacy search feature that allows users to find nearby pharmacies and search for specific medicines.

## Features

### 1. Pharmacy Search Screen
- **Location-based search**: Finds pharmacies near the user's current location
- **Medicine filtering**: Search for pharmacies that have specific medicines in stock
- **Real-time data**: Shows pharmacy status (open/closed), working hours, and available medicines
- **Distance calculation**: Displays distance from user's location to each pharmacy
- **Bilingual support**: Full Arabic and English interface

### 2. Key Functionality
- **GPS Integration**: Uses device location to find nearest pharmacies
- **Medicine Availability**: Filter pharmacies by specific medicine names
- **Contact Information**: Direct access to pharmacy phone numbers
- **Directions**: Get directions to selected pharmacies
- **Detailed Information**: View complete pharmacy details including all available medicines

### 3. User Interface
- **Modern Design**: Clean, intuitive interface with cards and icons
- **Search Filters**: Two search fields - pharmacy name/address and medicine name
- **Status Indicators**: Visual indicators for open/closed status
- **Distance Display**: Shows distance in meters or kilometers
- **Medicine Tags**: Displays available medicines as tags

## Technical Implementation

### Files Added/Modified

#### New Files:
1. **`lib/pharmacy_model.dart`** - Pharmacy data model
2. **`lib/location_service.dart`** - GPS and location services
3. **`lib/pharmacy_search_screen.dart`** - Main pharmacy search interface
4. **`lib/sample_data.dart`** - Sample data for testing

#### Modified Files:
1. **`lib/main.dart`** - Added pharmacy search to home screen features
2. **`lib/medicine_search_screen.dart`** - Added pharmacy search button to medicine items
3. **`lib/profile_screen.dart`** - Added sample data population button
4. **`pubspec.yaml`** - Added location and permission dependencies
5. **`android/app/src/main/AndroidManifest.xml`** - Added location permissions

### Dependencies Added:
- `geolocator: ^12.0.0` - GPS location services
- `geocoding: ^3.0.0` - Address geocoding
- `permission_handler: ^11.3.1` - Permission management

## Database Structure

### Pharmacies Collection
```javascript
{
  "name": "Pharmacy Name",
  "nameAr": "اسم الصيدلية",
  "address": "Pharmacy Address",
  "addressAr": "عنوان الصيدلية",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "phone": "+20 2 1234 5678",
  "workingHours": "24/7",
  "isOpen": true,
  "availableMedicines": ["Paracetamol", "Ibuprofen", ...]
}
```

### Medicines Collection
```javascript
{
  "nameEn": "Medicine Name",
  "nameAr": "اسم الدواء",
  "descriptionEn": "Medicine description",
  "descriptionAr": "وصف الدواء",
  "category": "Category",
  "categoryAr": "الفئة",
  "dosage": "Dosage information",
  "dosageAr": "معلومات الجرعة",
  "sideEffects": "Side effects",
  "sideEffectsAr": "الآثار الجانبية"
}
```

## Usage Instructions

### For Users:
1. **Access Pharmacy Search**: Tap the pharmacy icon on the home screen
2. **Enable Location**: Grant location permissions when prompted
3. **Search Pharmacies**: Use the search bar to find pharmacies by name or address
4. **Filter by Medicine**: Enter a medicine name to find pharmacies that have it
5. **View Details**: Tap on a pharmacy card to see full details
6. **Contact Pharmacy**: Use the phone button to call the pharmacy
7. **Get Directions**: Use the directions button for navigation

### For Developers:
1. **Populate Sample Data**: Go to Profile screen and tap "Populate Sample Data"
2. **Test Location Services**: Ensure GPS is enabled on the device
3. **Add Real Data**: Replace sample data with actual pharmacy information

## Features in Detail

### Location Services
- Automatic GPS detection
- Distance calculation using Haversine formula
- Permission handling for location access
- Fallback to show all pharmacies if location unavailable

### Search and Filtering
- Real-time search as you type
- Filter by pharmacy name (English/Arabic)
- Filter by address (English/Arabic)
- Filter by medicine availability
- Combined filtering (pharmacy + medicine)

### Pharmacy Information Display
- **Basic Info**: Name, address, phone, working hours
- **Status**: Open/closed indicator with color coding
- **Distance**: From user's location (if available)
- **Medicines**: List of available medicines with tags
- **Actions**: Call and directions buttons

### Responsive Design
- Works on different screen sizes
- Supports both portrait and landscape orientations
- Optimized for mobile devices
- Touch-friendly interface

## Future Enhancements

### Planned Features:
1. **Map Integration**: Show pharmacies on a map
2. **Reviews & Ratings**: User reviews for pharmacies
3. **Price Comparison**: Medicine prices across pharmacies
4. **Online Ordering**: Direct medicine ordering
5. **Pharmacy Chains**: Support for pharmacy networks
6. **Emergency Services**: 24/7 pharmacy highlighting
7. **Medicine Substitutes**: Alternative medicine suggestions

### Technical Improvements:
1. **Caching**: Offline pharmacy data
2. **Push Notifications**: Medicine availability alerts
3. **Analytics**: Usage tracking and insights
4. **API Integration**: Real-time inventory updates
5. **Machine Learning**: Smart medicine recommendations

## Testing

### Sample Data
The app includes comprehensive sample data for testing:
- 8 sample pharmacies across Cairo and Giza
- 7 common medicines with detailed information
- Realistic coordinates and contact information
- Varied working hours and availability status

### Test Scenarios
1. **Location Services**: Test with GPS enabled/disabled
2. **Search Functionality**: Test with various search terms
3. **Medicine Filtering**: Test with different medicine names
4. **Bilingual Support**: Test in both English and Arabic
5. **Network Connectivity**: Test with poor/no internet

## Troubleshooting

### Common Issues:
1. **Location Not Working**: Check GPS permissions and settings
2. **No Pharmacies Found**: Ensure sample data is populated
3. **Search Not Working**: Check internet connectivity
4. **App Crashes**: Verify all dependencies are installed

### Solutions:
1. **Location Issues**: Go to device settings and enable location for the app
2. **Data Issues**: Use the "Populate Sample Data" button in Profile screen
3. **Network Issues**: Check internet connection and Firebase configuration
4. **Dependency Issues**: Run `flutter pub get` to install missing packages

## Security Considerations

### Location Privacy:
- Location data is only used for distance calculation
- No location data is stored permanently
- User consent is required for location access

### Data Protection:
- Pharmacy data is read-only for users
- No personal information is collected
- Firebase security rules should be configured appropriately

## Performance Optimization

### Best Practices:
1. **Lazy Loading**: Load pharmacy data on demand
2. **Caching**: Cache frequently accessed data
3. **Pagination**: Load pharmacies in batches
4. **Image Optimization**: Optimize pharmacy images
5. **Network Efficiency**: Minimize API calls

### Monitoring:
1. **App Performance**: Monitor app startup time
2. **Location Accuracy**: Track GPS accuracy
3. **Search Speed**: Monitor search response times
4. **User Experience**: Track user engagement metrics

This pharmacy search feature significantly enhances the RePharma app by providing users with a comprehensive tool to find medicines and pharmacies in their area, making healthcare more accessible and convenient. 