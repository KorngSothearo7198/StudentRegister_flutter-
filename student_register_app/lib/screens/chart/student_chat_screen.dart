// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../models/admin/admin_model.dart';
//
// // ===== Cloudinary Service =====
// class CloudinaryService {
//   static const String cloudName = 'dxqkcp1hu';
//   static const String unsignedPreset = 'chart_file';
//
//   static Future<String?> uploadImage({
//     Uint8List? webImage,
//     String? filePath,
//     String folder = 'chat_images',
//   }) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
//     );
//
//     final request = http.MultipartRequest("POST", uri)
//       ..fields['upload_preset'] = unsignedPreset
//       ..fields['folder'] = folder;
//
//     if (kIsWeb && webImage != null) {
//       request.files.add(
//         http.MultipartFile.fromBytes('file', webImage, filename: 'image.jpg'),
//       );
//     } else if (filePath != null) {
//       request.files.add(await http.MultipartFile.fromPath('file', filePath));
//     }
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//     final data = json.decode(body);
//
//     if (response.statusCode == 200) {
//       return data['secure_url'];
//     } else {
//       throw Exception(data['error']['message']);
//     }
//   }
// }
//
// // ===== Image Preview Screen =====
// class ImagePreviewScreen extends StatelessWidget {
//   final List<String> images;
//   final int initialIndex;
//
//   const ImagePreviewScreen({
//     super.key,
//     required this.images,
//     this.initialIndex = 0,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     PageController pageController = PageController(initialPage: initialIndex);
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: pageController,
//             itemCount: images.length,
//             itemBuilder: (context, index) {
//               return InteractiveViewer(
//                 child: Center(
//                   child: Image.network(
//                     images[index],
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 16,
//             left: 16,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ===== Admin Chat Screen =====
// class AdminChatScreen extends StatefulWidget {
//   final String studentId;
//   final String studentFullName;
//   final String studentPhotoUrl;
//   final AdminModel? currentAdmin;
//
//   const AdminChatScreen({
//     super.key,
//     required this.studentId,
//     required this.studentFullName,
//     required this.studentPhotoUrl,
//     required this.currentAdmin,
//     required String photoUrl,
//     required String fullName,
//   });
//
//   @override
//   State<AdminChatScreen> createState() => _AdminChatScreenState();
// }
//
// class _AdminChatScreenState extends State<AdminChatScreen> {
//   final TextEditingController _messageCtrl = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ScrollController _scrollController = ScrollController();
//   bool _isSending = false;
//   final FocusNode _focusNode = FocusNode();
//
//   // Modern design colors
//   static const Color primaryColor = Color(0xFF0066FF);
//   static const Color secondaryColor = Color(0xFF8B5CF6);
//   static const Color backgroundColor = Color(0xFFF8FAFF);
//   static const Color cardColor = Colors.white;
//   static const Color studentMessageColor = Color(0xFFF0F4F8);
//   static const Color teacherMessageColor = Color(0xFF0066FF);
//   static const Color textPrimary = Color(0xFF1A1A2E);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color onlineStatus = Color(0xFF4ADE80);
//   static const Color inputBorder = Color(0xFFE5E7EB);
//   static const Color shadowColor = Color(0x0D000000);
//   static const Color fileAttachmentColor = Color(0xFFE8F4FF);
//
//   @override
//   void dispose() {
//     _messageCtrl.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   Widget _buildMessageBubble(DocumentSnapshot msg) {
//     final Map<String, dynamic> data = msg.data() as Map<String, dynamic>? ?? {};
//     final isTeacher = data['sender'] == 'teacher';
//     final text = data['text']?.toString() ?? '';
//
//     // Get image URL
//     String? imageUrl;
//     if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
//       imageUrl = data['imageUrl'].toString();
//     } else if (data['attachments'] != null && data['attachments'] is List) {
//       final attachments = data['attachments'] as List;
//       if (attachments.isNotEmpty) {
//         final firstAttachment = attachments[0] as Map<String, dynamic>;
//         if (firstAttachment['type'] == 'image') {
//           imageUrl = firstAttachment['url']?.toString();
//         }
//       }
//     }
//
//     final timestamp = data['time'] as Timestamp?;
//     final time = timestamp != null
//         ? DateFormat('hh:mm a').format(timestamp.toDate())
//         : '';
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Row(
//         mainAxisAlignment:
//         isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isTeacher)
//             Container(
//               width: 36,
//               height: 36,
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: inputBorder, width: 1),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: Colors.transparent,
//                 backgroundImage: widget.studentPhotoUrl.isNotEmpty
//                     ? NetworkImage(widget.studentPhotoUrl)
//                     : null,
//                 child: widget.studentPhotoUrl.isEmpty
//                     ? Text(
//                   widget.studentFullName[0].toUpperCase(),
//                   style: const TextStyle(
//                     color: textPrimary,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 )
//                     : null,
//               ),
//             ),
//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//               isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isTeacher ? teacherMessageColor : studentMessageColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: shadowColor,
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ===== Show images =====
//                       if (imageUrl != null)
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ImagePreviewScreen(
//                                   images: [imageUrl!],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 imageUrl!,
//                                 width: 200,
//                                 height: 200,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                       // ===== Show text =====
//                       if (text.isNotEmpty)
//                         Container(
//                           margin: EdgeInsets.only(
//                               top: imageUrl != null ? 8 : 0),
//                           child: Text(
//                             text,
//                             style: TextStyle(
//                               color: isTeacher ? Colors.white : textPrimary,
//                               fontSize: 15,
//                               height: 1.4,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   time,
//                   style: TextStyle(
//                     color: textSecondary,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isTeacher)
//             Container(
//               width: 36,
//               height: 36,
//               margin: const EdgeInsets.only(left: 8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: inputBorder, width: 1),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: Colors.transparent,
//                 backgroundImage: (widget.currentAdmin!.profileImage ?? '')
//                     .isNotEmpty
//                     ? NetworkImage(widget.currentAdmin!.profileImage!)
//                     : null,
//                 child: (widget.currentAdmin!.profileImage ?? '').isEmpty
//                     ? Text(
//                   widget.currentAdmin!.fullName?[0] ?? 'A',
//                   style: const TextStyle(
//                     color: textPrimary,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 )
//                     : null,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ===== Send Text Message =====
//   void _sendMessage() async {
//     final text = _messageCtrl.text.trim();
//     if (text.isEmpty || widget.studentId.isEmpty) return;
//
//     setState(() => _isSending = true);
//
//     try {
//       await _firestore
//           .collection('chats')
//           .doc(widget.studentId)
//           .collection('messages')
//           .add({
//         'text': text,
//         'sender': 'teacher',
//         'senderId': widget.currentAdmin!.uid,
//         'time': FieldValue.serverTimestamp(),
//       });
//
//       _messageCtrl.clear();
//       _focusNode.unfocus();
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.animateTo(
//             0,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to send message: ${e.toString()}'),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.only(
//             bottom: 80,
//             left: 16,
//             right: 16,
//           ),
//         ),
//       );
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }
//
//   // ===== Upload Image =====
//   void _uploadImage({Uint8List? bytes, String? filePath}) async {
//     setState(() => _isSending = true);
//
//     try {
//       final url = await CloudinaryService.uploadImage(
//         webImage: bytes,
//         filePath: filePath,
//         folder: 'chat_images',
//       );
//
//       if (url != null) {
//         await _firestore
//             .collection('chats')
//             .doc(widget.studentId)
//             .collection('messages')
//             .add({
//           'text': '',
//           'imageUrl': url,
//           'sender': 'teacher',
//           'senderId': widget.currentAdmin!.uid,
//           'time': FieldValue.serverTimestamp(),
//         });
//
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.animateTo(
//               0,
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//             );
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to upload image: ${e.toString()}'),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.only(
//             bottom: 80,
//             left: 16,
//             right: 16,
//           ),
//         ),
//       );
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }
//
//   // ===== Messages List =====
//   Widget _buildMessagesList() {
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               backgroundColor.withOpacity(0.95),
//               backgroundColor.withOpacity(0.85),
//             ],
//           ),
//         ),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: _firestore
//               .collection('chats')
//               .doc(widget.studentId)
//               .collection('messages')
//               .orderBy('time', descending: true)
//               .limit(50)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//                 ),
//               );
//             }
//
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.chat_bubble_outline,
//                       size: 64,
//                       color: textSecondary.withOpacity(0.3),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       "No messages yet",
//                       style: TextStyle(
//                         color: textSecondary,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Start the conversation with ${widget.studentFullName.split(' ')[0]}",
//                       style: TextStyle(
//                         color: textSecondary.withOpacity(0.7),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             final docs = snapshot.data!.docs;
//
//             return GestureDetector(
//               onTap: () {
//                 _focusNode.unfocus();
//               },
//               child: ListView.builder(
//                 controller: _scrollController,
//                 reverse: true,
//                 padding: const EdgeInsets.only(
//                   top: 16,
//                   bottom: 16,
//                   left: 8,
//                   right: 8,
//                 ),
//                 itemCount: docs.length,
//                 itemBuilder: (context, index) => _buildMessageBubble(docs[index]),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // ===== Input Section =====
//   Widget _buildInputSection() {
//     final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
//
//     return Container(
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 16,
//         top: 8,
//         bottom: keyboardBottom > 0
//             ? keyboardBottom + 8
//             : 16 + MediaQuery.of(context).padding.bottom,
//       ),
//       decoration: BoxDecoration(
//         color: cardColor,
//         border: Border(top: BorderSide(color: inputBorder, width: 1)),
//         boxShadow: [
//           BoxShadow(
//             color: shadowColor,
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // ===== Attachment Button =====
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: studentMessageColor,
//             ),
//             child: PopupMenuButton<String>(
//               icon: Icon(Icons.add, color: textSecondary, size: 24),
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'image',
//                   child: Row(
//                     children: [
//                       Icon(Icons.image, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Text('Image'),
//                     ],
//                   ),
//                 ),
//               ],
//               onSelected: (value) async {
//                 final ImagePicker picker = ImagePicker();
//                 XFile? pickedFile;
//                 if (kIsWeb) {
//                   pickedFile = await picker.pickImage(source: ImageSource.gallery);
//                   if (pickedFile != null) {
//                     final bytes = await pickedFile.readAsBytes();
//                     _uploadImage(bytes: bytes);
//                   }
//                 } else {
//                   pickedFile = await picker.pickImage(source: ImageSource.gallery);
//                   if (pickedFile != null) {
//                     _uploadImage(filePath: pickedFile.path);
//                   }
//                 }
//               },
//             ),
//           ),
//           const SizedBox(width: 12),
//
//           // ===== Text Field =====
//           Expanded(
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: studentMessageColor,
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(color: inputBorder, width: 1),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageCtrl,
//                       focusNode: _focusNode,
//                       maxLines: 5,
//                       minLines: 1,
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: (_) => _sendMessage(),
//                       style: const TextStyle(
//                         color: textPrimary,
//                         fontSize: 15,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: "Message ${widget.studentFullName.split(' ')[0]}...",
//                         hintStyle: TextStyle(
//                           color: textSecondary.withOpacity(0.6),
//                           fontSize: 15,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                         suffixIcon: _isSending
//                             ? Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                               AlwaysStoppedAnimation<Color>(primaryColor),
//                             ),
//                           ),
//                         )
//                             : null,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//
//           // ===== Send Button =====
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 colors: [primaryColor, secondaryColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.send_rounded,
//                 size: 22,
//                 color: Colors.white,
//               ),
//               onPressed: _messageCtrl.text.trim().isEmpty || _isSending
//                   ? null
//                   : _sendMessage,
//               padding: EdgeInsets.zero,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ===== AppBar =====
//   AppBar _buildAppBar() {
//     return AppBar(
//       backgroundColor: cardColor,
//       elevation: 0.5,
//       scrolledUnderElevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: inputBorder, width: 1.5),
//             ),
//             child: CircleAvatar(
//               backgroundColor: Colors.transparent,
//               backgroundImage: widget.studentPhotoUrl.isNotEmpty
//                   ? NetworkImage(widget.studentPhotoUrl)
//                   : null,
//               child: widget.studentPhotoUrl.isEmpty
//                   ? Text(
//                 widget.studentFullName[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: textPrimary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               )
//                   : null,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.studentFullName,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                     color: textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   "Student",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.info_outline, color: textSecondary),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.studentId.isEmpty) {
//       return Scaffold(
//         backgroundColor: backgroundColor,
//         body: Center(
//           child: Text(
//             "No student selected",
//             style: TextStyle(
//               color: textSecondary,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: _buildAppBar(),
//       body: GestureDetector(
//         onTap: () {
//           _focusNode.unfocus();
//         },
//         child: Column(
//           children: [
//             _buildMessagesList(),
//             _buildInputSection(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//




// import 'dart:typed_data';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../models/admin/admin_model.dart';
//
// // ===== Cloudinary Service =====
// class CloudinaryService {
//   static const String cloudName = 'dxqkcp1hu';
//   static const String unsignedPreset = 'chart_file';
//
//   static Future<String?> uploadImage({
//     Uint8List? webImage,
//     String? filePath,
//     String folder = 'chat_images',
//   }) async {
//     final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
//     final request = http.MultipartRequest("POST", uri)
//       ..fields['upload_preset'] = unsignedPreset
//       ..fields['folder'] = folder;
//
//     if (kIsWeb && webImage != null) {
//       request.files.add(http.MultipartFile.fromBytes('file', webImage, filename: 'image.jpg'));
//     } else if (filePath != null) {
//       request.files.add(await http.MultipartFile.fromPath('file', filePath));
//     }
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//     final data = json.decode(body);
//     if (response.statusCode == 200) return data['secure_url'];
//     throw Exception(data['error']['message']);
//   }
//
//   static Future<String?> uploadAudio(String path, {String folder = 'chat_audios'}) async {
//     final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/video/upload");
//     final request = http.MultipartRequest("POST", uri)
//       ..fields['upload_preset'] = unsignedPreset
//       ..fields['folder'] = folder
//       ..files.add(await http.MultipartFile.fromPath('file', path));
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//     final data = json.decode(body);
//     if (response.statusCode == 200) return data['secure_url'];
//     throw Exception(data['error']['message']);
//   }
// }
//
// // ===== Image Preview Screen =====
// class ImagePreviewScreen extends StatelessWidget {
//   final List<String> images;
//   final int initialIndex;
//
//   const ImagePreviewScreen({super.key, required this.images, this.initialIndex = 0});
//
//   @override
//   Widget build(BuildContext context) {
//     PageController pageController = PageController(initialPage: initialIndex);
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: pageController,
//             itemCount: images.length,
//             itemBuilder: (_, index) => InteractiveViewer(
//               child: Center(child: Image.network(images[index], fit: BoxFit.contain)),
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 16,
//             left: 16,
//             child: CircleAvatar(
//               backgroundColor: Colors.black54,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ===== Admin Chat Screen Modern with Voice & Date =====
// class AdminChatScreenModern extends StatefulWidget {
//   final String studentId;
//   final String studentFullName;
//   final String studentPhotoUrl;
//   final AdminModel? currentAdmin;
//
//   const AdminChatScreenModern({
//     super.key,
//     required this.studentId,
//     required this.studentFullName,
//     required this.studentPhotoUrl,
//     required this.currentAdmin,
//   });
//
//   @override
//   State<AdminChatScreenModern> createState() => _AdminChatScreenModernState();
// }
//
// class _AdminChatScreenModernState extends State<AdminChatScreenModern> {
//   final TextEditingController _messageCtrl = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();
//   bool _isSending = false;
//
//   // Voice recorder & player
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();
//   bool _isRecording = false;
//
//   // Colors
//   static const Color bgColor = Color(0xFFF8FAFF);
//   static const Color teacherBubble = Color(0xFF0066FF);
//   static const Color studentBubble = Color(0xFFF0F4F8);
//   static const Color textPrimary = Color(0xFF1A1A2E);
//   static const Color textSecondary = Color(0xFF6B7280);
//
//   @override
//   void initState() {
//     super.initState();
//     _recorder.openRecorder();
//     _player.openPlayer();
//   }
//
//   @override
//   void dispose() {
//     _messageCtrl.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     _recorder.closeRecorder();
//     _player.closePlayer();
//     super.dispose();
//   }
//
//   // ==== Format timestamp with date + time ====
//   String formatDateTime(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     final now = DateTime.now();
//
//     if (date.year == now.year && date.month == now.month && date.day == now.day) {
//       return DateFormat('hh:mm a').format(date); // Today → only time
//     } else {
//       return DateFormat('MMM dd, yyyy hh:mm a').format(date); // Older → date + time
//     }
//   }
//
//   // ==== Message Bubble ====
//   Widget _buildMessageBubble(DocumentSnapshot msg) {
//     final data = msg.data() as Map<String, dynamic>? ?? {};
//     final isTeacher = data['sender'] == 'teacher';
//     final text = data['text']?.toString() ?? '';
//     final timestamp = data['time'] as Timestamp?;
//     final time = timestamp != null ? formatDateTime(timestamp) : '';
//
//     // Collect all image URLs
//     List<String> imageUrls = [];
//     if (data['imageUrl'] != null) imageUrls.add(data['imageUrl']);
//
//     List attachments = data['attachments'] ?? [];
//     for (var att in attachments) {
//       if (att['type'] == 'image' && att['url'] != null) imageUrls.add(att['url']);
//     }
//
//     // Collect all audio URLs
//     List<String> audioUrls = [];
//     if (data['audioUrl'] != null) audioUrls.add(data['audioUrl']);
//     for (var att in attachments) {
//       if (att['type'] == 'voice' && att['url'] != null) audioUrls.add(att['url']);
//     }
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Row(
//         mainAxisAlignment: isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isTeacher)
//             CircleAvatar(
//               backgroundImage: widget.studentPhotoUrl.isNotEmpty ? NetworkImage(widget.studentPhotoUrl) : null,
//               radius: 18,
//               child: widget.studentPhotoUrl.isEmpty ? Text(widget.studentFullName[0].toUpperCase()) : null,
//             ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Column(
//               crossAxisAlignment: isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 // Show all images
//                 for (var img in imageUrls)
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => ImagePreviewScreen(images: [img])),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(img, width: 200, height: 200, fit: BoxFit.cover),
//                       ),
//                     ),
//                   ),
//
//                 // Show all voice messages
//                 for (var url in audioUrls)
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(_player.isPlaying ? Icons.stop : Icons.play_arrow),
//                         onPressed: () async {
//                           if (!_player.isPlaying) {
//                             await _player.startPlayer(
//                               fromURI: url,
//                               whenFinished: () => setState(() {}),
//                             );
//                           } else {
//                             await _player.stopPlayer();
//                           }
//                           setState(() {});
//                         },
//                       ),
//                       const Text("Voice message"),
//                     ],
//                   ),
//
//                 // Show text message
//                 if (text.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: EdgeInsets.only(top: imageUrls.isNotEmpty || audioUrls.isNotEmpty ? 8 : 0),
//                     decoration: BoxDecoration(
//                       color: isTeacher ? teacherBubble : studentBubble,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(text, style: TextStyle(color: isTeacher ? Colors.white : textPrimary)),
//                   ),
//
//                 const SizedBox(height: 4),
//                 Text(time, style: TextStyle(fontSize: 11, color: textSecondary)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           if (isTeacher)
//             CircleAvatar(
//               backgroundImage: widget.currentAdmin?.profileImage != null
//                   ? NetworkImage(widget.currentAdmin!.profileImage!)
//                   : null,
//               radius: 18,
//               child: (widget.currentAdmin?.profileImage ?? '').isEmpty
//                   ? Text(widget.currentAdmin?.fullName?[0] ?? 'A')
//                   : null,
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ==== Send Text Message ====
//   void _sendMessage() async {
//     final text = _messageCtrl.text.trim();
//     if (text.isEmpty || widget.studentId.isEmpty) return;
//     setState(() => _isSending = true);
//     try {
//       await _firestore.collection('chats').doc(widget.studentId).collection('messages').add({
//         'text': text,
//         'sender': 'teacher',
//         'senderId': widget.currentAdmin?.uid,
//         'time': FieldValue.serverTimestamp(),
//       });
//       _messageCtrl.clear();
//       _focusNode.unfocus();
//       _scrollToBottom();
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }
//
//   // ==== Upload Image ====
//   void _uploadImage({Uint8List? bytes, String? filePath}) async {
//     setState(() => _isSending = true);
//     try {
//       final url = await CloudinaryService.uploadImage(webImage: bytes, filePath: filePath);
//       if (url != null) {
//         await _firestore.collection('chats').doc(widget.studentId).collection('messages').add({
//           'text': '',
//           'imageUrl': url,
//           'sender': 'teacher',
//           'senderId': widget.currentAdmin?.uid,
//           'time': FieldValue.serverTimestamp(),
//         });
//         _scrollToBottom();
//       }
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }
//
//   // ==== Record Voice ====
//   void _recordVoice() async {
//     if (_isRecording) {
//       final path = await _recorder.stopRecorder();
//       setState(() => _isRecording = false);
//       if (path != null) {
//         final url = await CloudinaryService.uploadAudio(path);
//         if (url != null) {
//           await _firestore.collection('chats').doc(widget.studentId).collection('messages').add({
//             'text': '',
//             'audioUrl': url,
//             'sender': 'teacher',
//             'senderId': widget.currentAdmin?.uid,
//             'time': FieldValue.serverTimestamp(),
//           });
//           _scrollToBottom();
//         }
//       }
//     } else {
//       final tempDir = await getTemporaryDirectory();
//       final filePath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
//       await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
//       setState(() => _isRecording = true);
//     }
//   }
//
//   // ==== Scroll to bottom ====
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.minScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   // ==== Input Section ====
//   Widget _buildInputSection() {
//     return Container(
//       padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 8),
//       color: bgColor,
//       child: Row(
//         children: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.add),
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                   value: 'image',
//                   child: Row(children: [Icon(Icons.image), SizedBox(width: 8), Text('Image')])),
//
//             ],
//             onSelected: (v) async {
//               final picker = ImagePicker();
//               XFile? file = await picker.pickImage(source: ImageSource.gallery);
//               if (file != null) {
//                 if (kIsWeb) {
//                   final bytes = await file.readAsBytes();
//                   _uploadImage(bytes: bytes);
//                 } else {
//                   _uploadImage(filePath: file.path);
//                 }
//               }
//             },
//           ),
//           IconButton(
//             icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.red : Colors.black),
//             onPressed: _recordVoice,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: _messageCtrl,
//               focusNode: _focusNode,
//               textInputAction: TextInputAction.send,
//               onSubmitted: (_) => _sendMessage(),
//               decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: _isSending || _messageCtrl.text.trim().isEmpty ? null : _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==== Messages List ====
//   Widget _buildMessagesList() {
//     return Expanded(
//       child: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('chats').doc(widget.studentId).collection('messages').orderBy('time', descending: true).snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) return Center(child: Text("No messages yet", style: TextStyle(color: textSecondary)));
//           return ListView.builder(
//             controller: _scrollController,
//             reverse: true,
//             padding: const EdgeInsets.all(8),
//             itemCount: docs.length,
//             itemBuilder: (_, i) => _buildMessageBubble(docs[i]),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(64),
//         child: AppBar(
//           automaticallyImplyLeading: true,
//           elevation: 0.5,
//           backgroundColor: Colors.white,
//           titleSpacing: 0,
//           title: Row(
//             children: [
//               const SizedBox(width: 8),
//
//               /// Student Avatar
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Colors.grey.shade200,
//                 backgroundImage: widget.studentPhotoUrl.isNotEmpty
//                     ? NetworkImage(widget.studentPhotoUrl)
//                     : null,
//                 child: widget.studentPhotoUrl.isEmpty
//                     ? Text(
//                   widget.studentFullName[0].toUpperCase(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 )
//                     : null,
//               ),
//
//               const SizedBox(width: 12),
//
//               /// Student Name + Status
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     widget.studentFullName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                 ],
//               ),
//             ],
//           ),
//
//         ),
//       ),
//
//       /// ================= BODY =================
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// Messages
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFFF8FAFF),
//                       Color(0xFFFFFFFF),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: _buildMessagesList(),
//               ),
//             ),
//
//             /// Divider like Messenger
//             Container(
//               height: 1,
//               color: Colors.grey.shade300,
//             ),
//
//             /// Input Section
//             _buildInputSection(),
//           ],
//         ),
//       ),
//     );
//   }


