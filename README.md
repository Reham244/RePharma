# Repharma

The idea behind RePharma is to create a seamless and intelligent solution for medication accessibility and management. The core concept revolves around providing users with an innovative platform that utilizes advanced technology to address the challenges of medication unavailability and accessibility.

## Core Features
- **Substitute Search** by name and active ingredient
- **Secure Authentication** via Firebase
- **Offline Support** using Firestore cache
- **Smart Query Algorithms**
  - Prefix matching with Unicode range
  - Null-safe data rendering
  - Substitute lookup by field queries
## Dataset
- Manually curated Firestore collection containing:
  - Medicine name, ingredient, form, price
  - Verified substitutes linked by name
- Optimized for Egyptian pharmaceuticals
- Enables scalable and localized substitute logic

  ## Installation
1. Enable USB debugging on your Android device
2. Connect via USB
3. Run:
```bash
flutter pub get
flutter run
