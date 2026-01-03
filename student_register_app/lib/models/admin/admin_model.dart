

// lib/models/admin/admin_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// lib/models/admin/admin_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid; // Firestore document ID (Zue63EebwYRgyB9tJSZsYh5Inbi1)
  final String? fullName; // "JinHub"
  final String? email; // "y@gmail.com"
  final String? profileImage; // URL from Cloudinary
  final String? password;
  final String? id;
  final String? role;

  AdminModel({
    required this.uid,
    this.fullName,
    this.email,
    this.profileImage,
    this.password,
    this.id,
    this.role,
  });

  // Helper getter for photoUrl (for compatibility with chat screen)
  String? get photoUrl => profileImage;

  // CopyWith method
  AdminModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? profileImage,
    String? password,
    String? id,
    String? role,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
      id: id ?? this.id,
      role: role ?? this.role,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profileImage': profileImage,
      'password': password,
      'id': id,
      'role': role,
    };
  }

  // Create from Firestore document
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AdminModel(
      uid: doc.id, // This is "Zue63EebwYRgyB9tJSZsYh5Inbi1"
      fullName: data['fullName'] as String?,
      email: data['email'] as String?,
      profileImage: data['profileImage'] as String?,
      password: data['password'] as String?,
      id: data['id'] as String?,
      role: data['role'] as String? ?? 'Teacher', // Default to 'Teacher'
    );
  }
}