// @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: bgColor,
  //     appBar: AppBar(
  //       backgroundColor: bgColor,
  //       elevation: 1,
  //       title: Row(
  //         children: [
  //           CircleAvatar(
  //             backgroundImage: widget.studentPhotoUrl.isNotEmpty ? NetworkImage(widget.studentPhotoUrl) : null,
  //             child: widget.studentPhotoUrl.isEmpty ? Text(widget.studentFullName[0].toUpperCase()) : null,
  //           ),
  //           const SizedBox(width: 12),
  //           Text(widget.studentFullName, style: const TextStyle(color: textPrimary)),
  //         ],
  //       ),
  //     ),
  //     body: Column(
  //       children: [
  //         _buildMessagesList(),
  //         _buildInputSection(),
  //       ],
  //     ),
  //   );
  // }
// }


import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/admin/admin_model.dart';

// ================= CLOUDINARY SERVICE =================
class CloudinaryService {
  static const String cloudName = 'dxqkcp1hu';
  static const String unsignedPreset = 'chart_file';

  static Future<String?> uploadImage({
    Uint8List? webImage,
    String? filePath,
    String folder = 'chat_images',
  }) async {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = unsignedPreset
      ..fields['folder'] = folder;

    if (kIsWeb && webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('file', webImage, filename: 'image.jpg'));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = json.decode(body);
    if (response.statusCode == 200) return data['secure_url'];
    throw Exception(data['error']['message']);
  }

