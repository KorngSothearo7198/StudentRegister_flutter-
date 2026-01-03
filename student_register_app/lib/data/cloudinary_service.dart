// lib/services/cloudinary_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Use your Cloudinary credentials
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'student_profiles';

  /// Uploads a receipt image to Cloudinary and returns the secure URL
  static Future<String?> uploadReceipt(Uint8List bytes, String fileName) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    try {
      final response = await request.send();
      final resStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resStr);
        print(' Cloudinary upload successful: ${data['secure_url']}');
        return data['secure_url']; //  URL Dinary
      } else {
        print(' Cloudinary upload failed: $resStr');
        return null;
      }
    } catch (e) {
      print(' Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
