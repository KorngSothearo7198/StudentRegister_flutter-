import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:http/http.dart' as http;
import 'dart:convert';


// ======================================================
// CLOUDINARY SERVICE (IMAGE + VOICE)
// ======================================================
class CloudinaryService {
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'chart_file';

  // IMAGE
  static Future<String> uploadImage({
    Uint8List? webBytes,
    String? filePath,
    required String folder,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder;

    if (kIsWeb && webBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes as List<int>,
          filename: 'image.jpg',
        ),
      );
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final response = await request.send();
    final body = json.decode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      return body['secure_url'];
    } else {
      throw Exception(body['error']['message']);
    }
  }

  // VOICE / FILE
  static Future<String> uploadRaw({
    required String filePath,
    required String folder,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: http.MediaType('audio', 'aac'),
        ),
      );

    final response = await request.send();
    final body = json.decode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      return body['secure_url'];
    } else {
      throw Exception(body['error']['message']);
    }
  }
}

