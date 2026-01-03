// lib/screens/admin_student_detail_screen.dart
import 'dart:math';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_register_app/screens/admin/admin_login.dart';
import 'package:student_register_app/screens/chart/student_chat_screen.dart'
    hide AdminModel;
import 'package:url_launcher/url_launcher.dart';
import '../../models/student_model.dart';
import '../../models/admin/admin_model.dart';

class AdminStudentDetailScreen extends StatefulWidget {
  final Student student;
  final String photoUrl;
  // final String studentDocId; // <-- add this

  const AdminStudentDetailScreen({
    super.key,
    required this.student,
    required this.photoUrl,
    // required this.studentDocId,
  });

  @override
  State<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState extends State<AdminStudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late Student _currentStudent;
  bool _isUpdating = false;

  String? _generatedId;
  String? _generatedPassword;

  AdminModel? currentAdmin;

  late ConfettiController _confettiCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────
  // Generate credentials
  // ───────────────────────────────────────────────────────────────
  Future<void> _generateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'global_student_id_counter';

    int counter = (prefs.getInt(key) ?? 9999) + 1;
    await prefs.setInt(key, counter);

    _generatedId = "STU-${counter.toString().padLeft(5, '0')}";

    const words = ['smos', 'love', 'cute', 'baby'];
    final word = words[Random().nextInt(words.length)];
    final number = Random().nextInt(900) + 100;

    _generatedPassword = "$word$number";
  }

  Future<bool> _isStudentIdExists(String studentId) async {
    final q = await FirebaseFirestore.instance
        .collection('students_joinName')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    return q.docs.isNotEmpty;
  }

