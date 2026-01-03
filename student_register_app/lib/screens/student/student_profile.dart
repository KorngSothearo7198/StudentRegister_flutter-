import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:student_register_app/screens/student/qr_scanner_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _passwordCtrl;

  bool _obscurePassword = true;

  late Map<String, dynamic> _student;
  late String _status;

  File? _profileImage;
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  final CollectionReference studentsCollection = FirebaseFirestore.instance
      .collection('students_joinName');

  // Cloudinary config
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'student_profiles';

  // Colors
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color backgroundColor = Color(0xFFF8FAFF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _student = Map<String, dynamic>.from(widget.student);

    _firstNameCtrl = TextEditingController(text: _student['firstName'] ?? '');
    _lastNameCtrl = TextEditingController(text: _student['lastName'] ?? '');
    _passwordCtrl = TextEditingController(text: _student['password'] ?? '');

    if (_student['photo'] != null) {
      _profileImageBytes = _student['photo'] as Uint8List;
    }

    _status = _student['status'] ?? 'Pending';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Add this method to your _StudentProfileScreenState class
  Future<void> _scanAndShowStudentInfo() async {
    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scan Student QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Ready to scan student QR code...'),
            const SizedBox(height: 16),
            // Option to enter manually
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _enterQRManually();
              },
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter QR Data Manually'),
            ),
          ],
        ),
      ),
    );

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 1));

    // Close the loading dialog
    if (mounted) Navigator.pop(context);

    // For now, show test dialog. Later you can integrate real camera scanning
    _showTestScannerDialog();
  }

  void _enterQRManually() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Student QR Data'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText:
                'Paste student QR code JSON here...\nExample: {"studentId":"STU123","validUntil":"2025-12-31"}',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _processScannedQR(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
            ),
            child: const Text('Verify Student'),
          ),
        ],
      ),
    );
  }

  void _showTestScannerDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scanner UI
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0066CC),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: Color(0xFF0066CC),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Point camera at\nStudent QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircularProgressIndicator(
                          color: const Color(0xFF0066CC),
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Test buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Test with a student ID
                            _processScannedQR(
                              '{"studentId":"${_student['studentId'] ?? "STU2024001"}"}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                          ),
                          child: const Text('Test Scan'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _enterQRManually();
                    },
                    child: const Text('Enter QR Manually'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _processScannedQR(String qrData) async {
    try {
      final data = json.decode(qrData) as Map<String, dynamic>;
      final studentId = data['studentId']?.toString();

      if (studentId == null || studentId.isEmpty) {
        _showError('Invalid QR code: No student ID found');
        return;
      }

      // Fetch student from Firebase
      await _fetchAndShowStudent(studentId);
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _fetchAndShowStudent(String studentId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching student information...'),
          ],
        ),
      ),
    );

    try {
      // Try students_joinName collection first
      final studentQuery = await firestore
          .collection('students_joinName')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      Map<String, dynamic>? studentData;

      if (studentQuery.docs.isNotEmpty) {
        studentData = studentQuery.docs.first.data();
      } else {
        // Try students_payments collection
        final paymentsDoc = await firestore
            .collection('students_payments')
            .doc(studentId)
            .get();

        if (paymentsDoc.exists) {
          studentData = paymentsDoc.data();
        }
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (studentData == null) {
        _showError('Student not found: $studentId');
        return;
      }

      // Show student information
      _showStudentInfoCard(studentData);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Database error: ${e.toString()}');
    }
  }

  void _showStudentInfoCard(Map<String, dynamic> student) {
    final studentName =
        '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}'.trim();
    final studentId = student['studentId'] ?? 'N/A';
    final major = student['major'] ?? 'Not specified';
    final year = student['year'] ?? 'Not specified';
    final status = student['status'] ?? 'Unknown';
    final email = student['email'] ?? '';
    final phone = student['phone'] ?? '';
    final photoUrl = student['photoUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Student Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Student Photo/Icon
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl) as ImageProvider
                      : null,
                  child: photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF0066CC),
                        )
                      : null,
                ),

                const SizedBox(height: 16),

                // Student Name
                Text(
                  studentName.isNotEmpty ? studentName : 'Unknown Student',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Student ID Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: $studentId',
                    style: const TextStyle(
                      color: Color(0xFF0066CC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Student Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    // children: [
                    //   _buildInfoRow('Major', major),
                    //   _buildInfoRow('Year', year),
                    //   if (email.isNotEmpty) _buildInfoRow('Email', email),
                    //   if (phone.isNotEmpty) _buildInfoRow('Phone', phone),
                    //   _buildInfoRow(
                    //     'Verification Date',
                    //     DateTime.now().toString().split(' ')[0],
                    //   ),
                    // ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Could navigate to full profile
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Viewing full profile of $studentName',
                              ),
                              backgroundColor: const Color(0xFF0066CC),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                        ),
                        child: const Text('View Profile'),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData flag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ========== EXISTING PROFILE FUNCTIONS (UNCHANGED) ==========

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = File(pickedFile.path);
        _profileImageBytes = bytes;
        _student['photo'] = _profileImageBytes;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    try {
      if (_profileImageBytes == null && _profileImage == null) {
        return _student['photoUrl'];
      }

      Uint8List bytes;
      String fileName;

      if (kIsWeb) {
        bytes = _profileImageBytes!;
        fileName = '${_student['studentId'] ?? 'profile'}.jpg';
      } else {
        bytes = await _profileImage!.readAsBytes();
        fileName = _profileImage!.path.split('/').last;
      }

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );

      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);

      if (response.statusCode == 200) {
        final downloadUrl = resJson['secure_url'];
        _student['photoUrl'] = downloadUrl;

        setState(() {
          _profileImage = null;
          _profileImageBytes = null;
        });

        return downloadUrl;
      } else {
        print('Cloudinary error: ${resJson['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  Future<String?> getDocIdByStudentId(String studentId) async {
    try {
      final query = await studentsCollection
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) return query.docs.first.id;
    } catch (e) {
      print('Error fetching docId: $e');
    }
    return null;
  }

  Future<void> _saveProfile() async {
    final docId = await getDocIdByStudentId(_student['studentId']);
    if (docId == null) return;

    setState(() {
      _student['firstName'] = _firstNameCtrl.text.trim();
      _student['lastName'] = _lastNameCtrl.text.trim();
      _student['password'] = _passwordCtrl.text.trim();
    });

    // 1️⃣ Upload image to Cloudinary and get URL
    final uploadedUrl = await _uploadProfileImage();

    Map<String, dynamic> updateData = {
      'firstName': _student['firstName'],
      'lastName': _student['lastName'],
      'password': _student['password'],
    };

    if (uploadedUrl != null) {
      updateData['photoUrl'] = uploadedUrl;
      _student['photoUrl'] = uploadedUrl;

      // 2️⃣ Update in students_payments main collection
      final studentsPaymentsCollection = FirebaseFirestore.instance.collection(
        'students_payments',
      );

      final paymentsDocRef = studentsPaymentsCollection.doc(
        _student['studentId'],
      );

      await paymentsDocRef.set({
        'firstName': _student['firstName'],
        'lastName': _student['lastName'],
        'major': _student['major'] ?? '',
        'photoUrl': uploadedUrl,
      }, SetOptions(merge: true));
    }

    // 3️⃣ Update profile in students_joinName collection
    try {
      await studentsCollection.doc(docId).update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final docId = await getDocIdByStudentId(_student['studentId']);
    if (docId == null) return;

    try {
      await studentsCollection.doc(docId).update({
        'password': _passwordCtrl.text.trim(),
      });
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _student['photoUrl'] != null
                          ? Image.network(
                              _student['photoUrl'],
                              fit: BoxFit.cover,
                            )
                          : (_profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : (_profileImageBytes != null
                                      ? Image.memory(
                                          _profileImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF4D8BFF),
                                                primaryColor,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _firstNameCtrl,
                label: 'First Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameCtrl,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveProfile();
              await _changePassword();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ========== QR CODE FUNCTIONALITY ==========

  Future<void> _generateAndShowQRCode() async {
    // Prepare student data for QR code
    final studentData = {
      'studentId': _student['studentId'] ?? '',
      'name': '${_student['firstName'] ?? ''} ${_student['lastName'] ?? ''}',
      'major': _student['major'] ?? '',
      'year': _student['year'] ?? '',
      'validUntil': DateTime.now()
          .add(const Duration(days: 365))
          .toIso8601String(),
    };

    final qrData = json.encode(studentData);
  }



  // ========== UI BUILDING METHODS ==========

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: primaryColor.withOpacity(0.7),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryColor.withOpacity(0.7),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return successColor;
      case 'pending':
        return warningColor;
      case 'rejected':
        return errorColor;
      default:
        return textSecondary;
    }
  }

  Widget _buildProfileHeader() {
    String initials = '';
    if ((_student['firstName'] ?? '').isNotEmpty)
      initials += _student['firstName'][0];
    if ((_student['lastName'] ?? '').isNotEmpty)
      initials += _student['lastName'][0];

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child:
                    _student['photoUrl'] != null &&
                        _student['photoUrl'].toString().isNotEmpty
                    ? Image.network(
                        _student['photoUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsAvatar(initials),
                      )
                    : _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : _profileImageBytes != null
                    ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
                    : _buildInitialsAvatar(initials),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '${_student['firstName'] ?? ''} ${_student['lastName'] ?? ''}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _statusColor(_status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor(_status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(_status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        if (_student['studentId'] != null) ...[
          const SizedBox(height: 12),
          Text(
            'ID: ${_student['studentId']}',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFE8F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials.toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildInfoSection("Basic Information", [
                _buildInfoRow("Gender", _student['gender'] ?? '', Icons.person),
                _buildInfoRow(
                  "Nationality",
                  _student['nationality'] ?? 'Cambodian',
                  Icons.flag,
                ),
                if (_student['email'] != null)
                  _buildInfoRow("Email", _student['email'] ?? '', Icons.email),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection("Academic Details", [
                _buildInfoRow(
                  "Major",
                  _student['major'] ?? 'Not set',
                  Icons.school,
                ),
                _buildInfoRow(
                  "Degree",
                  _student['degree'] ?? 'Bachelor',
                  Icons.book,
                ),
                _buildInfoRow(
                  "Year",
                  _student['year'] ?? 'Year 1',
                  Icons.calendar_today,
                ),
                _buildInfoRow(
                  "Shift",
                  _student['shift'] ?? 'Morning',
                  Icons.access_time,
                ),
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

              ),
              // const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEditProfileDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
