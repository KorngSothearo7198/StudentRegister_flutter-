// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../../models/admin/admin_model.dart';
// // import '../../widgets/custom_button.dart';
// // import '../../widgets/custom_textfield.dart';
// // import 'admin_dashboard.dart';
// // import 'admin_register.dart';
//
// // class AdminLoginScreen extends StatefulWidget {
// //   const AdminLoginScreen({super.key});
//
// //   @override
// //   State<AdminLoginScreen> createState() => _AdminLoginScreenState();
// // }
//
// // class _AdminLoginScreenState extends State<AdminLoginScreen> {
// //   final _emailCtrl = TextEditingController();
// //   final _passCtrl = TextEditingController();
// //   final _formKey = GlobalKey<FormState>();
// //   bool _isLoading = false;
// //   bool _showPass = false;
//
// //   // Future<void> _login() async {
// //   //   if (!_formKey.currentState!.validate()) return;
//
// //   //   setState(() => _isLoading = true);
//
// //   //   final email = _emailCtrl.text.trim();
// //   //   final password = _passCtrl.text.trim();
//
// //   //   print("=== ADMIN LOGIN START ===");
// //   //   print("Email entered: $email");
//
// //   //   try {
// //   //     // 1️⃣ Try Firebase Auth first
// //   //     UserCredential cred = await FirebaseAuth.instance
// //   //         .signInWithEmailAndPassword(email: email, password: password);
//
// //   //     print("✅ Firebase Auth login successful, UID: ${cred.user!.uid}");
//
// //   //     await _loadAdminFromFirestore(cred.user!.uid);
// //   //   } on FirebaseAuthException catch (e) {
// //   //     print("Firebase Auth failed: ${e.code} - ${e.message}");
//
// //   //     // 2️⃣ If Auth fails, check admins collection manually
// //   //     bool firestoreLogin = await _checkFirestorePassword(email, password);
//
// //   //     if (!firestoreLogin) {
// //   //       _showError("Wrong email or password for $email");
// //   //     }
// //   //   } catch (e) {
// //   //     print("Unexpected error: $e");
// //   //     _showError("Check your internet connection.");
// //   //   } finally {
// //   //     if (mounted) setState(() => _isLoading = false);
// //   //   }
// //   // }
//
// //   Future<void> _login() async {
// //     if (!_formKey.currentState!.validate()) return;
//
// //     setState(() => _isLoading = true);
//
// //     try {
// //       UserCredential cred = await FirebaseAuth.instance
// //           .signInWithEmailAndPassword(
// //             email: _emailCtrl.text.trim(),
// //             password: _passCtrl.text.trim(),
// //           );
//
// //       print("✅ Firebase login success UID: ${cred.user!.uid}");
//
// //       await _loadAdminFromFirestore(cred.user!.uid);
// //     } on FirebaseAuthException catch (e) {
// //       _showError(e.message ?? "Login failed");
// //     } finally {
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }
//
// //   Future<void> _loadAdminFromFirestore(String uid) async {
// //     DocumentReference adminRef = FirebaseFirestore.instance
// //         .collection('admins')
// //         .doc(uid);
// //     DocumentSnapshot doc = await adminRef.get();
//
// //     if (!doc.exists) {
// //       print("⚠️ Firestore admin doc not found, creating one...");
// //       await adminRef.set({
// //         'uid': uid,
// //         'email': _emailCtrl.text.trim(),
// //         'fullName': _emailCtrl.text.trim().split('@')[0],
// //         'profileImage': '',
// //         'id': null,
// //         'password': null,
// //       });
// //       doc = await adminRef.get();
// //     }
//
// //     final adminData = AdminModel(
// //       uid: doc.id,
// //       fullName: doc['fullName'],
// //       email: doc['email'],
// //       profileImage: doc['profileImage'],
// //       id: doc['id'],
// //     );
//
// //     print("Firestore admin loaded: ${adminData.fullName}, ${adminData.email}");
//
// //     if (mounted) {
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (_) => AdminDashboard(admin: adminData)),
// //       );
// //     }
// //   }
//
// //   Future<bool> _checkFirestorePassword(String email, String password) async {
// //     final query = await FirebaseFirestore.instance
// //         .collection("admins")
// //         .where("email", isEqualTo: email)
// //         .limit(1)
// //         .get();
//
// //     if (query.docs.isEmpty) {
// //       print("No admin found with that email in Firestore");
// //       return false;
// //     }
//
// //     final data = query.docs.first.data();
// //     final adminPassword = data["password"];
//
// //     if (adminPassword == password) {
// //       print("✅ Firestore login successful for $email");
//
// //       final adminData = AdminModel(
// //         uid: data["uid"],
// //         fullName: data["fullName"],
// //         email: data["email"],
// //         profileImage: data["profileImage"] ?? '',
// //         id: data["id"],
// //       );
//
// //       if (mounted) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (_) => AdminDashboard(admin: adminData)),
// //         );
// //       }
//
// //       return true;
// //     } else {
// //       print("❌ Firestore password incorrect for $email");
// //       return false;
// //     }
// //   }
//
// //   void _showError(String message) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Text("Login Failed"),
// //         content: Text(message),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       body: Center(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   Icons.admin_panel_settings,
// //                   size: 90,
// //                   color: Colors.redAccent,
// //                 ),
// //                 const SizedBox(height: 20),
// //                 const Text(
// //                   "Welcome Back Admin",
// //                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 40),
// //                 CustomTextField(
// //                   label: "Email",
// //                   controller: _emailCtrl,
// //                   prefixIcon: Icons.email_outlined,
// //                   keyboardType: TextInputType.emailAddress,
// //                   validator: (v) => v!.isEmpty || !v.contains("@")
// //                       ? "Enter valid email"
// //                       : null,
// //                 ),
// //                 const SizedBox(height: 16),
// //                 CustomTextField(
// //                   label: "Password",
// //                   controller: _passCtrl,
// //                   obscureText: !_showPass,
// //                   prefixIcon: Icons.lock_outline,
// //                   suffixIcon: IconButton(
// //                     icon: Icon(
// //                       _showPass ? Icons.visibility : Icons.visibility_off,
// //                     ),
// //                     onPressed: () => setState(() => _showPass = !_showPass),
// //                   ),
// //                   validator: (v) =>
// //                       v!.isEmpty || v.length < 6 ? "Password too short" : null,
// //                 ),
// //                 const SizedBox(height: 30),
// //                 CustomButton(
// //                   text: "Login as Admin",
// //                   isLoading: _isLoading,
// //                   color: Colors.redAccent,
// //                   onPressed: _login,
// //                 ),
// //                 const SizedBox(height: 20),
// //                 TextButton(
// //                   onPressed: () => Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (_) => const RegisterAdminScreen(),
// //                     ),
// //                   ),
// //                   child: const Text(
// //                     "Create new admin account",
// //                     style: TextStyle(color: Colors.redAccent),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
//
// //   @override
// //   void dispose() {
// //     _emailCtrl.dispose();
// //     _passCtrl.dispose();
// //     super.dispose();
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'dart:math';
//
// import 'dart:math';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../models/admin/admin_model.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_textfield.dart';
// import 'admin_dashboard.dart';
// import 'admin_register.dart';
//
// class AdminLoginScreen extends StatefulWidget {
//   const AdminLoginScreen({super.key});
//
//   @override
//   State<AdminLoginScreen> createState() => _AdminLoginScreenState();
// }
//
// class _AdminLoginScreenState extends State<AdminLoginScreen> {
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _showPass = false;
//   bool _isGoogleLoading = false;
//
//   // Professional Blue Color Scheme
//   static const Color primaryColor = Color(0xFF0066CC);
//   static const Color accentColor = Color(0xFF4D8BFF);
//   static const Color lightBlue = Color(0xFFE8F4FF);
//   static const Color darkBlue = Color(0xFF004A99);
//   static const Color backgroundColor = Color(0xFFF8FAFF);
//
//   // ========== EXISTING PROCESSES (UNCHANGED) ==========
//
//
//
//   String _generateTemporaryPassword() {
//     const chars =
//         'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
//     final random = Random.secure();
//     return String.fromCharCodes(
//       List.generate(10, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
//     );
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       UserCredential cred = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//             email: _emailCtrl.text.trim(),
//             password: _passCtrl.text.trim(),
//           );
//
//       print("✅ Firebase login success UID: ${cred.user!.uid}");
//       await _loadAdminFromFirestore(cred.user!.uid);
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? "Login failed");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _loadAdminFromFirestore(String uid) async {
//     DocumentReference adminRef = FirebaseFirestore.instance
//         .collection('admins')
//         .doc(uid);
//     DocumentSnapshot doc = await adminRef.get();
//
//     if (!doc.exists) {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       print(" Firestore admin doc not found, creating one...");
//       await adminRef.set({
//         'uid': uid,
//         'email': currentUser?.email ?? _emailCtrl.text.trim(),
//         'fullName':
//             currentUser?.displayName ??
//             _emailCtrl.text.trim().split('@')[0] ??
//             'Admin',
//         'profileImage': currentUser?.photoURL ?? '',
//         'id': null,
//         'password': null,
//         'createdAt': FieldValue.serverTimestamp(),
//         'authProvider': 'google',
//       });
//       doc = await adminRef.get();
//     }
//
//     final adminData = AdminModel(
//       uid: doc.id,
//       fullName: doc['fullName'],
//       email: doc['email'],
//       profileImage: doc['profileImage'],
//       id: doc['id'],
//     );
//
//     print("Firestore admin loaded: ${adminData.fullName}, ${adminData.email}");
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => AdminDashboard(admin: adminData)),
//       );
//     }
//   }
//
//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Login Failed"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK", style: TextStyle(color: Color(0xFF0066CC))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showForgotPasswordDialog() {
//     final emailController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     bool isLoading = false;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text("Reset Password"),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.lock_reset, size: 50, color: primaryColor),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Enter your email to reset password",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 20),
//                   Form(
//                     key: formKey,
//                     child: TextFormField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: "Email Address",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[400]!),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                         prefixIcon: const Icon(
//                           Icons.email,
//                           color: primaryColor,
//                         ),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (v) => v!.isEmpty || !v.contains("@")
//                           ? "Enter valid email"
//                           : null,
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isLoading ? null : () => Navigator.pop(context),
//                   child: const Text(
//                     "Cancel",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () async {
//                           if (!formKey.currentState!.validate()) return;
//
//                           setState(() => isLoading = true);
//                           await Future.delayed(const Duration(seconds: 2));
//
//                           Navigator.pop(context);
//                           _showPasswordResetSuccess(
//                             emailController.text.trim(),
//                           );
//                           setState(() => isLoading = false);
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text("Reset Password"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showPasswordResetSuccess(String email) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       isScrollControlled: true,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_circle,
//                 size: 50,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Reset Email Sent",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Password reset instructions sent to:",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               email,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: primaryColor,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: lightBlue,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: primaryColor),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       "Check your inbox and follow the instructions to reset your password.",
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Got It",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _emailCtrl.text = email;
//               },
//               child: const Text(
//                 "Use this email to login",
//                 style: TextStyle(color: primaryColor),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ========== REDESIGNED UI ==========
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Section
//                   _buildHeader(),
//
//                   const SizedBox(height: 40),
//
//                   // Login Form
//                   _buildLoginForm(),
//
//                   const SizedBox(height: 30),
//
//                   // Google Sign In
//                   _buildGoogleSignIn(),
//
//                   const SizedBox(height: 40),
//
//                   // Register Link
//                   _buildRegisterLink(),
//
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20),
//
//         const SizedBox(height: 24),
//         const Text(
//           "Welcome Back,",
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.w300,
//             color: Colors.grey,
//             height: 1.2,
//           ),
//         ),
//         const Text(
//           "Administrator",
//           style: TextStyle(
//             fontSize: 36,
//             fontWeight: FontWeight.bold,
//             color: darkBlue,
//             height: 1.2,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           "Sign in to manage student registrations and academic data",
//           style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoginForm() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Email Field
//           CustomTextField(
//             label: "Email Address",
//             controller: _emailCtrl,
//             prefixIcon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             validator: (v) =>
//                 v!.isEmpty || !v.contains("@") ? "Enter valid email" : null,
//           ),
//           const SizedBox(height: 20),
//
//           // Password Field
//           CustomTextField(
//             label: "Password",
//             controller: _passCtrl,
//             obscureText: !_showPass,
//             prefixIcon: Icons.lock_outline,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _showPass ? Icons.visibility : Icons.visibility_off,
//                 color: Colors.grey[600],
//               ),
//               onPressed: () => setState(() => _showPass = !_showPass),
//             ),
//             validator: (v) =>
//                 v!.isEmpty || v.length < 6 ? "Password too short" : null,
//           ),
//           const SizedBox(height: 16),
//
//           // Forgot Password
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton(
//               onPressed: _showForgotPasswordDialog,
//               child: Text(
//                 "Forgot Password?",
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//
//           // Login Button
//           CustomButton(
//             text: "Sign In",
//             isLoading: _isLoading,
//             color: primaryColor,
//             onPressed: _login,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGoogleSignIn() {
//     return Column(
//       children: [
//         // Divider
//         Row(
//           children: [
//             Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "Or continue with",
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
//           ],
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }
//
//   Widget _buildRegisterLink() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "New administrator? ",
//             style: TextStyle(fontSize: 15, color: Colors.grey[600]),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const RegisterAdminScreen()),
//             ),
//             child: Text(
//               "Create account",
//               style: TextStyle(
//                 fontSize: 15,
//                 color: primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }
// }



