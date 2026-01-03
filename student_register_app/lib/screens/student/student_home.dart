import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_register_app/main.dart';
import 'package:student_register_app/models/payment_model.dart';
import 'package:student_register_app/screens/student/StudentChartListScreen.dart';
import 'package:student_register_app/screens/student/about_screen.dart';
import 'package:student_register_app/screens/student/chart_screen.dart';
import 'package:student_register_app/screens/student/curricula.dart';
import 'package:student_register_app/screens/student/payments_history_screen.dart';
import 'student_login.dart';
import 'student_profile.dart';
import 'student_payment.dart';
import 'student_register.dart';

import 'package:flutter_svg/flutter_svg.dart';

class StudentHomeScreen extends StatefulWidget {
  final Map<String, dynamic> student; // <-- use Map
  final Map<String, dynamic>? openChatStudent; //

  final String studentName;

  const StudentHomeScreen({
    super.key,
    required this.student,
    required this.studentName,
    required this.openChatStudent,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  // Define the payment order list:
  final List<Map<String, dynamic>> paymentOrder = [
    {'year': 1, 'semester': 'Semester 1'},
    {'year': 1, 'semester': 'Semester 2'},
    {'year': 2, 'semester': 'Semester 1'},
    {'year': 2, 'semester': 'Semester 2'},
    {'year': 3, 'semester': 'Semester 1'},
    {'year': 3, 'semester': 'Semester 2'},
    {'year': 4, 'semester': 'Semester 1'},
    {'year': 4, 'semester': 'Semester 2'},
  ];

  late Map<String, dynamic> student;

  // Find the Next Payment Student Must Pay
  Map<String, dynamic>? findNextPayment(List<Payment> payments) {
    for (var order in paymentOrder) {
      final Payment? match = payments.firstWhere(
            (p) =>
        p.year == order['year'] &&
            p.semester == order['semester'] &&
            p.status != 'Paid',
        // orElse: () => null,
      );

      if (match != null) {
        return {
          'year': match.year,
          'semester': match.semester,
          'status': match.status,
        };
      }
    }

    return null; // All payments completed
  }

  @override
  void initState() {
    super.initState();

    // If openChatStudent is provided, push chat screen after home builds

    _pages = [
      _HomePage(student: widget.student), // Pass it here
      const StudentRegisterScreen(),

      StudentPaymentScreen(
        student: {
          'studentId': widget.student['studentId'], // <-- Pass real studentId
          'firstName': widget.student['firstName'],
          'lastName': widget.student['lastName'],
          'Major': widget.student['major'],
        },
      ),

      // const StudentPaymentScreen(
      //   student: {'studentId': '', 'firstName': '', 'lastName': ''},
      // ),
      StudentProfileScreen(student: widget.student),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Register"),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: screenWidth * 0.03), // Responsive padding
            child: SvgPicture.asset(
              'assets/images/logo.png',
              color: Colors.white,
              height: screenHeight * 0.035, // Responsive height
            ),
          ),
        ],
      ),

      drawer: _buildDrawer(context),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF001F5B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 8,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: "Register",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ───── DRAWER (Safe, No Overflow) ─────
  Drawer _buildDrawer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final name = "${widget.student['firstName']} ${widget.student['lastName']}";
    final id = widget.student['studentId'] ?? "STU-00000";
    final photoUrl = widget.student['photoUrl'] ?? "";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0066CC)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.085,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Icon(
                    Icons.person,
                    size: screenWidth * 0.15,
                    color: const Color(0xFF0066CC),
                  )
                      : null,
                ),
                SizedBox(height: screenHeight * 0.01),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  id,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.033,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, "Home", 0),
          _drawerItem(Icons.info_outline, "About", 4),
          const Divider(height: 1),
          _drawerItem(Icons.logout, "Logout", -1, color: Colors.red),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index, {Color? color}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: screenWidth * 0.04),
      ),
      selected: _selectedIndex == index,
      selectedTileColor: const Color(0xFF0066CC).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);

        if (index == _selectedIndex) return;

        if (index == -1) {
          _showLogoutDialog(context);
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          );
        } else {
          _onItemTapped(index);
        }
      },
    );
  }

// ───── LOGOUT DIALOG ─────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.logout, color: Colors.orange),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first
              try {
                // Firebase logout (if using Firebase Auth)
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint("Logout error: $e");
              }
              // Navigate to Login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginAccountScreen(student: {},),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}

// ───── HOME PAGE (Quick Access – No Overflow) ─────//

class _HomePage extends StatefulWidget {
  final Map<String, dynamic> student;