  static Future<String?> uploadAudio(String path, {String folder = 'chat_audios'}) async {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/video/upload");
    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = unsignedPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = json.decode(body);
    if (response.statusCode == 200) return data['secure_url'];
    throw Exception(data['error']['message']);
  }
}

// ================= IMAGE PREVIEW SCREEN =================
class ImagePreviewScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImagePreviewScreen({super.key, required this.images, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: images.length,
            itemBuilder: (_, index) => InteractiveViewer(
              child: Center(child: Image.network(images[index], fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= ADMIN CHAT SCREEN MODERN =================
class AdminChatScreenModern extends StatefulWidget {
  final String studentId;
  final String studentFullName;
  final String studentPhotoUrl;
  final AdminModel? currentAdmin;

  const AdminChatScreenModern({
    super.key,
    required this.studentId,
    required this.studentFullName,
    required this.studentPhotoUrl,
    required this.currentAdmin,
  });

  @override
  State<AdminChatScreenModern> createState() => _AdminChatScreenModernState();
}

class _AdminChatScreenModernState extends State<AdminChatScreenModern> {
  final TextEditingController _messageCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  // Voice recorder & player
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;

  // Colors
  static const Color bgColor = Color(0xFFF8FAFF);
  static const Color teacherBubble = Color(0xFF0066FF);
  static const Color studentBubble = Color(0xFFF0F4F8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  // ==== Format timestamp with date + time ====
  String formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('hh:mm a').format(date); // Today → only time
    } else {
      return DateFormat('MMM dd, yyyy hh:mm a').format(date); // Older → date + time
    }
  }

  // ==== Format duration for voice message ====
  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ==== Message Bubble ====
  Widget _buildMessageBubble(DocumentSnapshot msg) {
    final data = msg.data() as Map<String, dynamic>? ?? {};
    final isTeacher = data['sender'] == 'teacher';
    final text = data['text']?.toString() ?? '';
    final timestamp = data['time'] as Timestamp?;
    final time = timestamp != null ? formatDateTime(timestamp) : '';

    List<String> imageUrls = [];
    if (data['imageUrl'] != null) imageUrls.add(data['imageUrl']);

    List attachments = data['attachments'] ?? [];

    // Collect all audio URLs
    List<Map<String, dynamic>> voiceAttachments = [];
    if (data['audioUrl'] != null) voiceAttachments.add({'url': data['audioUrl'], 'duration': data['duration'] ?? 0});
    for (var att in attachments) {
      if (att['type'] == 'voice' && att['url'] != null) voiceAttachments.add(att);
      if (att['type'] == 'image' && att['url'] != null) imageUrls.add(att['url']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isTeacher)
            CircleAvatar(
              backgroundImage: widget.studentPhotoUrl.isNotEmpty ? NetworkImage(widget.studentPhotoUrl) : null,
              radius: 18,
              child: widget.studentPhotoUrl.isEmpty ? Text(widget.studentFullName[0].toUpperCase()) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Images
                for (var img in imageUrls)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ImagePreviewScreen(images: [img])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(img, width: 200, height: 200, fit: BoxFit.cover),
                      ),
                    ),
                  ),

                // Voice messages with duration
                for (var att in voiceAttachments)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_player.isPlaying ? Icons.stop : Icons.play_arrow),
                        onPressed: () async {
                          if (!_player.isPlaying) {
                            await _player.startPlayer(
                              fromURI: att['url'],
                              whenFinished: () => setState(() {}),
                            );
                          } else {
                            await _player.stopPlayer();
                          }
                          setState(() {});
                        },
                      ),
                      if (att['duration'] != null)
                        Text(
                          _formatDuration(att['duration']),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                    ],
                  ),

                // Text
                if (text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: imageUrls.isNotEmpty || voiceAttachments.isNotEmpty ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isTeacher ? teacherBubble : studentBubble,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(text, style: TextStyle(color: isTeacher ? Colors.white : textPrimary)),
                  ),

                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isTeacher)
            CircleAvatar(
              backgroundImage: widget.currentAdmin?.profileImage != null ? NetworkImage(widget.currentAdmin!.profileImage!) : null,
              radius: 18,
              child: (widget.currentAdmin?.profileImage ?? '').isEmpty ? Text(widget.currentAdmin?.fullName?[0] ?? 'A') : null,
            ),
        ],
      ),
    );
  }

  // ==== Send Text Message ====
  void _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || widget.studentId.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await _firestore.collection('chats').doc(widget.studentId).collection('messages').add({
        'text': text,
        'sender': 'teacher',
        'senderId': widget.currentAdmin?.uid,
        'time': FieldValue.serverTimestamp(),
      });
      _messageCtrl.clear();
      _focusNode.unfocus();
      _scrollToBottom();
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ==== Upload Image ====
  void _uploadImage({Uint8List? bytes, String? filePath}) async {
    setState(() => _isSending = true);
    try {
      final url = await CloudinaryService.uploadImage(webImage: bytes, filePath: filePath);
      if (url != null) {
        await _firestore.collection('chats').doc(widget.studentId).collection('messages').add({
          'text': '',
          'imageUrl': url,
          'sender': 'teacher',
          'senderId': widget.currentAdmin?.uid,
          'time': FieldValue.serverTimestamp(),
        });
        _scrollToBottom();
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ==== Record Voice ====
  void _recordVoice() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() => _isRecording = false);

      if (path != null) {
        // Use just_audio to get duration
        final player = AudioPlayer();
        try {
          await player.setFilePath(path);
          final duration = player.duration; // Duration of audio
          await player.dispose();

          final url = await CloudinaryService.uploadAudio(path);
          if (url != null) {
            await _firestore
                .collection('chats')
                .doc(widget.studentId)
                .collection('messages')
                .add({
              'text': '',
              'attachments': [
                {
                  'type': 'voice',
                  'url': url,
                  'duration': duration?.inSeconds ?? 0,
                }
              ],
              'sender': 'teacher',
              'senderId': widget.currentAdmin?.uid,
              'time': FieldValue.serverTimestamp(),
            });
            _scrollToBottom();
          }
        } catch (e) {
          print("Error getting audio duration: $e");
        }
      }
    } else {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
      setState(() => _isRecording = true);
    }
  }


  // ==== Scroll to bottom ====
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ==== Input Section ====
  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 8),
      color: bgColor,
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.image),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'image',
                  child: Row(children: [Icon(Icons.image), SizedBox(width: 8), Text('Image')]))
            ],
            onSelected: (v) async {
              final picker = ImagePicker();
              XFile? file = await picker.pickImage(source: ImageSource.gallery);
              if (file != null) {
                if (kIsWeb) {
                  final bytes = await file.readAsBytes();
                  _uploadImage(bytes: bytes);
                } else {
                  _uploadImage(filePath: file.path);
                }
              }
            },
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.red : Colors.black),
            onPressed: _recordVoice,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isSending || _messageCtrl.text.trim().isEmpty ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  // ==== Messages List ====
  Widget _buildMessagesList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chats').doc(widget.studentId).collection('messages').orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("No messages yet", style: TextStyle(color: textSecondary)));
          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (_, i) => _buildMessageBubble(docs[i]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: widget.studentPhotoUrl.isNotEmpty ? NetworkImage(widget.studentPhotoUrl) : null,
              child: widget.studentPhotoUrl.isEmpty ? Text(widget.studentFullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.studentFullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            const Divider(height: 1, color: Colors.grey),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }
}











