import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'medicine_search_screen.dart'; // 👈 New import
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'medicine_alerts_screen.dart';
import 'contact_us_screen.dart';
import 'news_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import 'favourites_screen.dart';
import 'medicine_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pharmacy_search_screen.dart';
import 'pharmacy_search_screen.dart';
import 'health_profile_screen.dart';
import 'health_profile_service.dart';
import 'health_profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RePharmaApp());
}

class RePharmaApp extends StatefulWidget {
  const RePharmaApp({super.key});

  @override
  State<RePharmaApp> createState() => _RePharmaAppState();
}

class _RePharmaAppState extends State<RePharmaApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RePharma',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, show main navigation
          return MainNavigation();
        } else {
          // User is not logged in, show login screen
          return LoginScreen();
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    HomeScreen(onLocaleChange: (locale) {}),
    MedicineSearchScreen(),
    PharmacySearchScreen(),
    FavouritesScreen(),
    MedicineAlertsScreen(),
    ContactUsScreen(),
    NewsScreen(),
    AboutScreen(),
    ProfileScreen(),
    HealthProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: 'Pharmacy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;
        print('✅ Login successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      } catch (e) {
        if (!mounted) return;
        print('❌ General login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Language Switcher
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'en') {
                    // Find the nearest _RePharmaAppState and call _setLocale
                    final state = context.findAncestorStateOfType<_RePharmaAppState>();
                    state?._setLocale(const Locale('en'));
                  } else if (value == 'ar') {
                    final state = context.findAncestorStateOfType<_RePharmaAppState>();
                    state?._setLocale(const Locale('ar'));
                  }
                },
                icon: const Icon(Icons.language),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  const PopupMenuItem(
                    value: 'ar',
                    child: Text('العربية'),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_pharmacy,
                      size: 80,
                      color: Colors.teal[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to RePharma',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Egyptian Drug Platform',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const HomeScreen({super.key, required this.onLocaleChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFeature = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  String _getLocalizedLabel(AppLocalizations loc, String key, Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    switch (key) {
      case 'home':
        return loc.welcome;
      case 'searchMedicines':
        return loc.searchMedicines;
      case 'favourites':
        return loc.favourites;
      case 'medicineAlerts':
        return 'Medicine Alerts'; // Add to localization if needed
      case 'contactUs':
        return 'Contact Us'; // Add to localization if needed
      case 'news':
        return loc.news;
      case 'about':
        return loc.about;
      case 'pharmacySearch':
        return isArabic ? 'البحث عن الصيدليات' : 'Pharmacy Search';
      case 'profile':
        return 'User Profile'; // Add to localization if needed
      case 'healthProfile':
        return isArabic ? 'الملف الصحي' : 'Health Profile';
      default:
        return key;
    }
  }

  final List<_Feature> _features = [
    _Feature(icon: Icons.home, labelKey: 'home'),
    _Feature(icon: Icons.search, labelKey: 'searchMedicines', pageBuilder: (_, __) => MedicineSearchScreen()),
    _Feature(icon: Icons.local_pharmacy, labelKey: 'pharmacySearch', pageBuilder: (_, __) => PharmacySearchScreen()),
    _Feature(icon: Icons.favorite, labelKey: 'favourites', pageBuilder: (onLocaleChange, locale) => FavouritesScreen()),
    _Feature(icon: Icons.alarm, labelKey: 'medicineAlerts', pageBuilder: (onLocaleChange, locale) => MedicineAlertsScreen()),
    _Feature(icon: Icons.contact_mail, labelKey: 'contactUs', pageBuilder: (onLocaleChange, locale) => ContactUsScreen()),
    _Feature(icon: Icons.article, labelKey: 'news', pageBuilder: (onLocaleChange, locale) => NewsScreen()),
    _Feature(icon: Icons.info, labelKey: 'about', pageBuilder: (onLocaleChange, locale) => AboutScreen()),
    _Feature(icon: Icons.person, labelKey: 'profile', pageBuilder: (onLocaleChange, locale) => ProfileScreen()),
    _Feature(icon: Icons.health_and_safety, labelKey: 'healthProfile', pageBuilder: (onLocaleChange, locale) => HealthProfileScreen()),
  ];

  void _goToFeature(int index) {
    setState(() {
      _selectedFeature = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'ري فارما' : 'RePharma',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              isArabic ? 'منصة الأدوية المصرية' : 'Egyptian Drug Platform',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: loc.favourites,
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'en') {
                widget.onLocaleChange(const Locale('en'));
              } else if (value == 'ar') {
                widget.onLocaleChange(const Locale('ar'));
              }
            },
            icon: const Icon(Icons.language),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              PopupMenuItem(
                value: 'ar',
                child: Text('العربية'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!, Colors.cyan[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.blue[700],
                      iconSize: 32,
                      onPressed: _selectedFeature > 0
                          ? () => _goToFeature(_selectedFeature - 1)
                          : null,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _features.length,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedFeature = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final feature = _features[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: _selectedFeature == index ? 0 : 16),
                              decoration: BoxDecoration(
                                color: _selectedFeature == index ? Colors.blue[700] : Colors.blue[300],
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  if (_selectedFeature == index)
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: feature.pageBuilder != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => feature.pageBuilder!(widget.onLocaleChange, Localizations.localeOf(context)),
                                          ),
                                        );
                                      }
                                    : () {},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(feature.icon, size: 48, color: Colors.white),
                                    const SizedBox(height: 12),
                                    Text(
                                      _getLocalizedLabel(loc, feature.labelKey, Localizations.localeOf(context)),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.blue[700],
                      iconSize: 32,
                      onPressed: _selectedFeature < _features.length - 1
                          ? () => _goToFeature(_selectedFeature + 1)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _getLocalizedLabel(loc, _features[_selectedFeature].labelKey, Localizations.localeOf(context)),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.cyan[700], size: 32),
                            const SizedBox(width: 12),
                            Text(
                              isArabic ? 'نصيحة صحية اليوم' : 'Health Tip of the Day',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isArabic
                              ? 'اشرب كمية كافية من الماء يومياً للحفاظ على صحتك.'
                              : 'Drink enough water every day to stay healthy.',
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Health Profile Summary Card
                FutureBuilder<UserHealthProfile?>(
                  future: HealthProfileService.getUserHealthProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text(
                                isArabic ? 'جاري تحميل الملف الصحي...' : 'Loading health profile...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final healthProfile = snapshot.data;
                    if (healthProfile == null) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.health_and_safety, color: Colors.green[700], size: 32),
                                  SizedBox(width: 12),
                                  Text(
                                    isArabic ? 'الملف الصحي' : 'Health Profile',
                                    style: TextStyle(
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                isArabic 
                                    ? 'لم يتم إنشاء ملف صحي بعد. انقر هنا لإضافة معلوماتك الصحية.'
                                    : 'No health profile created yet. Click here to add your health information.',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HealthProfileScreen()),
                                  );
                                },
                                icon: Icon(Icons.add),
                                label: Text(isArabic ? 'إنشاء ملف صحي' : 'Create Health Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.health_and_safety, color: Colors.green[700], size: 32),
                                SizedBox(width: 12),
                                Text(
                                  isArabic ? 'الملف الصحي' : 'Health Profile',
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.green[700]),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => HealthProfileScreen()),
                                    );
                                  },
                                  tooltip: isArabic ? 'تعديل' : 'Edit',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Basic Info
                            if (healthProfile.age > 0 || healthProfile.weight > 0 || healthProfile.bloodType.isNotEmpty || healthProfile.gender.isNotEmpty)
                              _buildInfoRow(
                                isArabic ? 'المعلومات الأساسية' : 'Basic Info',
                                _getBasicInfoText(healthProfile, isArabic),
                                Icons.person,
                              ),
                            
                            // Health Conditions
                            if (healthProfile.healthConditions.isNotEmpty)
                              _buildInfoRow(
                                isArabic ? 'الحالات الصحية' : 'Health Conditions',
                                healthProfile.healthConditions.take(3).join(', ') + (healthProfile.healthConditions.length > 3 ? '...' : ''),
                                Icons.medical_services,
                                count: healthProfile.healthConditions.length,
                              ),
                            
                            // Current Medications
                            if (healthProfile.currentMedications.isNotEmpty)
                              _buildInfoRow(
                                isArabic ? 'الأدوية الحالية' : 'Current Medications',
                                healthProfile.currentMedications.take(3).join(', ') + (healthProfile.currentMedications.length > 3 ? '...' : ''),
                                Icons.medication,
                                count: healthProfile.currentMedications.length,
                              ),
                            
                            // Allergies
                            if (healthProfile.allergies.isNotEmpty)
                              _buildInfoRow(
                                isArabic ? 'الحساسية' : 'Allergies',
                                healthProfile.allergies.take(3).join(', ') + (healthProfile.allergies.length > 3 ? '...' : ''),
                                Icons.warning,
                                count: healthProfile.allergies.length,
                              ),
                            
                            // Emergency Contacts
                            if (healthProfile.emergencyContacts.isNotEmpty)
                              _buildInfoRow(
                                isArabic ? 'جهات الاتصال الطارئة' : 'Emergency Contacts',
                                '${healthProfile.emergencyContacts.length} ${isArabic ? 'جهة اتصال' : 'contact(s)'}',
                                Icons.emergency,
                              ),
                            
                            // Empty state
                            if (healthProfile.age == 0 && healthProfile.weight == 0 && healthProfile.bloodType.isEmpty && 
                                healthProfile.gender.isEmpty && healthProfile.healthConditions.isEmpty && 
                                healthProfile.currentMedications.isEmpty && healthProfile.allergies.isEmpty && 
                                healthProfile.emergencyContacts.isEmpty)
                              Text(
                                isArabic 
                                    ? 'لم يتم إضافة معلومات صحية بعد. انقر على أيقونة التعديل لإضافة معلوماتك.'
                                    : 'No health information added yet. Click the edit icon to add your information.',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon, {int? count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          if (count != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getBasicInfoText(UserHealthProfile profile, bool isArabic) {
    List<String> info = [];
    
    if (profile.age > 0) {
      info.add('${isArabic ? 'العمر' : 'Age'}: ${profile.age}');
    }
    if (profile.weight > 0) {
      info.add('${isArabic ? 'الوزن' : 'Weight'}: ${profile.weight} kg');
    }
    if (profile.bloodType.isNotEmpty) {
      info.add('${isArabic ? 'فصيلة الدم' : 'Blood Type'}: ${profile.bloodType}');
    }
    if (profile.gender.isNotEmpty) {
      info.add('${isArabic ? 'الجنس' : 'Gender'}: ${profile.gender}');
    }
    
    return info.join(', ');
  }
}

class _Feature {
  final IconData icon;
  final String labelKey;
  final Widget Function(void Function(Locale) onLocaleChange, Locale locale)? pageBuilder;
  _Feature({required this.icon, required this.labelKey, this.pageBuilder});
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const FeatureCard({super.key, required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),  
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineSearchScreen extends StatefulWidget {
  final Locale? locale;
  final void Function(Locale)? onLocaleChange;

  const MedicineSearchScreen({super.key, this.locale, this.onLocaleChange});

  @override
  State<MedicineSearchScreen> createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool searchByName = true;
  List<DocumentSnapshot> results = [];
  bool hasSearched = false;

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
      hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = (widget.locale ?? Localizations.localeOf(context)).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "البحث عن الأدوية" : "Search Medicines"),
        actions: [
          Switch(
            value: searchByName,
            onChanged: (value) {
              setState(() {
                searchByName = value;
                results.clear();
                _searchController.clear();
                hasSearched = false;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(searchByName
                ? (isArabic ? "الاسم" : "Name")
                : (isArabic ? "المادة الفعالة" : "Ingredient")),
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
                labelText: searchByName
                    ? (isArabic ? 'ابحث بالاسم' : 'Search by name')
                    : (isArabic ? 'ابحث بالمادة الفعالة' : 'Search by active ingredient'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text.trim()),
                ),
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !hasSearched
                  ? Center(
                      child: Text(
                        isArabic
                            ? "يرجى إدخال كلمة للبحث."
                            : "Please enter a query to search.",
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    )
                  : results.isEmpty
                      ? Center(
                          child: Text(
                            isArabic
                                ? "لا توجد نتائج."
                                : "No results found.",
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final med = results[index].data() as Map<String, dynamic>;
                            return Card(
                              child: ListTile(
                                title: Text(med['name'] ?? (isArabic ? 'بدون اسم' : 'Unnamed')),
                                subtitle: Text(med['pharmacology'] ?? (isArabic ? 'لا يوجد وصف' : 'No description')),
                                onTap: () {
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