  const _HomePage({super.key, required this.student});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  List<Payment> payments = [];
  Map<String, dynamic>? nextPayment;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final studentId = widget.student['studentId'] ?? '';
    try {
      final list = await loadPayments(studentId);
      final next = findNextPayment(list);

      setState(() {
        payments = list;
        nextPayment = next;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading payments: $e");
      setState(() => isLoading = false);
    }
  }

  Future<List<Payment>> loadPayments(String studentId) async {
    final snap = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .orderBy('year')
        .orderBy('semester')
        .get();

    return snap.docs
        .map((doc) => Payment.fromFirestore(studentId, doc.data()))
        .toList();
  }

  Map<String, dynamic>? findNextPayment(List<Payment> payments) {
    final paymentOrder = [
      {'year': 1, 'semester': 'Semester 1'},
      {'year': 1, 'semester': 'Semester 2'},
      {'year': 2, 'semester': 'Semester 1'},
      {'year': 2, 'semester': 'Semester 2'},
      {'year': 3, 'semester': 'Semester 1'},
      {'year': 3, 'semester': 'Semester 2'},
      {'year': 4, 'semester': 'Semester 1'},
      {'year': 4, 'semester': 'Semester 2'},
    ];

    for (var order in paymentOrder) {
      for (var p in payments) {
        if (p.year == order['year'] &&
            p.semester == order['semester'] &&
            p.status.toLowerCase() != 'paid') {
          return {
            'year': p.year,
            'semester': p.semester,
            'status': p.status,
            'amount': p.amount,
          };
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;
    final isPortrait = screenHeight > screenWidth;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF0066CC),
                strokeWidth: 3,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Loading your dashboard...',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final student = widget.student;
    final firstName = student['firstName'] ?? '';
    final lastName = student['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Welcome Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child:
                        student['photoUrl'] != null &&
                            student['photoUrl'].toString().isNotEmpty
                            ? Image.network(
                          student['photoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              firstName.isNotEmpty ? firstName[0] : '?',
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0066CC),
                              ),
                            ),
                          ),
                        )
                            : Center(
                          child: Text(
                            firstName.isNotEmpty ? firstName[0] : '?',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0066CC),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Student Status Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.045),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student Status',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066CC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          student['major'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0066CC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: screenWidth * 0.05,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      Expanded(
                        child: Text(
                          'Major: ${student['major'] ?? 'Not specified'}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Check if student has login credentials
                  if (student['password'] != null &&
                      student['password'].toString().isNotEmpty)
                  // Student has login account - show payment status
                    if (nextPayment != null)
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Payment Due',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              'Year ${nextPayment!['year']} • ${nextPayment!['semester']}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount: \$${nextPayment!['amount']}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (student['studentId'] != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StudentPaymentScreen(
                                            student: student,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05,
                                      vertical: screenHeight * 0.01,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            const Expanded(
                              child: Text(
                                'All payments completed!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  else
                  // Student does NOT have login account - show setup message
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                                size: screenWidth * 0.06,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Setup Your Account',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      'Create login credentials to access payment features',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LoginAccountScreen(student: student),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.012,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Setup Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.038,
                                ),
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

          SizedBox(height: screenHeight * 0.025),

          // Quick Actions Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: screenWidth * 0.030,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isSmallPhone ? 2 : 2,
                  mainAxisSpacing: screenHeight * 0.015,
                  crossAxisSpacing: screenWidth * 0.02,
                  childAspectRatio: isPortrait ? 1.1 : 1.5,
                  children: [
                    _quickActionCard(
                      icon: Icons.key,
                      title: 'Login\nAccount',
                      subtitle: 'Secure access',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginAccountScreen(student: student),
                        ),
                      ),
                      context: context,
                    ),
                    _quickActionCard(
                      icon: Icons.history,
                      title: 'Payments\nHistory',
                      subtitle: 'View all transactions',
                      color: const Color(0xFF00C853),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentsHistoryScreen(student: student),
                        ),
                      ),
                      context: context,
                    ),
                    _quickActionCard(
                      icon: Icons.menu_book,
                      title: 'Curricula',
                      subtitle: 'Course materials',
                      color: const Color(0xFF4CAF50),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CurriculaScreen()),
                      ),
                      context: context,
                    ),
                    _quickActionCard(
                      icon: Icons.person,
                      title: 'My\nProfile',
                      subtitle: 'Personal details',
                      color: Colors.purple,
                      onTap: () => _navigate(3, context),
                      context: context,
                    ),
                    _quickActionCard(
                      icon: Icons.message,
                      title: 'Messages',
                      subtitle: 'Send a message',
                      color: Colors.blue,
                      onTap: () async {
                        final studentId = widget.student['studentId'] ?? '';
                        final firstName = widget.student['firstName'] ?? '';
                        final lastName = widget.student['lastName'] ?? '';
                        final fullName = '$firstName $lastName'.trim();
                        final photoUrl = widget.student['photoUrl'] ?? '';

                        if (studentId.isEmpty) return;

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          // Load admin profile
                          final user = FirebaseAuth.instance.currentUser;
                          Map<String, dynamic>? adminProfile;

                          if (user != null) {
                            final adminDoc = await FirebaseFirestore.instance
                                .collection('admins')
                                .doc(user.uid)
                                .get();

                            if (adminDoc.exists) {
                              adminProfile = adminDoc.data();
                            }
                          }

                          // Mark messages as read
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(studentId)
                              .collection('messages')
                              .where('receiver', isEqualTo: 'teacher')
                              .where('isRead', isEqualTo: false)
                              .get()
                              .then((snapshot) {
                            for (var doc in snapshot.docs) {
                              doc.reference.update({'isRead': true});
                            }
                          });

                          // Close loading dialog
                          if (mounted) Navigator.pop(context);

                          // Navigate with admin profile
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentChatWithChartScreen(
                                studentchartId: studentId,
                                fullName: fullName,
                                photoUrl: photoUrl,
                                adminProfile: adminProfile,
                                adminId: '',
                              ),
                            ),
                          );
                        } catch (e) {
                          // Close loading dialog on error
                          if (mounted) Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error loading chat: $e')),
                          );
                        }
                      },
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive scaling
    final double padding = (width * 0.045).clamp(12.0, 20.0);
    final double iconBox = (width * 0.14).clamp(42.0, 56.0);
    final double iconSize = (width * 0.065).clamp(20.0, 28.0);
    final double titleSize = (width * 0.04).clamp(14.0, 18.0);
    final double subtitleSize = (width * 0.032).clamp(11.0, 14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _navigate(int index, BuildContext context) {
    final state = context.findAncestorStateOfType<_StudentHomeScreenState>();
    state?._onItemTapped(index);
  }
}