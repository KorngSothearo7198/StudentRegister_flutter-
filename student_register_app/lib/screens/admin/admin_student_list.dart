// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:student_register_app/models/admin/admin_model.dart';
// import 'package:student_register_app/screens/admin/login_screen.dart';
// import 'package:student_register_app/screens/chart/chat_student_list_screen.dart';
// import '../../models/student_model.dart';
// import '../../widgets/student_card.dart';
// import 'admin_student_detail.dart';
//
// class AdminStudentListScreen extends StatefulWidget {
//   const AdminStudentListScreen({super.key });
//
//   @override
//   State<AdminStudentListScreen> createState() => _AdminStudentListScreenState();
// }
//
// class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
//   List<Student> _allStudents = [];
//   List<Student> _filtered = [];
//   bool _loading = false;
//   final TextEditingController _searchCtrl = TextEditingController();
//   String _selectedFilter = 'All';
//   final List<String> _filters = ['All', 'Approved', 'Pending', 'Rejected'];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadStudents();
//     _searchCtrl.addListener(_filter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadStudents() async {
//     setState(() => _loading = true);
//
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('students_joinName')
//           .get();
//
//       if (snapshot.docs.isEmpty) {
//         _allStudents = [];
//         _filtered = [];
//       } else {
//         _allStudents = snapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return Student(
//             id: int.tryParse(doc.id.hashCode.toString()) ?? 0,
//             firstName: data['firstName'] ?? '',
//             lastName: data['lastName'] ?? '',
//             gender: data['gender'] ?? '',
//             status: data['status'] ?? 'Pending',
//             major: data['major'] ?? '',
//             year: data['Years'] ?? '',
//             nationality: data['nationality'] ?? '',
//             dateOfBirth: data['dateOfBirth'] ?? '',
//             degree: data['degree'] ?? '',
//             shift: data['shift'] ?? '',
//             village: data['village'] ?? '',
//             commune: data['commune'] ?? '',
//             district: data['district'] ?? '',
//             province: data['province'] ?? '',
//             studentId: data['studentId'] ?? '',
//             password: data['password'] ?? '',
//             photoUrl: data['photoUrl'] ?? '', // <-- Add this photoUrl
//           );
//         }).toList();
//
//         _filtered = List.from(_allStudents);
//       }
//     } catch (e) {
//       print("Error loading students: $e");
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _filter() {
//     final query = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       _filtered = _allStudents.where((s) {
//         if (_selectedFilter != 'All' && s.status != _selectedFilter) {
//           return false;
//         }
//         final fullName = '${s.firstName} ${s.lastName}'.toLowerCase();
//         final id = s.studentId?.toLowerCase() ?? '';
//         final major = s.major?.toLowerCase() ?? '';
//         return fullName.contains(query) ||
//             id.contains(query) ||
//             major.contains(query);
//       }).toList();
//     });
//   }
//
//   void _refreshUI(Student updatedStudent) {
//     final index = _allStudents.indexWhere((s) => s.id == updatedStudent.id);
//     if (index != -1) {
//       setState(() {
//         _allStudents[index] = updatedStudent;
//         _filter();
//       });
//     }
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchCtrl,
//         decoration: InputDecoration(
//           hintText: 'Search by name, ID, or major...',
//           hintStyle: TextStyle(color: Colors.grey[500]),
//           prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
//           suffixIcon: _searchCtrl.text.isNotEmpty
//               ? IconButton(
//                   icon: Icon(Icons.clear_rounded, color: Colors.grey[600]),
//                   onPressed: () {
//                     _searchCtrl.clear();
//                     _filter();
//                     FocusScope.of(context).unfocus();
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: _filters.map((filter) {
//           final count = filter == 'All'
//               ? _allStudents.length
//               : _allStudents.where((s) => s.status == filter).length;
//
//           final isSelected = _selectedFilter == filter;
//           final color = _getFilterColor(filter);
//
//           return Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: FilterChip.elevated(
//               label: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(filter),
//                   const SizedBox(width: 6),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.white : color.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       count.toString(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: isSelected ? color : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               selected: isSelected,
//               onSelected: (_) {
//                 setState(() {
//                   _selectedFilter = filter;
//                   _filter();
//                 });
//               },
//               backgroundColor: Colors.white,
//               selectedColor: color,
//               checkmarkColor: Colors.white,
//               elevation: 2,
//               side: BorderSide(
//                 color: isSelected ? color : Colors.grey[300]!,
//                 width: isSelected ? 0 : 1,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard() {
//     final approved = _allStudents.where((s) => s.status == 'Approved').length;
//     final pending = _allStudents.where((s) => s.status == 'Pending').length;
//     final rejected = _allStudents.where((s) => s.status == 'Rejected').length;
//
//     return Container();
//   }
//
//   Widget _buildStudentList() {
//     if (_loading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(
//               color: Color(0xFF0066CC),
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Loading Students...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_filtered.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             Text(
//               _searchCtrl.text.isEmpty
//                   ? 'No students found'
//                   : 'No students match your search',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[400],
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _searchCtrl.text.isEmpty
//                   ? 'Add some students to get started'
//                   : 'Try a different search term',
//               style: TextStyle(fontSize: 14, color: Colors.grey[400]),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _loadStudents,
//       color: const Color(0xFF0066CC),
//       child: _filtered.isEmpty
//           ? Center(
//               child: Text(
//                 'No students found',
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//               itemCount: _filtered.length,
//               itemBuilder: (ctx, i) {
//                 final student = _filtered[i];
//
//                 // Determine color based on status
//                 Color statusColor;
//                 switch (student.status) {
//                   case 'Approved':
//                     statusColor = Colors.green;
//                     break;
//                   case 'Pending':
//                     statusColor = Colors.orange;
//                     break;
//                   case 'Rejected':
//                     statusColor = Colors.red;
//                     break;
//                   default:
//                     statusColor = Colors.grey;
//                 }
//
//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     leading: student.photoUrl.isNotEmpty
//                         ? ClipOval(
//                             child: Image.network(
//                               student.photoUrl,
//                               width: 60,
//                               height: 60,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFF0066CC), Color(0xFF004499)],
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "${student.firstName[0]}${student.lastName[0]}"
//                                     .toUpperCase(),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                     title: Text("${student.firstName} ${student.lastName}"),
//                     subtitle: Text(
//                       '${student.major ?? ''} • ${student.dateOfBirth ?? ''} . ${student.createdAt ?? ''}',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//
//                     trailing: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         student.status,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () async {
//                       final updatedStudent = await Navigator.push<Student>(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AdminStudentDetailScreen(
//                             student: student,
//                             photoUrl: student.photoUrl,
//                           ),
//                         ),
//                       );
//
//                       if (updatedStudent != null) _refreshUI(updatedStudent);
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
//
//   Color _getFilterColor(String filter) {
//     switch (filter) {
//       case 'Approved':
//         return Colors.green;
//       case 'Pending':
//         return Colors.orange;
//       case 'Rejected':
//         return Colors.red;
//       default:
//         return const Color(0xFF0066CC);
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFD),
//
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: const Color(0xFF0066CC),
//         icon: const Icon(Icons.chat),
//         label: const Text('Chat'),
//         onPressed: _openChatWithStudent,
//       ),
//
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           const SizedBox(height: 8),
//           _buildFilterChips(),
//           const SizedBox(height: 8),
//           _buildSummaryCard(),
//           const SizedBox(height: 12),
//           Expanded(child: _buildStudentList()),
//         ],
//       ),
//     );
//   }
//
//  void _openChatWithStudent() {
//   final user = FirebaseAuth.instance.currentUser;
//
//   if (user == null) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => LoginScreen()), // OK
//     );
//   } else {
//     // DO NOT pass null
//     // Fetch admin from Firestore first
//     FirebaseFirestore.instance
//         .collection('admins')
//         .doc(user.uid)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         final admin = AdminModel.fromFirestore(doc);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ChatStudentListScreen(currentAdmin: admin),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Admin data not found')),
//         );
//       }
//     });
//   }
// }
//
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_register_app/models/admin/admin_model.dart';
import 'package:student_register_app/screens/admin/login_screen.dart';
import 'package:student_register_app/screens/chart/chat_student_list_screen.dart';
import '../../models/student_model.dart';
import '../../widgets/student_card.dart';
import 'admin_student_detail.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

  @override
  State<AdminStudentListScreen> createState() => _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
  List<Student> _allStudents = [];
  List<Student> _filtered = [];
  bool _loading = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Approved', 'Pending', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('students_joinName')
          .get();

      if (snapshot.docs.isEmpty) {
        _allStudents = [];
        _filtered = [];
      } else {
        _allStudents = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Student(
            id: int.tryParse(doc.id.hashCode.toString()) ?? 0,
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            gender: data['gender'] ?? '',
            status: data['status'] ?? 'Pending',
            major: data['major'] ?? '',
            year: data['year'] ?? '',
            nationality: data['nationality'] ?? '',
            dateOfBirth: data['dateOfBirth'] ?? '',
            degree: data['degree'] ?? '',
            shift: data['shift'] ?? '',
            village: data['village'] ?? '',
            commune: data['commune'] ?? '',
            district: data['district'] ?? '',
            province: data['province'] ?? '',
            studentId: data['studentId'] ?? '',
            password: data['password'] ?? '',
            photoUrl: data['photoUrl'] ?? '',
            photoUrls: List<String>.from(data['photoUrls'] ?? []),
            idCardImageUrl: data['idCardImageUrl'] ?? '',
            degreeDocumentUrl: data['degreeDocumentUrl'] ?? '',
            fatherName: data['fatherName'] ?? '',
            motherName: data['motherName'] ?? '',
            guardianPhone: data['guardianPhone'] ?? '',
            phone: data['phone'] ?? '',
            telegram: data['telegram'] ?? '',
            idCardNumber: data['idCardNumber'] ?? '',
            educationLevel: data['educationLevel'] ?? '',
            programType: data['programType'] ?? '',
            careerType: data['careerType'] ?? '',
            bacYear: data['bacYear'] ?? '',
            highSchoolName: data['highSchoolName'] ?? '',
            highSchoolLocation: data['highSchoolLocation'] ?? '',
            // country: data['country'] ?? '',
            // registrationDate: data['registrationDate'] != null
            //     ? (data['registrationDate'] as Timestamp).toDate()
            //     : null,
          );
        }).toList();

        _filtered = List.from(_allStudents);
      }
    } catch (e) {
      print("Error loading students: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _allStudents.where((s) {
        if (_selectedFilter != 'All' && s.status != _selectedFilter) {
          return false;
        }
        final fullName = '${s.firstName} ${s.lastName}'.toLowerCase();
        final id = s.studentId?.toLowerCase() ?? '';
        final major = s.major?.toLowerCase() ?? '';
        return fullName.contains(query) ||
            id.contains(query) ||
            major.contains(query);
      }).toList();
    });
  }

  void _refreshUI(Student updatedStudent) {
    final index = _allStudents.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      setState(() {
        _allStudents[index] = updatedStudent;
        _filter();
      });
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.04,
        screenWidth * 0.05,
        screenWidth * 0.03,
      ),
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
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search by name, ID, or major...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: screenWidth * 0.035,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey[600],
            size: screenWidth * 0.055,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey[600],
                    size: screenWidth * 0.055,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    _filter();
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
          contentPadding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.04,
            horizontal: screenWidth * 0.04,
          ),
        ),
        style: TextStyle(fontSize: screenWidth * 0.038),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        children: _filters.map((filter) {
          final count = filter == 'All'
              ? _allStudents.length
              : _allStudents.where((s) => s.status == filter).length;

          final isSelected = _selectedFilter == filter;
          final color = _getFilterColor(filter);

          return Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.025),
            child: FilterChip.elevated(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter, style: TextStyle(fontSize: screenWidth * 0.033)),
                  SizedBox(width: screenWidth * 0.015),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                  _filter();
                });
              },
              backgroundColor: Colors.white,
              selectedColor: color,
              checkmarkColor: Colors.white,
              elevation: 2,
              side: BorderSide(
                color: isSelected ? color : Colors.grey[300]!,
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

  Widget _buildSummaryCard() {
    return Container();
  }

  Widget _buildStudentList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF0066CC),
              strokeWidth: 3,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Loading Students...',
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

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: screenWidth * 0.2,
              color: Colors.grey[300],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              _searchCtrl.text.isEmpty
                  ? 'No students found'
                  : 'No students match your search',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              _searchCtrl.text.isEmpty
                  ? 'Add some students to get started'
                  : 'Try a different search term',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      color: const Color(0xFF0066CC),
      child: _filtered.isEmpty
          ? Center(
              child: Text(
                'No students found',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05,
                0,
                screenWidth * 0.05,
                screenHeight * 0.02,
              ),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final student = _filtered[i];

                Color statusColor;
                switch (student.status) {
                  case 'Approved':
                    statusColor = Colors.green;
                    break;
                  case 'Pending':
                    statusColor = Colors.orange;
                    break;
                  case 'Rejected':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    leading: student.photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              student.photoUrl,
                              width: screenWidth * 0.16,
                              height: screenWidth * 0.16,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: screenWidth * 0.16,
                            height: screenWidth * 0.16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0066CC), Color(0xFF004499)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "${student.firstName[0]}${student.lastName[0]}"
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ),
                    title: Text(
                      "${student.firstName} ${student.lastName}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          student.major ?? 'No major',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.003),
                        if (student.studentId?.isNotEmpty == true)
                          Text(
                            'ID: ${student.studentId}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        student.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.032,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final updatedStudent = await Navigator.push<Student>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminStudentDetailScreen(
                            student: student,
                            photoUrl: student.photoUrl,
                          ),
                        ),
                      );

                      if (updatedStudent != null) _refreshUI(updatedStudent);
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return const Color(0xFF0066CC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0066CC),
        icon: Icon(Icons.chat, size: screenWidth * 0.055),
        label: Text('Chat', style: TextStyle(fontSize: screenWidth * 0.038)),
        onPressed: _openChatWithStudent,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          SizedBox(height: screenHeight * 0.01),
          _buildFilterChips(context),
          SizedBox(height: screenHeight * 0.01),
          _buildSummaryCard(),
          SizedBox(height: screenHeight * 0.015),
          Expanded(child: _buildStudentList(context)),
        ],
      ),
    );
  }

  void _openChatWithStudent() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      FirebaseFirestore.instance.collection('admins').doc(user.uid).get().then((
        doc,
      ) {
        if (doc.exists) {
          final admin = AdminModel.fromFirestore(doc);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatStudentListScreen(currentAdmin: admin),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Admin data not found')));
        }
      });
    }
  }
}
