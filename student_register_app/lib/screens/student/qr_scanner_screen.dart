// // import 'package:flutter/material.dart';
// // import 'package:qr_code_scanner/qr_code_scanner.dart';
// // import 'dart:convert';

// // class SimpleQRScanner extends StatefulWidget {
// //   const SimpleQRScanner({super.key});

// //   @override
// //   State<SimpleQRScanner> createState() => _SimpleQRScannerState();
// // }

// // class _SimpleQRScannerState extends State<SimpleQRScanner> {
// //   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
// //   QRViewController? controller;
// //   String? scannedData;

// //   @override
// //   void dispose() {
// //     controller?.dispose();
// //     super.dispose();
// //   }

// //   void _onQRViewCreated(QRViewController controller) {
// //     this.controller = controller;
// //     controller.scannedDataStream.listen((scanData) {
// //       if (scanData.code != null && scannedData == null) {
// //         setState(() {
// //           scannedData = scanData.code;
// //         });
        
// //         // Stop camera after scan
// //         controller.pauseCamera();
        
// //         // Show student info
// //         _showStudentInfo(scanData.code!);
// //       }
// //     });
// //   }

// //   void _showStudentInfo(String qrData) {
// //     try {
// //       final data = json.decode(qrData) as Map<String, dynamic>;
      
// //       showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (context) => AlertDialog(
// //           title: const Text(
// //             '🎓 Student Verified',
// //             style: TextStyle(color: Color(0xFF0066CC)),
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Student Card
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF8FAFF),
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     // Student Icon
// //                     const Icon(
// //                       Icons.school,
// //                       size: 50,
// //                       color: Color(0xFF0066CC),
// //                     ),
// //                     const SizedBox(height: 12),
                    
// //                     // Student Name
// //                     Text(
// //                       data['name'] ?? 'Unknown Student',
// //                       style: const TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF1A1A1A),
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
                    
// //                     const SizedBox(height: 8),
                    
// //                     // Student ID Badge
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFF0066CC).withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         'ID: ${data['studentId'] ?? 'N/A'}',
// //                         style: const TextStyle(
// //                           color: Color(0xFF0066CC),
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
                    
// //                     const SizedBox(height: 16),
                    
// //                     // Details
// //                     _buildInfoRow('Major', data['major'] ?? 'Not specified'),
// //                     _buildInfoRow('Year', data['year'] ?? 'Not specified'),
// //                     _buildInfoRow('Status', 'Verified ✅'),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context); // Close dialog
// //                 _resetScanner();
// //               },
// //               child: const Text('Scan Another'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.pop(context); // Close dialog
// //                 Navigator.pop(context); // Go back to profile
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF0066CC),
// //               ),
// //               child: const Text('Done'),
// //             ),
// //           ],
// //         ),
// //       );
// //     } catch (e) {
// //       // Not a valid student QR
// //       showDialog(
// //         context: context,
// //         builder: (context) => AlertDialog(
// //           title: const Text('⚠️ Invalid QR Code'),
// //           content: Text('Scanned data: $qrData'),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //                 _resetScanner();
// //               },
// //               child: const Text('Try Again'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //   }

