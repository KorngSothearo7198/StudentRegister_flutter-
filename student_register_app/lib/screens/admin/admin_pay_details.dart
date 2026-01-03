import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/payment_model.dart';

Future<Payment?> getLatestPayment(String studentId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .orderBy('date', descending: true) // latest payment first
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint("❌ No payments found for student $studentId");
      return null;
    }

    final doc = querySnapshot.docs.first;
    debugPrint("🔥 Latest payment data:");
    debugPrint(doc.data().toString());
    debugPrint("🔥 Receipt URL: ${doc.data()['receiptUrl']}");

    return Payment.fromFirestore(studentId, doc.data());
  } catch (e) {
    debugPrint("❌ Error fetching latest payment: $e");
    return null;
  }
}

class PaymentDetailsScreen extends StatelessWidget {
  final Payment payment;
  final VoidCallback onMarkPaid;

  const PaymentDetailsScreen({
    super.key,
    required this.payment,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    debugPrint("======================================");
    debugPrint("📌 Screen Loaded: Payment Details");
    debugPrint("Student: ${payment.studentName}");
    debugPrint("Receipt URL from model: ${payment.receiptUrl}");
    debugPrint("======================================");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Payment - ${payment.studentName}'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPaymentCard(formatter),
            if (payment.status == "Paid") const SizedBox(height: 20),
            if (payment.status == "Paid") _buildReceiptCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(DateFormat formatter) {
    // --- Debug prints ---
    debugPrint("======================================");
    debugPrint("📌 Student Info Loaded:");
    debugPrint("Name: ${payment.studentName}");
    debugPrint("ID: ${payment.studentId}");
    debugPrint("Photo URL: ${payment.photoUrl}");
    debugPrint("======================================");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFE3F2FD),
                  backgroundImage:
                      (payment.photoUrl != null && payment.photoUrl!.isNotEmpty)
                      ? NetworkImage(payment.photoUrl!)
                      : null,
                  child: (payment.photoUrl == null || payment.photoUrl!.isEmpty)
                      ? Text(
                          payment.studentName.isNotEmpty
                              ? payment.studentName[0]
                              : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.studentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.studentId,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24),
            _detailItem('Major', payment.major),
            const SizedBox(height: 16),
            _detailItem(
              'Amount',
              '\$${payment.amount}',
              valueColor: const Color(0xFF0066CC),
              isBold: true,
            ),
            const SizedBox(height: 16),
            if (payment.paidDate != null)
              _detailItem(
                'Paid Date',
                formatter.format(payment.paidDate!),
                valueColor: Colors.green,
              ),
            if (payment.paidDate != null) const SizedBox(height: 16),
            _detailItem(
              'Status',
              payment.status,
              valueColor: _getStatusColor(payment.status),
            ),
            if (payment.status == 'Pending') const SizedBox(height: 32),
            // if (payment.status == 'Pending')
            //   SizedBox(
            //     width: double.infinity,
            //     height: 48,
            //     child: ElevatedButton(
            //       onPressed: onMarkPaid,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.green,
            //         foregroundColor: Colors.white,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       child: const Text(
            //         'Mark as Paid',
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _detailItem(
              'Receipt ID',
              payment.receiptId.isNotEmpty ? payment.receiptId : 'N/A',
            ),
            const SizedBox(height: 12),
            _detailItem(
              'Payment Method',
              payment.paymentMethod.isNotEmpty ? payment.paymentMethod : 'N/A',
            ),
            const SizedBox(height: 12),
            _detailItemWithUrl('Receipt', payment.receiptUrl),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _detailItemWithUrl(String label, String? url) {
    debugPrint("📌 Building URL row — value: $url");

    if (url == null || url.isEmpty) {
      return SizedBox(); // don't show anything if URL is empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              debugPrint("❌ Could not launch URL: $url");
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Owing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
