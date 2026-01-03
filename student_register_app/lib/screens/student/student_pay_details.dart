// // // lib/screens/payment_details_screen.dart
// import 'dart:io';
// import 'dart:ui';
// import 'package:confetti/confetti.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:student_register_app/data/cloudinary_service.dart';
// import 'package:student_register_app/models/payment_model.dart'; // payments Modal
// import 'package:student_register_app/screens/student/student_qr_payment.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'aba_web_payment_screen.dart';
// import 'student_payment.dart';
// import 'dart:ui';
// import 'dart:io';
// import 'package:cross_file/cross_file.dart';
// import 'package:share_plus/share_plus.dart';

// // import 'package:share_plus/share_plus.dart';

// import 'package:path_provider/path_provider.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

// class PaymentDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> student;
//   final Payment payment;

//   const PaymentDetailsScreen({
//     super.key,
//     required this.student,
//     required this.payment,
//   });

//   @override
//   State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
// }

// class _PaymentDetailsScreenState extends State<PaymentDetailsScreen>
//     with TickerProviderStateMixin {
//   final _amountController = TextEditingController();
//   bool _isProcessing = false;
//   String _selectedMethod = 'Cash';
//   late final ConfettiController _confettiCtrl;

//   final List<String> _paymentMethods = [
//     'Cash',
//     'ABA Bank',
//     'Wing',
//     'ACLEDA',
//     'TrueMoney',
//   ];

//   late final String studentFullName;
//   late final String studentId;
//   late String majorName;

//   bool _hasPaid = false; // to track payment status

//   @override
//   void initState() {
//     super.initState();

//     // Null-safe student data
//     final student = widget.student;
//     final firstName = student['firstName'] ?? '';
//     final lastName = student['lastName'] ?? '';
//     // final major = student['major'] ?? '';
//     majorName = student['major'] ?? 'No Major';

//     studentFullName = '$firstName $lastName';
//     studentId = student['studentId'] ?? '';

//     // Set amount text
//     _amountController.text = widget.payment.amount.toString();

//     _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));

//     _checkIfAlreadyPaid(); // check payment
//   }

//   // === Check payment status === //
//   Future<void> _checkIfAlreadyPaid() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('payments')
//         .doc(studentId)
//         .get();

//     if (doc.exists) {
//       final payments = doc.data()?['payments'] as List<dynamic>? ?? [];
//       for (var payment in payments) {
//         if (payment['semester'] == widget.payment.semester &&
//             payment['year'] == widget.payment.year) {
//           setState(() => _hasPaid = true);
//           break;
//         }
//       }
//     }
//   }
//   //==End check status ==//

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _confettiCtrl.dispose();
//     super.dispose();
//   }

//   // ────── PROCESS PAYMENT ──────
//   Future<void> _processPayment() async {
//     final amount = double.tryParse(_amountController.text) ?? 0;
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Enter a valid amount'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Bank → QR
//     if (_selectedMethod != 'Cash') {
//       _showQrScreen(amount);
//       // openAbaPayment();
//       return;
//     }

//     // Cash → simulate processing
//     setState(() => _isProcessing = true);
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() => _isProcessing = false);

//     _showAnimatedReceipt(amount);
//   }

//   // ────── QR SCREEN ──────
//   void _showQrScreen(double amount) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QrPaymentScreen(
//           amount: amount,
//           method: _selectedMethod,
//           studentName: studentFullName,
//           onPaid: () {
//             Navigator.pop(context);
//             _showAnimatedReceipt(amount);
//           }, qrLink: '',

//         ),
//       ),
//     );
//   }

//   void openAbaPayment(BuildContext context, double amount) {
//     final paymentUrl =
//         "https://link.payway.com.kh/aba"
//         "?id=5BDC4CB78BA6"
//         "&dynamic=true"
//         "&source_caller=api"
//         "&pid=app_to_app"
//         "&link_action=abaqr"
//         "&shortlink=4b4xzamg"
//         "&amount=${amount.toStringAsFixed(2)}"
//         "&created_from_app=true"
//         "&acc=995555061"
//         "&userid=5BDC4CB78BA6"
//         "&code=838141"
//         "&c=abaqr";

