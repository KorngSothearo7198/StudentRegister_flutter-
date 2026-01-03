import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_register_app/models/student_model.dart';
import 'package:student_register_app/screens/student/chart_screen.dart';
// import '../../db/db_student/student_db.dart';
import 'student_home.dart';

class LoginAccountScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const LoginAccountScreen({super.key, required this.student});

  @override
  State<LoginAccountScreen> createState() => _LoginAccountScreenState();
}

class _LoginAccountScreenState extends State<LoginAccountScreen> {
  late TextEditingController _idController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final id = widget.student['studentId'] ?? '';
    final password = widget.student['password'] ?? '';
    _idController = TextEditingController(text: id);
    _passwordController = TextEditingController(text: password);
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('students_joinName')
          .where('studentId', isEqualTo: _idController.text.trim())
          .where('password', isEqualTo: _passwordController.text.trim())
          .where('status', isEqualTo: 'Approved')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final student = Student.fromMap(doc.data(), docId: doc.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomeScreen(
              student: student.toMap(),
              studentName: student.lastName,
              openChatStudent: student.toMap(), // pass student to open chat
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Student ID, Password, or Account not Approved",
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Login Account"),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        // centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.security,
                    size: 80,
                    color: Color(0xFF0066CC),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Login to Your Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your credentials below",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _idController,
                            label: "Student ID",
                            icon: Icons.badge,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter your Student ID'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter your password'
                                : null,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF0066CC),
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Login Button with Loading State
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066CC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : _login, // Disable when loading
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Logging in...",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Full-screen Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0066CC),
                          strokeWidth: 4,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Signing in...",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 140, 155, 169),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: !_isLoading, // Disable input when loading
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0066CC)),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: _isLoading ? Colors.grey[200] : Colors.white,
      ),
    );
  }
}

