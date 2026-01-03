// admin_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_register_app/models/admin/admin_model.dart';
// import '../models/admin/admin_model.dart';

class AdminProvider extends ChangeNotifier {
  AdminModel? _currentAdmin;
  
  AdminModel? get currentAdmin => _currentAdmin;
  
  bool get isLoggedIn => _currentAdmin != null;
  
  Future<void> loadCurrentAdmin() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null) {
      _currentAdmin = null;
      notifyListeners();
      return;
    }
    
    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(firebaseUser.uid)
          .get();
      
      if (adminDoc.exists) {
        _currentAdmin = AdminModel.fromFirestore(adminDoc);
      } else {
        // Create admin profile if doesn't exist
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(firebaseUser.uid)
            .set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'Admin',
          'profileImage': firebaseUser.photoURL ?? '',
          'role': 'Teacher',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        final newDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(firebaseUser.uid)
            .get();
            
        _currentAdmin = AdminModel.fromFirestore(newDoc);
      }
    } catch (e) {
      print('Error loading admin: $e');
      // Fallback
      _currentAdmin = AdminModel(
        uid: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? 'Admin',
        email: firebaseUser.email ?? '',
        profileImage: firebaseUser.photoURL,
        role: 'Teacher',
      );
    }
    
    notifyListeners();
  }
  
  void logout() {
    FirebaseAuth.instance.signOut();
    _currentAdmin = null;
    notifyListeners();
  }
}