//     // ✅ WEB
//     if (kIsWeb) {
//       launchUrl(Uri.parse(paymentUrl));
//       return;
//     }

//     // ✅ MOBILE
//     // if (Platform.isAndroid || Platform.isIOS) {
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(
//     //       builder: (_) => AbaWebPaymentScreen(paymentUrl: paymentUrl),
//     //     ),
//     //   );
//     //   return;
//     // }

//     // ❌ DESKTOP (Windows, Mac, Linux)
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('ABA Payment is supported on mobile only')),
//     );
//   }

//   // save in firebase
//   // new version

//   Future<void> _savePaymentToFirebase(
//     double amount,
//     String receiptId,
//     String cloudUrl,
//   ) async {
//     try {
//       final now = DateTime.now();

//       final studentDocRef = FirebaseFirestore.instance
//           .collection('students_payments')
//           .doc(studentId);

//       final paymentsCollection = studentDocRef.collection('payments');

//       final querySnapshot = await paymentsCollection
//           .where('semester', isEqualTo: widget.payment.semester)
//           .where('year', isEqualTo: widget.payment.year)
//           .where('status', isEqualTo: 'Pending')
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docRef = querySnapshot.docs.first.reference;

//         await docRef.update({
//           'status': 'Paid',
//           'amount': amount,
//           'method': _selectedMethod,
//           'date': now.toIso8601String(),
//           'receiptId': receiptId,
//           'photoUrl': widget.student['photoUrl'] ?? '',
//           'receiptUrl': cloudUrl,
//         });

//         setState(() => _hasPaid = true);
//         print('Payment updated successfully with receipt URL!');
//       } else {
//         print('No pending payment found.');
//       }
//     } catch (e) {
//       print('Error updating payment: $e');
//     }
//   }

//   Future<List<Payment>> fetchPayments(String studentId) async {
//     Map<String, dynamic>? studentData;
//     String photoUrl = '';

//     try {
//       // Step 1: Get student document
//       final studentDoc = await FirebaseFirestore.instance
//           .collection('students_payments')
//           .doc(studentId)
//           .get();

//       if (!studentDoc.exists) {
//         print("❌ Student document not found: $studentId");
//       } else {
//         studentData = studentDoc.data() as Map<String, dynamic>?;
//         photoUrl = studentData?['photoUrl'] ?? '';
//         print("✅ Student document loaded. photoUrl: $photoUrl");
//       }
//     } catch (e) {
//       print("❌ Error fetching student document: $e");
//     }

//     List<Payment> payments = [];

//     try {
//       // Step 2: Get payments subcollection
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('students_payments')
//           .doc(studentId)
//           .collection('payments')
//           .get();

//       print(
//         "✅ Payments subcollection loaded: ${querySnapshot.docs.length} items",
//       );

//       // Step 3: Map documents to Payment objects
//       for (var doc in querySnapshot.docs) {
//         try {
//           final data = doc.data();
//           final payment = Payment.fromFirestore(studentId, {
//             ...data,
//             'photoUrl': photoUrl,
//           });
//           payments.add(payment);
//           print(
//             "✅ Payment loaded: ${payment.semester}, ${payment.year}, amount: ${payment.amount}",
//           );
//         } catch (e) {
//           print("❌ Error parsing payment doc ${doc.id}: $e");
//         }
//       }
//     } catch (e) {
//       print("❌ Error fetching payments subcollection: $e");
//     }

//     return payments;
//   }

//   //=== End save in database ===///

//   // ────── ANIMATED RECEIPT ──────
//   Future<void> _showAnimatedReceipt(double amount) async {
//     final now = DateTime.now();
//     final receiptId = 'REC${now.millisecondsSinceEpoch}'.substring(0, 10);

//     _confettiCtrl.play();

//     final receiptKey = GlobalKey();

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierLabel: '',
//       transitionDuration: const Duration(milliseconds: 300),
//       pageBuilder: (_, __, ___) {
//         return PaymentReceiptDialog(
//           payment: widget.payment,
//           receiptId: receiptId, // ✅ ADD THIS

