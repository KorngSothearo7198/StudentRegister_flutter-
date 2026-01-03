import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentFirestoreService {
  static Future<String> createPendingPayment({
    required String studentId,
    required String semester,
    required String year,
    required double amount,
    required String method,
  }) async {
    final ref = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .add({
      'semester': semester,
      'year': year,
      'amount': amount,
      'method': method,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  static Future<void> attachReceipt({
    required String studentId,
    required String paymentId,
    required String receiptUrl,
    required String transactionRef,
  }) async {
    await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .doc(paymentId)
        .update({
      'receiptUrl': receiptUrl,
      'transactionRef': transactionRef,
    });
  }

  static Future<bool> isAlreadyPaid({
    required String studentId,
    required String semester,
    required String year,
  }) async {
    final snap = await FirebaseFirestore.instance
        .collection('students_payments')
        .doc(studentId)
        .collection('payments')
        .where('semester', isEqualTo: semester)
        .where('year', isEqualTo: year)
        .where('status', isEqualTo: 'Paid')
        .get();

    return snap.docs.isNotEmpty;
  }
}
