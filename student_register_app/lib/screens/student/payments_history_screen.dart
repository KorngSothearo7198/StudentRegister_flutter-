import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const PaymentsHistoryScreen({super.key, required this.student});

  @override
  State<PaymentsHistoryScreen> createState() => _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends State<PaymentsHistoryScreen> {
  List<Map<String, dynamic>> payments = [];
  bool loading = true;
  double totalPaid = 0.0;
  int totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      final stuId = widget.student['studentId'];

      final snapshot = await FirebaseFirestore.instance
          .collection("students_payments")
          .doc(stuId)
          .collection("payments")
          .orderBy("date", descending: true)
          .get();

      payments = snapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      totalTransactions = payments.length;
      totalPaid = payments.fold(0.0, (sum, p) {
        final amount = (p['amount'] ?? 0).toDouble();
        return p['status'] == 'Paid' ? sum + amount : sum;
      });

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Error loading payments: $e");
    }
  }

  Color getStatusColor(String status) =>
      status == "Paid" ? Colors.green : Colors.orange;

  // ===================== HEADER =====================
  Widget _buildHeader(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.10, w * 0.04, w * 0.05),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Payment History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: w * 0.07,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: widget.student['photoUrl'] != null &&
                      widget.student['photoUrl'].toString().isNotEmpty
                      ? Image.network(
                    widget.student['photoUrl'],
                    width: w * 0.14,
                    height: w * 0.14,
                    fit: BoxFit.cover,
                  )
                      : Text(
                    widget.student['firstName']?[0]?.toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: w * 0.07,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0066CC),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.student['firstName'] ?? ''} ${widget.student['lastName'] ?? ''}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.student['studentId'] ?? ''}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: w * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== SUMMARY =====================
  Widget _buildSummary(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
      child: Row(
        children: [
          _summaryCard(
            w,
            title: 'Total Paid',
            value: '\$${totalPaid.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _summaryCard(
            w,
            title: 'Transactions',
            value: totalTransactions.toString(),
            icon: Icons.receipt_long,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      double w, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: w * 0.05,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: w * 0.032, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== PAYMENT CARD =====================
  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> p) {
    final w = MediaQuery.of(context).size.width;
    final color = getStatusColor(p['status']);
    final amount = (p['amount'] ?? 0).toDouble();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentDetailScreen(
              payment: p,
              student: widget.student,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  p['status'] == 'Paid'
                      ? Icons.check_circle
                      : Icons.pending,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p['semester'] ?? '',
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p['status'],
                    style: TextStyle(
                      color: color,
                      fontSize: w * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0066CC),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(p['date']),
              style: TextStyle(fontSize: w * 0.033, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(date.toDate());
    }
    return date?.toString() ?? '';
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildHeader(context),
          if (payments.isNotEmpty) _buildSummary(context),
          Expanded(
            child: payments.isEmpty
                ? const Center(child: Text("No payment history"))
                : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (c, i) =>
                  _buildPaymentCard(c, payments[i]),
            ),
          ),
        ],
      ),
    );
  }
}


class PaymentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> payment;
  final Map<String, dynamic> student;

  const PaymentDetailScreen({
    super.key,
    required this.payment,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final statusColor =
    payment['status'] == 'Paid' ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== STUDENT INFO =====
            _sectionTitle("Student Information"),
            _infoCard(
              children: [
                _infoRow("Name",
                    "${student['firstName']} ${student['lastName']}"),
                _infoRow("Student ID", student['studentId']),
              ],
            ),

            const SizedBox(height: 20),

            // ===== PAYMENT INFO =====
            _sectionTitle("Payment Information"),
            _infoCard(
              children: [
                _infoRow("Semester", payment['semester']),
                _infoRow("Year", payment['year'].toString()),
                _infoRow("Method", payment['method'] ?? "N/A"),
                _infoRow(
                  "Amount",
                  "\$${(payment['amount'] ?? 0).toStringAsFixed(2)}",
                  valueColor: const Color(0xFF0066CC),
                ),
                _infoRow(
                  "Status",
                  payment['status'],
                  valueColor: statusColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== DATE & RECEIPT =====
            _sectionTitle("Additional Details"),
            _infoCard(
              children: [
                _infoRow(
                  "Payment Date",
                  _formatDate(payment['date']),
                ),
                if (payment['receiptId'] != null &&
                    payment['receiptId'].toString().isNotEmpty)
                  _infoRow("Receipt ID", payment['receiptId']),
              ],
            ),


            const SizedBox(height: 20),

// ===== RECEIPT IMAGE =====
            if (payment['receiptUrl'] != null &&
                payment['receiptUrl'].toString().isNotEmpty) ...[
              _sectionTitle("Payment Receipt"),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptPreviewScreen(
                        imageUrl: payment['receiptUrl'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: w * 0.6, // responsive height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      payment['receiptUrl'],
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, loading) {
                        if (loading == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
      String label,
      String value, {
        Color valueColor = Colors.black87,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(date.toDate());
    }
    return date?.toString() ?? 'N/A';
  }
}

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
