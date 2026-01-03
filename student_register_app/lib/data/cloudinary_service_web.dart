import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class CloudinaryServiceImpl {
  static const cloudName = 'dxqkcp1hu';
  static const uploadPreset = 'chart';

  static Future<String?> uploadWebFile(
    html.File file,
    String folder,
  ) async {
    final reader = html.FileReader();
    final completer = Completer<List<int>>();

    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      completer.complete(reader.result as List<int>);
    });

    final bytes = await completer.future;

    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body)['secure_url'];
    }
    return null;
  }
}
