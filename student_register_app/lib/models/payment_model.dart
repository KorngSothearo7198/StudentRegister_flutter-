// {"id":"84129","variant":"standard","title":"Payment class with fromFirestore"}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Payment {
  final int id;
  final String studentName;
  final String major;
  final double amount;
  final DateTime dueDate;
  final String status; // "Paid", "Pending", "Owing"
  final DateTime? paidDate; // null if not paid
  final String? notes;
  final String receiptId; // for receiptid
  final String paymentMethod; // "ABA Bank", "Wing", "PayPal"
  final DateTime transactionDate; // When the payment was made
  final String semester; // "Semester 1", "Semester 2"
  final int year;
  String studentId; // 2025, 2026...

  final String? receiptUrl; // <-- new field

  final String? photoUrl;
  final DateTime? doDate;

  Payment({
    required this.id,
    required this.studentName,
    required this.major,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.notes,
    required this.paymentMethod,
    required this.transactionDate,
    required this.semester,
    required this.year,
    required this.studentId,
    required this.receiptId,

    this.receiptUrl, // <-- add to constructor

    this.photoUrl,
    this.doDate,
  });

  Payment copyWith({
    int? id,
    String? studentName,
    String? major,
    double? amount,
    DateTime? dueDate,
    String? status,
    DateTime? paidDate,
    String? notes,
    String? paymentMethod,
    DateTime? transactionDate,
    String? semester,
    int? year,
    String? studentId,
    String? receiptId,
    String? receiptUrl,

    String? photoUrl,
    DateTime? doDate,
  }) {
    return Payment(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      major: major ?? this.major,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      studentId: studentId ?? this.studentId,
      receiptId: receiptId ?? this.receiptId,

      receiptUrl: receiptUrl ?? this.receiptUrl, // <-- ✔ ADD

      photoUrl: photoUrl ?? this.photoUrl,
      doDate: doDate ?? this.doDate,
    );
  }

  // Firestore-friendly constructor

  factory Payment.fromFirestore(String studentId, Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Payment(
      studentId: studentId,
      studentName:
          data['studentName'] ?? '', // optional if you have studentName
          
      major: data['major'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      // paymentMethod: data['method'] ?? '',
      // receiptId: data['receiptId'] ?? '',
      paymentMethod: data['paymentMethod'] ?? data['method'] ?? '',

      // receiptId: data['receiptId']?.toString() ?? '',
      receiptId: data['receiptId']?.toString() ??
           data['referenceNo']?.toString() ??
           data['ref']?.toString() ??
           '',

      semester: data['semester'] ?? '',
      year: data['year'] ?? 0,
      transactionDate: parseDate(data['date']),
      dueDate: parseDate(data['createdAt']),
      paidDate: parseDate(data['doDate']),
      notes: data['notes'],
      id: data['id'] ?? 0,
      photoUrl: data['photoUrl'],
      receiptUrl: data['receiptUrl'], // THIS WILL NOW WORK
      doDate: parseDate(data['doDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'major': major,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'receiptId': receiptId,
      'semester': semester,
      'year': year,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'notes': notes,
      'id': id,

      // NEW FIELDS
      'photoUrl': photoUrl,
      'receiptUrl': receiptUrl,
      'doDate': doDate?.toIso8601String(),
    };
  }

  String get method => paymentMethod;
  DateTime get date => transactionDate;

  @override
  String toString() {
    return 'Payment(id: $id, $studentName, $major, \$${amount.toStringAsFixed(2)}, $status, $paymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