//   Future<void> _approveStudent() async {
//     if (_currentStudent.status == "Approved") return;
//
//     setState(() => _isUpdating = true);
//
//     try {
//       await _generateCredentials();
//       if (_generatedId == null || _generatedPassword == null) {
//         throw "Generated ID or password is null.";
//       }
//
//       final exists = await _isStudentIdExists(_generatedId!);
//       if (exists) throw "Student ID already exists! Please regenerate ID.";
//
//       final studentsCollection = FirebaseFirestore.instance.collection(
//         'students_joinName',
//       );
//       final studentsPaymentsCollection = FirebaseFirestore.instance.collection(
//         'students_payments',
//       );
//
//       DocumentReference? studentDocRef;
//
//       if (_currentStudent.docId != null && _currentStudent.docId!.isNotEmpty) {
//         studentDocRef = studentsCollection.doc(_currentStudent.docId);
//       } else {
//         final querySnapshot = await studentsCollection
//             .where('firstName', isEqualTo: _currentStudent.firstName)
//             .where('lastName', isEqualTo: _currentStudent.lastName)
//             .limit(1)
//             .get();
//
//         if (querySnapshot.docs.isNotEmpty) {
//           studentDocRef = querySnapshot.docs.first.reference;
//         }
//       }
//
//       if (studentDocRef != null) {
//         await studentDocRef.update({
//           'status': 'Approved',
//           'studentId': _generatedId,
//           'password': _generatedPassword,
//           'approvedAt': FieldValue.serverTimestamp(), // ✅ Add this
//         });
//       } else {
//         studentDocRef = await studentsCollection.add({
//           'firstName': _currentStudent.firstName,
//           'lastName': _currentStudent.lastName,
//           'gender': _currentStudent.gender,
//           'major': _currentStudent.major ?? '',
//           'degree': _currentStudent.degree ?? '',
//           'shift': _currentStudent.shift ?? '',
//           'year': _currentStudent.year ?? '',
//           'status': 'Approved',
//           'dateOfBirth': _currentStudent.dateOfBirth ?? '',
//           'nationality': _currentStudent.nationality ?? '',
//           'village': _currentStudent.village ?? '',
//           'commune': _currentStudent.commune ?? '',
//           'district': _currentStudent.district ?? '',
//           'province': _currentStudent.province ?? '',
//           'studentId': _generatedId,
//           'password': _generatedPassword,
//           "createdAt": FieldValue.serverTimestamp(),
//           "approvedAt": FieldValue.serverTimestamp(), // ✅ Add this
//         });
//       }
//
//       setState(() {
//         _currentStudent = _currentStudent.copyWith(
//           status: 'Approved',
//           studentId: _generatedId!,
//           password: _generatedPassword!,
//           docId: studentDocRef!.id,
//         );
//       });
//
//       // Payments
//       final paymentsDocRef = studentsPaymentsCollection.doc(_generatedId);
//       final paymentsSnapshot = await paymentsDocRef
//           .collection('payments')
//           .get();
//
//       if (paymentsSnapshot.docs.isEmpty) {
//         await paymentsDocRef.set({
//           'firstName': _currentStudent.firstName,
//           'lastName': _currentStudent.lastName,
//           'major': _currentStudent.major ?? '',
//           'photoUrl': _currentStudent.photoUrl,
//         });
//
//         for (int year = 1; year <= 4; year++) {
//           for (int sem = 1; sem <= 2; sem++) {
//             await paymentsDocRef.collection('payments').add({
//               'amount': 0.01,
//               'semester': 'Semester $sem',
//               'year': year,
//               'status': 'Pending',
//               'createdAt': FieldValue.serverTimestamp(),
//               'photoUrl': _currentStudent.photoUrl ?? '',
//             });
//           }
//         }
//       }
//
//       _confettiCtrl.play();
//       _fadeCtrl.forward();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Student approved! Credentials generated."),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//
//       // ✅ SEND CREDENTIALS TO STUDENT IF CHAT ID EXISTS
//       if (_currentStudent.telegramChatId != null &&
//           _currentStudent.telegramChatId!.isNotEmpty) {
//         await _sendTelegramCredentials(
//           chatId: _currentStudent.telegramChatId!,
//           studentName: "${_currentStudent.firstName} ${_currentStudent.lastName}",
//           studentId: _generatedId!,
//           password: _generatedPassword!,
//         );
//       } else {
//         print("⚠️ Student has no Telegram chatId");
//       }
//
//       // ✅ Send credentials to Telegram Group (Optional)
//       const String telegramGroupId = '-1001234567890'; // Replace with your group ID
//       await _sendTelegramCredentials(
//         chatId: telegramGroupId,
//         studentName: "${_currentStudent.firstName} ${_currentStudent.lastName}",
//         studentId: _generatedId!,
//         password: _generatedPassword!,
//       );
//
//
//
//     } catch (e) {
//       print("Firestore Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to approve student: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isUpdating = false);
//     }
//   }
//
//   String escapeMarkdown(String text) {
//     return text.replaceAllMapped(
//       RegExp(r'[_*[\]()~`>#+\-=|{}.!]'),
//           (m) => '\\${m[0]}',
//     );
//   }
//
//
//   Future<void> _sendTelegramCredentials({
//     required String chatId,
//     required String studentName,
//     required String studentId,
//     required String password,
//   }) async {
//     const String botToken = '8546897347:AAF2Pfm5cYm_OZH1aS_UyBwBcP0Nj6mqgRA';
//
//     final message = '''
// 🎓 *Student Account Approved*
//
// 👤 Name: ${escapeMarkdown(studentName)}
// 🆔 Student ID: ${escapeMarkdown(studentId)}
// 🔐 Password: ${escapeMarkdown(password)}
//
// ⚠️ Please keep your credentials safe.
// 📲 Login to the system now.
//
// — University Administration
// ''';
//
//     final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
//
//     try {
//       final response = await http.post(
//         url,
//         body: {
//           'chat_id': chatId,
//           'text': message,
//           'parse_mode': 'Markdown',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         print('✅ Telegram message sent successfully to $chatId');
//       } else {
//         print('❌ Telegram failed: ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Telegram error: $e');
//     }
//   }





  Future<void> _approveStudent() async {
    print("🔹 Start approving student: ${_currentStudent.firstName} ${_currentStudent.lastName}");

    if (_currentStudent.status == "Approved") {
      print("⚠️ Student already approved");
      return;
    }

    setState(() => _isUpdating = true);

    try {
      print("🔹 Generating credentials...");
      await _generateCredentials();
      print("🔹 Generated ID: $_generatedId, Password: $_generatedPassword");

      if (_generatedId == null || _generatedPassword == null) {
        throw "Generated ID or password is null.";
      }

      final exists = await _isStudentIdExists(_generatedId!);
      print("🔹 Checking if student ID exists: $exists");
      if (exists) throw "Student ID already exists! Please regenerate ID.";

      final studentsCollection = FirebaseFirestore.instance.collection('students_joinName');
      final studentsPaymentsCollection = FirebaseFirestore.instance.collection('students_payments');

      DocumentReference? studentDocRef;

      if (_currentStudent.docId != null && _currentStudent.docId!.isNotEmpty) {
        studentDocRef = studentsCollection.doc(_currentStudent.docId);
        print("🔹 Using existing document ID: ${_currentStudent.docId}");
      } else {
        final querySnapshot = await studentsCollection
            .where('firstName', isEqualTo: _currentStudent.firstName)
            .where('lastName', isEqualTo: _currentStudent.lastName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          studentDocRef = querySnapshot.docs.first.reference;
          print("🔹 Found existing student document in Firestore: ${studentDocRef.id}");
        }
      }

      if (studentDocRef != null) {
        print("🔹 Updating existing student document...");
        await studentDocRef.update({
          'status': 'Approved',
          'studentId': _generatedId,
          'password': _generatedPassword,
          'approvedAt': FieldValue.serverTimestamp(),
        });
      } else {
        print("🔹 Adding new student document...");
        studentDocRef = await studentsCollection.add({
          'firstName': _currentStudent.firstName,
          'lastName': _currentStudent.lastName,
          'gender': _currentStudent.gender,
          'major': _currentStudent.major ?? '',
          'degree': _currentStudent.degree ?? '',
          'shift': _currentStudent.shift ?? '',
          'year': _currentStudent.year ?? '',
          'status': 'Approved',
          'dateOfBirth': _currentStudent.dateOfBirth ?? '',
          'nationality': _currentStudent.nationality ?? '',
          'village': _currentStudent.village ?? '',
          'commune': _currentStudent.commune ?? '',
          'district': _currentStudent.district ?? '',
          'province': _currentStudent.province ?? '',
          'studentId': _generatedId,
          'password': _generatedPassword,
          "createdAt": FieldValue.serverTimestamp(),
          "approvedAt": FieldValue.serverTimestamp(),
        });
        print("🔹 New student document added with ID: ${studentDocRef.id}");
      }

      setState(() {
        _currentStudent = _currentStudent.copyWith(
          status: 'Approved',
          studentId: _generatedId!,
          password: _generatedPassword!,
          docId: studentDocRef!.id,
        );
      });

      print("🔹 Updating payments...");
      final paymentsDocRef = studentsPaymentsCollection.doc(_generatedId);
      final paymentsSnapshot = await paymentsDocRef.collection('payments').get();

      if (paymentsSnapshot.docs.isEmpty) {
        await paymentsDocRef.set({
          'firstName': _currentStudent.firstName,
          'lastName': _currentStudent.lastName,
          'major': _currentStudent.major ?? '',
          'photoUrl': _currentStudent.photoUrl,
        });

        for (int year = 1; year <= 4; year++) {
          for (int sem = 1; sem <= 2; sem++) {
            await paymentsDocRef.collection('payments').add({
              'amount': 0.01,
              'semester': 'Semester $sem',
              'year': year,
              'status': 'Pending',
              'createdAt': FieldValue.serverTimestamp(),
              'photoUrl': _currentStudent.photoUrl ?? '',
            });
            print("🔹 Added payment record: Year $year Semester $sem");
          }
        }
      } else {
        print("🔹 Payments already exist for this student.");
      }

      _confettiCtrl.play();
      _fadeCtrl.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student approved! Credentials generated."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ✅ SEND CREDENTIALS TO STUDENT IF CHAT ID EXISTS
      if (_currentStudent.telegramChatId != null && _currentStudent.telegramChatId!.isNotEmpty) {
        await _sendTelegramCredentials(
          chatId: _currentStudent.telegramChatId!,
          studentName: "${_currentStudent.firstName} ${_currentStudent.lastName}",
          studentId: _generatedId!,
          password: _generatedPassword!,
        );

      } else {
        print("⚠️ Student has no Telegram chatId yet. Ask student to send /start to bot.");
      }


      // ✅ Send credentials to Telegram Group
      const String telegramGroupId = '-1001234567890'; // Replace with your group ID
      print("🔹 Sending Telegram credentials to groupId: $telegramGroupId");
      await _sendTelegramCredentials(
        chatId: telegramGroupId,
        studentName: "${_currentStudent.firstName} ${_currentStudent.lastName}",
        studentId: _generatedId!,
        password: _generatedPassword!,
      );

      print("✅ Approve student process completed for ${_currentStudent.firstName} ${_currentStudent.lastName}");

    } catch (e) {
      print("❌ Firestore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve student: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
      print("🔹 _approveStudent finished.");
    }
  }

  String escapeMarkdown(String text) {
    return text.replaceAllMapped(
      RegExp(r'[_*[\]()~`>#+\-=|{}.!]'),
          (m) => '\\${m[0]}',
    );
  }

  Future<void> _sendTelegramCredentials({
    required String chatId,
    required String studentName,
    required String studentId,
    required String password,
  }) async {
    const String botToken = '8546897347:AAF2Pfm5cYm_OZH1aS_UyBwBcP0Nj6mqgRA';

    final message = '''
🎓 *Student Account Approved*

👤 Name: ${escapeMarkdown(studentName)}
🆔 Student ID: ${escapeMarkdown(studentId)}
🔐 Password: ${escapeMarkdown(password)}

⚠️ Please keep your credentials safe.
📲 Login to the system now.

— University Administration
''';

    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

    try {
      print("🔹 Sending Telegram message to $chatId");
      final response = await http.post(
        url,
        body: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Telegram message sent successfully to $chatId");
      } else {
        print("❌ Telegram failed for $chatId: ${response.body}");
      }
    } catch (e) {
      print("❌ Telegram error for $chatId: $e");
    }
  }








  Future<void> _rejectStudent() async {
    if (_currentStudent.status == "Rejected") return;

    setState(() => _isUpdating = true);

    try {
      final studentsCollection = FirebaseFirestore.instance.collection(
        'students_joinName',
      );
      DocumentReference? studentDocRef;

      if (_currentStudent.docId != null && _currentStudent.docId!.isNotEmpty) {
        studentDocRef = studentsCollection.doc(_currentStudent.docId);
      } else {
        final querySnapshot = await studentsCollection
            .where('firstName', isEqualTo: _currentStudent.firstName)
            .where('lastName', isEqualTo: _currentStudent.lastName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          studentDocRef = querySnapshot.docs.first.reference;
        }
      }

      if (studentDocRef != null) {
        await studentDocRef.update({'status': 'Rejected'});

        setState(() {
          _currentStudent = _currentStudent.copyWith(
            status: 'Rejected',
            docId: studentDocRef!.id,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student has been rejected.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw "Student document not found!";
      }
    } catch (e) {
      print("Firestore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to reject student: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isApproved = _currentStudent.status == "Approved";
    final isRejected = _currentStudent.status == "Rejected";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          "Student Detail",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: screenHeight * 0.02),
                _buildStatusBanner(context),
                SizedBox(height: screenHeight * 0.02),
                _buildPersonalInfoSection(context),
                SizedBox(height: screenHeight * 0.015),
                _buildAcademicInfoSection(context),
                SizedBox(height: screenHeight * 0.015),
                _buildAddressInfoSection(context),
                SizedBox(height: screenHeight * 0.02),

                // NEW SECTIONS
                _buildAdditionalInfoSection(context),
                SizedBox(height: screenHeight * 0.02),
                _buildImageGallery(context),
                SizedBox(height: screenHeight * 0.02),

                Column(
                  children: [
                    if (isApproved)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildCredentialsCard(context),
                      ),
                    if (isApproved) SizedBox(height: screenHeight * 0.02),
                    if (!isApproved && !isRejected)
                      _buildActionButtons(context),
                    if (isApproved) _buildActionButtons(context),
                    if (_isUpdating)
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.02),
                        child: Column(
                          children: const [
                            CircularProgressIndicator(
                              color: Color(0xFF0066CC),
                              strokeWidth: 2,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Processing...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.06,
              numberOfParticles: 40,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // Sections
  // ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Hero(
            tag: "avatar_${_currentStudent.id}",
            child: Container(
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0066CC), Color(0xFF004499)],
                ),
              ),
              child: ClipOval(
                child:
                    _currentStudent.photoUrl != null &&
                        _currentStudent.photoUrl!.isNotEmpty
                    ? Image.network(
                        _currentStudent.photoUrl ??
                            '', // fallback to empty string
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: screenWidth * 0.5,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: screenWidth * 0.5,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          "${_currentStudent.firstName[0]}${_currentStudent.lastName[0]}"
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            "${_currentStudent.firstName} ${_currentStudent.lastName}",
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            _currentStudent.studentId ?? "Pending ID",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Color statusColor;
    IconData statusIcon;
    String statusText = _currentStudent.status;

    switch (_currentStudent.status) {
      case "Approved":
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      case "Rejected":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = "Pending Review";
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.02),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return _buildInfoSection(
      context: context,
      title: "Personal Information",
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          "First Name",
          _currentStudent.firstName,
          Icons.person,
          context,
        ),
        _buildInfoRow(
          "Last Name",
          _currentStudent.lastName,
          Icons.person,
          context,
        ),
        _buildInfoRow("Gender", _currentStudent.gender, Icons.wc, context),
        _buildInfoRow(
          "Date of Birth",
          _currentStudent.dateOfBirth ?? "N/A",
          Icons.cake,
          context,
        ),
        _buildInfoRow(
          "Nationality",
          _currentStudent.nationality ?? "N/A",
          Icons.flag,
          context,
        ),
      ],
    );
  }

  Widget _buildAcademicInfoSection(BuildContext context) {
    return _buildInfoSection(
      context: context,
      title: "Academic Information",
      icon: Icons.school_outlined,
      children: [
        _buildInfoRow(
          "Major",
          _currentStudent.major ?? "N/A",
          Icons.auto_stories,
          context,
        ),
        _buildInfoRow(
          "Degree",
          _currentStudent.degree ?? "N/A",
          Icons.workspace_premium,
          context,
        ),
        _buildInfoRow(
          "Shift",
          _currentStudent.shift ?? "N/A",
          Icons.access_time,
          context,
        ),
        if (_currentStudent.year != null)
          _buildInfoRow(
            "Year",
            _currentStudent.year!,
            Icons.calendar_month,
            context,
          ),
      ],
    );
  }

  Widget _buildAddressInfoSection(BuildContext context) {
    return _buildInfoSection(
      context: context,
      title: "Address Information",
      icon: Icons.location_on_outlined,
      children: [
        _buildInfoRow(
          "Village",
          _currentStudent.village ?? "N/A",
          Icons.home,
          context,
        ),
        _buildInfoRow(
          "Commune",
          _currentStudent.commune ?? "N/A",
          Icons.house,
          context,
        ),
        _buildInfoRow(
          "District",
          _currentStudent.district ?? "N/A",
          Icons.location_city,
          context,
        ),
        _buildInfoRow(
          "Province",
          _currentStudent.province ?? "N/A",
          Icons.map,
          context,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // NEW: Additional Information Section
  // ───────────────────────────────────────────────────────────────
  Widget _buildAdditionalInfoSection(BuildContext context) {
    return _buildInfoSection(
      context: context,
      title: "Additional Information",
      icon: Icons.info_outline,
      children: [
        _buildInfoRow(
          "Father's Name",
          _currentStudent.fatherName ?? "N/A",
          Icons.person,
          context,
        ),
        _buildInfoRow(
          "Mother's Name",
          _currentStudent.motherName ?? "N/A",
          Icons.person,
          context,
        ),
        _buildInfoRow(
          "Phone",
          _currentStudent.phone ?? "N/A",
          Icons.phone,
          context,
        ),
        _buildInfoRow(
          "Guardian Phone",
          _currentStudent.guardianPhone ?? "N/A",
          Icons.phone_android,
          context,
        ),
        _buildInfoRow(
          "Telegram",
          _currentStudent.telegram ?? "N/A",
          Icons.telegram,
          context,
        ),
        // _buildInfoRow(
        //   "ID Card Number",
        //   _currentStudent.idCardNumber ?? "N/A",
        //   Icons.badge,
        //   context,
        // ),
        _buildInfoRow(
          "Education Level",
          _currentStudent.educationLevel ?? "N/A",
          Icons.school,
          context,
        ),
        _buildInfoRow(
          "Program Type",
          _currentStudent.programType ?? "N/A",
          Icons.work,
          context,
        ),
        _buildInfoRow(
          "Career Type",
          _currentStudent.careerType ?? "N/A",
          Icons.work_outline,
          context,
        ),
        _buildInfoRow(
          "Bac Year",
          _currentStudent.bacYear ?? "N/A",
          Icons.calendar_today,
          context,
        ),
        _buildInfoRow(
          "High School Name",
          _currentStudent.highSchoolName ?? "N/A",
          Icons.school_outlined,
          context,
        ),
        _buildInfoRow(
          "High School Location",
          _currentStudent.highSchoolLocation ?? "N/A",
          Icons.location_on,
          context,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // NEW: Image Gallery Section
  // ───────────────────────────────────────────────────────────────
  Widget _buildImageGallery(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Build a list of image URLs with labels
    final imagesWithLabels = [
      if (_currentStudent.idCardImageUrl != null)
        {'label': 'ID Card', 'url': _currentStudent.idCardImageUrl},
      if (_currentStudent.degreeDocumentUrl != null)
        {'label': 'Degree Document', 'url': _currentStudent.degreeDocumentUrl},
      if (_currentStudent.photoUrls != null)
        ..._currentStudent.photoUrls!.map(
          (url) => {'label': 'Photo', 'url': url},
        ),
    ];

    if (imagesWithLabels.isEmpty) return const SizedBox();

    return _buildInfoSection(
      context: context,
      title: "Uploaded Documents & Photos",
      icon: Icons.image,
      children: imagesWithLabels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value['label']!;
        final url = entry.value['url']!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  print("📌 Tapped Image URL: $url");

                  // Open full screen preview
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: imagesWithLabels.length,
                            controller: PageController(initialPage: index),
                            itemBuilder: (context, i) => InteractiveViewer(
                              child: Image.network(
                                imagesWithLabels[i]['url']!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Close button
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: screenWidth * 0.5,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      height: screenWidth * 0.5,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // Reusable Helpers
  // ───────────────────────────────────────────────────────────────
  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0066CC)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.012),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // Action Buttons
  // ───────────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _approveStudent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
            ),
            child: const Text("Approve"),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _rejectStudent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
            ),
            child: const Text("Reject"),
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Generated Credentials",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildCredentialRow("Student ID", _currentStudent.studentId ?? ""),
          const SizedBox(height: 5),
          _buildCredentialRow("Password", _currentStudent.password ?? ""),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: $value", style: const TextStyle(fontSize: 14)),
        IconButton(
          onPressed: () {
            FlutterClipboard.copy(value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$label copied to clipboard")),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
        ),
      ],
    );
  }
}
