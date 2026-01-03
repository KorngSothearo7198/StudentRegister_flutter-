// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:student_register_app/models/admin/admin_model.dart';
// import 'package:student_register_app/screens/admin/admin_login.dart';
// import '../../models/student_model.dart';
// import 'admin_settings.dart' hide AdminModel;
// import 'admin_student_list.dart';
// import 'admin_payment_list.dart';
//
// class AdminDashboard extends StatefulWidget {
//   final AdminModel admin;
//
//   const AdminDashboard({super.key, required this.admin});
//
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   int _selectedIndex = 0;
//   late List<Widget> _tabs;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   int totalStudents = 0;
//   int approvedStudents = 0;
//   int pendingStudents = 0;
//   int overdueStudents = 0;
//   int totalPayments = 0;
//   double totalRevenue = 0.0;
//
//   bool _isLoading = true;
//   late AdminModel admin;
//   late AdminModel _admin;
//
//   @override
//   void initState() {
//     super.initState();
//     admin = widget.admin;
//     _admin = widget.admin;
//     _loadAllStats();
//     _fetchAdmin();
//
//     _tabs = [
//       const Center(child: CircularProgressIndicator()),
//       const AdminStudentListScreen(),
//       const AdminPaymentListScreen(),
//       AdminSettingsScreen(admin: widget.admin),
//     ];
//   }
//
//   Future<void> _fetchAdmin() async {
//     setState(() => _isLoading = true);
//
//     // Get logged-in admin UID
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//
//     if (uid == null) {
//       debugPrint("❌ No admin is logged in.");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     // Fetch from Firestore using your AdminDao
//     final fetchedAdmin = await AdminDao.getAdmin(uid);
//
//     if (fetchedAdmin != null) {
//       setState(() {
//         _admin = fetchedAdmin;
//         _isLoading = false;
//       });
//
//       debugPrint("✅ Admin fetched successfully:");
//       debugPrint("Name: ${_admin!.fullName}");
//       debugPrint("Email: ${_admin!.email}");
//       debugPrint("Image: ${_admin!.profileImage}");
//     } else {
//       debugPrint("❌ Admin not found for UID: $uid");
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _loadAllStats() async {
//     try {
//       await _loadStudentStats();
//       await _loadPaymentStats();
//
//       setState(() {
//         _isLoading = false;
//         _tabs[0] = _HomeTab(
//           totalStudents: totalStudents,
//           approvedStudents: approvedStudents,
//           pendingStudents: pendingStudents,
//           overdueStudents: overdueStudents,
//           totalPayments: totalPayments,
//           totalRevenue: totalRevenue,
//
//           adminName: admin.fullName ?? 'Admin', // Pass the admin name here
//           adminProfileImage: admin.profileImage, // pass profile image
//         );
//       });
//     } catch (e) {
//       print("Error loading stats: $e");
//     }
//   }
//
//   Future<void> _loadStudentStats() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('students_joinName')
//           .get();
//
//       totalStudents = snapshot.docs.length;
//       approvedStudents = snapshot.docs
//           .where((d) => (d.data()['status'] ?? '') == 'Approved')
//           .length;
//       pendingStudents = snapshot.docs
//           .where((d) => (d.data()['status'] ?? '') == 'Pending')
//           .length;
//       overdueStudents = snapshot.docs.where((doc) {
//         final dueDate = doc.data()['dueDate'];
//         if (dueDate == null) return false;
//         final date = (dueDate as Timestamp).toDate();
//         return date.isBefore(DateTime.now()) &&
//             doc.data()['status'] != 'Approved';
//       }).length;
//     } catch (e) {
//       print("Error loading student stats: $e");
//     }
//   }
//
//   Future<void> _loadPaymentStats() async {
//     try {
//       final paymentsSnapshot = await FirebaseFirestore.instance
//           .collection('students_payments')
//           .get();
//
//       totalPayments = 0;
//       totalRevenue = 0.0;
//
//       for (var studentDoc in paymentsSnapshot.docs) {
//         final paymentDocs = await studentDoc.reference
//             .collection('payments')
//             .where('status', isEqualTo: 'Paid')
//             .get();
//
//         totalPayments += paymentDocs.docs.length;
//
//         for (var p in paymentDocs.docs) {
//           final amount = (p.data()['amount'] ?? 0).toDouble();
//           totalRevenue += amount;
//         }
//       }
//     } catch (e) {
//       print("Error loading payment stats: $e");
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.white,
//       drawer: _buildDrawer(context),
//       appBar: AppBar(
//         title: const Text(
//           'Admin Dashboard',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: const Color(0xFF0066CC),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.menu),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         ),
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.notifications_none),
//           //   onPressed: () {},
//           // ),
//           Padding(
//             padding: const EdgeInsets.only(right: 12.0),
//             child: Image.asset(
//               'assets/images/logo.png',
//               height: 30,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF0066CC)),
//             )
//           : _tabs[_selectedIndex],
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }
//
//   Widget _buildDrawer(BuildContext context) {
//     final currentAdmin = _admin; // Use the updated admin from state
//
//     // Debug print to confirm
//     debugPrint("=== Drawer Header Admin Info ===");
//     debugPrint("Profile Image URL: ${currentAdmin.profileImage}");
//     debugPrint("Full Name: ${currentAdmin.fullName}");
//     debugPrint("Email: ${currentAdmin.email}");
//     debugPrint("===============================");
//
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // Drawer Header Logo
//           SizedBox(
//             height: 60,
//             child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
//           ),
//           const SizedBox(height: 20),
//
//           // Drawer Header with Admin Info
//           Container(
//             height: 200,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // Avatar
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       border: Border.all(color: Colors.white, width: 3),
//                       image:
//                           currentAdmin.profileImage != null &&
//                               currentAdmin.profileImage!.isNotEmpty
//                           ? DecorationImage(
//                               image: NetworkImage(currentAdmin.profileImage!),
//                               fit: BoxFit.cover,
//                             )
//                           : null,
//                     ),
//                     child:
//                         currentAdmin.profileImage == null ||
//                             currentAdmin.profileImage!.isEmpty
//                         ? const Icon(
//                             Icons.person,
//                             color: Color(0xFF0066CC),
//                             size: 40,
//                           )
//                         : null,
//                   ),
//
//                   const SizedBox(height: 16),
//                   Text(
//                     currentAdmin.fullName ?? 'Admin',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     currentAdmin.email ?? 'admin@school.edu',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Drawer Menu Items
//           _drawerItem(Icons.dashboard_outlined, "Home", 0, context),
//           _drawerItem(Icons.people_outlined, "Students", 1, context),
//           _drawerItem(Icons.payments_outlined, "Payments", 2, context),
//           _drawerItem(Icons.settings_outlined, "Settings", 3, context),
//
//           const Divider(thickness: 1, height: 20),
//
//           // Additional Options
//           _drawerItem(Icons.analytics_outlined, "Reports", -1, context),
//           _drawerItem(Icons.help_outline, "Help & Support", -1, context),
//           _drawerItem(Icons.info_outline, "About", -1, context),
//
//           const Divider(thickness: 1, height: 20),
//
//           // Logout Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.red.withOpacity(0.1)),
//               ),
//               child: ListTile(
//                 leading: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.red.withOpacity(0.1),
//                   ),
//                   child: const Icon(
//                     Icons.logout_outlined,
//                     color: Colors.red,
//                     size: 20,
//                   ),
//                 ),
//                 title: const Text(
//                   'Logout',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 trailing: Icon(
//                   Icons.chevron_right,
//                   color: Colors.red.withOpacity(0.5),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showLogoutDialog(context);
//                 },
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // App Version
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'Version 1.0.0',
//               style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _drawerItem(
//     IconData icon,
//     String title,
//     int index,
//     BuildContext context,
//   ) {
//     final isSelected = _selectedIndex == index;
//
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.pop(context); // Close drawer first
//           if (index >= 0) {
//             setState(() => _selectedIndex = index);
//           }
//         },
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF0066CC).withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             leading: Icon(
//               icon,
//               color: isSelected ? const Color(0xFF0066CC) : Colors.grey[700],
//             ),
//             title: Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? const Color(0xFF0066CC) : Colors.black87,
//               ),
//             ),
//             trailing: isSelected
//                 ? Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFF0066CC),
//                     ),
//                   )
//                 : null,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: const Color(0xFF0066CC),
//         // selectedItemColor: const Color(0xFF0066CC),
//         selectedItemColor: Colors.white,
//         unselectedItemColor:
//             Colors.white70, // Inactive = slightly transparent white (optional)
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         elevation: 0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_outlined),
//             activeIcon: Icon(Icons.dashboard_rounded),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.people_outline),
//             activeIcon: Icon(Icons.people_rounded),
//             label: "Students",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.payments_outlined),
//             activeIcon: Icon(Icons.payments_rounded),
//             label: "Payments",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_outlined),
//             activeIcon: Icon(Icons.settings_rounded),
//             label: "Settings",
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Logout',
//           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
//         ),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await FirebaseAuth.instance.signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AdminLoginScreen(),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0066CC),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text('Logout', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ============ HOME TAB ============
//
// class _HomeTab extends StatefulWidget {
//   final int totalStudents;
//   final int approvedStudents;
//   final int pendingStudents;
//   final int overdueStudents;
//   final int totalPayments;
//   final double totalRevenue;
//
//   final String adminName;
//
//   final String? adminProfileImage; // add this
//
//   const _HomeTab({
//     required this.totalStudents,
//     required this.approvedStudents,
//     required this.pendingStudents,
//     required this.overdueStudents,
//     required this.totalPayments,
//     required this.totalRevenue,
//
//     required this.adminName,
//
//     this.adminProfileImage,
//   });
//
//   @override
//   State<_HomeTab> createState() => _HomeTabState();
// }
//
// class _HomeTabState extends State<_HomeTab> {
//   AdminModel? _admin; // HERE
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration(milliseconds: 300), () {
//       _fetchAdmin();
//     });
//
//     // _fetchAdmin();
//   }
//
//   Future<void> _fetchAdmin() async {
//     setState(() => _isLoading = true);
//
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//
//     if (uid == null) {
//       debugPrint("❌ No admin logged in.");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final fetchedAdmin = await AdminDao.getAdmin(uid);
//
//     if (fetchedAdmin != null) {
//       setState(() {
//         _admin = fetchedAdmin;
//         _isLoading = false;
//       });
//
//       debugPrint("✅ Admin fetched successfully");
//       debugPrint("Name: ${_admin!.fullName}");
//       debugPrint("Email: ${_admin!.email}");
//       debugPrint("Image: ${_admin!.profileImage}");
//     } else {
//       debugPrint("❌ Admin not found for UID: $uid");
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Welcome Header
//           // Container(
//           //   padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
//           //   decoration: BoxDecoration(
//           //     gradient: LinearGradient(
//           //       begin: Alignment.topLeft,
//           //       end: Alignment.bottomRight,
//           //       colors: [
//           //         const Color(0xFFFFFFFF),
//           //         const Color(0xFFF5F5F5),
//           //         const Color(0xFFEEEEEE),
//           //       ],
//           //       stops: const [0.0, 0.5, 1.0],
//           //     ),
//           //     borderRadius: const BorderRadius.only(
//           //       bottomLeft: Radius.circular(30),
//           //       bottomRight: Radius.circular(30),
//           //     ),
//           //     boxShadow: [
//           //       BoxShadow(
//           //         color: Colors.black.withOpacity(0.08),
//           //         blurRadius: 15,
//           //         spreadRadius: 2,
//           //         offset: const Offset(0, 5),
//           //       ),
//           //     ],
//           //   ),
//           //   child: Column(
//           //     crossAxisAlignment: CrossAxisAlignment.start,
//           //     children: [
//           //       Row(
//           //         children: [
//           //           Container(
//           //             width: 50,
//           //             height: 50,
//           //             decoration: BoxDecoration(
//           //               shape: BoxShape.circle,
//           //               color: const Color(0xFFF0F0F0),
//           //               border: Border.all(
//           //                 color: const Color(0xFFE0E0E0),
//           //                 width: 2,
//           //               ),
//           //               boxShadow: [
//           //                 BoxShadow(
//           //                   color: Colors.black.withOpacity(0.05),
//           //                   blurRadius: 8,
//           //                   offset: const Offset(0, 3),
//           //                 ),
//           //               ],
//           //               image:
//           //                   _admin?.profileImage != null &&
//           //                       _admin!.profileImage!.isNotEmpty
//           //                   ? DecorationImage(
//           //                       image: NetworkImage(_admin!.profileImage!),
//           //                       fit: BoxFit.cover,
//           //                     )
//           //                   : null,
//           //             ),
//           //             child:
//           //                 _admin?.profileImage == null ||
//           //                     _admin!.profileImage!.isEmpty
//           //                 ? const Icon(
//           //                     Icons.person,
//           //                     color: Color(0xFF424242),
//           //                     size: 30,
//           //                   )
//           //                 : null,
//           //           ),
//           //           const SizedBox(width: 16),
//           //           Expanded(
//           //             child: Column(
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               children: [
//           //                 Text(
//           //                   'Welcome back,',
//           //                   style: TextStyle(
//           //                     fontSize: 14,
//           //                     color: Colors.black.withOpacity(0.6),
//           //                     fontWeight: FontWeight.w500,
//           //                   ),
//           //                 ),
//           //                 const SizedBox(height: 4),
//           //                 Text(
//           //                   _admin?.fullName ?? 'Admin',
//           //                   style: const TextStyle(
//           //                     fontSize: 20,
//           //                     fontWeight: FontWeight.w700,
//           //                     color: Color(0xFF212121),
//           //                   ),
//           //                 ),
//           //               ],
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //       const SizedBox(height: 20),
//           //       Container(
//           //         padding: const EdgeInsets.symmetric(
//           //           horizontal: 16,
//           //           vertical: 10,
//           //         ),
//           //         decoration: BoxDecoration(
//           //           color: Colors.white,
//           //           borderRadius: BorderRadius.circular(12),
//           //           border: Border.all(
//           //             color: const Color(0xFFE0E0E0),
//           //             width: 1,
//           //           ),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.03),
//           //               blurRadius: 4,
//           //               offset: const Offset(0, 2),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Row(
//           //           mainAxisSize: MainAxisSize.min,
//           //           children: [
//           //             Icon(
//           //               Icons.calendar_today,
//           //               size: 16,
//           //               color: Colors.black.withOpacity(0.5),
//           //             ),
//           //             const SizedBox(width: 8),
//           //             Text(
//           //               DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
//           //               style: TextStyle(
//           //                 fontSize: 14,
//           //                 color: Colors.black.withOpacity(0.7),
//           //                 fontWeight: FontWeight.w500,
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           const SizedBox(height: 20),
//
//           // Stats Grid
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 1.2,
//               children: [
//                 _statCard(
//                   title: 'Total Students',
//                   value: widget.totalStudents.toString(),
//                   icon: Icons.school_outlined,
//                   color: Colors.blue,
//                 ),
//                 _statCard(
//                   title: 'Approved',
//                   value: widget.approvedStudents.toString(),
//                   icon: Icons.check_circle_outline,
//                   color: Colors.green,
//                 ),
//                 _statCard(
//                   title: 'Pending',
//                   value: widget.pendingStudents.toString(),
//                   icon: Icons.pending_outlined,
//                   color: Colors.orange,
//                 ),
//                 _statCard(
//                   title: 'Total Revenue',
//                   value: '\$${widget.totalRevenue}',
//                   icon: Icons.attach_money_outlined,
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 32),
//
//           // Recent Activities
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Recent Activities',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF333333),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'View All',
//                         style: TextStyle(
//                           color: Color(0xFF0066CC),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Scrollable Activities Container
//                 Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height * 0.4,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     // border: Border.all(
//                     //   color: const Color(0xFFE0E0E0),
//                     //   width: 1,
//                     // ),
//                   ),
//                   child: FutureBuilder<List<Map<String, String>>>(
//                     future: _fetchRecentActivities(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return ListView.builder(
//                           padding: const EdgeInsets.all(12),
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: 3,
//                           itemBuilder: (context, index) => _activitySkeleton(),
//                         );
//                       }
//
//                       if (snapshot.hasError || snapshot.data!.isEmpty) {
//                         return Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: _emptyActivities(),
//                           ),
//                         );
//                       }
//
//                       final activities = snapshot.data!;
//
//                       return ListView.builder(
//                         padding: const EdgeInsets.all(12),
//                         shrinkWrap: true,
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: activities.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: _activityItem(activities[index]),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
//
//   // ────────── Responsive Stat Card ──────────
//   Widget _statCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(screenWidth * 0.04),
//         border: Border.all(color: color.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: screenWidth * 0.02,
//             offset: Offset(0, screenHeight * 0.005),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: screenWidth * 0.12,
//             height: screenWidth * 0.12,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: screenWidth * 0.06),
//           ),
//           SizedBox(height: screenHeight * 0.015),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: screenWidth * 0.06,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.005),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: screenWidth * 0.035,
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _activityItem(Map<String, String> activity) {
//     final isPayment = activity["type"] == "payment";
//     final isNewStudent = activity["type"] == "new_student";
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[100]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: isPayment
//                   ? Colors.blue.withOpacity(0.1)
//                   : isNewStudent
//                   ? Colors.green.withOpacity(0.1)
//                   : Colors.orange.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               isPayment
//                   ? Icons.payments_outlined
//                   : isNewStudent
//                   ? Icons.person_add_outlined
//                   : Icons.notifications_outlined,
//               color: isPayment
//                   ? Colors.blue
//                   : isNewStudent
//                   ? Colors.green
//                   : Colors.orange,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   activity["title"] ?? '',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF333333),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   activity["time"] ?? '',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _activitySkeleton() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[100]!),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 14,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 10,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _emptyActivities() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.history_outlined, size: 60, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           const Text(
//             'No recent activities',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Activities will appear here',
//             style: TextStyle(fontSize: 14, color: Colors.grey[400]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<List<Map<String, String>>> _fetchRecentActivities() async {
//     List<Map<String, String>> activities = [];
//
//     try {
//       final firestore = FirebaseFirestore.instance;
//
//       // Fetch newest students
//       final joinSnapshot = await firestore
//           .collection('students_joinName')
//           .orderBy('createdAt', descending: true)
//           .limit(3)
//           .get();
//
//       for (var doc in joinSnapshot.docs) {
//         final data = doc.data();
//         final firstName = data['firstName'] ?? '';
//         final lastName = data['lastName'] ?? '';
//         final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
//
//         activities.add({
//           "title": "New student: $firstName $lastName",
//           "time": _formatTimeAgo(createdAt),
//           "timestamp": createdAt?.millisecondsSinceEpoch.toString() ?? '0',
//           "type": "new_student",
//         });
//       }
//
//       // Fetch recent payments
//       final paymentsSnapshot = await firestore
//           .collection('students_payments')
//           .get();
//
//       for (var studentDoc in paymentsSnapshot.docs) {
//         final studentData = studentDoc.data();
//         final firstName = studentData['firstName'] ?? '';
//         final lastName = studentData['lastName'] ?? '';
//
//         final paymentDocs = await studentDoc.reference
//             .collection('payments')
//             .orderBy('date', descending: true)
//             .limit(2)
//             .get();
//
//         for (var p in paymentDocs.docs) {
//           final pData = p.data();
//
//           DateTime? createdAt;
//           try {
//             final dateStr = pData['date'] ?? '';
//             if (dateStr.isNotEmpty) createdAt = DateTime.parse(dateStr);
//           } catch (e) {
//             createdAt = DateTime.now();
//           }
//
//           final amount = pData['amount']?.toString() ?? '0';
//           final status = pData['status'] ?? '';
//           final formattedAmount = NumberFormat.currency(
//             symbol: '\$',
//             decimalDigits: 0,
//           ).format(double.tryParse(amount) ?? 0);
//
//           activities.add({
//             "title":
//                 "${status == 'Paid' ? '✅' : '⏳'} $formattedAmount by $firstName $lastName",
//             "time": _formatTimeAgo(createdAt),
//             "timestamp": createdAt?.millisecondsSinceEpoch.toString() ?? '0',
//             "type": "payment",
//           });
//         }
//       }
//
//       // Sort and limit
//       activities.sort((a, b) {
//         final t1 = int.tryParse(a['timestamp'] ?? '0') ?? 0;
//         final t2 = int.tryParse(b['timestamp'] ?? '0') ?? 0;
//         return t2.compareTo(t1);
//       });
//
//       if (activities.length > 5) {
//         activities = activities.sublist(0, 5);
//       }
//     } catch (e) {
//       print("Error fetching activities: $e");
//     }
//
//     return activities;
//   }
//
//   String _formatTimeAgo(DateTime? date) {
//     if (date == null) return 'Just now';
//
//     final diff = DateTime.now().difference(date);
//
//     if (diff.inSeconds < 60) return 'Just now';
//     if (diff.inMinutes < 60) {
//       final minutes = diff.inMinutes;
//       return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
//     }
//     if (diff.inHours < 24) {
//       final hours = diff.inHours;
//       return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
//     }
//     if (diff.inDays < 7) {
//       final days = diff.inDays;
//       return '$days ${days == 1 ? 'day' : 'days'} ago';
//     }
//     return DateFormat('MMM d').format(date);
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_register_app/models/admin/admin_model.dart';
import 'package:student_register_app/screens/admin/admin_login.dart';
import '../../models/student_model.dart';
import 'admin_settings.dart' hide AdminModel;
import 'admin_student_list.dart';
import 'admin_payment_list.dart';

class AdminDashboard extends StatefulWidget {
  final AdminModel admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _tabs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int totalStudents = 0;
  int approvedStudents = 0;
  int pendingStudents = 0;
  int overdueStudents = 0;
  int totalPayments = 0;
  double totalRevenue = 0.0;

  bool _isLoading = true;
  late AdminModel admin;
  late AdminModel _admin;

  @override
  void initState() {
    super.initState();
    admin = widget.admin;
    _admin = widget.admin;
    _loadAllStats();
    _fetchAdmin();

    _tabs = [
      const Center(child: CircularProgressIndicator()),
      const AdminStudentListScreen(),
      const AdminPaymentListScreen(),
      AdminSettingsScreen(admin: widget.admin),
    ];
  }

  Future<void> _fetchAdmin() async {
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      debugPrint("❌ No admin is logged in.");
      setState(() => _isLoading = false);
      return;
    }

    final fetchedAdmin = await AdminDao.getAdmin(uid);

    if (fetchedAdmin != null) {
      setState(() {
        _admin = fetchedAdmin;
        _isLoading = false;
      });

      debugPrint("✅ Admin fetched successfully:");
      debugPrint("Name: ${_admin.fullName}");
      debugPrint("Email: ${_admin.email}");
      debugPrint("Image: ${_admin.profileImage}");
    } else {
      debugPrint("❌ Admin not found for UID: $uid");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllStats() async {
    try {
      await _loadStudentStats();
      await _loadPaymentStats();

      setState(() {
        _isLoading = false;
        _tabs[0] = _HomeTab(
          totalStudents: totalStudents,
          approvedStudents: approvedStudents,
          pendingStudents: pendingStudents,
          overdueStudents: overdueStudents,
          totalPayments: totalPayments,
          totalRevenue: totalRevenue,
          adminName: admin.fullName ?? 'Admin',
          adminProfileImage: admin.profileImage,
        );
      });
    } catch (e) {
      print("Error loading stats: $e");
    }
  }

  Future<void> _loadStudentStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students_joinName')
          .get();

      totalStudents = snapshot.docs.length;
      approvedStudents = snapshot.docs
          .where((d) => (d.data()['status'] ?? '') == 'Approved')
          .length;
      pendingStudents = snapshot.docs
          .where((d) => (d.data()['status'] ?? '') == 'Pending')
          .length;
      overdueStudents = snapshot.docs.where((doc) {
        final dueDate = doc.data()['dueDate'];
        if (dueDate == null) return false;
        final date = (dueDate as Timestamp).toDate();
        return date.isBefore(DateTime.now()) &&
            doc.data()['status'] != 'Approved';
      }).length;
    } catch (e) {
      print("Error loading student stats: $e");
    }
  }

  Future<void> _loadPaymentStats() async {
    try {
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('students_payments')
          .get();

      totalPayments = 0;
      totalRevenue = 0.0;

      for (var studentDoc in paymentsSnapshot.docs) {
        final paymentDocs = await studentDoc.reference
            .collection('payments')
            .where('status', isEqualTo: 'Paid')
            .get();

        totalPayments += paymentDocs.docs.length;

        for (var p in paymentDocs.docs) {
          final amount = (p.data()['amount'] ?? 0).toDouble();
          totalRevenue += amount;
        }
      }
    } catch (e) {
      print("Error loading payment stats: $e");
    }
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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, size: screenWidth * 0.06),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: Image.asset(
              'assets/images/logo.png',
              height: screenHeight * 0.035,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066CC)),
      )
          : _tabs[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final currentAdmin = _admin;

    return Drawer(
      width: screenWidth * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header Logo
          SizedBox(
            height: screenHeight * 0.08,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Drawer Header with Admin Info
          Container(
            height: screenHeight * 0.25,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      image: currentAdmin.profileImage != null &&
                          currentAdmin.profileImage!.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(currentAdmin.profileImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: currentAdmin.profileImage == null ||
                        currentAdmin.profileImage!.isEmpty
                        ? Icon(
                      Icons.person,
                      color: const Color(0xFF0066CC),
                      size: screenWidth * 0.1,
                    )
                        : null,
                  ),

                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    currentAdmin.fullName ?? 'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    currentAdmin.email ?? 'admin@school.edu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenWidth * 0.033,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Drawer Menu Items
          _drawerItem(Icons.dashboard_outlined, "Home", 0, context),
          _drawerItem(Icons.people_outlined, "Students", 1, context),
          _drawerItem(Icons.payments_outlined, "Payments", 2, context),
          _drawerItem(Icons.settings_outlined, "Settings", 3, context),

          Divider(thickness: 1, height: screenHeight * 0.02),

          // Additional Options
          _drawerItem(Icons.analytics_outlined, "Reports", -1, context),
          _drawerItem(Icons.help_outline, "Help & Support", -1, context),
          _drawerItem(Icons.info_outline, "About", -1, context),

          Divider(thickness: 1, height: screenHeight * 0.02),

          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: Container(
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.red,
                    size: screenWidth * 0.05,
                  ),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.red.withOpacity(0.5),
                  size: screenWidth * 0.05,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // App Version
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon,
      String title,
      int index,
      BuildContext context,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (index >= 0) {
            setState(() => _selectedIndex = index);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0066CC).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? const Color(0xFF0066CC) : Colors.grey[700],
              size: screenWidth * 0.055,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF0066CC) : Colors.black87,
                fontSize: screenWidth * 0.038,
              ),
            ),
            trailing: isSelected
                ? Container(
              width: screenWidth * 0.02,
              height: screenWidth * 0.02,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0066CC),
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0066CC),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: screenWidth * 0.03,
        ),
        unselectedLabelStyle: TextStyle(fontSize: screenWidth * 0.03),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
              size: screenWidth * 0.06,
            ),
            activeIcon: Icon(
              Icons.dashboard_rounded,
              size: screenWidth * 0.06,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_outline,
              size: screenWidth * 0.06,
            ),
            activeIcon: Icon(
              Icons.people_rounded,
              size: screenWidth * 0.06,
            ),
            label: "Students",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.payments_outlined,
              size: screenWidth * 0.06,
            ),
            activeIcon: Icon(
              Icons.payments_rounded,
              size: screenWidth * 0.06,
            ),
            label: "Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              size: screenWidth * 0.06,
            ),
            activeIcon: Icon(
              Icons.settings_rounded,
              size: screenWidth * 0.06,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.045,
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ============ HOME TAB ============

class _HomeTab extends StatefulWidget {
  final int totalStudents;
  final int approvedStudents;
  final int pendingStudents;
  final int overdueStudents;
  final int totalPayments;
  final double totalRevenue;

  final String adminName;
  final String? adminProfileImage;

  const _HomeTab({
    required this.totalStudents,
    required this.approvedStudents,
    required this.pendingStudents,
    required this.overdueStudents,
    required this.totalPayments,
    required this.totalRevenue,
    required this.adminName,
    this.adminProfileImage,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  AdminModel? _admin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      _fetchAdmin();
    });
  }

  Future<void> _fetchAdmin() async {
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      debugPrint("❌ No admin logged in.");
      setState(() => _isLoading = false);
      return;
    }

    final fetchedAdmin = await AdminDao.getAdmin(uid);

    if (fetchedAdmin != null) {
      setState(() {
        _admin = fetchedAdmin;
        _isLoading = false;
      });

      debugPrint("✅ Admin fetched successfully");
      debugPrint("Name: ${_admin!.fullName}");
      debugPrint("Email: ${_admin!.email}");
      debugPrint("Image: ${_admin!.profileImage}");
    } else {
      debugPrint("❌ Admin not found for UID: $uid");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;
    final isPortrait = screenHeight > screenWidth;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          // Container(
          //   padding: EdgeInsets.fromLTRB(
          //     screenWidth * 0.06,
          //     screenHeight * 0.04,
          //     screenWidth * 0.06,
          //     screenHeight * 0.03,
          //   ),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [
          //         const Color(0xFFFFFFFF),
          //         const Color(0xFFF5F5F5),
          //         const Color(0xFFEEEEEE),
          //       ],
          //       stops: const [0.0, 0.5, 1.0],
          //     ),
          //     borderRadius: const BorderRadius.only(
          //       bottomLeft: Radius.circular(30),
          //       bottomRight: Radius.circular(30),
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.08),
          //         blurRadius: 15,
          //         spreadRadius: 2,
          //         offset: const Offset(0, 5),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Container(
          //             width: screenWidth * 0.13,
          //             height: screenWidth * 0.13,
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: const Color(0xFFF0F0F0),
          //               border: Border.all(
          //                 color: const Color(0xFFE0E0E0),
          //                 width: 2,
          //               ),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.black.withOpacity(0.05),
          //                   blurRadius: 8,
          //                   offset: const Offset(0, 3),
          //                 ),
          //               ],
          //               image: _admin?.profileImage != null &&
          //                   _admin!.profileImage!.isNotEmpty
          //                   ? DecorationImage(
          //                 image: NetworkImage(_admin!.profileImage!),
          //                 fit: BoxFit.cover,
          //               )
          //                   : null,
          //             ),
          //             child: _admin?.profileImage == null ||
          //                 _admin!.profileImage!.isEmpty
          //                 ? Icon(
          //               Icons.person,
          //               color: const Color(0xFF424242),
          //               size: screenWidth * 0.08,
          //             )
          //                 : null,
          //           ),
          //           SizedBox(width: screenWidth * 0.04),
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Welcome back,',
          //                   style: TextStyle(
          //                     fontSize: screenWidth * 0.035,
          //                     color: Colors.black.withOpacity(0.6),
          //                     fontWeight: FontWeight.w500,
          //                   ),
          //                 ),
          //                 SizedBox(height: screenHeight * 0.005),
          //                 Text(
          //                   _admin?.fullName ?? 'Admin',
          //                   style: TextStyle(
          //                     fontSize: screenWidth * 0.05,
          //                     fontWeight: FontWeight.w700,
          //                     color: const Color(0xFF212121),
          //                   ),
          //                   maxLines: 1,
          //                   overflow: TextOverflow.ellipsis,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: screenHeight * 0.02),
          //       Container(
          //         padding: EdgeInsets.symmetric(
          //           horizontal: screenWidth * 0.04,
          //           vertical: screenHeight * 0.012,
          //         ),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(12),
          //           border: Border.all(
          //             color: const Color(0xFFE0E0E0),
          //             width: 1,
          //           ),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withOpacity(0.03),
          //               blurRadius: 4,
          //               offset: const Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Icon(
          //               Icons.calendar_today,
          //               size: screenWidth * 0.04,
          //               color: Colors.black.withOpacity(0.5),
          //             ),
          //             SizedBox(width: screenWidth * 0.02),
          //             Text(
          //               DateFormat('EEE, MMM d, yyyy').format(DateTime.now()),
          //               style: TextStyle(
          //                 fontSize: screenWidth * 0.035,
          //                 color: Colors.black.withOpacity(0.7),
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          SizedBox(height: screenHeight * 0.02),

          // Stats Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isPortrait ? (isSmallPhone ? 2 : 2) : 4,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenWidth * 0.04,
              childAspectRatio: isPortrait ? (isSmallPhone ? 1.1 : 1.2) : 1.1,
              children: [
                _statCard(
                  title: 'Total Students',
                  value: widget.totalStudents.toString(),
                  icon: Icons.school_outlined,
                  color: Colors.blue,
                  context: context,
                ),
                _statCard(
                  title: 'Approved',
                  value: widget.approvedStudents.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  context: context,
                ),
                _statCard(
                  title: 'Pending',
                  value: widget.pendingStudents.toString(),
                  icon: Icons.pending_outlined,
                  color: Colors.orange,
                  context: context,
                ),
                _statCard(
                  title: 'Total Revenue',
                  value: '\$${widget.totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money_outlined,
                  color: Colors.purple,
                  context: context,
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // Recent Activities
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: const Color(0xFF0066CC),
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),

                // Scrollable Activities Container
                Container(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FutureBuilder<List<Map<String, String>>>(
                    future: _fetchRecentActivities(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              _activitySkeleton(context),
                        );
                      }

                      if (snapshot.hasError || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: _emptyActivities(context),
                          ),
                        );
                      }

                      final activities = snapshot.data!;

                      return ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: _activityItem(activities[index], context),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: screenWidth * 0.055,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(
      Map<String, String> activity, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPayment = activity["type"] == "payment";
    final isNewStudent = activity["type"] == "new_student";

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: isPayment
                  ? Colors.blue.withOpacity(0.1)
                  : isNewStudent
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPayment
                  ? Icons.payments_outlined
                  : isNewStudent
                  ? Icons.person_add_outlined
                  : Icons.notifications_outlined,
              color: isPayment
                  ? Colors.blue
                  : isNewStudent
                  ? Colors.green
                  : Colors.orange,
              size: screenWidth * 0.05,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity["title"] ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.037,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  activity["time"] ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activitySkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.015,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  height: screenHeight * 0.012,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyActivities(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.08),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: screenWidth * 0.15,
            color: Colors.grey[300],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'No recent activities',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Activities will appear here',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchRecentActivities() async {
    List<Map<String, String>> activities = [];

    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch newest students
      final joinSnapshot = await firestore
          .collection('students_joinName')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      for (var doc in joinSnapshot.docs) {
        final data = doc.data();
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        activities.add({
          "title": "New student: $firstName $lastName",
          "time": _formatTimeAgo(createdAt),
          "timestamp": createdAt?.millisecondsSinceEpoch.toString() ?? '0',
          "type": "new_student",
        });
      }

      // Fetch recent payments
      final paymentsSnapshot = await firestore
          .collection('students_payments')
          .get();

      for (var studentDoc in paymentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final firstName = studentData['firstName'] ?? '';
        final lastName = studentData['lastName'] ?? '';

        final paymentDocs = await studentDoc.reference
            .collection('payments')
            .orderBy('date', descending: true)
            .limit(2)
            .get();

        for (var p in paymentDocs.docs) {
          final pData = p.data();

          DateTime? createdAt;
          try {
            final dateStr = pData['date'] ?? '';
            if (dateStr.isNotEmpty) createdAt = DateTime.parse(dateStr);
          } catch (e) {
            createdAt = DateTime.now();
          }

          final amount = pData['amount']?.toString() ?? '0';
          final status = pData['status'] ?? '';
          final formattedAmount = NumberFormat.currency(
            symbol: '\$',
            decimalDigits: 0,
          ).format(double.tryParse(amount) ?? 0);

          activities.add({
            "title":
            "${status == 'Paid' ? '✅' : '⏳'} $formattedAmount by $firstName $lastName",
            "time": _formatTimeAgo(createdAt),
            "timestamp": createdAt?.millisecondsSinceEpoch.toString() ?? '0',
            "type": "payment",
          });
        }
      }

      // Sort and limit
      activities.sort((a, b) {
        final t1 = int.tryParse(a['timestamp'] ?? '0') ?? 0;
        final t2 = int.tryParse(b['timestamp'] ?? '0') ?? 0;
        return t2.compareTo(t1);
      });

      if (activities.length > 5) {
        activities = activities.sublist(0, 5);
      }
    } catch (e) {
      print("Error fetching activities: $e");
    }

    return activities;
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Just now';

    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final days = diff.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    return DateFormat('MMM d').format(date);
  }
}