// //   Widget _buildInfoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Text(
// //               '$label:',
// //               style: const TextStyle(
// //                 color: Color(0xFF6B7280),
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: const TextStyle(
// //                 color: Color(0xFF1A1A1A),
// //                 fontWeight: FontWeight.w600,
// //               ),
// //               textAlign: TextAlign.right,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _resetScanner() {
// //     setState(() {
// //       scannedData = null;
// //     });
// //     controller?.resumeCamera();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Scan Student QR Code'),
// //         backgroundColor: const Color(0xFF0066CC),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.flash_on),
// //             onPressed: () async {
// //               await controller?.toggleFlash();
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Scanner View
// //           Expanded(
// //             child: QRView(
// //               key: qrKey,
// //               onQRViewCreated: _onQRViewCreated,
// //               overlay: QrScannerOverlayShape(
// //                 borderColor: const Color(0xFF0066CC),
// //                 borderRadius: 10,
// //                 borderLength: 30,
// //                 borderWidth: 10,
// //                 cutOutSize: 250,
// //               ),
// //             ),
// //           ),
          
// //           // Instructions
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             color: Colors.black.withOpacity(0.8),
// //             child: const Text(
// //               'Point camera at student QR code',
// //               style: TextStyle(color: Colors.white),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:convert';

// class UniversalQRScanner extends StatefulWidget {
//   const UniversalQRScanner({super.key});

//   @override
//   State<UniversalQRScanner> createState() => _UniversalQRScannerState();
// }

// class _UniversalQRScannerState extends State<UniversalQRScanner> {
//   String? scannedData;
//   bool _isWeb = false;

//   @override
//   void initState() {
//     super.initState();
//     _isWeb = kIsWeb;
//   }

//   // Web QR Scanner Simulation
//   void _simulateWebQRScan() {
//     // For web, we simulate scanning with a dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Web QR Scanner'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('On web, you can:'),
//             const SizedBox(height: 16),
//             // Option 1: Upload QR image
//             ElevatedButton.icon(
//               onPressed: _uploadQRImage,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload QR Image'),
//             ),
//             const SizedBox(height: 8),
//             // Option 2: Enter QR data manually
//             ElevatedButton.icon(
//               onPressed: _enterQRDataManually,
//               icon: const Icon(Icons.keyboard),
//               label: const Text('Enter QR Data'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Mobile QR Scanner
//   void _startMobileQRScan() {
//     // For mobile, we'll use device camera if available
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Mobile QR Scanner'),
//         content: _buildMobileScannerUI(),
//       ),
//     );
//   }

//   Widget _buildMobileScannerUI() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Scanner placeholder with animation
//         Container(
//           width: 250,
//           height: 250,
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFF0066CC), width: 4),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.qr_code_scanner, size: 60, color: Color(0xFF0066CC)),
//                 SizedBox(height: 16),
//                 Text('Point camera at QR code'),
//                 SizedBox(height: 8),
//                 CircularProgressIndicator(),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Simulate scan for demo
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//             // Demo student data
//             _processQRData('{"studentId":"STU2024001","name":"John Smith","major":"Computer Science","year":"Year 3","validUntil":"2025-12-31"}');
//           },
//           child: const Text('Demo Scan'),
//         ),
//       ],
//     );
//   }

//   void _uploadQRImage() {
//     // Implement image upload logic here
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Upload QR Image'),
//         content: const Text('Upload feature coming soon. Using demo data for now.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _processQRData('{"studentId":"STU2024001","name":"John Smith","major":"Computer Science","year":"Year 3"}');
//             },
//             child: const Text('Use Demo'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _enterQRDataManually() {
//     final TextEditingController controller = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Enter QR Code Data'),
//         content: TextField(
//           controller: controller,
//           maxLines: 5,
//           decoration: const InputDecoration(
//             hintText: 'Paste QR code JSON here...',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 Navigator.pop(context);
//                 _processQRData(controller.text);
//               }
//             },
//             child: const Text('Verify'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _processQRData(String qrData) {
//     setState(() {
//       scannedData = qrData;
//     });

//     try {
//       final data = json.decode(qrData) as Map<String, dynamic>;
//       _showStudentInfo(data);
//     } catch (e) {
//       _showError('Invalid QR code format. Expected JSON.');
//     }
//   }

//   void _showStudentInfo(Map<String, dynamic> studentData) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xFF0066CC),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Row(
//             children: [
//               Icon(Icons.verified, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 'Student Verified',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         content: _buildStudentCard(studentData),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() => scannedData = null);
//             },
//             child: const Text('Scan Another'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0066CC),
//             ),
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentCard(Map<String, dynamic> student) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Student Avatar
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
//             child: const Icon(
//               Icons.school,
//               size: 40,
//               color: Color(0xFF0066CC),
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Student Name
//           Text(
//             student['name'] ?? 'Unknown Student',
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A1A),
//             ),
//             textAlign: TextAlign.center,
//           ),
          
//           const SizedBox(height: 8),
          
//           // Student ID
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0066CC).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'ID: ${student['studentId'] ?? 'N/A'}',
//               style: const TextStyle(
//                 color: Color(0xFF0066CC),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Student Details
//           _buildDetailRow('Major', student['major'] ?? 'Not specified'),
//           _buildDetailRow('Year', student['year'] ?? 'Not specified'),
//           _buildDetailRow('Valid Until', 
//               student['validUntil'] != null 
//                   ? student['validUntil'].toString().split('T')[0]
//                   : 'N/A'),
          