//           receiptKey: receiptKey,
//           onClose: () => Navigator.of(context).pop(),
//           isPaymentDone: true, // ✅ hide action buttons
//         );
//       },
//       transitionBuilder: (_, anim, __, child) {
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
//           child: child,
//         );
//       },
//     );

//     // Wait for the widget to render
//     await Future.delayed(const Duration(milliseconds: 290));

//     // Capture the receipt as image
//     final boundary =
//         receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//     if (boundary == null) return;

//     final image = await boundary.toImage(pixelRatio: 3.0);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();

//     // Upload to Cloudinary
//     final cloudUrl = await CloudinaryService.uploadReceipt(
//       pngBytes,
//       'receipt_$receiptId.png',
//     );

//     //  Pass all 3 arguments now
//     await _savePaymentToFirebase(
//       amount,
//       receiptId,
//       cloudUrl!,
//     ); // store recepit url
//   }

//   @override
//   Widget build(BuildContext context) {
//     final student = widget.student;
//     final payment = widget.payment;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         // title: Text('Pay ${student['major'] ?? "No Major"}'),
//         title: Text('Payment $majorName'),

//         // majorName = student['major'] ?? '';
//         backgroundColor: const Color(0xFF0066CC),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Student Header ──
//                     Row(
//                       children: [
//                         // profile
//                         CircleAvatar(
//                           radius: 32,
//                           backgroundColor: const Color(
//                             0xFF0066CC,
//                           ).withOpacity(0.1),
//                           child:
//                               (payment.photoUrl != null &&
//                                   payment.photoUrl!.isNotEmpty)
//                               ? ClipOval(
//                                   child: Image.network(
//                                     payment.photoUrl!,
//                                     width: 60,
//                                     height: 60,
//                                     fit: BoxFit.cover,
//                                     loadingBuilder:
//                                         (context, child, loadingProgress) {
//                                           if (loadingProgress == null)
//                                             return child;
//                                           print(
//                                             "⏳ Loading image: ${payment.photoUrl}",
//                                           );
//                                           return const Center(
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2.5,
//                                               color: Color(0xFF0066CC),
//                                             ),
//                                           );
//                                         },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       print("❌ Error loading image: $error");
//                                       print("StackTrace: $stackTrace");
//                                       return const Icon(
//                                         Icons.person,
//                                         size: 36,
//                                         color: Color(0xFF0066CC),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.person,
//                                   size: 36,
//                                   color: Color(0xFF0066CC),
//                                 ),
//                         ),

//                         // end
//                         const SizedBox(width: 16),

//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 studentFullName,
//                                 style: const TextStyle(
//                                   fontSize: 19,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 studentId,
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                               Text(
//                                 '${payment.semester ?? ''} • Year ${payment.year ?? ''}',
//                                 style: const TextStyle(
//                                   color: Color(0xFF0066CC),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 28),
//                     const Divider(),

//                     // ── Amount ──
//                     const Text(
//                       'Amount (USD)',
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 8),

//                     TextField(
//                       controller: _amountController,
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.attach_money,
//                           color: Color(0xFF0066CC),
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFF1F3F5),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(
//                             color: Color(0xFF0066CC),
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // ── Method ──
//                     const Text(
//                       'Payment Method',
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF1F3F5),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: _selectedMethod,
//                           items: _paymentMethods
//                               .map(
//                                 (m) =>
//                                     DropdownMenuItem(value: m, child: Text(m)),
//                               )
//                               .toList(),
//                           onChanged: (v) =>
//                               setState(() => _selectedMethod = v!),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 36),

//                     //=== buttom pay===//
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: (_isProcessing || _hasPaid)
//                             ? null
//                             : _processPayment,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _hasPaid
//                               ? Colors.white
//                               : const Color(0xFF00A650),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 4,
//                         ),
//                         child: _isProcessing
//                             ? const SizedBox(
//                                 height: 24,
//                                 width: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.5,
//                                 ),
//                               )
//                             : Text(
//                                 _hasPaid ? 'Already Paid' : 'Pay Now',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),

