//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../models/admin/admin_model.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/custom_button.dart';
// import 'admin_login.dart';
//
// class RegisterAdminScreen extends StatefulWidget {
//   const RegisterAdminScreen({super.key});
//
//   @override
//   State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
// }
//
// class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   final _confirmPasswordCtrl = TextEditingController();
//
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _termsAccepted = false;
//
//
//   static const Color primaryColor = Color(0xFF0066CC);
//
//   // === EXISTING VALIDATION METHODS (UNCHANGED) ===
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return "Please enter password";
//     if (value.length < 6) return "Password must be at least 6 characters";
//     return null;
//   }
//
//   String? _validateConfirmPassword(String? value) {
//     if (value != _passwordCtrl.text) return "Passwords do not match";
//     return null;
//   }
//
//   // === EXISTING REGISTRATION LOGIC (UNCHANGED) ===
//   void _registerAdmin() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_termsAccepted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please accept the terms and conditions"),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       // 1️⃣ Create user in Firebase Auth
//       final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text.trim(),
//       );
//
//       // 2️⃣ Build AdminModel
//       final admin = AdminModel(
//         uid: cred.user!.uid,
//         fullName: _fullNameCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         profileImage: '', // default blank
//         id: null,
//       );
//
//       // 3️⃣ Save admin info to Firestore
//       await FirebaseFirestore.instance
//           .collection('admins')
//           .doc(admin.uid)
//           .set(admin.toMap());
//
//       setState(() => _isLoading = false);
//
//       // 4️⃣ Show success dialog
//       _showSuccessDialog();
//     } on FirebaseAuthException catch (e) {
//       setState(() => _isLoading = false);
//       String msg = e.message ?? "Registration failed";
//       if (e.code == 'email-already-in-use') msg = "Email already exists";
//       if (e.code == 'weak-password') msg = "Password is too weak";
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Check your internet connection.")),
//       );
//     }
//   }
//
//   // === EXISTING SUCCESS DIALOG (UNCHANGED) ===
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle,
//                   size: 50,
//                   color: Colors.green,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Registration Successful!",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Your admin account has been created successfully.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const AdminLoginScreen(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Go to Login",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showTermsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Terms & Conditions",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "By creating an admin account, you agree to:",
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 12),
//               _termPoint("Use the platform responsibly and ethically"),
//               _termPoint("Maintain confidentiality of student data"),
//               _termPoint("Follow institutional policies and guidelines"),
//               _termPoint("Report any security concerns immediately"),
//               _termPoint("Use admin privileges only for official purposes"),
//               const SizedBox(height: 20),
//               const Text(
//                 "Administrators are responsible for maintaining data integrity and following all applicable laws and regulations.",
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text("Close"),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() => _termsAccepted = true);
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text("I Accept"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _termPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.check_circle, size: 16, color: Colors.green),
//           const SizedBox(width: 8),
//           Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Back Button
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16, bottom: 20),
//                   child: IconButton(
//                     icon: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(Icons.arrow_back),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//
//                 // Header
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Create",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w300,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const Text(
//                   "Admin Account",
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Register as an administrator to manage the system",
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//
//                 // Form Fields
//                 const SizedBox(height: 40),
//                 CustomTextField(
//                   label: "Full Name",
//                   controller: _fullNameCtrl,
//                   prefixIcon: Icons.person_outline,
//                   validator: (v) => v!.isEmpty ? "Enter full name" : null,
//                   // filled: true,
//                   // fillColor: Colors.grey[50],
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextField(
//                   label: "Email Address",
//                   controller: _emailCtrl,
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) => v!.isEmpty || !v.contains("@")
//                       ? "Enter valid email"
//                       : null,
//                   // filled: true,
//                   // fillColor: Colors.grey[50],
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextField(
//                   label: "Password",
//                   controller: _passwordCtrl,
//                   obscureText: _obscurePassword,
//                   prefixIcon: Icons.lock_outline,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () =>
//                         setState(() => _obscurePassword = !_obscurePassword),
//                   ),
//                   validator: _validatePassword,
//                   // helperText: "Minimum 6 characters",
//                   // filled: true,
//                   // fillColor: Colors.grey[50],
//                 ),
//                 const SizedBox(height: 20),
//                 CustomTextField(
//                   label: "Confirm Password",
//                   controller: _confirmPasswordCtrl,
//                   obscureText: _obscureConfirmPassword,
//                   prefixIcon: Icons.lock_outline,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirmPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () => setState(
//                       () => _obscureConfirmPassword = !_obscureConfirmPassword,
//                     ),
//                   ),
//                   validator: _validateConfirmPassword,
//                   // filled: true,
//                   // fillColor: Colors.grey[50],
//                 ),
//
//                 // Terms & Conditions
//                 const SizedBox(height: 24),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue[100]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: _termsAccepted,
//                         onChanged: (value) =>
//                             setState(() => _termsAccepted = value ?? false),
//                         activeColor: Colors.redAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: _showTermsDialog,
//                           child: RichText(
//                             text: TextSpan(
//                               text: "I agree to the ",
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 14,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: "Terms & Conditions",
//                                   style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const TextSpan(text: " and "),
//                                 TextSpan(
//                                   text: "Privacy Policy",
//                                   style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Register Button
//                 const SizedBox(height: 30),
//                 CustomButton(
//                   text: "Create Admin Account",
//                   isLoading: _isLoading,
//                   color: Colors.redAccent,
//                   onPressed: _registerAdmin,
//                   // height: 56,
//                   // borderRadius: 12,
//                 ),
//
//                 // Already have account
//                 const SizedBox(height: 30),
//                 // Define at the top of your class
//
//                 // Then use it
//                 Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Already have an account? ",
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       GestureDetector(
//                         onTap: () => Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const AdminLoginScreen(),
//                           ),
//                         ),
//                         child: Text(
//                           "Sign In",
//                           style: TextStyle(
//                             color: primaryColor, // Using the variable
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Security Note
//                 const SizedBox(height: 40),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.security, color: Colors.green, size: 20),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           "Your data is securely encrypted and protected",
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _fullNameCtrl.dispose();
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     _confirmPasswordCtrl.dispose();
//     super.dispose();
//   }
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/admin/admin_model.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'admin_login.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;

  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Colors.redAccent;

  // === EXISTING VALIDATION METHODS (UNCHANGED) ===
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Please enter password";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordCtrl.text) return "Passwords do not match";
    return null;
  }

  // === EXISTING REGISTRATION LOGIC (UNCHANGED) ===
  void _registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the terms and conditions"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create user in Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      // 2️⃣ Build AdminModel
      final admin = AdminModel(
        uid: cred.user!.uid,
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        profileImage: '', // default blank
        id: null,
      );

      // 3️⃣ Save admin info to Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(admin.uid)
          .set(admin.toMap());

      setState(() => _isLoading = false);

      // 4️⃣ Show success dialog
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = e.message ?? "Registration failed";
      if (e.code == 'email-already-in-use') msg = "Email already exists";
      if (e.code == 'weak-password') msg = "Password is too weak";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check your internet connection.")),
      );
    }
  }

  // === RESPONSIVE SUCCESS DIALOG ===
  void _showSuccessDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                "Registration Successful!",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Your admin account has been created successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Go to Login",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Terms & Conditions",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "By creating an admin account, you agree to:",
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              _termPoint("Use the platform responsibly and ethically", screenWidth),
              _termPoint("Maintain confidentiality of student data", screenWidth),
              _termPoint("Follow institutional policies and guidelines", screenWidth),
              _termPoint("Report any security concerns immediately", screenWidth),
              _termPoint("Use admin privileges only for official purposes", screenWidth),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Administrators are responsible for maintaining data integrity and following all applicable laws and regulations.",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _termsAccepted = true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "I Accept",
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
  }

  Widget _termPoint(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: screenWidth * 0.04,
            color: Colors.green,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                // Back Button
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    bottom: screenHeight * 0.02,
                  ),
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Header
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Create",
                  style: TextStyle(
                    fontSize: isSmallPhone
                        ? screenWidth * 0.07
                        : screenWidth * 0.075,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Admin Account",
                  style: TextStyle(
                    fontSize: isSmallPhone
                        ? screenWidth * 0.08
                        : screenWidth * 0.085,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.008),
                Text(
                  "Register as an administrator to manage the system",
                  style: TextStyle(
                    fontSize: isSmallPhone
                        ? screenWidth * 0.035
                        : screenWidth * 0.038,
                    color: Colors.grey[600],
                  ),
                ),

                // Form Fields
                SizedBox(height: screenHeight * 0.04),
                CustomTextField(
                  label: "Full Name",
                  controller: _fullNameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Enter full name" : null,
                  // context: context,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  label: "Email Address",
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains("@")
                      ? "Enter valid email"
                      : null,
                  // context: context,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  label: "Password",
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: screenWidth * 0.055,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: _validatePassword,
                  // context: context,
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomTextField(
                  label: "Confirm Password",
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: screenWidth * 0.055,
                    ),
                    onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  // context: context,
                ),

                // Terms & Conditions
                SizedBox(height: screenHeight * 0.025),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) =>
                            setState(() => _termsAccepted = value ?? false),
                        activeColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTermsDialog,
                          child: RichText(
                            text: TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenWidth * 0.035,
                              ),
                              children: [
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                TextSpan(
                                  text: " and ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Register Button
                SizedBox(height: screenHeight * 0.03),
                CustomButton(
                  text: "Create Admin Account",
                  isLoading: _isLoading,
                  color: accentColor,
                  onPressed: _registerAdmin,
                  // context: context,
                ),

                // Already have account
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.036,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminLoginScreen(),
                          ),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.036,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Security Note
                SizedBox(height: screenHeight * 0.04),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.green,
                        size: screenWidth * 0.05,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Text(
                          "Your data is securely encrypted and protected",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.033,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }
}