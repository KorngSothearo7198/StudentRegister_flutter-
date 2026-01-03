import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_register_app/screens/chart/student_chat_screen.dart';
import '../../models/admin/admin_model.dart';

class ChatStudentListScreen extends StatefulWidget {
  final AdminModel currentAdmin;
  const ChatStudentListScreen({super.key, required this.currentAdmin});

  @override
  State<ChatStudentListScreen> createState() => _ChatStudentListScreenState();
}

class _ChatStudentListScreenState extends State<ChatStudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<DocumentSnapshot> _allStudents = [];
  List<DocumentSnapshot> _filteredStudents = [];

  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Color(0xFF4D8BFF);
  static const Color lightBlue = Color(0xFFE8F4FF);
  static const Color backgroundColor = Color(0xFFF8FAFF);
  static const Color textLight = Color(0xFF6B7280);
  static const Color cardBackground = Color(0xFFFFFFFF);

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredStudents = List.from(_allStudents);
      } else {
        _filteredStudents = _allStudents.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fullName =
          '${data['firstName']} ${data['lastName']}'.toLowerCase();
          final studentId = (data['studentId'] ?? '').toLowerCase();
          return fullName.contains(_searchQuery) ||
              studentId.contains(_searchQuery);
        }).toList();
      }
    });
  }

  Future<Map<String, dynamic>> getLastMessage(String studentId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(studentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return {
        'text': data['text'] ?? '',
        'time': data['time'] as Timestamp?,
      };
    }

    return {'text': '', 'time': null};
  }

  void _clearSearch() {
    _searchController.clear();
    _filterStudents('');
    setState(() => _isSearching = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection('students_joinName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return _buildErrorState();
          }
          final docs = snapshot.data!.docs;
          _allStudents = docs;
          if (_filteredStudents.isEmpty && _searchQuery.isEmpty) {
            _filteredStudents = List.from(docs);
          }
          if (docs.isEmpty) return _buildEmptyState();
          return _buildStudentList();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: _isSearching ? _buildSearchField() : _buildAppBarTitle(),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: _clearSearch,
          )
              : null,
        ),
        onChanged: _filterStudents,
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor.withOpacity(0.1),
          backgroundImage: widget.currentAdmin.profileImage != null &&
              widget.currentAdmin.profileImage!.isNotEmpty
              ? NetworkImage(widget.currentAdmin.profileImage!)
              : null,
          child: widget.currentAdmin.profileImage == null ||
              widget.currentAdmin.profileImage!.isEmpty
              ? Text(
            (widget.currentAdmin.fullName ?? 'A')[0].toUpperCase(),
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.w600),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Chats',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[900]),
            ),
            Text(
              '${_filteredStudents.length} ${_filteredStudents.length == 1 ? 'student' : 'students'} found',
              style: TextStyle(
                  fontSize: 12, color: textLight, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Text('Cancel',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
          onPressed: _clearSearch,
        ),
      ];
    }
    return [
      IconButton(
        icon: Icon(Icons.search, color: primaryColor),
        onPressed: () => setState(() => _isSearching = true),
      ),
    ];
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(child: Text('Unable to load students', style: TextStyle(color: textLight)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 60, color: primaryColor),
          const SizedBox(height: 12),
          Text('No Students Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Widget _buildStudentList() {
  //   return ListView.separated(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: _filteredStudents.length,
  //     separatorBuilder: (_, __) => const SizedBox(height: 12),
  //     itemBuilder: (context, index) {
  //       final data = _filteredStudents[index].data() as Map<String, dynamic>;
  //       final fullName = '${data['firstName']} ${data['lastName']}';
  //       final studentId = data['studentId'] ?? 'N/A';
  //       final photoUrl = data['photoUrl'] ?? '';
  //       final lastActiveAt = data['lastActiveAt'] as Timestamp?;
  //       final bool isActiveNow = lastActiveAt != null &&
  //           lastActiveAt.toDate().isAfter(
  //             DateTime.now().subtract(const Duration(minutes: 3)),
  //           );
  //
  //       // Fetch last message for this student
  //       return FutureBuilder<QuerySnapshot>(
  //         future: FirebaseFirestore.instance
  //             .collection('chats')
  //             .doc(studentId)
  //             .collection('messages')
  //             .orderBy('time', descending: true)
  //             .limit(1)
  //             .get(),
  //         builder: (context, snapshot) {
  //           String lastMessage = 'No messages yet';
  //           Timestamp? lastMessageTime;
  //
  //           if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
  //             final msgData =
  //             snapshot.data!.docs.first.data() as Map<String, dynamic>;
  //             lastMessage = msgData['text'] ?? '';
  //             lastMessageTime = msgData['time'] as Timestamp?;
  //           }
  //
  //           return GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (_) => AdminChatScreen(
  //                     studentId: studentId,
  //                     studentFullName: fullName,
  //                     studentPhotoUrl: photoUrl,
  //                     currentAdmin: widget.currentAdmin,
  //                     fullName: widget.currentAdmin.fullName ?? '',
  //                     photoUrl: widget.currentAdmin.photoUrl ?? '',
  //                   ),
  //                 ),
  //               );
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: cardBackground,
  //                 borderRadius: BorderRadius.circular(12),
  //                 boxShadow: const [
  //                   BoxShadow(color: Colors.black12, blurRadius: 4)
  //                 ],
  //               ),
  //               child: Row(
  //                 children: [
  //                   Stack(
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 28,
  //                         backgroundColor: lightBlue,
  //                         backgroundImage:
  //                         photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
  //                         child: photoUrl.isEmpty
  //                             ? Text(
  //                           fullName.isNotEmpty
  //                               ? fullName[0].toUpperCase()
  //                               : "S",
  //                           style: TextStyle(
  //                             fontSize: 20,
  //                             color: primaryColor,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         )
  //                             : null,
  //                       ),
  //                       Positioned(
  //                         bottom: 0,
  //                         right: 0,
  //                         child: CircleAvatar(
  //                           radius: 7,
  //                           backgroundColor:
  //                           isActiveNow ? Colors.green : Colors.grey,
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           fullName,
  //                           style: const TextStyle(fontWeight: FontWeight.w600),
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           lastMessage.isNotEmpty
  //                               ? lastMessage
  //                               : 'No messages yet',
  //                           style: TextStyle(color: textLight, fontSize: 13),
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       if (lastMessageTime != null)
  //                         Text(
  //                           _formatLastSeen(lastMessageTime.toDate()),
  //                           style: TextStyle(fontSize: 10, color: textLight),
  //                         ),
  //                       const SizedBox(height: 4),
  //                       Icon(Icons.chat_bubble_outline, color: primaryColor),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildStudentList() {
    debugPrint('[CHAT_LIST] Building student list with ${_filteredStudents.length} students');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = _filteredStudents[index];
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          debugPrint('[CHAT_LIST] Warning: student document is null at index $index');
          return const SizedBox();
        }

        final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
        final studentId = (data['studentId'] ?? '').toString();

        if (studentId.isEmpty) {
          debugPrint('[CHAT_LIST] Warning: studentId is empty for $fullName');
          return const SizedBox();
        }

        final photoUrl = data['photoUrl'] ?? '';
        final lastActiveAt = data['lastActiveAt'] as Timestamp?;
        final bool isActiveNow = lastActiveAt != null &&
            lastActiveAt.toDate().isAfter(DateTime.now().subtract(const Duration(minutes: 3)));

        // Fetch last message safely
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('chats')
              .doc(studentId)
              .collection('messages')
              .orderBy('time', descending: true)
              .limit(1)
              .get(),
          builder: (context, snapshot) {
            String lastMessage = 'No messages yet';
            Timestamp? lastMessageTime;

            if (snapshot.hasError) {
              debugPrint('[CHAT_LIST] Error loading last message for $studentId: ${snapshot.error}');
            }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final msgData = snapshot.data!.docs.first.data() as Map<String, dynamic>?;

              if (msgData != null) {
                lastMessage = msgData['text'] ?? 'No messages yet';
                lastMessageTime = msgData['time'] as Timestamp?;
                debugPrint('[CHAT_LIST] Last message for $studentId: $lastMessage');
              }
            }

            return GestureDetector(
              onTap: () {
                debugPrint('[CHAT_LIST] Open chat -> studentId=$studentId');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminChatScreenModern(
                      studentId: studentId,
                      studentFullName: fullName,
                      studentPhotoUrl: photoUrl,
                      currentAdmin: widget.currentAdmin,
                      // fullName: widget.currentAdmin.fullName ?? '',
                      // photoUrl: widget.currentAdmin.photoUrl ?? '',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: lightBlue,
                          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty
                              ? Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : "S",
                            style: TextStyle(fontSize: 20, color: primaryColor, fontWeight: FontWeight.w600),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: isActiveNow ? Colors.green : Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage,
                            style: TextStyle(color: textLight, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (lastMessageTime != null)
                          Text(_formatLastSeen(lastMessageTime.toDate()), style: TextStyle(fontSize: 10, color: textLight)),
                        const SizedBox(height: 4),
                        Icon(Icons.chat_bubble_outline, color: primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return 'on ${DateFormat('MMM d').format(lastSeen)}';
  }
}






//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:student_register_app/screens/chart/student_chat_screen.dart';
// import '../../models/admin/admin_model.dart';
//
// class ChatStudentListScreen extends StatefulWidget {
//   final AdminModel currentAdmin;
//   const ChatStudentListScreen({super.key, required this.currentAdmin});
//
//   @override
//   State<ChatStudentListScreen> createState() => _ChatStudentListScreenState();
// }
//
// class _ChatStudentListScreenState extends State<ChatStudentListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _isSearching = false;
//   String _searchQuery = '';
//   List<DocumentSnapshot> _allStudents = [];
//   List<DocumentSnapshot> _filteredStudents = [];
//
//   static const String TAG = 'CHAT_LIST';
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('[$TAG] Screen initialized');
//     debugPrint('[$TAG] Current admin: ${widget.currentAdmin.fullName}');
//   }
//
//   void _filterStudents(String query) {
//     debugPrint('[$TAG] Search query: $query');
//
//     setState(() {
//       _searchQuery = query.toLowerCase();
//
//       if (_searchQuery.isEmpty) {
//         _filteredStudents = List.from(_allStudents);
//         debugPrint('[$TAG] Reset filter, total: ${_filteredStudents.length}');
//       } else {
//         _filteredStudents = _allStudents.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final fullName =
//           '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
//               .toLowerCase();
//           final studentId =
//           (data['studentId'] ?? '').toString().toLowerCase();
//
//           return fullName.contains(_searchQuery) ||
//               studentId.contains(_searchQuery);
//         }).toList();
//
//         debugPrint('[$TAG] Filtered result: ${_filteredStudents.length}');
//       }
//     });
//   }
//
//   void _clearSearch() {
//     debugPrint('[$TAG] Clear search');
//     _searchController.clear();
//     _filterStudents('');
//     setState(() => _isSearching = false);
//   }
//
//   @override
//   void dispose() {
//     debugPrint('[$TAG] Dispose screen');
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint('[$TAG] Build UI');
//
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('students_joinName')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             debugPrint('[$TAG] Loading students...');
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.hasError) {
//             debugPrint('[$TAG] ERROR loading students');
//             return const Center(child: Text('Error loading students'));
//           }
//
//           _allStudents = snapshot.data!.docs;
//
//           debugPrint(
//               '[$TAG] Students loaded: ${_allStudents.length}');
//
//           if (_filteredStudents.isEmpty && _searchQuery.isEmpty) {
//             _filteredStudents = List.from(_allStudents);
//           }
//
//           if (_filteredStudents.isEmpty) {
//             debugPrint('[$TAG] No students found');
//             return const Center(child: Text('No students'));
//           }
//
//           return _buildStudentList();
//         },
//       ),
//     );
//   }
//
//   AppBar _buildAppBar() {
//     debugPrint('[$TAG] Build AppBar');
//
//     return AppBar(
//       title: _isSearching ? _buildSearchField() : const Text('Student Chats'),
//       actions: [
//         if (_isSearching)
//           TextButton(onPressed: _clearSearch, child: const Text('Cancel'))
//         else
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               debugPrint('[$TAG] Search icon pressed');
//               setState(() => _isSearching = true);
//             },
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSearchField() {
//     debugPrint('[$TAG] Build search field');
//
//     return TextField(
//       controller: _searchController,
//       autofocus: true,
//       decoration: const InputDecoration(
//         hintText: 'Search...',
//         border: InputBorder.none,
//       ),
//       onChanged: _filterStudents,
//     );
//   }
//
//   Widget _buildStudentList() {
//     debugPrint(
//         '[$TAG] Build student list: ${_filteredStudents.length}');
//
//     return ListView.builder(
//       itemCount: _filteredStudents.length,
//       itemBuilder: (context, index) {
//         final data =
//         _filteredStudents[index].data() as Map<String, dynamic>;
//
//         final studentId = data['studentId'] ?? '';
//         final fullName =
//             '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
//         final photoUrl = data['photoUrl'] ?? '';
//
//         debugPrint('[$TAG] Item[$index] studentId=$studentId');
//
//         return StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chats')
//               .doc(studentId)
//               .collection('messages')
//               .orderBy('time', descending: true)
//               .limit(1)
//               .snapshots(),
//           builder: (context, snapshot) {
//             String lastMessage = 'No messages';
//             Timestamp? lastTime;
//
//             if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//               final msg =
//               snapshot.data!.docs.first.data() as Map<String, dynamic>;
//
//               lastMessage = msg['text'] ?? '';
//               lastTime = msg['time'];
//
//               debugPrint(
//                   '[$TAG] Last message for $studentId: $lastMessage');
//             }
//
//             return ListTile(
//               title: Text(fullName),
//               subtitle: Text(
//                 lastMessage,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               trailing: lastTime != null
//                   ? Text(_formatTime(lastTime.toDate()))
//                   : null,
//               onTap: () {
//                 debugPrint(
//                     '[$TAG] Open chat → studentId=$studentId');
//
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AdminChatScreen(
//                       studentId: studentId,
//                       studentFullName: fullName,
//                       studentPhotoUrl: photoUrl,
//                       currentAdmin: widget.currentAdmin,
//                       fullName:
//                       widget.currentAdmin.fullName ?? '',
//                       photoUrl:
//                       widget.currentAdmin.photoUrl ?? '',
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   String _formatTime(DateTime time) {
//     final diff = DateTime.now().difference(time);
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//     if (diff.inHours < 24) return '${diff.inHours}h';
//     return DateFormat('MMM d').format(time);
//   }
// }
