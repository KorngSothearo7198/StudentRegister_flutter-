
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'student_login.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ───── REGISTER LOGIC ─────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // Mock API

    if (!mounted) return;

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created! Please login."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );

    // Navigator.pushReplacement(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (_, __, ___) => const StudentLoginScreen(),
    //     transitionDuration: const Duration(milliseconds: 400),
    //     transitionsBuilder: (_, a, __, c) =>
    //         FadeTransition(opacity: a, child: c),
    //   ),
    // );
  }

  // ───── MAIN BUILD ─────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 100 : 24,
            vertical: 20,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ───── LOGO + HEADER ─────
                  _buildHeader(isWide),

                  const SizedBox(height: 40),

                  // ───── FORM FIELDS ─────
                  _buildFormFields(isWide),

                  const SizedBox(height: 32),

                  // ───── REGISTER BUTTON ─────
                  _buildRegisterButton(isWide),

                  const SizedBox(height: 24),

                  // ───── LOGIN LINK ─────
                  _buildLoginLink(isWide),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───── HEADER WITH LOGO ─────
  Widget _buildHeader(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              size: isWide ? 60 : 48,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: isWide ? 36 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Join us and start your learning journey today!",
          style: TextStyle(
            fontSize: isWide ? 18 : 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ───── FORM FIELDS ─────
  Widget _buildFormFields(bool isWide) {
    return Column(
      children: [
        // Full Name
        CustomTextField(
          label: "Full Name",
          controller: _nameCtrl,
          prefixIcon: Icons.person_outline,
          validator: (v) => v!.trim().isEmpty ? "Enter your name" : null,
        ),
        const SizedBox(height: 16),

        // Email
        CustomTextField(
          label: "Email",
          controller: _emailCtrl,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v!.trim().isEmpty) return "Enter email";
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
              return "Enter a valid email";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password
        CustomTextField(
          label: "Password",
          controller: _passCtrl,
          obscureText: _obscurePass,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          validator: (v) => v!.length < 6 ? "Password must be 6+ characters" : null,
        ),
        const SizedBox(height: 16),

        // Confirm Password
        CustomTextField(
          label: "Confirm Password",
          controller: _confirmCtrl,
          obscureText: _obscureConfirm,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          validator: (v) {
            if (v != _passCtrl.text) return "Passwords don't match";
            return null;
          },
        ),
      ],
    );
  }

  // ───── REGISTER BUTTON ─────
  Widget _buildRegisterButton(bool isWide) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: "Create Account",
        isLoading: _loading,
        onPressed: _register,
       
      ),
    );
  }

  // ───── LOGIN LINK ─────
  Widget _buildLoginLink(bool isWide) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          // TextButton(
          //   onPressed: () => Navigator.pushReplacement(
          //     context,
          //     PageRouteBuilder(
          //       pageBuilder: (_, __, ___) => const StudentLoginScreen(),
          //       transitionDuration: const Duration(milliseconds: 400),
          //       transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          //     ),
          //   ),
          //   child: const Text(
          //     "Sign In",
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.deepPurple,
          //       fontSize: 15,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}