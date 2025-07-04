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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RePharmaApp());
}

class RePharmaApp extends StatefulWidget {
  const RePharmaApp({Key? key}) : super(key: key);

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(onLocaleChange: _setLocale);
          } else {
            return const LoginScreen();
          }
        },
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
          MaterialPageRoute(builder: (context) => HomeScreen(onLocaleChange: (locale) {
            // You may want to handle locale change here or pass a callback from above
          })),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                'assets/project_logo.jpg',
                height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to RePharma',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
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
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
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
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const HomeScreen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFeature = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  String _getLocalizedLabel(AppLocalizations loc, String key) {
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
      case 'profile':
        return 'User Profile'; // Add to localization if needed
      default:
        return key;
    }
  }

  final List<_Feature> _features = [
    _Feature(icon: Icons.home, labelKey: 'home'),
    _Feature(icon: Icons.search, labelKey: 'searchMedicines', pageBuilder: (_, __) => MedicineSearchScreen()),
    _Feature(icon: Icons.favorite, labelKey: 'favourites', pageBuilder: (onLocaleChange, locale) => FavouritesScreen()),
    _Feature(icon: Icons.alarm, labelKey: 'medicineAlerts', pageBuilder: (onLocaleChange, locale) => MedicineAlertsScreen()),
    _Feature(icon: Icons.contact_mail, labelKey: 'contactUs', pageBuilder: (onLocaleChange, locale) => ContactUsScreen()),
    _Feature(icon: Icons.article, labelKey: 'news', pageBuilder: (onLocaleChange, locale) => NewsScreen()),
    _Feature(icon: Icons.info, labelKey: 'about', pageBuilder: (onLocaleChange, locale) => AboutScreen()),
    _Feature(
      icon: Icons.person,
      labelKey: 'profile',
      pageBuilder: (onLocaleChange, locale) {
        final user = FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? '';
        final email = user?.email ?? '';
        return ProfileScreen(name: name, email: email);
      },
    ),
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
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
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
                                    _getLocalizedLabel(loc, feature.labelKey),
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
                  _getLocalizedLabel(loc, _features[_selectedFeature].labelKey),
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
            ],
          ),
        ),
      ),
    );
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
  const FeatureCard({Key? key, required this.icon, required this.label, required this.onTap, required this.color}) : super(key: key);

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

  const MedicineSearchScreen({Key? key, this.locale, this.onLocaleChange}) : super(key: key);

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
