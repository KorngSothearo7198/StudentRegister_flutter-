// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class QrPaymentScreen extends StatefulWidget {
//   final double amount;
//   final String method;
//   final String studentName;
//   final VoidCallback onPaid;

//   const QrPaymentScreen({
//     super.key,
//     required this.amount,
//     required this.method,
//     required this.studentName,
//     required this.onPaid,
//   });

//   @override
//   State<QrPaymentScreen> createState() => _QrPaymentScreenState();
// }

// class _QrPaymentScreenState extends State<QrPaymentScreen> {

//   late final String paywayLink;

//   @override
//   void initState() {
//     super.initState();

//     paywayLink =
//         "https://link.payway.com.kh/aba"
//         "?id=5BDC4CB78BA6"
//         "&dynamic=true"
//         "&source_caller=api"
//         "&pid=app_to_app"
//         "&link_action=abaqr"
//         "&shortlink=rk5jo5fj"
//         "&amount=${widget.amount.toStringAsFixed(2)}"
//         "&created_from_app=true"
//         "&acc=995555061"
//         "&userid=5BDC4CB78BA6"
//         "&code=271366"
//         "&c=abaqr";

//     // ✅ AUTO OPEN ABA
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _openPaywayLink();
//     });
//   }

//   Future<void> _openPaywayLink() async {
//     final uri = Uri.parse(paywayLink);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       debugPrint('Could not launch PayWay link');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       appBar: AppBar(
//         title: Text('${widget.method} QR Payment'),
//         backgroundColor: const Color(0xFF0066CC),
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),
//             Card(
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Amount: \$${widget.amount.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF0066CC),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // ✅ QR CODE
//                     QrImageView(
//                       data: paywayLink,
//                       size: 250,
//                       backgroundColor: Colors.white,
//                     ),

//                     const SizedBox(height: 16),

//                     // ✅ MANUAL OPEN BUTTON
//                     TextButton.icon(
//                       onPressed: _openPaywayLink,
//                       icon: const Icon(Icons.open_in_new),
//                       label: const Text(
//                         'Open ABA PayWay',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const Spacer(),

//             ElevatedButton.icon(
//               onPressed: widget.onPaid,
//               icon: const Icon(Icons.check_circle_outline),
//               label: const Text('Payment Completed'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00A650),
//                 minimumSize: const Size(double.infinity, 56),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class QrPaymentScreen extends StatefulWidget {
  final double amount;
  final String method;
  final String studentName;
  final String qrLink; // Link generated for real payment

  const QrPaymentScreen({
    super.key,
    required this.amount,
    required this.method,
    required this.studentName,
    required this.qrLink, required Null Function() onPaid,
  });

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  @override
  void initState() {
    super.initState();
    _sendTelegramAlert();
  }

  Future<void> _sendTelegramAlert() async {
    const String botToken = 'YOUR_BOT_TOKEN';
    const String chatId = 'YOUR_CHAT_ID';
    final String message =
        '📢 Payment screen opened!\n\n'
        'Student: ${widget.studentName}\n'
        'Amount: \$${widget.amount.toStringAsFixed(2)}\n'
        'Method: ${widget.method}';

    final Uri url = Uri.parse(
      'https://api.telegram.org/bot$botToken/sendMessage',
    );

    await http.post(url, body: {'chat_id': chatId, 'text': message});
  }

  Future<void> _openPaymentApp() async {
    final Uri uri = Uri.parse(widget.qrLink); // Real payment link
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch payment app');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open payment app.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text('${widget.method} QR Payment'),
        backgroundColor: const Color(0xFF0066CC),
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Amount: \$${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ Real QR from link
                Image.network(
                  widget.qrLink,
                  width: 250,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),

                const SizedBox(height: 16),
                Text(
                  'Scan this QR with your banking app to pay',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                  onPressed: _openPaymentApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

// class QrPaymentScreen extends StatefulWidget {
//   final double amount;
//   final String method;
//   final String studentName;
//   // final String studentId;
//   // final String paymentId;

//   const QrPaymentScreen({
//     super.key,
//     required this.amount,
//     required this.method,
//     required this.studentName,
//     required Null Function() onPaid,
//     // required this.studentId,
//     // required this.paymentId,
//   });

//   @override
//   State<QrPaymentScreen> createState() => _QrPaymentScreenState();
// }

// class _QrPaymentScreenState extends State<QrPaymentScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Telegram alert
//     _sendTelegramAlert();
//   }

//   Future<void> _sendTelegramAlert() async {
//     const String botToken = '8474628673:AAG0EXzZ7Th9H_xPZp65KqVPfVWr-dcOXj4';
//     const String chatId = ''; // ប្ដូរជាមួយ chat ID របស់អ្នក
//     final String message =
//         '📢 Payment screen opened!\n\n'
//         'Student: ${widget.studentName}\n'
//         // 'Student ID: ${widget.studentId}\n'
//         // 'Payment ID: ${widget.paymentId}\n'
//         'Amount: \$${widget.amount.toStringAsFixed(2)}\n'
//         'Method: ${widget.method}';

//     final Uri url = Uri.parse(
//       'https://api.telegram.org/bot$botToken/sendMessage',
//     );

//     await http.post(url, body: {'chat_id': chatId, 'text': message});
//   }

//   Future<void> _openAcledaApp() async {
//     // ប្រសិនបើអ្នកចង់ open app Acleda
//     final uri = Uri.parse('acledapay://'); // ឬ link ពិតៗ Acleda
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       debugPrint('Could not launch Acleda app');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       appBar: AppBar(
//         title: Text('${widget.method} QR Payment'),
//         backgroundColor: const Color(0xFF0066CC),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Card(
//           elevation: 6,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Amount: \$${widget.amount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF0066CC),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // ✅ បង្ហាញ QR PNG ពី assets
//                 Image.asset('assets/acledaqrcode.png', width: 250, height: 250),

//                 const SizedBox(height: 16),
//                 Text(
//                   'Scan this QR with Acleda Pay to pay',
//                   style: const TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