//                     // ────── buttom pay──────────//
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Confetti
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _confettiCtrl,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               colors: const [
//                 Colors.green,
//                 Colors.blue,
//                 Colors.orange,
//                 Colors.purple,
//                 Colors.pink,
//               ],
//               emissionFrequency: 0.05,
//               numberOfParticles: 30,
//               gravity: 0.15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _captureAndUploadReceipt(
//     GlobalKey receiptKey,
//     String receiptId,
//   ) async {
//     try {
//       // 1️⃣ Capture the widget as an image
//       final boundary =
//           receiptKey.currentContext?.findRenderObject()
//               as RenderRepaintBoundary?;
//       if (boundary == null) {
//         print("❌ RenderRepaintBoundary not found.");
//         return;
//       }

//       final image = await boundary.toImage(pixelRatio: 3.0);
//       final byteData = await image.toByteData(format: ImageByteFormat.png);
//       final pngBytes = byteData!.buffer.asUint8List();

//       //  Save locally (optional)
//       final dir = Directory.systemTemp;
//       final file = File('${dir.path}/receipt_$receiptId.png');
//       await file.writeAsBytes(pngBytes);
//       print(" Receipt saved locally at: ${file.path}");

//       //  Upload to Cloudinary
//       final cloudUrl = await CloudinaryService.uploadReceipt(
//         pngBytes,
//         'receipt_$receiptId.png',
//       );
//       if (cloudUrl != null) {
//         print(" Receipt uploaded to Cloudinary: $cloudUrl");

//         //  Optionally save URL in Firestore
//         await FirebaseFirestore.instance
//             .collection('students_payments')
//             .doc(studentId)
//             .collection('payments')
//             .doc(widget.payment.id as String?)
//             .update({'receiptUrl': cloudUrl});
//         print(" Receipt URL saved in Firestore");
//       }
//     } catch (e) {
//       print(" Error capturing/uploading receipt: $e");
//     }
//   }
// }

// //===================//

// //
// // ────── RECEIPT DIALOG ──────

// Future<void> captureAndShare(GlobalKey key) async {
//   try {
//     // Wait for the widget to render
//     await Future.delayed(const Duration(milliseconds: 400));

//     final boundary =
//         key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//     if (boundary == null) {
//       print("❌ Widget not ready for capture");
//       return;
//     }

//     final image = await boundary.toImage(pixelRatio: 3.0);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();

//     // Get temporary directory
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/receipt.png');
//     await file.writeAsBytes(pngBytes);

//     // Share the file
//     await Share.shareXFiles([XFile(file.path)], text: 'My Payment Receipt');
//   } catch (e) {
//     print("❌ Error sharing receipt: $e");
//   }
// }

// // ─────────────────────────────────────────────
// // STATIC RECEIVER (LOCKED)
// // ─────────────────────────────────────────────

// const String RECEIVER_NAME = 'Tong heng KEO';
// const String RECEIVER_ACCOUNT = '096 205 0984 (USD)';
// const String RECEIVER_SHORT = 'TE';

// // ───────────────── PAYMENT RECEIPT DIALOG ─────────────────
// class PaymentReceiptDialog extends StatefulWidget {
//   final Payment payment;
//   final String receiptId;
//   final VoidCallback onClose;
//   final GlobalKey receiptKey;
//   final bool isPaymentDone; // if true, hide buttons

//   const PaymentReceiptDialog({
//     super.key,
//     required this.payment,
//     required this.receiptId,
//     required this.onClose,
//     required this.receiptKey,
//     required this.isPaymentDone,
//   });

//   @override
//   State<PaymentReceiptDialog> createState() => _PaymentReceiptDialogState();
// }

// class _PaymentReceiptDialogState extends State<PaymentReceiptDialog> {
//   bool _showActionButtons = true;

//   @override
//   Widget build(BuildContext context) {
//     final dateFmt = DateFormat('dd-MMM-yyyy | hh:mm a');

//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: RepaintBoundary(
//           key: widget.receiptKey,
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ───── HEADER ─────
//                 const Center(
//                   child: Text('Transferred to', style: TextStyle(fontSize: 18)),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 26,
//                       backgroundColor: const Color(0xFF7B4A3A),
//                       child: const Text(
//                         RECEIVER_SHORT,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             RECEIVER_NAME,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '${widget.payment.amount.toStringAsFixed(0)} USD',
//                             style: const TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 _dashDivider(),

//                 // ───── TRANSFERRED FROM ─────
//                 _row('Transferred From', widget.payment.studentName),
//                 _row('Account No.', widget.payment.studentId),
//                 _row(
//                   'Debit Amount',
//                   '-${widget.payment.amount.toStringAsFixed(0)} USD',
//                   valueColor: Colors.red,
//                 ),
//                 const SizedBox(height: 16),
//                 _dashDivider(),

//                 // ───── RECEIVER ─────
//                 _row('Receiver', RECEIVER_NAME),
//                 _row('Account No.', RECEIVER_ACCOUNT),
//                 const SizedBox(height: 16),
//                 _dashDivider(),

//                 // ───── REFERENCE & DATE ─────
//                 if (widget.receiptId.isNotEmpty)
//                   _row('Reference No.', widget.receiptId),
//                 _row('Date', dateFmt.format(widget.payment.transactionDate)),
//                 const SizedBox(height: 20),
//                 _dashDivider(),

//                 // ───── CALL CENTER INFO ─────
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Call center (24/7)',
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     '023 994 444 | 015 999 233',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ───── ACTION BUTTONS ─────
//                 if (_showActionButtons)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _downloadReceipt,
//                         icon: const Icon(Icons.download),
//                         label: const Text('Download'),
//                         style: ElevatedButton.styleFrom(
//                           // backgroundColor: const Color.fromARGB(255, 142, 184, 226),
//                           foregroundColor: Colors.grey,
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _shareReceipt,
//                         icon: const Icon(Icons.share),
//                         label: const Text('Share'),
//                         style: ElevatedButton.styleFrom(
//                           // backgroundColor: const Color.fromARGB(255, 183, 239, 210),
//                           foregroundColor: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),

//                 const SizedBox(height: 16),

//                 // ───── CLOSE BUTTON ─────
//                 // if (!widget.isPaymentDone)
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: widget.onClose,
//                     style: ElevatedButton.styleFrom(
//                       // backgroundColor: const Color(0xFF0066CC),
//                       // foregroundColor: Colors.grey,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     child: const Text(
//                       'Close',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                       ),
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

//   // ───── ROW HELPER ─────
//   Widget _row(String label, String value, {Color? valueColor}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       children: [
//         SizedBox(
//           width: 130,
//           child: Text(label, style: const TextStyle(color: Colors.grey)),
//         ),
//         Expanded(
//           child: Text(
//             ': $value',
//             style: TextStyle(color: valueColor, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ],
//     ),
//   );

//   // ───── DASH DIVIDER ─────
//   Widget _dashDivider() =>
//       const Divider(color: Colors.grey, thickness: 1, height: 24);

//   // ───────── CAPTURE RECEIPT IMAGE ─────────
//   Future<void> captureReceiptImage(Function(File) onCaptured) async {
//     setState(() => _showActionButtons = false); // hide buttons
//     await Future.delayed(const Duration(milliseconds: 50)); // wait rebuild

//     final boundary =
//         widget.receiptKey.currentContext?.findRenderObject()
//             as RenderRepaintBoundary?;
//     if (boundary == null) return;

//     final image = await boundary.toImage(pixelRatio: 3.0);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/receipt_${widget.receiptId}.png');
//     await file.writeAsBytes(pngBytes);

//     onCaptured(file);

//     setState(() => _showActionButtons = true); // restore buttons
//   }

//   Future<void> _downloadReceipt() async {
//     await captureReceiptImage((file) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Receipt downloaded to temp folder')),
//       );
//     });
//   }

//   Future<void> _shareReceipt() async {
//     await captureReceiptImage((file) async {
//       await Share.shareXFiles([XFile(file.path)], text: 'My Payment Receipt');
//     });
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_register_app/data/cloudinary_service.dart';
import 'package:student_register_app/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class CloudinaryService {
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'payment_receipts';

  // Mobile
  static Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);
    return resJson['secure_url'] ?? '';
  }

  // Web
  static Future<String> uploadWebImage(Uint8List bytes) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'receipt.png',
          contentType: MediaType('image', 'png'),
        ),
      );

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);
    return resJson['secure_url'] ?? '';
  }
}

class PaymentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final Payment payment;

  const PaymentDetailsScreen({
    super.key,
    required this.student,
    required this.payment,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  String _selectedMethod = 'Cash';
  late final ConfettiController _confettiCtrl;
  // File? _receiptImage;

  final List<String> _paymentMethods = [
    'Cash',
    'ABA Bank',
    'Wing',
    'ACLEDA',
    'TrueMoney',
  ];

  late final String studentFullName;
  late final String studentId;
  late String majorName;
  bool _hasPaid = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    final firstName = student['firstName'] ?? '';
    final lastName = student['lastName'] ?? '';
    majorName = student['major'] ?? 'No Major';

    studentFullName = '$firstName $lastName';
    studentId = student['studentId'] ?? '';
    _amountController.text = widget.payment.amount.toString();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
    _checkIfAlreadyPaid();
  }

  Future<void> _checkIfAlreadyPaid() async {
    final doc = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .get();

    if (doc.exists) {
      final payments = doc.data()?['payments'] as List<dynamic>? ?? [];
      for (var payment in payments) {
        if (payment['semester'] == widget.payment.semester &&
            payment['year'] == widget.payment.year) {
          setState(() => _hasPaid = true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment has already been completed!'),
              backgroundColor: Colors.green,
            ),
          );

          // Optional: Telegram alert
          await _sendTelegramAlert(
            studentName: studentFullName,
            amount: payment['amount']?.toDouble() ?? 0,
            method: payment['method'] ?? 'Unknown',
          );
          break;
        }
      }
    }
  }

  // Future<void> _sendTelegramAlert({
  //   required String studentName,
  //   required double amount,
  //   required String method,
  // }) async {
  //   const String botToken = '8474628673:AAG0EXzZ7Th9H_xPZp65KqVPfVWr-dcOXj4';
  //   const String chatId = '5892708527';
  //   final String message =
  //       '📢 Payment completed!\n\n'
  //       'Student: $studentName\n'
  //       'Amount: \$${amount.toStringAsFixed(2)}\n'
  //       'Method: $method';
  //
  //   final Uri url = Uri.parse(
  //     'https://api.telegram.org/bot$botToken/sendMessage',
  //   );
  //
  //   try {
  //     await http.post(url, body: {'chat_id': chatId, 'text': message});
  //     print('✅ Telegram alert sent.');
  //   } catch (e) {
  //     print('❌ Error sending Telegram alert: $e');
  //   }
  // }


  Future<void> _sendTelegramAlert({
    required String studentName,
    required double amount,
    required String method,
  }) async {
    const String botToken = '8474628673:AAG0EXzZ7Th9H_xPZp65KqVPfVWr-dcOXj4';
    const String chatId = '5892708527';

    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')} '
        '${_monthName(now.month)} '
        '${now.year}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    final String message = '''
✅ *PAYMENT CONFIRMED*

👤 *Student*
• Name: $studentName

💰 *Payment Details*
• Amount: \$${amount.toStringAsFixed(2)}
• Method: $method

📅 *Date:* $date
⏰ *Time:* $time

🏫 _Student Registration App_
''';

    final Uri url =
    Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

    try {
      await http.post(
        url,
        body: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );
      print('✅ Telegram alert sent.');
    } catch (e) {
      print('❌ Error sending Telegram alert: $e');
    }
  }


  // ---------------------
  // Pick Image
  // ---------------------
  Uint8List? _receiptWebImage;
  File? _receiptImage;

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      String receiptUrl = '';
      try {
        if (kIsWeb) {
          _receiptWebImage = await pickedFile.readAsBytes();
          receiptUrl = await CloudinaryService.uploadWebImage(
            _receiptWebImage!,
          );
        } else {
          _receiptImage = File(pickedFile.path);
          receiptUrl = await CloudinaryService.uploadImage(_receiptImage!);
        }

        if (receiptUrl.isNotEmpty) {
          final now = DateTime.now();
          final receiptId = 'REC${now.millisecondsSinceEpoch}'.substring(0, 10);

          // Save receipt URL to Firebase
          final studentDocRef = FirebaseFirestore.instance
              .collection('students_payments')
              .doc(studentId);

          final paymentsCollection = studentDocRef.collection('payments');

          // Find the current payment for this semester/year
          final querySnapshot = await paymentsCollection
              .where('semester', isEqualTo: widget.payment.semester)
              .where('year', isEqualTo: widget.payment.year)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docRef = querySnapshot.docs.first.reference;

            await docRef.update({
              'receiptUrl': receiptUrl, // ✅ Save uploaded link here
              'receiptId': receiptId,
              'photoUrl': widget.student['photoUrl'] ?? '',
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt uploaded and link saved!'),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {}); // refresh UI
          } else {
            print('No payment record found to update receipt URL.');
          }
        }
      } catch (e) {
        print('Error uploading receipt: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload receipt.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------
  // Upload Receipt
  // ---------------------
  Future<String> _uploadReceipt() async {
    try {
      if (kIsWeb && _receiptWebImage != null) {
        return await CloudinaryService.uploadWebImage(_receiptWebImage!);
      } else if (_receiptImage != null) {
        return await CloudinaryService.uploadImage(_receiptImage!);
      }
      return '';
    } catch (e) {
      print('Error uploading receipt: $e');
      return '';
    }
  }

  /// Simulated checkPaymentStatus function
  /// Returns `true` after a short delay to simulate a successful payment.

  Future<bool> checkPaymentStatus(String transactionId) async {
    // Simulate 3 seconds delay to mimic real payment confirmation
    await Future.delayed(const Duration(seconds: 1));

    // Always return true to simulate a successful payment
    return true;
  }

  Future<void> _processPayment() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // -------------------
    // Upload receipt
    // -------------------
    String receiptUrl = '';
    if (_receiptImage != null || _receiptWebImage != null) {
      receiptUrl = await _uploadReceipt();
      if (receiptUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload receipt.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // -------------------
    // Cash payment
    // -------------------
    if (_selectedMethod == 'Cash') {
      await _simulateCashPayment(amount, receiptUrl);
      return;
    }

    // -------------------
    // Online payment simulation
    // -------------------
    await _openPaymentWeb(_selectedMethod, amount);

    bool paid = false;
    int retry = 0;

    while (!paid && retry < 10) {
      await Future.delayed(const Duration(seconds: 1));
      paid = await checkPaymentStatus('STATIC_TXN_ID'); // dummy ID
      retry++;
    }

    // -------------------
    // Save to Firebase
    // -------------------
    if (paid) {
      final now = DateTime.now();
      final receiptId = 'REC${now.millisecondsSinceEpoch}'.substring(0, 10);

      await _savePaymentToFirebase(amount, receiptId, receiptUrl);

      // Optional: send alert
      await _sendTelegramAlert(
        studentName: studentFullName,
        amount: amount,
        method: _selectedMethod,
      );

      _confettiCtrl.play();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment not confirmed yet. Try again later.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ---------------------
  // Save Payment to Firebase
  // ---------------------
  Future<void> _savePaymentToFirebase(
    double amount,
    String receiptId,
    String receiptUrl,
  ) async {
    try {
      final now = DateTime.now();
      final studentDocRef = FirebaseFirestore.instance
          .collection('students_payments')
          .doc(studentId);

      final paymentsCollection = studentDocRef.collection('payments');

      final querySnapshot = await paymentsCollection
          .where('semester', isEqualTo: widget.payment.semester)
          .where('year', isEqualTo: widget.payment.year)
          .where('status', isEqualTo: 'Pending')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({
          'status': 'Paid',
          'amount': amount,
          'method': _selectedMethod, // from your widget
          'date': now.toIso8601String(),
          'receiptId': receiptId,
          'receiptUrl': receiptUrl,
          'photoUrl': widget.student['photoUrl'] ?? '',
        });

        setState(() => _hasPaid = true);
        print('Payment updated successfully with receipt URL!');
      } else {
        print('No pending payment found.');
      }
    } catch (e) {
      print('Error updating payment: $e');
    }
  }

  Future<void> _simulateCashPayment(double amount, String receiptUrl) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    final now = DateTime.now();
    final receiptId = 'REC${now.millisecondsSinceEpoch}'.substring(0, 10);

    await _savePaymentToFirebase(amount, receiptId, receiptUrl);
    _confettiCtrl.play();

    await _sendTelegramAlert(
      studentName: studentFullName,
      amount: amount,
      method: 'Cash',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cash payment recorded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String getQrAsset(String method, double amount) {
    final amountStr = amount.toStringAsFixed(2); // 2 decimals
    switch (method) {
      case 'ABA Bank':
        return 'https://link.payway.com.kh/aba?id=1C58DB35F981&dynamic=true&source_caller=api&pid=app_to_app&link_action=abaqr&shortlink=p6f2eh4w&amount=$amountStr&created_from_app=true&acc=013874873&userid=1C58DB35F981&code=858036&c=abaqr';
      case 'Wing':
        return 'https://link-to-wing-qr.com/?amount=$amountStr'; // replace with real URL
      case 'ACLEDA':
        return 'https://link-to-acleda-qr.com/?amount=$amountStr'; // replace with real URL
      case 'TrueMoney':
        return 'https://link-to-truemoney-qr.com/?amount=$amountStr'; // replace with real URL
      default:
        return 'https://link-to-default-qr.com/?amount=$amountStr'; // fallback URL
    }
  }

  Future<void> _openPaymentWeb(String method, double amount) async {
    final url = getQrAsset(method, amount);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open payment link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment $majorName'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 2,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.grey.shade50],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------
                  // Student Info Card
                  // -----------------------------
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Stack(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0066CC),
                                  width: 2,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade100,
                                    Colors.blue.shade200,
                                  ],
                                ),
                              ),
                              child:
                                  widget.student['photoUrl'] != null &&
                                      widget.student['photoUrl'] != ''
                                  ? ClipOval(
                                      child: Image.network(
                                        widget.student['photoUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 36,
                                      color: Color(0xFF0066CC),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentFullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ID: $studentId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0066CC),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      majorName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // -----------------------------
                  // Payment Status Banner
                  // -----------------------------
                  if (_hasPaid)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment Completed Successfully',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_hasPaid) const SizedBox(height: 24),

                  // -----------------------------
                  // Payment Form Card
                  // -----------------------------
                  Container(
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        const Row(
                          children: [
                            Icon(Icons.payment, color: Color(0xFF0066CC)),
                            SizedBox(width: 8),
                            Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),

                        // Amount Field
                        const SizedBox(height: 20),
                        Text(
                          'Amount to Pay',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Color(0xFF0066CC),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  readOnly: true,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Payment Method
                        const SizedBox(height: 24),
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedMethod,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                            items: _paymentMethods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        m,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedMethod = v!),
                          ),
                        ),

                        // Receipt Upload
                        const SizedBox(height: 24),
                        Text(
                          'Payment Receipt',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickReceiptImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _receiptImage == null
                                    ? Colors.grey.shade300
                                    : Colors.green.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _receiptImage == null
                                  ? Colors.grey.shade50
                                  : Colors.green.shade50,
                            ),
                            child: _receiptImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload,
                                        size: 32,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to upload receipt',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _receiptImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),
                        ),
                        if (_receiptImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _pickReceiptImage,
                                  icon: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.blue.shade600,
                                  ),
                                  label: Text(
                                    'Change Receipt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Submit Button
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isProcessing || _hasPaid)
                                ? null
                                : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasPaid
                                  ? Colors.green.shade500
                                  : const Color(0xFF0066CC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isProcessing
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Processing...'),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _hasPaid
                                            ? Icons.check_circle
                                            : Icons.lock,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _hasPaid
                                            ? 'Payment Verified'
                                            : 'Complete Payment',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.pink,
              ],
              emissionFrequency: 0.02,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

}