//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:student_register_app/models/student_model.dart';
// import 'package:student_register_app/screens/student/student_home.dart';
//
// class LoginAccountScreen extends StatefulWidget {
//   final Map<String, dynamic> student;
//   const LoginAccountScreen({super.key, required this.student});
//
//   @override
//   State<LoginAccountScreen> createState() => _LoginAccountScreenState();
// }
//
// class _LoginAccountScreenState extends State<LoginAccountScreen>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _idController;
//   late TextEditingController _passwordController;
//   bool _obscurePassword = true;
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//
//   // Animation controllers
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     final id = widget.student['studentId'] ?? '';
//     final password = widget.student['password'] ?? '';
//     _idController = TextEditingController(text: id);
//     _passwordController = TextEditingController(text: password);
//
//     // Initialize animations
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.elasticOut,
//       ),
//     );
//
//     // Start animation after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _animationController.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _idController.dispose();
//     _passwordController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     // Dismiss keyboard
//     FocusScope.of(context).unfocus();
//
//     // Vibrate on tap
//     HapticFeedback.lightImpact();
//
//     setState(() => _isLoading = true);
//
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('students_joinName')
//           .where('studentId', isEqualTo: _idController.text.trim())
//           .where('password', isEqualTo: _passwordController.text.trim())
//           .where('status', isEqualTo: 'Approved')
//           .limit(1)
//           .get();
//
//       if (querySnapshot.docs.isNotEmpty) {
//         final doc = querySnapshot.docs.first;
//         final student = Student.fromMap(doc.data(), docId: doc.id);
//
//         if (!mounted) return;
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 const SizedBox(width: 8),
//                 const Text("Login successful!"),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             elevation: 10,
//           ),
//         );
//
//         // Navigate with animation
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => StudentHomeScreen(
//               student: student.toMap(),
//               studentName: student.lastName,
//               openChatStudent: student.toMap(), // pass student to open chat
//             ),
//           )
//         );
//       } else {
//         if (!mounted) return;
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "Invalid Student ID, Password, or Account not Approved",
//                     maxLines: 2,
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             elevation: 10,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       debugPrint("Login Error: $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.warning, color: Colors.white),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   "Login failed: ${e.toString()}",
//                   maxLines: 2,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.orange,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 10,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 360;
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text("Login Account"),
//         backgroundColor: const Color(0xFF0066CC),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
//           statusBarColor: const Color(0xFF0066CC),
//         ),
//       ),
//       body: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Stack(
//             children: [
//               // Main Content
//               SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isLandscape ? screenSize.width * 0.1 : 20,
//                   vertical: isLandscape ? 10 : 20,
//                 ),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     minHeight: screenSize.height,
//                   ),
//                   child: IntrinsicHeight(
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (!isLandscape) ...[
//                             SizedBox(height: screenSize.height * 0.02),
//                             Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: Transform.scale(
//                                 scale: _scaleAnimation.value,
//                                 child: Icon(
//                                   Icons.security,
//                                   size: isSmallScreen ? 60 : 80,
//                                   color: const Color(0xFF0066CC),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: screenSize.height * 0.02),
//                             Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: isSmallScreen ? 8.0 : 0.0,
//                                 ),
//                                 child: Text(
//                                   "Login to Your Account",
//                                   style: TextStyle(
//                                     fontSize: isSmallScreen ? 20 : 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFF1A1A1A),
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: screenSize.height * 0.01),
//                             Text(
//                               "Enter your credentials below",
//                               style: TextStyle(
//                                 fontSize: isSmallScreen ? 14 : 16,
//                                 color: Colors.grey[700],
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: screenSize.height * 0.04),
//                           ] else ...[
//                             // Landscape layout
//                             Opacity(
//                               opacity: _fadeAnimation.value,
//                               child: Transform.scale(
//                                 scale: _scaleAnimation.value,
//                                 child: Column(
//                                   children: [
//                                     Icon(
//                                       Icons.security,
//                                       size: screenSize.height * 0.15,
//                                       color: const Color(0xFF0066CC),
//                                     ),
//                                     SizedBox(height: screenSize.height * 0.02),
//                                     Text(
//                                       "Login to Your Account",
//                                       style: TextStyle(
//                                         fontSize: screenSize.height * 0.025,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     SizedBox(height: screenSize.height * 0.01),
//                                     Text(
//                                       "Enter your credentials below",
//                                       style: TextStyle(
//                                         fontSize: screenSize.height * 0.018,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: screenSize.height * 0.03),
//                           ],
//
//                           // Login Card
//                           Opacity(
//                             opacity: _fadeAnimation.value,
//                             child: Transform.scale(
//                               scale: _scaleAnimation.value,
//                               child: Container(
//                                 width: isLandscape
//                                     ? screenSize.width * 0.6
//                                     : double.infinity,
//                                 constraints: BoxConstraints(
//                                   maxWidth: 500,
//                                 ),
//                                 child: Card(
//                                   elevation: 8,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
//                                     child: Column(
//                                       children: [
//                                         _buildTextField(
//                                           isSmallScreen: isSmallScreen,
//                                           controller: _idController,
//                                           label: "Student ID",
//                                           icon: Icons.badge,
//                                           validator: (value) => value?.isEmpty ?? true
//                                               ? 'Please enter your Student ID'
//                                               : null,
//                                         ),
//                                         SizedBox(height: isSmallScreen ? 12 : 20),
//                                         _buildTextField(
//                                           isSmallScreen: isSmallScreen,
//                                           controller: _passwordController,
//                                           label: "Password",
//                                           icon: Icons.lock,
//                                           obscureText: _obscurePassword,
//                                           validator: (value) => value?.isEmpty ?? true
//                                               ? 'Please enter your password'
//                                               : null,
//                                           suffix: IconButton(
//                                             icon: Icon(
//                                               _obscurePassword
//                                                   ? Icons.visibility_off
//                                                   : Icons.visibility,
//                                               color: const Color(0xFF0066CC),
//                                               size: isSmallScreen ? 20 : 24,
//                                             ),
//                                             onPressed: () {
//                                               HapticFeedback.selectionClick();
//                                               setState(() => _obscurePassword = !_obscurePassword);
//                                             },
//                                           ),
//                                         ),
//                                         SizedBox(height: isSmallScreen ? 20 : 30),
//
//                                         // Login Button
//                                         SizedBox(
//                                           width: double.infinity,
//                                           height: isSmallScreen ? 48 : 56,
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: const Color(0xFF0066CC),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(16),
//                                               ),
//                                               elevation: 4,
//                                             ),
//                                             onPressed: _isLoading ? null : _login,
//                                             child: _isLoading
//                                                 ? SizedBox(
//                                               width: isSmallScreen ? 16 : 24,
//                                               height: isSmallScreen ? 16 : 24,
//                                               child: CircularProgressIndicator(
//                                                 color: Colors.white,
//                                                 strokeWidth: isSmallScreen ? 2.0 : 2.5,
//                                               ),
//                                             )
//                                                 : Text(
//                                               "Login",
//                                               style: TextStyle(
//                                                 fontSize: isSmallScreen ? 16 : 18,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//
//                                         SizedBox(height: isSmallScreen ? 12 : 20),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(height: screenSize.height * 0.03),
//
//                           // Bottom text
//                           if (!isLandscape)
//                             Text(
//                               "Need help? Contact your administrator",
//                               style: TextStyle(
//                                 fontSize: isSmallScreen ? 12 : 14,
//                                 color: Colors.grey[600],
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Loading Overlay
//               if (_isLoading)
//                 Container(
//                   color: Colors.black54,
//                   child: Center(
//                     child: Card(
//                       elevation: 10,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: isSmallScreen ? 40 : 60,
//                               height: isSmallScreen ? 40 : 60,
//                               child: CircularProgressIndicator(
//                                 color: const Color(0xFF0066CC),
//                                 strokeWidth: isSmallScreen ? 3 : 4,
//                               ),
//                             ),
//                             SizedBox(height: isSmallScreen ? 12 : 16),
//                             Text(
//                               "Signing in...",
//                               style: TextStyle(
//                                 fontSize: isSmallScreen ? 16 : 18,
//                                 color: const Color.fromARGB(255, 140, 155, 169),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required bool isSmallScreen,
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     String? Function(String?)? validator,
//     Widget? suffix,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       validator: validator,
//       enabled: !_isLoading,
//       style: TextStyle(
//         fontSize: isSmallScreen ? 16 : 18,
//         fontWeight: FontWeight.bold,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           fontSize: isSmallScreen ? 14 : 16,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: const Color(0xFF0066CC),
//           size: isSmallScreen ? 20 : 24,
//         ),
//         suffixIcon: suffix,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         filled: true,
//         fillColor: _isLoading ? Colors.grey[200] : Colors.white,
//         contentPadding: EdgeInsets.symmetric(
//           vertical: isSmallScreen ? 12 : 16,
//           horizontal: isSmallScreen ? 12 : 16,
//         ),
//       ),
//     );
//   }
// }