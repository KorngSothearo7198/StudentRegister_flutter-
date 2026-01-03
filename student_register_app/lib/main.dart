// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_register_app/data/sample_students.dart';
import 'package:student_register_app/screens/splash_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'firebase_options.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_login.dart';
import 'screens/student/student_home.dart';

// Your AdminModel
import 'models/admin/admin_model.dart';

// Import for Android
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase

    // Set platform implementation for WebView
  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = AndroidWebViewPlatform(); // For Android
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Register',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        fontFamily: 'Inter',
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper: decides which screen to show
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in → check role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(
                  'users',
                ) // <-- adjust if you use 'admins' collection
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // if (docSnapshot.hasData && docSnapshot.data!.exists) {
              //   final data = docSnapshot.data!.data() as Map<String, dynamic>;
              //   // final data = docSnapshot.data!.data() as Map<String, dynamic>;

              //   final role = data['role'] as String?;

              //   // if (role == 'admin') {
              //   //   final admin = AdminModel.fromMap(data); // <-- fix here
              //   //   return AdminDashboard(admin: admin);
              //   // } else if (role == 'student') {
              //   //   return StudentHomeScreen(student: data, studentName: '');
              //   // }
              // }

              // No valid role → logout
              FirebaseAuth.instance.signOut();
              return const WelcomeScreen();
            },
          );
        }

        // Not logged in
        return const WelcomeScreen();
      },
    );
  }
}

// Welcome Screen (unchanged)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildHeader(isSmall),
                  SizedBox(height: screenHeight * 0.05),
                  _buildOptionsSection(isSmall),
                  SizedBox(height: screenHeight * 0.05),
                  _buildFooter(),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Column(
      children: [
        Container(
          width: isSmall ? 80 : 100,
          height: isSmall ? 80 : 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.blue[700]!],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
              ),
            ],
          ),
          child: Icon(Icons.school_rounded, size: isSmall ? 40 : 50, color: Colors.white),
        ),
        SizedBox(height: isSmall ? 16 : 24),
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: isSmall ? 20 : 28,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
        Text(
          'Student Register',
          style: TextStyle(fontSize: isSmall ? 28 : 36, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: isSmall ? 8 : 16),
        Text(
          'Your gateway to seamless education management',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isSmall ? 12 : 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(bool isSmall) {
    return Column(
      children: [
        _buildCard(
          icon: Icons.school_rounded,
          title: "Student Portal",
          subtitle: "Access your courses, payments, and profile",
          colors: [AppColors.primary, Colors.blue[700]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SplashScreen()),
          ),
          isSmall: isSmall,
        ),
        SizedBox(height: isSmall ? 12 : 20),
        _buildCard(
          icon: Icons.admin_panel_settings_rounded,
          title: "Admin Panel",
          subtitle: "Manage students, payments, and system settings",
          colors: [Colors.redAccent, Colors.red[700]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          ),
          isSmall: isSmall,
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(isSmall ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmall ? 50 : 60,
              height: isSmall ? 50 : 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: isSmall ? 24 : 30, color: Colors.white),
            ),
            SizedBox(width: isSmall ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        color: Colors.white.withOpacity(0.8),
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: isSmall ? 20 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Colors.grey[300], height: 40),
        const Text(
          'Secure • Reliable • Easy to Use',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Version smos',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}


// Colors
class AppColors {
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF2196F3, <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      });
  static const Color primary = Color(0xFF2196F3);
  static const Color background = Color(0xFFFAFAFA);
}