//           const SizedBox(height: 16),
          
//           // Verification Status
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.green),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.verified, color: Colors.green, size: 18),
//                 SizedBox(width: 8),
//                 Text(
//                   'VERIFIED STUDENT',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Color(0xFF6B7280),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Color(0xFF1A1A1A),
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() => scannedData = null);
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student QR Scanner'),
//         backgroundColor: const Color(0xFF0066CC),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Scanner Icon
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF0066CC).withOpacity(0.1),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: const Color(0xFF0066CC), width: 3),
//               ),
//               child: const Icon(
//                 Icons.qr_code_scanner,
//                 size: 100,
//                 color: Color(0xFF0066CC),
//               ),
//             ),
            
//             const SizedBox(height: 32),
            
//             // Scanner Title
//             const Text(
//               'Student QR Code Scanner',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1A1A1A),
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             Text(
//               _isWeb 
//                   ? 'Web Version - Upload or enter QR data'
//                   : 'Mobile Version - Use camera to scan',
//               style: const TextStyle(
//                 color: Color(0xFF6B7280),
//               ),
//               textAlign: TextAlign.center,
//             ),
            
//             const SizedBox(height: 32),
            
//             // Scan Button
//             ElevatedButton.icon(
//               onPressed: _isWeb ? _simulateWebQRScan : _startMobileQRScan,
//               icon: const Icon(Icons.qr_code_scanner),
//               label: Text(_isWeb ? 'Start Web Scanner' : 'Start Mobile Scanner'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0066CC),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Demo Button
//             OutlinedButton.icon(
//               onPressed: () {
//                 _processQRData('{"studentId":"STU2024001","name":"Sophia Chen","major":"Business Administration","year":"Year 2","validUntil":"2025-12-31"}');
//               },
//               icon: const Icon(Icons.play_arrow),
//               label: const Text('Try Demo QR Code'),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 side: BorderSide(color: const Color(0xFF0066CC).withOpacity(0.5)),
//               ),
//             ),
            
//             // Last scanned data
//             if (scannedData != null) ...[
//               const SizedBox(height: 32),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Last Scanned:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       scannedData!.length > 100 
//                           ? '${scannedData!.substring(0, 100)}...' 
//                           : scannedData!,
//                       style: const TextStyle(fontFamily: 'monospace'),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DynamicQRScanner extends StatefulWidget {
  const DynamicQRScanner({super.key});

  @override
  State<DynamicQRScanner> createState() => _DynamicQRScannerState();
}

