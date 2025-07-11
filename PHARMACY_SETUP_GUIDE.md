# Pharmacy Search Setup Guide

## 🚨 Issue: No Pharmacies Displaying

The pharmacy search is not showing any pharmacies because the sample data hasn't been populated in the database yet. Follow these steps to fix this:

## 📋 Step-by-Step Solution

### Step 1: Populate Sample Data
1. **Open the RePharma app**
2. **Go to Profile Screen** (bottom navigation)
3. **Tap "Populate Sample Data"** button
4. **Wait for success message** - this will add 30+ Egyptian pharmacies and 20+ medicines to your database

### Step 2: Test Database Connection
1. **Still in Profile Screen**
2. **Tap "Test Database"** button
3. **Check the result** - should show something like "Database Test: 30 pharmacies, 20 medicines"

### Step 3: Test Pharmacy Search
1. **Go to Pharmacy Search** (from main menu or medicine search)
2. **Check the debug info** - tap the bug icon (🐛) in the top right
3. **Look at console logs** - should show pharmacy loading information

### Step 4: Test Medicine Search
1. **In Pharmacy Search screen**
2. **Enter "Panadol"** in the medicine filter field
3. **Should see pharmacies** that have Panadol in stock

## 🔍 Debug Information

### Console Logs to Look For:
```
🔍 Loading pharmacies from Firestore...
📊 Found 30 pharmacy documents
🏥 Loaded 30 pharmacies
📍 Calculating distances from current position...
📏 Sorted pharmacies by distance
✅ Pharmacy loading completed. Total: 30, Filtered: 30
```

### If You See "Found 0 pharmacy documents":
- The sample data hasn't been populated yet
- Go back to Step 1 and populate the data

### If You See Errors:
- Check your Firebase connection
- Ensure you have proper internet connection
- Verify Firebase configuration is correct

## 🧪 Testing Scenarios

### Test 1: Basic Pharmacy Search
- Open Pharmacy Search
- Should see 30+ pharmacies listed
- Pharmacies should be sorted by distance

### Test 2: Medicine Filter
- Enter "Panadol" in medicine filter
- Should see only pharmacies with Panadol
- Clear filter to see all pharmacies again

### Test 3: Text Search
- Enter "Cairo" in search field
- Should see only Cairo pharmacies
- Try "Alexandria" for Alexandria pharmacies

### Test 4: Medicine Search Integration
- Go to Medicine Search
- Tap pharmacy icon next to any medicine
- Should open Pharmacy Search with that medicine pre-filtered

## 🛠️ Troubleshooting

### Problem: "No pharmacies available" message
**Solution**: 
1. Tap "Load Sample Data" button in the empty state
2. Or go to Profile → "Populate Sample Data"

### Problem: Database test shows 0 pharmacies
**Solution**:
1. Check Firebase connection
2. Ensure you're logged in
3. Try populating data again

### Problem: Medicine filter not working
**Solution**:
1. Try searching for "Panadol" (exact spelling)
2. Check console logs for debug info
3. Ensure medicine name matches exactly

### Problem: Location not working
**Solution**:
1. Grant location permissions to the app
2. Tap location icon to refresh
3. Check if GPS is enabled on device

## 📱 Expected Results

### After Populating Data:
- **30+ Egyptian pharmacies** across major cities
- **20+ common medicines** with prices in EGP
- **Real GPS coordinates** for accurate distance calculation
- **Bilingual support** (English/Arabic)

### Pharmacy Information Includes:
- Pharmacy name (English & Arabic)
- Full address (English & Arabic)
- Phone number
- Working hours
- Open/closed status
- Distance from your location
- Available medicines list

### Medicine Information Includes:
- Medicine name (English & Arabic)
- Detailed description
- Dosage information
- Side effects
- Price range in EGP

## 🎯 Quick Test Commands

### In Profile Screen:
```dart
// Test database connection
await SampleData.populateSampleData();
```

### In Pharmacy Search:
```dart
// Check loaded pharmacies
print('Pharmacies loaded: ${_pharmacies.length}');
print('Filtered results: ${_filteredPharmacies.length}');
```

## 📞 Support

If you're still having issues:
1. Check the console logs for error messages
2. Verify Firebase configuration
3. Ensure all dependencies are installed
4. Test with a simple medicine name like "Panadol"

---

**Remember**: The pharmacy search feature requires the sample data to be populated first. Once the data is loaded, you'll be able to search for pharmacies by location and medicine availability. 