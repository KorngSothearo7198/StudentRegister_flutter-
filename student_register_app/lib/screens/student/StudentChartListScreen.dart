// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:student_register_app/screens/student/chart_screen.dart';

// class StudentChartListScreen extends StatelessWidget {
//   final String studentId; // <-- add this

//   const StudentChartListScreen({super.key, required this.studentId});

//   /// Get the current logged-in student profile
//   Future<Map<String, dynamic>?> _getCurrentStudentProfile() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final studentDoc = await FirebaseFirestore.instance
//           .collection('students_joinName')
//           .doc(user.uid)
//           .get();
//       if (studentDoc.exists) {
//         return studentDoc.data();
//       }
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Scaffold(body: Center(child: Text("Student not logged in")));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Student Chats")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .snapshots(), // Get all chat documents
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) return const Center(child: Text('No chats yet.'));

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final chatDoc = docs[index];
//               final studentId = chatDoc.id; // chat doc ID is studentId

//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('students_joinName')
//                     .doc(studentId)
//                     .get(),
//                 builder: (context, studentSnapshot) {
//                   if (!studentSnapshot.hasData) {
//                     return const ListTile(title: Text("Loading student..."));
//                   }

//                   final data =
//                       studentSnapshot.data!.data() as Map<String, dynamic>? ??
//                       {};
//                   final firstName = data['firstName'] ?? '';
//                   final lastName = data['lastName'] ?? '';
//                   final fullName = '$firstName $lastName'.trim();
//                   final photoUrl = data['photoUrl'] ?? '';

//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: photoUrl.isNotEmpty
//                           ? NetworkImage(photoUrl)
//                           : null,
//                       child: photoUrl.isEmpty
//                           ? Text(
//                               firstName.isNotEmpty
//                                   ? firstName[0].toUpperCase()
//                                   : '?',
//                               style: const TextStyle(color: Colors.white),
//                             )
//                           : null,
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                     title: Text(fullName.isNotEmpty ? fullName : "Student"),
//                     subtitle: Text(studentId),
//                     trailing: const Icon(Icons.chat),
//                     onTap: () async {
//                       // Show loading
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (_) =>
//                             const Center(child: CircularProgressIndicator()),
//                       );

//                       try {
//                         // Mark unread messages as read (for student role)
//                         final unreadMessages = await FirebaseFirestore.instance
//                             .collection('chats')
//                             .doc(studentId)
//                             .collection('messages')
//                             .where('receiver', isEqualTo: 'student')
//                             .where('isRead', isEqualTo: false)
//                             .get();

//                         for (var doc in unreadMessages.docs) {
//                           await doc.reference.update({'isRead': true});
//                         }

//                         if (context.mounted) Navigator.pop(context);

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => StudentChatWithChartScreen(
//                               studentchartId: studentId,
//                               fullName: fullName,
//                               photoUrl: photoUrl,
//                             ),
//                           ),
//                         );
//                       } catch (e) {
//                         if (context.mounted) Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error opening chat: $e')),
//                         );
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:student_register_app/screens/student/chart_screen.dart';

// class StudentChartListScreen extends StatelessWidget {
//   final String studentId; // logged-in student ID

//   const StudentChartListScreen({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Admin Contacts")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('admins').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData)
//             return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty)
//             return const Center(child: Text("No admins available."));

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final admin = docs[index];
//               final adminData = admin.data() as Map<String, dynamic>? ?? {};
//               final fullName = adminData['fullName'] ?? 'Admin';
//               final photoUrl = adminData['photoUrl'] ?? '';

//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage:
//                       photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
//                   child: photoUrl.isEmpty
//                       ? Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A')
//                       : null,
//                 ),
//                 title: Text(fullName),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => StudentChatWithChartScreen(
//                         studentchartId: studentId,
//                         adminId: admin.id,
//                         fullName: fullName,
//                         photoUrl: photoUrl,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_register_app/screens/student/chart_screen.dart';
import '../../models/admin/admin_model.dart';

class StudentChartListScreen extends StatelessWidget {
  final String studentId; // logged-in student ID

  const StudentChartListScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Contacts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text("No admins available."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final adminDoc = docs[index];
              final admin = AdminModel.fromFirestore(adminDoc);
              final fullName = admin.fullName ?? 'Admin';
              final photoUrl = admin.photoUrl ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(fullName.isNotEmpty
                          ? fullName[0].toUpperCase()
                          : 'A')
                      : null,
                ),
                title: Text(fullName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentChatWithChartScreen(
                        studentchartId: studentId,
                        adminId: admin.uid,
                        fullName: fullName,
                        photoUrl: photoUrl,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentChartListScreen extends StatelessWidget {
//   final String studentId; // received from home screen

//   const StudentChartListScreen({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context) {
//     if (studentId.isEmpty) {
//       return const Scaffold(
//         body: Center(child: Text("Student not logged in")),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Messages")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .doc(studentId)
//             .collection('messages')
//             .orderBy('time', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) return const Center(child: Text("No messages yet."));

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final msg = docs[index];
//               final text = msg['text'] ?? '';
//               final sender = msg['sender'] ?? '';
//               return ListTile(
//                 title: Text(text),
//                 subtitle: Text(sender),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
