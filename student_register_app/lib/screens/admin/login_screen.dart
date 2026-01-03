

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/admin/admin_model.dart';
// import '../chart/chat_student_list_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//   bool loading = false;
//   bool _obscurePassword = true;
//   final _formKey = GlobalKey<FormState>();
//
//   // Modern color scheme
//   static const Color primaryColor = Color(0xFF0066CC);
//   static const Color accentColor = Color(0xFF4D8BFF);
//   static const Color lightBlue = Color(0xFFE8F4FF);
//   static const Color backgroundColor = Color(0xFFF8FAFF);
//   static const Color textLight = Color(0xFF6B7280);
//
//   Future<AdminModel?> fetchCurrentAdmin(String uid) async {
//     final doc = await FirebaseFirestore.instance
//         .collection('admins')
//         .doc(uid)
//         .get();
//     if (doc.exists) {
//       return AdminModel.fromFirestore(doc);
//     }
//     return null;
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => loading = true);
//     try {
//       final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailCtrl.text.trim(),
//         password: passwordCtrl.text.trim(),
//       );
//
//       final admin = await fetchCurrentAdmin(userCred.user!.uid);
//
//       if (admin == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Admin data not found'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//         setState(() => loading = false);
//         return;
//       }
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ChatStudentListScreen(currentAdmin: admin),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'Login failed';
//
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Incorrect password';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'Invalid email address';
//       } else if (e.code == 'user-disabled') {
//         errorMessage = 'This account has been disabled';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Login failed. Please try again.'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     emailCtrl.dispose();
//     passwordCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top -
//                   MediaQuery.of(context).padding.bottom,
//             ),
//             child: Column(
//               children: [
//                 // Header section with illustration
//                 Container(
//                   height: 300,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [primaryColor, accentColor],
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(40),
//                       bottomRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         top: 40,
//                         right: 30,
//                         child: Opacity(
//                           opacity: 0.1,
//                           child: Icon(
//                             Icons.admin_panel_settings,
//                             size: 200,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.3),
//                                   width: 2,
//                                 ),
//                               ),
//                               child: Icon(
//                                 Icons.admin_panel_settings,
//                                 size: 50,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             const Text(
//                               'Admin Portal',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.w700,
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               'Secure access to student communications',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.9),
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Login form
//                 Padding(
//                   padding: const EdgeInsets.all(30),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 20),
//                         Text(
//                           'Welcome Back',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.grey[900],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Please sign in to continue',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: textLight,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//
//                         // Email field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Email Address',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: TextFormField(
//                                 controller: emailCtrl,
//                                 keyboardType: TextInputType.emailAddress,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter your email',
//                                   hintStyle: TextStyle(color: Colors.grey[500]),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 18,
//                                   ),
//                                   prefixIcon: Container(
//                                     margin: const EdgeInsets.all(12),
//                                     child: Icon(
//                                       Icons.email_outlined,
//                                       color: primaryColor,
//                                       size: 22,
//                                     ),
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your email';
//                                   }
//                                   if (!value.contains('@')) {
//                                     return 'Please enter a valid email';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 25),
//
//                         // Password field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Password',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: TextFormField(
//                                 controller: passwordCtrl,
//                                 obscureText: _obscurePassword,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter your password',
//                                   hintStyle: TextStyle(color: Colors.grey[500]),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 18,
//                                   ),
//                                   prefixIcon: Container(
//                                     margin: const EdgeInsets.all(12),
//                                     child: Icon(
//                                       Icons.lock_outline,
//                                       color: primaryColor,
//                                       size: 22,
//                                     ),
//                                   ),
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       _obscurePassword
//                                           ? Icons.visibility_outlined
//                                           : Icons.visibility_off_outlined,
//                                       color: Colors.grey[500],
//                                       size: 22,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         _obscurePassword = !_obscurePassword;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your password';
//                                   }
//                                   if (value.length < 6) {
//                                     return 'Password must be at least 6 characters';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 30),
//
//                         // Login button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 56,
//                           child: ElevatedButton(
//                             onPressed: loading ? null : _login,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               shadowColor: primaryColor.withOpacity(0.3),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             child: loading
//                                 ? SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.white,
//                                       ),
//                                     ),
//                                   )
//                                 : Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         'Sign In',
//                                         style: TextStyle(
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Icon(
//                                         Icons.arrow_forward_rounded,
//                                         size: 20,
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 25),
//
//                         // Additional info
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.security,
//                               size: 16,
//                               color: textLight,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Secure admin portal access',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: textLight,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Version info
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: lightBlue,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: primaryColor,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   'This portal is for authorized administrators only. '
//                                   'All activities are logged for security purposes.',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[700],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin/admin_model.dart';
import '../chart/chat_student_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Color(0xFF4D8BFF);
  static const Color lightBlue = Color(0xFFE8F4FF);
  static const Color backgroundColor = Color(0xFFF8FAFF);
  static const Color textLight = Color(0xFF6B7280);

  Future<AdminModel?> fetchCurrentAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();
    if (doc.exists) {
      return AdminModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final admin = await fetchCurrentAdmin(userCred.user!.uid);

      if (admin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Admin data not found'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() => loading = false);
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatStudentListScreen(currentAdmin: admin),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login failed. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: isLandscape
                ? Row(
              children: [
                // Left side - Illustration/Logo
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primaryColor, accentColor],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: screenWidth * 0.08,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                            ),
                            child: Text(
                              'Secure access to student communications',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: screenWidth * 0.025,
                                fontWeight: FontWeight.w400,
                                // textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right side - Login Form
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: _buildLoginForm(context),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                // Header section with illustration (Portrait)
                Container(
                  height: isSmallPhone ? screenHeight * 0.25 : screenHeight * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: isSmallPhone ? 20 : 40,
                        right: isSmallPhone ? 15 : 30,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: isSmallPhone ? 120 : 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: isSmallPhone
                                  ? screenWidth * 0.25
                                  : screenWidth * 0.2,
                              height: isSmallPhone
                                  ? screenWidth * 0.25
                                  : screenWidth * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: isSmallPhone
                                    ? screenWidth * 0.12
                                    : screenWidth * 0.1,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isSmallPhone ? 10 : 20),
                            Text(
                              'Admin Portal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallPhone
                                    ? screenWidth * 0.08
                                    : screenWidth * 0.075,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: isSmallPhone ? 5 : 10),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallPhone ? 20 : 40,
                              ),
                              child: Text(
                                'Secure access to student communications',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isSmallPhone
                                      ? screenWidth * 0.035
                                      : screenWidth * 0.04,
                                  fontWeight: FontWeight.w400,
                                  // textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Login form
                Padding(
                  padding: EdgeInsets.all(
                    isSmallPhone ? screenWidth * 0.04 : screenWidth * 0.05,
                  ),
                  child: _buildLoginForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isLandscape ? 0 : screenHeight * 0.02),
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: isSmallPhone ? screenWidth * 0.07 : screenWidth * 0.065,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            'Please sign in to continue',
            style: TextStyle(
              fontSize: isSmallPhone ? screenWidth * 0.038 : screenWidth * 0.04,
              color: textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: isSmallPhone
                      ? screenWidth * 0.035
                      : screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: isSmallPhone
                        ? screenWidth * 0.04
                        : screenWidth * 0.042,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isSmallPhone
                          ? screenWidth * 0.038
                          : screenWidth * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.all(screenWidth * 0.03),
                      child: Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                        size: screenWidth * 0.055,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontSize: isSmallPhone
                      ? screenWidth * 0.035
                      : screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: passwordCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    fontSize: isSmallPhone
                        ? screenWidth * 0.04
                        : screenWidth * 0.042,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isSmallPhone
                          ? screenWidth * 0.038
                          : screenWidth * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.all(screenWidth * 0.03),
                      child: Icon(
                        Icons.lock_outline,
                        color: primaryColor,
                        size: screenWidth * 0.055,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[500],
                        size: screenWidth * 0.055,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.03),

          // Login button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.065,
            child: ElevatedButton(
              onPressed: loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: primaryColor.withOpacity(0.3),
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              ),
              child: loading
                  ? SizedBox(
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: isSmallPhone
                          ? screenWidth * 0.042
                          : screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: screenWidth * 0.05,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.025),

          // Additional info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: screenWidth * 0.04,
                color: textLight,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Secure admin portal access',
                style: TextStyle(
                  fontSize: isSmallPhone
                      ? screenWidth * 0.033
                      : screenWidth * 0.035,
                  color: textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Version info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    'This portal is for authorized administrators only. '
                        'All activities are logged for security purposes.',
                    style: TextStyle(
                      fontSize: isSmallPhone
                          ? screenWidth * 0.032
                          : screenWidth * 0.035,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}