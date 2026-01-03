//
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../models/admin/admin_model.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// // ========== CLOUDINARY SERVICE (NO CHANGES) ==========
// class CloudinaryService {
//   static const String cloudName = "dxqkcp1hu";
//   static const String uploadPreset = "admins_profiles";
//
//   static String _generatePublicId() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final random = (timestamp % 10000).toString();
//     return 'admin_profile_${timestamp}_$random';
//   }
//
//   static Future<String?> uploadProfileImageWeb({
//     required Uint8List bytes,
//     required String fileName,
//     String? publicId,
//   }) async {
//     try {
//       final url = Uri.parse(
//         "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
//       );
//
//       final request = http.MultipartRequest("POST", url)
//         ..fields["upload_preset"] = uploadPreset;
//
//       final finalPublicId = publicId ?? _generatePublicId();
//       request.fields["public_id"] = finalPublicId;
//
//       request.files.add(
//         http.MultipartFile.fromBytes("file", bytes, filename: fileName),
//       );
//
//       debugPrint("Uploading with public_id: $finalPublicId");
//
//       final response = await request.send();
//       final responseString = await response.stream.bytesToString();
//       final jsonResponse = json.decode(responseString);
//
//       debugPrint("Cloudinary upload response: $responseString");
//
//       if (jsonResponse["secure_url"] != null) {
//         debugPrint("✅ Upload successful! URL: ${jsonResponse["secure_url"]}");
//         return jsonResponse["secure_url"];
//       } else {
//         debugPrint("❌ Upload failed: ${jsonResponse['error']?['message']}");
//         throw Exception("Upload failed: ${jsonResponse['error']?['message']}");
//       }
//     } catch (e) {
//       debugPrint("❌ Cloudinary upload error: $e");
//       rethrow;
//     }
//   }
//
//   static Future<String?> uploadProfileImageMobile({
//     required File imageFile,
//     String? publicId,
//   }) async {
//     try {
//       final url = Uri.parse(
//         "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
//       );
//
//       final request = http.MultipartRequest("POST", url)
//         ..fields["upload_preset"] = uploadPreset;
//
//       final finalPublicId = publicId ?? _generatePublicId();
//       request.fields["public_id"] = finalPublicId;
//
//       request.files.add(
//         await http.MultipartFile.fromPath("file", imageFile.path),
//       );
//
//       debugPrint("Uploading with public_id: $finalPublicId");
//
//       final response = await request.send();
//       final responseString = await response.stream.bytesToString();
//       final jsonResponse = json.decode(responseString);
//
//       debugPrint("Cloudinary upload response: $responseString");
//
//       if (jsonResponse["secure_url"] != null) {
//         debugPrint("✅ Upload successful! URL: ${jsonResponse["secure_url"]}");
//         return jsonResponse["secure_url"];
//       } else {
//         debugPrint("❌ Upload failed: ${jsonResponse['error']?['message']}");
//         throw Exception("Upload failed: ${jsonResponse['error']?['message']}");
//       }
//     } catch (e) {
//       debugPrint("❌ Cloudinary upload error: $e");
//       rethrow;
//     }
//   }
// }
//
// // ========== ADMIN DAO (NO CHANGES) ==========
// class AdminDao {
//   static final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   static Future<AdminModel?> getAdmin(String uid) async {
//     try {
//       debugPrint("=== getAdmin DEBUG ===");
//       debugPrint("Requested UID: '$uid'");
//
//       if (uid.isEmpty) {
//         debugPrint("❌ UID is empty. Returning null.");
//         return null;
//       }
//
//       final doc = await _db.collection('admins').doc(uid).get();
//       debugPrint("Document exists: ${doc.exists}");
//       debugPrint("Document ID: ${doc.id}");
//       debugPrint("Document data: ${doc.data()}");
//
//       if (!doc.exists) {
//         debugPrint("❌ Admin document not found. Returning null.");
//         return null;
//       }
//
//       final admin = AdminModel.fromFirestore(doc);
//       debugPrint("✅ Admin fetched successfully:");
//       debugPrint("Admin UID: ${admin.uid}");
//       debugPrint("Admin Name: ${admin.fullName}");
//       debugPrint("Admin Email: ${admin.email}");
//       debugPrint("Admin Profile Image: ${admin.profileImage}");
//       debugPrint("=== END getAdmin DEBUG ===");
//
//       return admin;
//     } catch (e) {
//       debugPrint("❌ Error getting admin: $e");
//       return null;
//     }
//   }
//
//   static Future<void> updateAdmin(AdminModel admin) async {
//     try {
//       debugPrint("=== UPDATE ADMIN DEBUG ===");
//       debugPrint("Admin UID to update: ${admin.uid}");
//       debugPrint("Admin UID length: ${admin.uid.length}");
//       debugPrint("Admin fullName: ${admin.fullName}");
//       debugPrint("Admin email: ${admin.email}");
//       debugPrint("Admin profileImage: ${admin.profileImage}");
//       debugPrint("=== END DEBUG ===");
//
//       if (admin.uid.isEmpty) {
//         throw Exception("Admin UID is empty. Current UID: '${admin.uid}'");
//       }
//
//       final adminData = admin.toMap();
//       debugPrint("Updating admin with UID: ${admin.uid}");
//       debugPrint("Admin data to update: $adminData");
//
//       await _db.collection('admins').doc(admin.uid).update(adminData);
//       debugPrint("✅ Admin updated successfully");
//     } catch (e) {
//       debugPrint("❌ Error updating admin: $e");
//       rethrow;
//     }
//   }
//
//   static Future<String?> uploadProfileImageToCloudinary({
//     File? file,
//     Uint8List? bytes,
//     String? fileName,
//     String? publicId,
//   }) async {
//     try {
//       final finalPublicId = publicId ?? CloudinaryService._generatePublicId();
//
//       if (kIsWeb) {
//         if (bytes == null) {
//           throw Exception("Bytes are required for web");
//         }
//         return await CloudinaryService.uploadProfileImageWeb(
//           bytes: bytes,
//           fileName:
//               fileName ??
//               'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           publicId: finalPublicId,
//         );
//       } else {
//         if (file == null) {
//           throw Exception("File is required for mobile/desktop");
//         }
//         return await CloudinaryService.uploadProfileImageMobile(
//           imageFile: file,
//           publicId: finalPublicId,
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ Upload error: $e");
//       rethrow;
//     }
//   }
//
//   static Future<String?> pickAndUploadImage(
//     BuildContext context,
//     String uid,
//   ) async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 800,
//         maxHeight: 800,
//       );
//
//       if (pickedFile == null) return null;
//
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         return await AdminDao.uploadProfileImageToCloudinary(
//           bytes: bytes,
//           fileName: pickedFile.name,
//           publicId: uid.isEmpty ? null : 'admin_$uid',
//         );
//       } else {
//         final file = File(pickedFile.path);
//         return await AdminDao.uploadProfileImageToCloudinary(
//           file: file,
//           publicId: uid.isEmpty ? null : 'admin_$uid',
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ Pick and upload error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Failed to upload image: ${e.toString().split(':').last}",
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return null;
//     }
//   }
// }
//
// // ========== UPDATED ADMIN SETTINGS SCREEN ==========
//
// class AdminSettingsScreen extends StatefulWidget {
//   final AdminModel admin;
//
//   const AdminSettingsScreen({super.key, required this.admin});
//
//   @override
//   State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
// }
//
// class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
//   late AdminModel _admin;
//   bool _isLoading = false;
//   bool _isUploadingImage = false;
//
//   final GlobalKey<FormState> _editProfileFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
//
//   // Modern Color Scheme
//   static const Color primaryColor = Color(0xFF0066CC);
//   static const Color accentColor = Color(0xFF4D8BFF);
//   static const Color backgroundColor = Color(0xFFF8FAFF);
//   static const Color cardColor = Colors.white;
//   static const Color textPrimary = Color(0xFF1A1A1A);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color successColor = Color(0xFF10B981);
//   static const Color errorColor = Color(0xFFEF4444);
//
//   @override
//   void initState() {
//     super.initState();
//     _admin = widget.admin;
//     _loadAdmin();
//   }
//
//   Future<void> _loadAdmin() async {
//     setState(() => _isLoading = true);
//     try {
//       final fetched = await AdminDao.getAdmin(_admin.uid);
//       if (fetched != null) {
//         setState(() => _admin = fetched);
//       }
//     } catch (e) {
//       _showSnackBar("Error loading admin data", isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _pickAndUploadProfileImage() async {
//     setState(() => _isUploadingImage = true);
//     try {
//       final imageUrl = await AdminDao.pickAndUploadImage(context, _admin.uid);
//
//       if (imageUrl != null) {
//         final updatedAdmin = _admin.copyWith(profileImage: imageUrl);
//         await AdminDao.updateAdmin(updatedAdmin);
//         setState(() => _admin = updatedAdmin);
//         _showSnackBar("Profile picture updated!", isError: false);
//       }
//     } catch (e) {
//       _showSnackBar("Failed to upload image", isError: true);
//     } finally {
//       setState(() => _isUploadingImage = false);
//     }
//   }
//
//   Future<void> _updateProfile({
//     required String fullName,
//     required String email,
//   }) async {
//     setState(() => _isLoading = true);
//     try {
//       final updatedAdmin = _admin.copyWith(fullName: fullName, email: email);
//       await AdminDao.updateAdmin(updatedAdmin);
//       setState(() => _admin = updatedAdmin);
//       _showSnackBar("Profile updated successfully!", isError: false);
//     } catch (e) {
//       _showSnackBar("Failed to update profile", isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _updatePassword(String newPassword) async {
//     setState(() => _isLoading = true);
//     try {
//       final updatedAdmin = _admin.copyWith(password: newPassword);
//       await AdminDao.updateAdmin(updatedAdmin);
//       _showSnackBar("Password changed successfully!", isError: false);
//     } catch (e) {
//       _showSnackBar("Failed to change password", isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ========== MODERN DIALOGS ==========
//   void _showEditProfileDialog() {
//     final nameController = TextEditingController(text: _admin.fullName);
//     final emailController = TextEditingController(text: _admin.email);
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _editProfileFormKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "Edit Profile",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Profile Image with Modern Design
//                 GestureDetector(
//                   onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: primaryColor, width: 3),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ClipOval(
//                           child: _admin.profileImage?.isNotEmpty == true
//                               ? Image.network(
//                                   _admin.profileImage!,
//                                   fit: BoxFit.cover,
//                                   loadingBuilder: (context, child, progress) =>
//                                       progress == null
//                                       ? child
//                                       : const CircularProgressIndicator(),
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       _buildDefaultAvatar(),
//                                 )
//                               : _buildDefaultAvatar(),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: primaryColor,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: _isUploadingImage
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.camera_alt,
//                                   size: 18,
//                                   color: Colors.white,
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Name Field
//                 _buildDialogTextField(
//                   controller: nameController,
//                   label: "Full Name",
//                   icon: Icons.person_outline,
//                   validator: (value) => value == null || value.trim().isEmpty
//                       ? 'Please enter your name'
//                       : null,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Email Field
//                 _buildDialogTextField(
//                   controller: emailController,
//                   label: "Email",
//                   icon: Icons.email_outlined,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(
//                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     ).hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(color: Colors.grey.shade300),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(color: textSecondary),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           if (_editProfileFormKey.currentState!.validate()) {
//                             Navigator.pop(context);
//                             await _updateProfile(
//                               fullName: nameController.text.trim(),
//                               email: emailController.text.trim(),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           elevation: 2,
//                         ),
//                         child: const Text("Save Changes"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showChangePasswordDialog() {
//     final newPasswordController = TextEditingController();
//     final confirmPasswordController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _passwordFormKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "Change Password",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // New Password
//                 _buildDialogTextField(
//                   controller: newPasswordController,
//                   label: "New Password",
//                   icon: Icons.lock_outline,
//                   isPassword: true,
//                   validator: (value) => value == null || value.length < 6
//                       ? 'Password must be at least 6 characters'
//                       : null,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Confirm Password
//                 _buildDialogTextField(
//                   controller: confirmPasswordController,
//                   label: "Confirm Password",
//                   icon: Icons.lock_reset,
//                   isPassword: true,
//                   validator: (value) => value != newPasswordController.text
//                       ? 'Passwords do not match'
//                       : null,
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         child: const Text("Cancel"),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           if (_passwordFormKey.currentState!.validate()) {
//                             Navigator.pop(context);
//                             await _updatePassword(
//                               newPasswordController.text.trim(),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         child: const Text(
//                           "Update",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ========== MODERN UI COMPONENTS ==========
//   Widget _buildDialogTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//     bool isPassword = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: primaryColor, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//       ),
//       validator: validator,
//     );
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4D8BFF), primaryColor],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//       ),
//       child: const Center(
//         child: Icon(Icons.person, size: 50, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader() {
//     return Column(
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: primaryColor, width: 3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipOval(
//                 child: _admin.profileImage?.isNotEmpty == true
//                     ? Image.network(
//                         _admin.profileImage!,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, progress) =>
//                             progress == null
//                             ? child
//                             : const CircularProgressIndicator(),
//                         errorBuilder: (context, error, stackTrace) =>
//                             _buildDefaultAvatar(),
//                       )
//                     : _buildDefaultAvatar(),
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: GestureDetector(
//                 onTap: _pickAndUploadProfileImage,
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 3),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: _isUploadingImage
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Icon(
//                           Icons.camera_alt,
//                           size: 20,
//                           color: Colors.white,
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Text(
//           _admin.fullName ?? "Admin User",
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: textPrimary,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _admin.email ?? "admin@example.com",
//           style: TextStyle(fontSize: 15, color: textSecondary),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         // Container(
//         //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         //   decoration: BoxDecoration(
//         //     color: primaryColor.withOpacity(0.1),
//         //     borderRadius: BorderRadius.circular(20),
//         //     border: Border.all(color: primaryColor.withOpacity(0.3)),
//         //   ),
//         //   // child: Text(
//         //   //   "Administrator",
//         //   //   style: TextStyle(
//         //   //     color: primaryColor,
//         //   //     fontWeight: FontWeight.w600,
//         //   //     fontSize: 14,
//         //   //     letterSpacing: 0.5,
//         //   //   ),
//         //   // ),
//         // ),
//       ],
//     );
//   }
//
//   Widget _buildSettingSection(String title, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(top: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 8, bottom: 12),
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: textPrimary,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: cardColor,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(children: children),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSettingTile({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//     Color? iconColor,
//   }) {
//     return ListTile(
//       leading: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: (iconColor ?? primaryColor).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: iconColor ?? primaryColor, size: 22),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: textPrimary,
//         ),
//       ),
//       trailing: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//       ),
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//     );
//   }
//
//   Widget _buildLogoutButton() {
//     return Container(
//       margin: const EdgeInsets.only(top: 32, bottom: 40),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           onPressed: _showLogoutConfirmation,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             foregroundColor: Colors.red,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
//             elevation: 0,
//             shadowColor: Colors.transparent,
//           ),
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.logout_rounded,
//               size: 20,
//               color: Colors.red.shade700,
//             ),
//           ),
//           label: Text(
//             "Logout Account",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.red.shade700,
//               letterSpacing: 0.3,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.logout, size: 30, color: Colors.red),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Logout?",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Are you sure you want to logout?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: textSecondary),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       child: const Text("Cancel"),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.popUntil(context, (route) => route.isFirst);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       child: const Text(
//                         "Logout",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? errorColor : successColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   _buildProfileHeader(),
//
//                   // Account Settings
//                   _buildSettingSection("Account Settings", [
//                     _buildSettingTile(
//                       title: "Edit Profile",
//                       icon: Icons.person_outline,
//                       onTap: _showEditProfileDialog,
//                     ),
//                     const Divider(height: 1, indent: 72),
//                     _buildSettingTile(
//                       title: "Change Password",
//                       icon: Icons.lock_outline,
//                       onTap: _showChangePasswordDialog,
//                     ),
//                   ]),
//
//                   // Support
//                   _buildSettingSection("Support", [
//                     _buildSettingTile(
//                       title: "Help & Support",
//                       icon: Icons.help_outline,
//                       iconColor: Colors.blue,
//                       onTap: () => _showSnackBar(
//                         "Contact support@example.com",
//                         isError: false,
//                       ),
//                     ),
//                     const Divider(height: 1, indent: 72),
//                     _buildSettingTile(
//                       title: "About",
//                       icon: Icons.info_outline,
//                       iconColor: Colors.green,
//                       onTap: () =>
//                           _showSnackBar("App Version 1.0.0", isError: false),
//                     ),
//                   ]),
//
//                   // Logout Button
//                   _buildLogoutButton(),
//                 ],
//               ),
//             ),
//           ),
//
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }
//






import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/admin/admin_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ========== CLOUDINARY SERVICE ==========
class CloudinaryService {
  static const String cloudName = "dxqkcp1hu";
  static const String uploadPreset = "admins_profiles";

  static String _generatePublicId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString();
    return 'admin_profile_${timestamp}_$random';
  }

  static Future<String?> uploadProfileImageWeb({
    required Uint8List bytes,
    required String fileName,
    String? publicId,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", url)
        ..fields["upload_preset"] = uploadPreset;

      final finalPublicId = publicId ?? _generatePublicId();
      request.fields["public_id"] = finalPublicId;

      request.files.add(
        http.MultipartFile.fromBytes("file", bytes, filename: fileName),
      );

      debugPrint("Uploading with public_id: $finalPublicId");

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseString);

      debugPrint("Cloudinary upload response: $responseString");

      if (jsonResponse["secure_url"] != null) {
        debugPrint("✅ Upload successful! URL: ${jsonResponse["secure_url"]}");
        return jsonResponse["secure_url"];
      } else {
        debugPrint("❌ Upload failed: ${jsonResponse['error']?['message']}");
        throw Exception("Upload failed: ${jsonResponse['error']?['message']}");
      }
    } catch (e) {
      debugPrint("❌ Cloudinary upload error: $e");
      rethrow;
    }
  }

  static Future<String?> uploadProfileImageMobile({
    required File imageFile,
    String? publicId,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", url)
        ..fields["upload_preset"] = uploadPreset;

      final finalPublicId = publicId ?? _generatePublicId();
      request.fields["public_id"] = finalPublicId;

      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

      debugPrint("Uploading with public_id: $finalPublicId");

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseString);

      debugPrint("Cloudinary upload response: $responseString");

      if (jsonResponse["secure_url"] != null) {
        debugPrint("✅ Upload successful! URL: ${jsonResponse["secure_url"]}");
        return jsonResponse["secure_url"];
      } else {
        debugPrint("❌ Upload failed: ${jsonResponse['error']?['message']}");
        throw Exception("Upload failed: ${jsonResponse['error']?['message']}");
      }
    } catch (e) {
      debugPrint("❌ Cloudinary upload error: $e");
      rethrow;
    }
  }
}

// ========== ADMIN DAO ==========
class AdminDao {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<AdminModel?> getAdmin(String uid) async {
    try {
      debugPrint("=== getAdmin DEBUG ===");
      debugPrint("Requested UID: '$uid'");

      if (uid.isEmpty) {
        debugPrint("❌ UID is empty. Returning null.");
        return null;
      }

      final doc = await _db.collection('admins').doc(uid).get();
      debugPrint("Document exists: ${doc.exists}");
      debugPrint("Document ID: ${doc.id}");
      debugPrint("Document data: ${doc.data()}");

      if (!doc.exists) {
        debugPrint("❌ Admin document not found. Returning null.");
        return null;
      }

      final admin = AdminModel.fromFirestore(doc);
      debugPrint("✅ Admin fetched successfully:");
      debugPrint("Admin UID: ${admin.uid}");
      debugPrint("Admin Name: ${admin.fullName}");
      debugPrint("Admin Email: ${admin.email}");
      debugPrint("Admin Profile Image: ${admin.profileImage}");
      debugPrint("=== END getAdmin DEBUG ===");

      return admin;
    } catch (e) {
      debugPrint("❌ Error getting admin: $e");
      return null;
    }
  }

  static Future<void> updateAdmin(AdminModel admin) async {
    try {
      debugPrint("=== UPDATE ADMIN DEBUG ===");
      debugPrint("Admin UID to update: ${admin.uid}");
      debugPrint("Admin UID length: ${admin.uid.length}");
      debugPrint("Admin fullName: ${admin.fullName}");
      debugPrint("Admin email: ${admin.email}");
      debugPrint("Admin profileImage: ${admin.profileImage}");
      debugPrint("=== END DEBUG ===");

      if (admin.uid.isEmpty) {
        throw Exception("Admin UID is empty. Current UID: '${admin.uid}'");
      }

      final adminData = admin.toMap();
      debugPrint("Updating admin with UID: ${admin.uid}");
      debugPrint("Admin data to update: $adminData");

      await _db.collection('admins').doc(admin.uid).update(adminData);
      debugPrint("✅ Admin updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating admin: $e");
      rethrow;
    }
  }

  static Future<String?> uploadProfileImageToCloudinary({
    File? file,
    Uint8List? bytes,
    String? fileName,
    String? publicId,
  }) async {
    try {
      final finalPublicId = publicId ?? CloudinaryService._generatePublicId();

      if (kIsWeb) {
        if (bytes == null) {
          throw Exception("Bytes are required for web");
        }
        return await CloudinaryService.uploadProfileImageWeb(
          bytes: bytes,
          fileName:
          fileName ??
              'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          publicId: finalPublicId,
        );
      } else {
        if (file == null) {
          throw Exception("File is required for mobile/desktop");
        }
        return await CloudinaryService.uploadProfileImageMobile(
          imageFile: file,
          publicId: finalPublicId,
        );
      }
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      rethrow;
    }
  }

  static Future<String?> pickAndUploadImage(
      BuildContext context,
      String uid,
      ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        return await AdminDao.uploadProfileImageToCloudinary(
          bytes: bytes,
          fileName: pickedFile.name,
          publicId: uid.isEmpty ? null : 'admin_$uid',
        );
      } else {
        final file = File(pickedFile.path);
        return await AdminDao.uploadProfileImageToCloudinary(
          file: file,
          publicId: uid.isEmpty ? null : 'admin_$uid',
        );
      }
    } catch (e) {
      debugPrint("❌ Pick and upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to upload image: ${e.toString().split(':').last}",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
}

// ========== ADMIN SETTINGS SCREEN ==========

class AdminSettingsScreen extends StatefulWidget {
  final AdminModel admin;

  const AdminSettingsScreen({super.key, required this.admin});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late AdminModel _admin;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final GlobalKey<FormState> _editProfileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Color(0xFF4D8BFF);
  static const Color backgroundColor = Color(0xFFF8FAFF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _admin = widget.admin;
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await AdminDao.getAdmin(_admin.uid);
      if (fetched != null) {
        setState(() => _admin = fetched);
      }
    } catch (e) {
      _showSnackBar("Error loading admin data", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    setState(() => _isUploadingImage = true);
    try {
      final imageUrl = await AdminDao.pickAndUploadImage(context, _admin.uid);

      if (imageUrl != null) {
        final updatedAdmin = _admin.copyWith(profileImage: imageUrl);
        await AdminDao.updateAdmin(updatedAdmin);
        setState(() => _admin = updatedAdmin);
        _showSnackBar("Profile picture updated!", isError: false);
      }
    } catch (e) {
      _showSnackBar("Failed to upload image", isError: true);
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _updateProfile({
    required String fullName,
    required String email,
  }) async {
    setState(() => _isLoading = true);
    try {
      final updatedAdmin = _admin.copyWith(fullName: fullName, email: email);
      await AdminDao.updateAdmin(updatedAdmin);
      setState(() => _admin = updatedAdmin);
      _showSnackBar("Profile updated successfully!", isError: false);
    } catch (e) {
      _showSnackBar("Failed to update profile", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    setState(() => _isLoading = true);
    try {
      final updatedAdmin = _admin.copyWith(password: newPassword);
      await AdminDao.updateAdmin(updatedAdmin);
      _showSnackBar("Password changed successfully!", isError: false);
    } catch (e) {
      _showSnackBar("Failed to change password", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ========== MODERN DIALOGS ==========
  void _showEditProfileDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    final nameController = TextEditingController(text: _admin.fullName);
    final emailController = TextEditingController(text: _admin.email);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Form(
              key: _editProfileFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Profile Image with Modern Design
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _admin.profileImage?.isNotEmpty == true
                                ? Image.network(
                              _admin.profileImage!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const CircularProgressIndicator(),
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(screenWidth),
                            )
                                : _buildDefaultAvatar(screenWidth),
                          ),
                        ),
                        Positioned(
                          bottom: screenWidth * 0.01,
                          right: screenWidth * 0.01,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _isUploadingImage
                                ? SizedBox(
                              width: screenWidth * 0.04,
                              height: screenWidth * 0.04,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Icon(
                              Icons.camera_alt,
                              size: screenWidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Name Field
                  _buildDialogTextField(
                    controller: nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                    context: context,
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Email Field
                  _buildDialogTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    context: context,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_editProfileFormKey.currentState!.validate()) {
                              Navigator.pop(context);
                              await _updateProfile(
                                fullName: nameController.text.trim(),
                                email: emailController.text.trim(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Save Changes",
                            style: TextStyle(fontSize: screenWidth * 0.038),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // New Password
                  _buildDialogTextField(
                    controller: newPasswordController,
                    label: "New Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => value == null || value.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    context: context,
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Confirm Password
                  _buildDialogTextField(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    icon: Icons.lock_reset,
                    isPassword: true,
                    validator: (value) => value != newPasswordController.text
                        ? 'Passwords do not match'
                        : null,
                    context: context,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: screenWidth * 0.038),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_passwordFormKey.currentState!.validate()) {
                              Navigator.pop(context);
                              await _updatePassword(
                                newPasswordController.text.trim(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                          child: Text(
                            "Update",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== MODERN UI COMPONENTS ==========
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required BuildContext context,
    bool isPassword = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: screenWidth * 0.038),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        prefixIcon: Icon(
          icon,
          color: primaryColor.withOpacity(0.7),
          size: screenWidth * 0.05,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.035,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDefaultAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D8BFF), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: screenWidth * 0.12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
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
              child: ClipOval(
                child: _admin.profileImage?.isNotEmpty == true
                    ? Image.network(
                  _admin.profileImage!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                  progress == null
                      ? child
                      : const CircularProgressIndicator(),
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(screenWidth),
                )
                    : _buildDefaultAvatar(screenWidth),
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.01,
              right: screenWidth * 0.01,
              child: GestureDetector(
                onTap: _pickAndUploadProfileImage,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingImage
                      ? SizedBox(
                    width: screenWidth * 0.045,
                    height: screenWidth * 0.045,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    Icons.camera_alt,
                    size: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          _admin.fullName ?? "Admin User",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          _admin.email ?? "admin@example.com",
          style: TextStyle(
            fontSize: screenWidth * 0.038,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.02,
              bottom: screenHeight * 0.01,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListTile(
      leading: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: (iconColor ?? primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? primaryColor,
          size: screenWidth * 0.055,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
      trailing: Container(
        width: screenWidth * 0.09,
        height: screenWidth * 0.09,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: screenWidth * 0.05,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(
        top: screenHeight * 0.03,
        bottom: screenHeight * 0.04,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showLogoutConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
            ),
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          icon: Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              size: screenWidth * 0.05,
              color: Colors.red.shade700,
            ),
          ),
          label: Text(
            "Logout Account",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: screenWidth * 0.07,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Logout?",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.012),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: textSecondary,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: screenWidth * 0.038),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.038,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
        ),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                children: [
                  _buildProfileHeader(context),

                  // Account Settings
                  _buildSettingSection("Account Settings", [
                    _buildSettingTile(
                      title: "Edit Profile",
                      icon: Icons.person_outline,
                      onTap: _showEditProfileDialog,
                      context: context,
                    ),
                    Divider(height: 1, indent: screenWidth * 0.18),
                    _buildSettingTile(
                      title: "Change Password",
                      icon: Icons.lock_outline,
                      onTap: _showChangePasswordDialog,
                      context: context,
                    ),
                  ], context),

                  // Support
                  _buildSettingSection("Support", [
                    _buildSettingTile(
                      title: "Help & Support",
                      icon: Icons.help_outline,
                      iconColor: Colors.blue,
                      onTap: () => _showSnackBar(
                        "Contact support@example.com",
                        isError: false,
                      ),
                      context: context,
                    ),
                    Divider(height: 1, indent: screenWidth * 0.18),
                    _buildSettingTile(
                      title: "About",
                      icon: Icons.info_outline,
                      iconColor: Colors.green,
                      onTap: () =>
                          _showSnackBar("App Version 1.0.0", isError: false),
                      context: context,
                    ),
                  ], context),

                  // Logout Button
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
