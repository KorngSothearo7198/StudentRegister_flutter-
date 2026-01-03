// // lib/data/cloudinary_servicechart.dart
// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'dart:html' as html; // For web file operations
// import 'package:http/http.dart' as http;
// import 'package:universal_html/html.dart' as html2; // Alternative import


// import 'cloudinary_service_mobile.dart'
//     if (dart.library.html) 'cloudinary_service_web.dart';


// class CloudinaryService {
//   // Your Cloudinary credentials
//   static const String cloudName = 'dxqkcp1hu';
//   static const String uploadPreset = 'chart';

//   // Get file type for folder organization
//   static String getFileType(String fileName) {
//     final ext = fileName.split('.').last.toLowerCase();
//     if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
//       return 'image';
//     } else if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
//       return 'document';
//     } else {
//       return 'file';
//     }
//   }

//   // Get folder path based on file type
//   static String getFolderForFileType(String fileType) {
//     switch (fileType) {
//       case 'image':
//         return 'chat/images';
//       case 'document':
//         return 'chat/documents';
//       default:
//         return 'chat/files';
//     }
//   }

//   // Upload bytes (for web - handles File objects)
//   static Future<String?> uploadBytes(
//     List<int> bytes, {
//     required String fileName,
//     required String folder,
//   }) async {
//     try {
//       print('🔄 Uploading to Cloudinary: $fileName to folder: $folder');
      
//       final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
//       // Create multipart request
//       final request = http.MultipartRequest('POST', uri)
//         ..fields['upload_preset'] = uploadPreset
//         ..fields['folder'] = folder
//         ..files.add(http.MultipartFile.fromBytes(
//           'file',
//           bytes,
//           filename: fileName,
//         ));

//       // Send the request
//       final response = await request.send();
      
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         final jsonResponse = jsonDecode(responseData);
//         final downloadUrl = jsonResponse['secure_url'];
        
//         print('✅ Cloudinary upload successful: $downloadUrl');
//         return downloadUrl;
//       } else {
//         print('❌ Cloudinary upload failed with status: ${response.statusCode}');
//         final error = await response.stream.bytesToString();
//         print('❌ Error details: $error');
//         return null;
//       }
//     } catch (e) {
//       print('❌ Cloudinary upload error: $e');
//       return null;
//     }
//   }

//   // Upload web file
//   static Future<String?> uploadWebFile(
//     html.File file, {
//     String? folder,
//   }) async {
//     try {
//       final fileName = file.name;
//       final fileType = getFileType(fileName);
//       final uploadFolder = folder ?? getFolderForFileType(fileType);
      
//       // Convert web File to bytes
//       final reader = html.FileReader();
//       final completer = Completer<List<int>>();
      
//       reader.onLoadEnd.listen((event) {
//         final result = reader.result as List<int>?;
//         completer.complete(result ?? []);
//       });
      
//       reader.onError.listen((event) {
//         completer.completeError(Exception('Failed to read file'));
//       });
      
//       reader.readAsArrayBuffer(file);
//       final bytes = await completer.future;
      
//       return await uploadBytes(
//         bytes,
//         fileName: fileName,
//         folder: uploadFolder,
//       );
//     } catch (e) {
//       print('❌ Cloudinary web file upload error: $e');
//       return null;
//     }
//   }
// }


//
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// class CloudinaryService {
//   static const String cloudName = 'dxqkcp1hu';
//   static const String uploadPreset = 'chart';
//
//   static Future<String?> uploadImage({
//     Uint8List? webImage,
//     String? filePath,
//   }) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
//     );
//
//     var request = http.MultipartRequest("POST", uri);
//     request.fields["upload_preset"] = uploadPreset;
//
//     if (kIsWeb && webImage != null) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           "file",
//           webImage,
//           filename: "web_image.jpg",
//         ),
//       );
//     } else if (filePath != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath("file", filePath),
//       );
//     }
//
//     final response = await request.send();
//     final resBody = await response.stream.bytesToString();
//     final data = json.decode(resBody);
//
//     if (response.statusCode == 200) {
//       return data["secure_url"];
//     } else {
//       throw Exception(data["error"]["message"]);
//     }
//   }
// }

class CloudinaryService {
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'chart';

  static Future<String?> uploadImage({
    Uint8List? webImage,
    String? filePath,
    String folder = 'chat_images',
  }) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder;

    if (kIsWeb && webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webImage,
          filename: 'image.jpg',
        ),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = json.decode(body);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      throw Exception(data['error']['message']);
    }
  }
}

