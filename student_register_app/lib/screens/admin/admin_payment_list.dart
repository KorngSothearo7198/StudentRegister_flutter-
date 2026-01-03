import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payment_model.dart';
import 'admin_pay_details.dart';

class AdminPaymentListScreen extends StatefulWidget {
  const AdminPaymentListScreen({super.key});

  @override
  State<AdminPaymentListScreen> createState() => _AdminPaymentListScreenState();
}

class _AdminPaymentListScreenState extends State<AdminPaymentListScreen> {
  List<Payment> _allPayments = [];
  List<Payment> _filtered = [];
  String _filter = 'All';
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  DateTime? parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);

    try {
      debugPrint('Fetching students from Firebase...');

      // Get all students
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('students_payments')
          .get();

      debugPrint('Found ${studentsSnapshot.docs.length} students');

      List<Payment> allPayments = [];

      // all

      for (var studentDoc in studentsSnapshot.docs) {
        final studentId = studentDoc.id;
        final studentData = studentDoc.data();

        final studentName =
            "${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}"
                .trim();
        final studentMajor = studentData['major'] ?? 'Unknown';

        // Get payments subcollection
        final paymentsSnapshot = await FirebaseFirestore.instance
            .collection('students_payments')
            .doc(studentId)
            .collection('payments')
            .get();

        debugPrint(
          'Found ${paymentsSnapshot.docs.length} payments for $studentName',
        );

        for (var paymentDoc in paymentsSnapshot.docs) {
          final data = paymentDoc.data();
          allPayments.add(
            Payment(
              studentId: studentId,
              studentName: studentName,
              major: studentMajor,
              amount: (data['amount'] ?? 0).toDouble(),
              status: data['status'] ?? 'Pending',
              paymentMethod: data['method'] ?? '',
              receiptId: data['receiptId'] ?? '',
              receiptUrl: (data['receiptUrl'] ?? '').toString(), // <-- ADD THIS
              // photoUrl: (data['photoUrl'] ?? '').toString(), // <-- ADD THIS
              photoUrl: (studentData['photoUrl'] ?? '')
                  .toString(), // <-- add this

              semester: data['semester'] ?? '',
              year: data['year'] ?? 0,
              transactionDate: parseDate(data['date']),
              dueDate: parseDate(data['doDate']), // maybe use doDate or dueDate
              paidDate: parseNullableDate(data['paidDate']),
              notes: data['notes'] ?? '',
              id: data['id'] ?? 0,
            ),
          );
        }
      }

      // end

      setState(() {
        _allPayments = allPayments;
        _updateList();
        _loading = false;
      });

      debugPrint('Total payments loaded: ${_allPayments.length}');
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error loading payments: $e');
    }
  }

  void _updateList() {
    setState(() {
      _filtered = _allPayments.where((p) {
        final matchesFilter = _filter == 'All' || p.status == _filter;
        final matchesSearch =
            _search.isEmpty ||
            p.studentName.toLowerCase().contains(_search.toLowerCase()) ||
            p.major.toLowerCase().contains(_search.toLowerCase()) ||
            (p.studentId.toLowerCase()).contains(_search.toLowerCase());
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) {
          _search = v;
          _updateList();
        },
        decoration: InputDecoration(
          hintText: 'Search by name...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey[600]),
                  onPressed: () {
                    _search = '';
                    _updateList();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'color': Colors.blue, 'icon': Icons.all_inclusive},
      {'label': 'Paid', 'color': Colors.green, 'icon': Icons.check_circle},
      {'label': 'Pending', 'color': Colors.orange, 'icon': Icons.pending},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filter == filter['label'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip.elevated(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : filter['color'] as Color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                _filter = filter['label'] as String;
                _updateList();
              },
              backgroundColor: Colors.white,
              selectedColor: filter['color'] as Color,
              checkmarkColor: Colors.white,
              elevation: 2,
              side: BorderSide(
                color: isSelected
                    ? filter['color'] as Color
                    : Colors.grey[300]!,
                width: isSelected ? 0 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final total = _filtered.fold(0.0, (sum, p) => sum + p.amount);
    final paid = _filtered.where((p) => p.status == 'Paid').fold(0.0, (sum, p) => sum + p.amount);
    final pending = _filtered.where((p) => p.status == 'Pending').fold(0.0, (sum, p) => sum + p.amount);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 20.0;
    final verticalPadding = isSmallScreen ? 12.0 : 20.0;
    final amountFontSize = isSmallScreen ? 18.0 : 22.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      padding: EdgeInsets.all(verticalPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAFAFA), Color(0xFFEEEEEE)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildSummaryItem('Total', total, const Color(0xFF212121), amountFontSize, labelFontSize),
          _buildSummaryItem('Paid', paid, const Color(0xFF2E7D32), amountFontSize, labelFontSize),
          _buildSummaryItem('Pending', pending, const Color(0xFFEF6C00), amountFontSize, labelFontSize),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, double amountFontSize, double labelFontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
          style: TextStyle(
            fontSize: amountFontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }


  // Wrap long rows and chips in Flexible/Expanded
  Widget _buildPaymentCard(Payment payment) {
    final statusColor = _getStatusColor(payment.status);
    final statusBgColor = statusColor.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentDetailsScreen(payment: payment, onMarkPaid: () {  },),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status Indicator
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Status Row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  payment.studentName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF333333),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(payment.status),
                                      size: 12,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      payment.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Student Info
                          Text(
                            'ID: ${payment.studentId} • ${payment.major}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          // Payment Details Chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildDetailChip(
                                  'Sem ${payment.semester}', Icons.school_outlined, Colors.blue),
                              _buildDetailChip(
                                  'Year ${payment.year}', Icons.calendar_today_outlined, Colors.purple),
                              _buildDetailChip(
                                  payment.paymentMethod, Icons.payment_outlined, Colors.green),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Amount and Completed
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(symbol: '\$')
                                        .format(payment.amount),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0066CC),
                                    ),
                                  ),
                                ],
                              ),
                              if (payment.status == 'Paid')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDetailChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF0066CC),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Payments...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(_filtered[index]);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildFilterChips(),
          const SizedBox(height: 10),
          _buildSummaryRow(),
          const SizedBox(height: 10),
          Expanded(child: _buildPaymentList()),
        ],
      ),
    );
  }
}
