// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../../models/payment_model.dart';
// import 'student_pay_details.dart';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../models/payment_model.dart';
//
// class StudentPaymentService {
//   static Future<List<Payment>> loadPayments(String studentId) async {
//     // 1️⃣ Get student document
//     final studentDoc = await FirebaseFirestore.instance
//         .collection('students_payments')
//         .doc(studentId)
//         .get();
//
//     if (!studentDoc.exists) {
//       debugPrint("❌ Student $studentId not found");
//       return [];
//     }
//
//     final studentData = studentDoc.data()!;
//     final studentName =
//         "${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}"
//             .trim();
//     final studentMajor = studentData['major'] ?? 'Unknown';
//     final studentPhotoUrl = studentData['photoUrl'] ?? '';
//
//     // 2️⃣ Load payments
//     final snap = await FirebaseFirestore.instance
//         .collection('students_payments')
//         .doc(studentId)
//         .collection('payments')
//         .orderBy('year')
//         .orderBy('semester')
//         .get();
//
//     // 3️⃣ Convert payments
//     return snap.docs.map((doc) {
//       final data = doc.data();
//       return Payment.fromFirestore(studentId, data).copyWith(
//         studentName: studentName,
//         major: studentMajor,
//         photoUrl: studentPhotoUrl,
//       );
//     }).toList();
//   }
// }
//
// // Change this function to be static
// Future<List<Payment>> loadPayments(String studentId) async {
//   // 1️⃣ Get student document
//   final studentDoc = await FirebaseFirestore.instance
//       .collection('students_payments')
//       .doc(studentId)
//       .get();
//
//   if (!studentDoc.exists) {
//     debugPrint("❌ Student $studentId not found");
//     return [];
//   }
//
//   final studentData = studentDoc.data()!;
//   final studentName =
//       "${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}"
//           .trim();
//   final studentMajor = studentData['major'] ?? 'Unknown';
//   final studentPhotoUrl = studentData['photoUrl'] ?? '';
//
//   // 2️⃣ Load payments
//   final snap = await FirebaseFirestore.instance
//       .collection('students_payments')
//       .doc(studentId)
//       .collection('payments')
//       .orderBy('year')
//       .orderBy('semester')
//       .get();
//
//   // 3️⃣ Convert payments
//   return snap.docs.map((doc) {
//     final data = doc.data();
//     return Payment.fromFirestore(studentId, data).copyWith(
//       studentName: studentName,
//       major: studentMajor,
//       photoUrl: studentPhotoUrl,
//     );
//   }).toList();
// }
//
// // Payment order definition
// final List<Map<String, dynamic>> paymentOrder = [
//   {'year': 1, 'semester': 'Semester 1'},
//   {'year': 1, 'semester': 'Semester 2'},
//   {'year': 2, 'semester': 'Semester 1'},
//   {'year': 2, 'semester': 'Semester 2'},
//   {'year': 3, 'semester': 'Semester 1'},
//   {'year': 3, 'semester': 'Semester 2'},
//   {'year': 4, 'semester': 'Semester 1'},
//   {'year': 4, 'semester': 'Semester 2'},
// ];
//
// // Next payment finder
// Map<String, dynamic>? findNextPayment(List<Payment> payments) {
//   for (var order in paymentOrder) {
//     for (var p in payments) {
//       if (p.year == order['year'] &&
//           p.semester == order['semester'] &&
//           p.status != 'Paid') {
//         return {'year': p.year, 'semester': p.semester, 'status': p.status};
//       }
//     }
//   }
//   return null;
// }
//
// // ────────────────────────────────
// // DYNAMIC STUDENT PAYMENT SCREEN
// // ────────────────────────────────
// class StudentPaymentScreen extends StatefulWidget {
//   final Map<String, dynamic> student;
//
//   const StudentPaymentScreen({super.key, required this.student});
//
//   @override
//   State<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
// }
//
// class _StudentPaymentScreenState extends State<StudentPaymentScreen> {
//   String _selectedYear = 'All';
//   String _selectedSemester = 'All';
//   List<Payment> payments = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFirebasePayments();
//   }
//
//   Future<void> _loadFirebasePayments() async {
//     final studentId = widget.student['studentId'] ?? '';
//
//     try {
//       // Use the service class
//       final list = await StudentPaymentService.loadPayments(studentId);
//
//       setState(() {
//         payments = list;
//         isLoading = false;
//       });
//
//       // Call next-payment logic
//       final next = findNextPayment(list);
//
//       if (next == null) {
//         debugPrint("All payments complete!");
//       } else {
//         debugPrint("Next payment: Year ${next['year']} - ${next['semester']}");
//       }
//     } catch (e) {
//       debugPrint("Error loading payments: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     final filteredPayments = payments.where((p) {
//       final semesterMatch =
//           _selectedSemester == 'All' || p.semester == _selectedSemester;
//       final yearMatch =
//           _selectedYear == 'All' || p.year.toString() == _selectedYear;
//       return semesterMatch && yearMatch;
//     }).toList();
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           _buildFilterCard(),
//           Expanded(child: _buildGroupedList(filteredPayments)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterCard() {
//     const years = ['All', '1', '2', '3', '4'];
//     const semesters = ['All', 'Semester 1', 'Semester 2'];
//
//     return Card(
//       margin: const EdgeInsets.all(12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedYear,
//                     decoration: InputDecoration(
//                       labelText: "Year",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     items: years
//                         .map(
//                           (y) => DropdownMenuItem(
//                             value: y,
//                             child: Text(y == 'All' ? 'All Years' : 'Year $y'),
//                           ),
//                         )
//                         .toList(),
//                     onChanged: (v) => setState(() => _selectedYear = v!),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedSemester,
//                     decoration: InputDecoration(
//                       labelText: "Semester",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     items: semesters
//                         .map((s) => DropdownMenuItem(value: s, child: Text(s)))
//                         .toList(),
//                     onChanged: (v) => setState(() => _selectedSemester = v!),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton.icon(
//                 onPressed: () {
//                   setState(() {
//                     _selectedYear = 'All';
//                     _selectedSemester = 'All';
//                   });
//                 },
//                 icon: const Icon(Icons.refresh, color: Colors.blueAccent),
//                 label: const Text(
//                   "Show All",
//                   style: TextStyle(color: Colors.blueAccent),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGroupedList(List<Payment> filtered) {
//     final Map<int, Map<String, List<Payment>>> grouped = {};
//
//     for (var p in filtered) {
//       grouped.putIfAbsent(p.year, () => {});
//       grouped[p.year]!.putIfAbsent(p.semester, () => []);
//       grouped[p.year]![p.semester]!.add(p);
//     }
//
//     final sortedYears = grouped.keys.toList()..sort();
//
//     if (sortedYears.isEmpty) {
//       return const Center(
//         child: Text("No payments found.", style: TextStyle(color: Colors.grey)),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: sortedYears.length,
//       itemBuilder: (context, index) {
//         final year = sortedYears[index];
//         final semData = grouped[year]!;
//
//         return Card(
//           color: const Color.fromARGB(255, 0, 32, 112),
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 2,
//           child: ExpansionTile(
//             textColor: Colors.white,
//             iconColor: Colors.white,
//             collapsedTextColor: Colors.white,
//             collapsedIconColor: Colors.white,
//             title: Text(
//               "Year $year",
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             children: semData.keys.map((semester) {
//               final list = semData[semester]!;
//
//               return ExpansionTile(
//                 title: Text(
//                   semester,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 children: list.map((p) {
//                   final isPaid = p.status == 'Paid';
//
//                   return ListTile(
//                     leading: Icon(
//                       Icons.receipt_long_rounded,
//                       color: _getStatusColor(p.status),
//                       size: 30,
//                     ),
//                     title: Text(
//                       "Major ${p.major.isNotEmpty ? p.major : (widget.student['major'] ?? 'Unknown')}",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     subtitle: Text(
//                       "Amount: \$${p.amount} | Status: ${p.status}",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: _getStatusColor(p.status),
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                     onTap: isPaid
//                         ? null
//                         : () {
//                             final studentId = widget.student['studentId'] ?? '';
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => PaymentDetailsScreen(
//                                   payment: p,
//                                   student: {
//                                     'studentId': studentId,
//                                     'firstName':
//                                         widget.student['firstName'] ?? '',
//                                     'lastName':
//                                         widget.student['lastName'] ?? '',
//                                     'major': widget.student['major'] ?? '',
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                   );
//                 }).toList(),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   Color _getStatusColor(String st) {
//     switch (st) {
//       case "Paid":
//         return Colors.green;
//       case "Pending":
//         return Colors.orange;
//       case "Owing":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/payment_model.dart';
import 'student_pay_details.dart';

class StudentPaymentService {
  static Future<List<Payment>> loadPayments(String studentId) async {
    // 1️⃣ Get student document
    final studentDoc = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .get();

    if (!studentDoc.exists) {
      debugPrint("❌ Student $studentId not found");
      return [];
    }

    final studentData = studentDoc.data()!;
    final studentName =
        "${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}"
            .trim();
    final studentMajor = studentData['major'] ?? 'Unknown';
    final studentPhotoUrl = studentData['photoUrl'] ?? '';

    // 2️⃣ Load payments
    final snap = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .orderBy('year')
        .orderBy('semester')
        .get();

    // 3️⃣ Convert payments
    return snap.docs.map((doc) {
      final data = doc.data();
      return Payment.fromFirestore(studentId, data).copyWith(
        studentName: studentName,
        major: studentMajor,
        photoUrl: studentPhotoUrl,
      );
    }).toList();
  }
}

// Payment order definition
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

// Next payment finder
Map<String, dynamic>? findNextPayment(List<Payment> payments) {
  for (var order in paymentOrder) {
    for (var p in payments) {
      if (p.year == order['year'] &&
          p.semester == order['semester'] &&
          p.status != 'Paid') {
        return {'year': p.year, 'semester': p.semester, 'status': p.status};
      }
    }
  }
  return null;
}


// ────────────────────────────────
// DYNAMIC STUDENT PAYMENT SCREEN
// ────────────────────────────────
class StudentPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentPaymentScreen({super.key, required this.student});

  @override
  State<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends State<StudentPaymentScreen> {
  String _selectedYear = 'All';
  String _selectedSemester = 'All';
  List<Payment> payments = [];
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    _loadFirebasePayments();
  }

  Future<void> _loadFirebasePayments() async {
    final studentId = widget.student['studentId'] ?? '';

    try {
      final list = await StudentPaymentService.loadPayments(studentId);

      setState(() {
        payments = list;
        isLoading = false;
      });

      final next = findNextPayment(list);

      if (next == null) {
        debugPrint("All payments complete!");
      } else {
        debugPrint("Next payment: Year ${next['year']} - ${next['semester']}");
      }
    } catch (e) {
      debugPrint("Error loading payments: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredPayments = payments.where((p) {
      final semesterMatch =
          _selectedSemester == 'All' || p.semester == _selectedSemester;
      final yearMatch =
          _selectedYear == 'All' || p.year.toString() == _selectedYear;
      return semesterMatch && yearMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildFilterCard(w, h),
          Expanded(child: _buildGroupedList(filteredPayments, w, h)),
        ],
      ),
    );
  }

  Widget _buildFilterCard(double w, double h) {
    const years = ['All', '1', '2', '3', '4'];
    const semesters = ['All', 'Semester 1', 'Semester 2'];

    return Card(
      margin: EdgeInsets.all(w * 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: "Year",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.015,
                      ),
                    ),
                    items: years
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text(
                              y == 'All' ? 'All Years' : 'Year $y',
                              style: TextStyle(fontSize: w * 0.035),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    decoration: InputDecoration(
                      labelText: "Semester",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.015,
                      ),
                    ),
                    items: semesters
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: TextStyle(fontSize: w * 0.035),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSemester = v!),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.015),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedYear = 'All';
                    _selectedSemester = 'All';
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.blueAccent,
                  size: w * 0.04,
                ),
                label: Text(
                  "Show All",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: w * 0.035,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(List<Payment> filtered, double w, double h) {
    final Map<int, Map<String, List<Payment>>> grouped = {};

    for (var p in filtered) {
      grouped.putIfAbsent(p.year, () => {});
      grouped[p.year]!.putIfAbsent(p.semester, () => []);
      grouped[p.year]![p.semester]!.add(p);
    }

    final sortedYears = grouped.keys.toList()..sort();

    if (sortedYears.isEmpty) {
      return const Center(
        child: Text("No payments found.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final semData = grouped[year]!;

        return Card(
          color: const Color.fromARGB(255, 0, 32, 112),
          margin: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.008,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          elevation: 2,
          child: ExpansionTile(
            textColor: Colors.white,
            iconColor: Colors.white,
            collapsedTextColor: Colors.white,
            collapsedIconColor: Colors.white,
            title: Text(
              "Year $year",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            children: semData.keys.map((semester) {
              final list = semData[semester]!;

              return ExpansionTile(
                title: Text(
                  semester,
                  style: TextStyle(color: Colors.white, fontSize: w * 0.04),
                ),
                children: list.map((p) {
                  final isPaid = p.status == 'Paid';

                  return ListTile(
                    leading: Icon(
                      Icons.receipt_long_rounded,
                      color: _getStatusColor(p.status),
                      size: w * 0.07,
                    ),
                    title: Text(
                      "Major ${p.major.isNotEmpty ? p.major : (widget.student['major'] ?? 'Unknown')}",
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "Amount: \$${p.amount} | Status: ${p.status}",
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: _getStatusColor(p.status),
                      ),
                    ),
                    trailing: p.receiptUrl != null && p.receiptUrl!.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReceiptPreviewScreen(
                                    imageUrl: p.receiptUrl!,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: w * 0.06,
                            ),
                          )
                        : null,
                    onTap: isPaid
                        ? null
                        : () {
                            final studentId = widget.student['studentId'] ?? '';
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => PaymentDetailsScreen(
                            //       payment: p,
                            //       student: {
                            //         'studentId': studentId,
                            //         'firstName': widget.student['firstName'] ?? '',
                            //         'lastName': widget.student['lastName'] ?? '',
                            //         'major': widget.student['major'] ?? '',
                            //       },
                            //     ),
                            //   ),
                            // );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentDetailsScreen(
                                  student: {
                                    'studentId': studentId,
                                    'firstName':
                                        widget.student['firstName'] ?? '',
                                    'lastName':
                                        widget.student['lastName'] ?? '',
                                    'major': widget.student['major'] ?? '',
                                  },
                                  payment: p, // Payment object
                                ),
                              ),
                            );
                          },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String st) {
    switch (st) {
      case "Paid":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Owing":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ────────────────────────────────
// RECEIPT PREVIEW SCREEN
// ────────────────────────────────
class ReceiptPreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ReceiptPreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Receipt"),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (c, child, loading) {
              if (loading == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}