class _DynamicQRScannerState extends State<DynamicQRScanner> {
  String? scannedData;
  bool _isWeb = false;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isWeb = kIsWeb;
  }

  // ✅ REAL QR SCANNING - Parse and Fetch from Firebase
  Future<void> _processRealQRData(String qrData) async {
    setState(() {
      _isLoading = true;
      scannedData = qrData;
    });

    try {
      final data = json.decode(qrData) as Map<String, dynamic>;
      
      // Extract student ID from QR code
      final studentId = data['studentId']?.toString();
      
      if (studentId == null || studentId.isEmpty) {
        _showError('Invalid QR: No student ID found');
        return;
      }

      // ✅ FETCH REAL STUDENT DATA FROM FIREBASE
      await _fetchStudentFromFirebase(studentId, data);
      
    } catch (e) {
      _showError('Invalid QR code format or connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ FETCH REAL STUDENT FROM FIREBASE
  Future<void> _fetchStudentFromFirebase(
    String studentId, 
    Map<String, dynamic> qrData
  ) async {
    try {
      // Fetch from students_joinName collection
      final studentDoc = await _firestore
          .collection('students_joinName')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (studentDoc.docs.isEmpty) {
        // Try students_payments collection
        final paymentsDoc = await _firestore
            .collection('students_payments')
            .doc(studentId)
            .get();

        if (paymentsDoc.exists) {
          _showStudentInfo(paymentsDoc.data()!, qrData);
        } else {
          _showError('Student not found in database');
        }
      } else {
        _showStudentInfo(studentDoc.docs.first.data(), qrData);
      }
    } catch (e) {
      _showError('Database error: $e');
    }
  }

  // ✅ SHOW REAL STUDENT INFO WITH DYNAMIC DATA
  void _showStudentInfo(
    Map<String, dynamic> firebaseData, 
    Map<String, dynamic> qrData
  ) {
    // Combine Firebase data with QR data
    final studentInfo = {
      ...firebaseData,  // Firebase data (real)
      ...qrData,        // QR data (current)
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0066CC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Student Verified',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: _buildRealStudentCard(studentInfo),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => scannedData = null);
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to student profile or details
              _viewFullProfile(studentInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
            ),
            child: const Text('View Full Profile'),
          ),
        ],
      ),
    );
  }

  // ✅ REAL STUDENT CARD WITH FIREBASE DATA
  Widget _buildRealStudentCard(Map<String, dynamic> student) {
    final studentName = '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}'.trim();
    final studentId = student['studentId'] ?? 'N/A';
    final major = student['major'] ?? 'Not specified';
    final year = student['year'] ?? 'Not specified';
    final status = student['status'] ?? 'Unknown';
    final email = student['email'] ?? '';
    final phone = student['phone'] ?? '';
    final photoUrl = student['photoUrl'] ?? '';

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Student Photo
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
              backgroundImage: photoUrl.isNotEmpty 
                  ? NetworkImage(photoUrl) as ImageProvider
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF0066CC),
                    )
                  : null,
            ),
            
            const SizedBox(height: 16),
            
            // Student Name
            Text(
              studentName.isNotEmpty ? studentName : 'Unknown Student',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Student ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: $studentId',
                style: const TextStyle(
                  color: Color(0xFF0066CC),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Student Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Student Details
            _buildDetailRow('Major', major),
            _buildDetailRow('Year', year),
            
            if (email.isNotEmpty) _buildDetailRow('Email', email),
            if (phone.isNotEmpty) _buildDetailRow('Phone', phone),
            
            _buildDetailRow('Valid Until', 
                student['validUntil'] != null 
                    ? student['validUntil'].toString().split('T')[0]
                    : 'N/A'),
            
            const SizedBox(height: 16),
            
            // Verification Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'VERIFIED - ${DateTime.now().toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewFullProfile(Map<String, dynamic> student) {
    // Navigate to student profile screen
    // You can implement this based on your app structure
    Navigator.pop(context); // Close dialog first
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening profile of ${student['firstName'] ?? 'Student'}'),
        backgroundColor: const Color(0xFF0066CC),
      ),
    );
  }

  // ✅ DYNAMIC SCANNER UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student QR Scanner'),
        backgroundColor: const Color(0xFF0066CC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scanner Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0066CC), width: 3),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF0066CC),
                          strokeWidth: 4,
                        )
                      : const Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Color(0xFF0066CC),
                        ),
                ),
                
                const SizedBox(height: 32),
                
                // Scanner Title
                const Text(
                  'Dynamic QR Scanner',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _isWeb 
                      ? 'Web Version - Paste QR data from student'
                      : 'Mobile Version - Scan student QR codes',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Scan Options
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isWeb ? _showWebScanner : _showMobileScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(_isWeb ? 'Paste QR Data' : 'Open Camera Scanner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Test with Real Student Data
                    OutlinedButton.icon(
                      onPressed: () => _testWithRealStudent(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Test with Real Student'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: const Color(0xFF0066CC).withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWebScanner() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Student QR Data'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste student QR code JSON here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _processRealQRData(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
            ),
            child: const Text('Verify Student'),
          ),
        ],
      ),
    );
  }

  void _showMobileScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mobile QR Scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0066CC), width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 60, color: Color(0xFF0066CC)),
                    SizedBox(height: 16),
                    Text('Scan Student QR Code'),
                    SizedBox(height: 8),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: For real scanning, you would integrate a camera QR scanner package',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showWebScanner(); // Fallback to manual input
              },
              child: const Text('Enter QR Manually'),
            ),
          ],
        ),
      ),
    );
  }

  void _testWithRealStudent() {
    // This would be a real student ID from your database
    _processRealQRData('{"studentId":"STU2024001","validUntil":"2025-12-31"}');
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => scannedData = null);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}