import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/admin/admin_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'admin_dashboard.dart';
import 'admin_register.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPass = false;
  bool _isGoogleLoading = false;

  // Professional Blue Color Scheme
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Color(0xFF4D8BFF);
  static const Color lightBlue = Color(0xFFE8F4FF);
  static const Color darkBlue = Color(0xFF004A99);
  static const Color backgroundColor = Color(0xFFF8FAFF);

  String _generateTemporaryPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      List.generate(10, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      print("✅ Firebase login success UID: ${cred.user!.uid}");
      await _loadAdminFromFirestore(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdminFromFirestore(String uid) async {
    DocumentReference adminRef = FirebaseFirestore.instance
        .collection('admins')
        .doc(uid);
    DocumentSnapshot doc = await adminRef.get();

    if (!doc.exists) {
      final currentUser = FirebaseAuth.instance.currentUser;
      print(" Firestore admin doc not found, creating one...");
      await adminRef.set({
        'uid': uid,
        'email': currentUser?.email ?? _emailCtrl.text.trim(),
        'fullName':
        currentUser?.displayName ??
            _emailCtrl.text.trim().split('@')[0] ??
            'Admin',
        'profileImage': currentUser?.photoURL ?? '',
        'id': null,
        'password': null,
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'google',
      });
      doc = await adminRef.get();
    }

    final adminData = AdminModel(
      uid: doc.id,
      fullName: doc['fullName'],
      email: doc['email'],
      profileImage: doc['profileImage'],
      id: doc['id'],
    );

    print("Firestore admin loaded: ${adminData.fullName}, ${adminData.email}");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard(admin: adminData)),
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Login Failed",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.038,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: primaryColor,
                fontSize: MediaQuery.of(context).size.width * 0.038,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: screenWidth * 0.13,
                        color: primaryColor,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        "Enter your email to reset password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: emailController,
                          style: TextStyle(fontSize: screenWidth * 0.038),
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.email,
                              color: primaryColor,
                              size: screenWidth * 0.055,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.02,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                          v!.isEmpty || !v.contains("@")
                              ? "Enter valid email"
                              : null,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isLoading ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                if (!formKey.currentState!.validate()) return;

                                setState(() => isLoading = true);
                                await Future.delayed(const Duration(seconds: 2));

                                Navigator.pop(context);
                                _showPasswordResetSuccess(
                                  emailController.text.trim(),
                                );
                                setState(() => isLoading = false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                width: screenWidth * 0.05,
                                height: screenWidth * 0.05,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPasswordResetSuccess(String email) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.15,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: screenWidth * 0.13,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Reset Email Sent",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.012),
              Text(
                "Password reset instructions sent to:",
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
              Text(
                email,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        "Check your inbox and follow the instructions to reset your password.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Got It",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _emailCtrl.text = email;
                },
                child: Text(
                  "Use this email to login",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== REDESIGNED UI ==========

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallPhone
                  ? screenWidth * 0.04
                  : screenWidth * 0.06,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(context),

                  SizedBox(height: screenHeight * 0.04),

                  // Login Form
                  _buildLoginForm(context),

                  SizedBox(height: screenHeight * 0.03),

                  // Google Sign In
                  _buildGoogleSignIn(context),

                  SizedBox(height: screenHeight * 0.04),

                  // Register Link
                  _buildRegisterLink(context),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.02),
        SizedBox(height: screenHeight * 0.02),
        Text(
          "Welcome Back,",
          style: TextStyle(
            fontSize: isSmallPhone ? screenWidth * 0.07 : screenWidth * 0.08,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
            height: 1.2,
          ),
        ),
        Text(
          "Administrator",
          style: TextStyle(
            fontSize: isSmallPhone ? screenWidth * 0.08 : screenWidth * 0.085,
            fontWeight: FontWeight.bold,
            color: darkBlue,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Text(
          "Sign in to manage student registrations and academic data",
          style: TextStyle(
            fontSize: isSmallPhone ? screenWidth * 0.035 : screenWidth * 0.038,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallPhone
          ? screenWidth * 0.05
          : screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            label: "Email Address",
            controller: _emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
            v!.isEmpty || !v.contains("@") ? "Enter valid email" : null,
            // context: context,
          ),
          SizedBox(height: screenHeight * 0.02),

          // Password Field
          CustomTextField(
            label: "Password",
            controller: _passCtrl,
            obscureText: !_showPass,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
                size: screenWidth * 0.055,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
            validator: (v) =>
            v!.isEmpty || v.length < 6 ? "Password too short" : null,
            // context: context,
          ),
          SizedBox(height: screenHeight * 0.016),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          // Login Button
          CustomButton(
            text: "Sign In",
            isLoading: _isLoading,
            color: primaryColor,
            onPressed: _login,
            // context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignIn(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Text(
                "Or continue with",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),
        SizedBox(height: screenHeight * 0.024),
        // You can add Google sign-in button here when ready
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallPhone
          ? screenWidth * 0.04
          : screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "New administrator? ",
            style: TextStyle(
              fontSize: screenWidth * 0.036,
              color: Colors.grey[600],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterAdminScreen()),
            ),
            child: Text(
              "Create account",
              style: TextStyle(
                fontSize: screenWidth * 0.036,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}