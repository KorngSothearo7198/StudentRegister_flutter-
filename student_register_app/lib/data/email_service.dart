// lib/services/email_service.dart - SIMPLER VERSION
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  // Generate temporary password
  static String generateTemporaryPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      List.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  // Store password in Firestore
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      print('🔍 Looking up admin: $email');
      
      // Find admin in Firestore
      final adminQuery = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (adminQuery.docs.isEmpty) {
        return {'success': false, 'message': 'No admin found'};
      }
      
      final adminDoc = adminQuery.docs.first;
      final adminData = adminDoc.data();
      final adminName = adminData['fullName'] ?? 'Admin';
      
      // Generate and store password
      final newPassword = generateTemporaryPassword();
      
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminDoc.id)
          .update({
        'password': newPassword,
        'passwordResetAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Password updated in Firestore');
      
      // Show password to user
      _showPasswordResult(context, adminName, email, newPassword);
      
      return {
        'success': true,
        'password': newPassword,
        'name': adminName,
      };
      
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  
  static void _showPasswordResult(
    BuildContext context,
    String name,
    String email,
    String password,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Password Reset"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_reset, size: 50, color: Colors.blue),
            const SizedBox(height: 16),
            Text("Password reset for: $name"),
            const SizedBox(height: 8),
            Text("Email: $email"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text("New Password:"),
                  const SizedBox(height: 8),
                  SelectableText(
                    password,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Use this password to login",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}