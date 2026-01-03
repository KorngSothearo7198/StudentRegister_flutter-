// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:just_audio/just_audio.dart';
// import 'package:image_picker/image_picker.dart';
//
// /// ================== CLOUDINARY SERVICE ==================
// class CloudinaryService {
//   static const String cloudName = 'dxqkcp1hu';
//   static const String uploadPreset = 'chart_file';
//
//   static Future<String> uploadImage({
//     Uint8List? webBytes,
//     String? filePath,
//     required String folder,
//   }) async {
//     final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..fields['folder'] = folder;
//
//     if (kIsWeb && webBytes != null) {
//       request.files.add(http.MultipartFile.fromBytes('file', webBytes, filename: 'image.jpg'));
//     } else if (filePath != null) {
//       request.files.add(await http.MultipartFile.fromPath('file', filePath));
//     }
//
//     final response = await request.send();
//     final body = json.decode(await response.stream.bytesToString());
//
//     if (response.statusCode == 200) return body['secure_url'];
//     throw Exception(body['error']['message']);
//   }
//
//   static Future<String> uploadVoice({required String filePath, required String folder}) async {
//     final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..fields['folder'] = folder
//       ..files.add(await http.MultipartFile.fromPath('file', filePath));
//     final response = await request.send();
//     final body = json.decode(await response.stream.bytesToString());
//
//     if (response.statusCode == 200) return body['secure_url'];
//     throw Exception(body['error']['message']);
//   }
// }
//
// /// ================== CHAT SCREEN ==================
// class StudentChatWithChartScreen extends StatefulWidget {
//   final String studentchartId;
//   final String fullName;
//   final String adminId;
//   final String? photoUrl;
//   final Map<String, dynamic>? adminProfile;
//
//   const StudentChatWithChartScreen({
//     super.key,
//     required this.studentchartId,
//     required this.fullName,
//     required this.adminId,
//     this.photoUrl,
//     this.adminProfile,
//   });
//
//   @override
//   State<StudentChatWithChartScreen> createState() => _StudentChatWithChartScreenState();
// }
//
// class _StudentChatWithChartScreenState extends State<StudentChatWithChartScreen> {
//   final _messageCtrl = TextEditingController();
//   final _firestore = FirebaseFirestore.instance;
//
//   FlutterSoundRecorder? _recorder;
//   FlutterSoundPlayer? _player;
//
//   bool _isRecording = false;
//   String? _voicePath;
//
//   @override
//   void initState() {
//     super.initState();
//     _recorder = FlutterSoundRecorder();
//     _player = FlutterSoundPlayer();
//     _initAudio();
//   }
//
//   Future<void> _initAudio() async {
//     await Permission.microphone.request();
//     await _recorder!.openRecorder();
//     await _player!.openPlayer();
//   }
//
//   @override
//   void dispose() {
//     _recorder?.closeRecorder();
//     _player?.closePlayer();
//     _messageCtrl.dispose();
//     super.dispose();
//   }
//
//   /// ================== VOICE ==================
//   Future<void> _startRecording() async {
//     final dir = Directory.systemTemp;
//     final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
//
//     await _recorder!.startRecorder(toFile: filePath, codec: Codec.aacADTS);
//     setState(() {
//       _isRecording = true;
//       _voicePath = filePath;
//     });
//   }
//
//   Future<int> getVoiceDuration(String path) async {
//     final player = AudioPlayer();
//     final duration = await player.setFilePath(path);
//     await player.dispose();
//     return duration != null ? duration.inSeconds : 0;
//   }
//
//   Future<void> _stopRecording() async {
//     await _recorder!.stopRecorder();
//     setState(() => _isRecording = false);
//     if (_voicePath == null) return;
//
//     // Get duration of local voice file
//     final durationSeconds = await getVoiceDuration(_voicePath!);
//
//     final url = await CloudinaryService.uploadVoice(
//       filePath: _voicePath!,
//       folder: 'chat_voice/${widget.studentchartId}',
//     );
//
//     await _firestore.collection('chats').doc(widget.studentchartId).collection('messages').add({
//       'type': 'voice',
//       'attachments': [
//         {
//           'type': 'voice',
//           'url': url,
//           'name': 'voice.aac',
//           'duration': durationSeconds
//         }
//       ],
//       'sender': 'student',
//       'text': '',
//       'time': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<void> _playVoice(String url) async => await _player!.startPlayer(fromURI: url);
//
//   /// ================== IMAGE ==================
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final img = await picker.pickImage(source: ImageSource.gallery);
//     if (img == null) return;
//
//     final url = await CloudinaryService.uploadImage(
//       filePath: img.path,
//       folder: 'chat_images/${widget.studentchartId}',
//     );
//
//     await _firestore.collection('chats').doc(widget.studentchartId).collection('messages').add({
//       'type': 'image',
//       'attachments': [
//         {'type': 'image', 'url': url, 'name': img.name}
//       ],
//       'sender': 'student',
//       'text': '',
//       'time': FieldValue.serverTimestamp(),
//     });
//   }
//
//   /// ================== SEND TEXT ==================
//   Future<void> _sendMessage() async {
//     if (_messageCtrl.text.trim().isEmpty) return;
//
//     await _firestore.collection('chats').doc(widget.studentchartId).collection('messages').add({
//       'type': 'text',
//       'text': _messageCtrl.text.trim(),
//       'attachments': [],
//       'sender': 'student',
//       'time': FieldValue.serverTimestamp(),
//     });
//
//     _messageCtrl.clear();
//   }
//
//   /// ================== UI ==================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.fullName)),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chats')
//                   .doc(widget.studentchartId)
//                   .collection('messages')
//                   .orderBy('time')
//                   .snapshots(),
//               builder: (_, snap) {
//                 if (!snap.hasData) return const Center(child: CircularProgressIndicator());
//
//                 return ListView(
//                   padding: const EdgeInsets.all(8),
//                   children: snap.data!.docs.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final attachments = data['attachments'] as List<dynamic>?;
//
//                     final isStudent = data['sender'] == 'student';
//                     final align = isStudent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
//                     final color = isStudent ? Colors.blue[100] : Colors.grey[200];
//
//                     // Format timestamp
//                     String timeStr = '';
//                     if (data['time'] != null) {
//                       final ts = data['time'] as Timestamp;
//                       timeStr = DateFormat('hh:mm a dd/MM/yyyy').format(ts.toDate());
//                     }
//
//                     return Container(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: Column(
//                         crossAxisAlignment: align,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: color,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: align,
//                               children: [
//                                 // Text
//                                 if (data['text'] != null && data['text'].toString().isNotEmpty)
//                                   Text(data['text']),
//
//                                 // Direct imageUrl
//                                 if (data['imageUrl'] != null)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 5),
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => ImagePreviewScreen(imageUrl: data['imageUrl']),
//                                           ),
//                                         );
//                                       },
//                                       child: Image.network(
//                                         data['imageUrl'],
//                                         width: 150,
//                                         height: 150,
//                                       ),
//                                     ),
//                                   ),
//
//                                 // Direct audioUrl
//                                 if (data['audioUrl'] != null)
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IconButton(
//                                         icon: const Icon(Icons.play_arrow),
//                                         onPressed: () => _playVoice(data['audioUrl']),
//                                       ),
//                                       const Text("Voice message"),
//                                     ],
//                                   ),
//
//                                 // Attachments
//                                 if (attachments != null)
//                                   for (final a in attachments)
//                                     if (a['type'] == 'image')
//                                       Padding(
//                                         padding: const EdgeInsets.only(top: 5),
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (_) => ImagePreviewScreen(imageUrl: a['url']),
//                                               ),
//                                             );
//                                           },
//                                           child: Image.network(
//                                             a['url'],
//                                             width: 150,
//                                             height: 150,
//                                           ),
//                                         ),
//                                       )
//                                     else if (a['type'] == 'voice')
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           IconButton(
//                                             icon: const Icon(Icons.play_arrow),
//                                             onPressed: () => _playVoice(a['url']),
//                                           ),
//                                           if (a['duration'] != null)
//                                             Text(
//                                               _formatDuration(a['duration']),
//                                               style: const TextStyle(fontSize: 12, color: Colors.black54),
//                                             ),
//                                         ],
//                                       ),
//
//                                 // Timestamp
//                                 if (timeStr.isNotEmpty)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 5),
//                                     child: Text(
//                                       timeStr,
//                                       style: const TextStyle(fontSize: 10, color: Colors.grey),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//
//
//
//
//           // Input Row
//           Row(
//             children: [
//
//               IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
//               IconButton(
//                 icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.red : Colors.blue),
//                 onPressed: _isRecording ? _stopRecording : _startRecording,
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: _messageCtrl,
//                   decoration: const InputDecoration(hintText: 'Type message...'),
//                 ),
//               ),
//               IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// ================== HELPER ==================
//   String _formatDuration(int seconds) {
//     final min = (seconds ~/ 60).toString().padLeft(2, '0');
//     final sec = (seconds % 60).toString().padLeft(2, '0');
//     return '$min:$sec';
//   }
// }
//
// /// ================== IMAGE PREVIEW SCREEN ==================
// class ImagePreviewScreen extends StatelessWidget {
//   final String imageUrl;
//
//   const ImagePreviewScreen({super.key, required this.imageUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Center(
//             child: InteractiveViewer(
//               child: Image.network(imageUrl),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             right: 20,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }









import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

/// ================== CLOUDINARY SERVICE ==================
class CloudinaryService {
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'chart_file';

  static Future<String> uploadImage({
    Uint8List? webBytes,
    String? filePath,
    required String folder,
  }) async {
    final uri =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder;

    if (kIsWeb && webBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', webBytes, filename: 'image.jpg'),
      );
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final res = await request.send();
    final body = json.decode(await res.stream.bytesToString());

    if (res.statusCode == 200) return body['secure_url'];
    throw Exception(body['error']['message']);
  }

  static Future<String> uploadVoice({
    required String filePath,
    required String folder,
  }) async {
    final uri =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final res = await request.send();
    final body = json.decode(await res.stream.bytesToString());

    if (res.statusCode == 200) return body['secure_url'];
    throw Exception(body['error']['message']);
  }
}

/// ================== CHAT SCREEN ==================
class StudentChatWithChartScreen extends StatefulWidget {
  final String studentchartId;
  final String fullName;
  final String adminId;
  final String? photoUrl; // student photo
  final Map<String, dynamic>? adminProfile; // teacher profile

  const StudentChatWithChartScreen({
    super.key,
    required this.studentchartId,
    required this.fullName,
    required this.adminId,
    this.photoUrl,
    this.adminProfile,
  });

  @override
  State<StudentChatWithChartScreen> createState() =>
      _StudentChatWithChartScreenState();
}

class _StudentChatWithChartScreenState
    extends State<StudentChatWithChartScreen> {
  final _messageCtrl = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;

  bool _isRecording = false;
  String? _voicePath;

  // Add this scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await Permission.microphone.request();
    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    _messageCtrl.dispose();
    super.dispose();
  }

  /// ================== VOICE ==================
  Future<void> _startRecording() async {
    final dir = Directory.systemTemp;
    final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
      _voicePath = filePath;
    });

    debugPrint('🎙 START RECORDING: $filePath');
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  Future<int> _getVoiceDuration(String path) async {
    final p = AudioPlayer();
    final d = await p.setFilePath(path);
    await p.dispose();
    return d?.inSeconds ?? 0;
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() => _isRecording = false);

    if (_voicePath == null) return;

    final duration = await _getVoiceDuration(_voicePath!);

    final url = await CloudinaryService.uploadVoice(
      filePath: _voicePath!,
      folder: 'chat_voice/${widget.studentchartId}',
    );

    debugPrint('🎧 VOICE UPLOADED: $url ($duration s)');

    await _firestore
        .collection('chats')
        .doc(widget.studentchartId)
        .collection('messages')
        .add({
      'sender': 'student',
      'text': '',
      'attachments': [
        {
          'type': 'voice',
          'url': url,
          'duration': duration,
        }
      ],
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _playVoice(String url) async {
    debugPrint('▶ PLAY VOICE: $url');
    await _player!.startPlayer(fromURI: url);
  }

  /// ================== IMAGE ==================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final url = await CloudinaryService.uploadImage(
      filePath: img.path,
      folder: 'chat_images/${widget.studentchartId}',
    );

    debugPrint('🖼 IMAGE UPLOADED: $url');

    await _firestore
        .collection('chats')
        .doc(widget.studentchartId)
        .collection('messages')
        .add({
      'sender': 'student',
      'text': '',
      'attachments': [
        {'type': 'image', 'url': url}
      ],
      'time': FieldValue.serverTimestamp(),
    });
  }

  /// ================== SEND TEXT ==================
  Future<void> _sendMessage() async {
    if (_messageCtrl.text.trim().isEmpty) return;

    debugPrint('✉ SEND TEXT: ${_messageCtrl.text}');

    await _firestore
        .collection('chats')
        .doc(widget.studentchartId)
        .collection('messages')
        .add({
      'sender': 'student',
      'text': _messageCtrl.text.trim(),
      'attachments': [],
      'time': FieldValue.serverTimestamp(),
    });

    _messageCtrl.clear();
  }

  /// ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.photoUrl != null
                  ? NetworkImage(widget.photoUrl!)
                  : null,
              child: widget.photoUrl == null
                  ? Text(widget.fullName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.fullName),
          ],
        ),
      ),
      body: Column(
        children: [
          /// ================== MESSAGE LIST ==================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.studentchartId)
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                // Schedule scroll to bottom after frame
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());


                return ListView(
                  controller: _scrollController,  // Add controller here
                  padding: const EdgeInsets.all(8),
                  children: snap.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final attachments = data['attachments'] as List<dynamic>?;

                    final isStudent = data['sender'] == 'student';
                    final align = isStudent ? CrossAxisAlignment.start : CrossAxisAlignment.end;
                    final color = isStudent ? Colors.blue[100] : Colors.grey[200];

                    // Format timestamp
                    String timeStr = '';
                    if (data['time'] != null) {
                      final ts = data['time'] as Timestamp;
                      timeStr = DateFormat('hh:mm a dd/MM/yyyy').format(ts.toDate());
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      isStudent ? MainAxisAlignment.start : MainAxisAlignment.end,
                      children: [
                        // Avatar
                        if (isStudent)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.photoUrl != null
                                ? NetworkImage(widget.photoUrl!)
                                : null,
                            child: widget.photoUrl == null
                                ? Text(widget.fullName[0])
                                : null,
                          ),

                        if (isStudent) const SizedBox(width: 8),

                        // Message bubble
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: align,
                              children: [
                                // Text
                                if (data['text'] != null && data['text'].toString().isNotEmpty)
                                  Text(data['text']),

                                // Direct imageUrl
                                if (data['imageUrl'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ImagePreviewScreen(imageUrl: data['imageUrl']),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        data['imageUrl'],
                                        width: 150,
                                        height: 150,
                                      ),
                                    ),
                                  ),

                                // Direct audioUrl
                                if (data['audioUrl'] != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () => _playVoice(data['audioUrl']),
                                      ),
                                      const Text("Voice message"),
                                    ],
                                  ),

                                // Attachments
                                if (attachments != null)
                                  for (final a in attachments)
                                    if (a['type'] == 'image')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ImagePreviewScreen(imageUrl: a['url']),
                                              ),
                                            );
                                          },
                                          child: Image.network(
                                            a['url'],
                                            width: 150,
                                            height: 150,
                                          ),
                                        ),
                                      )
                                    else if (a['type'] == 'voice')
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.play_arrow),
                                            onPressed: () => _playVoice(a['url']),
                                          ),
                                          if (a['duration'] != null)
                                            Text(
                                              _formatDuration(a['duration']),
                                              style: const TextStyle(
                                                  fontSize: 12, color: Colors.black54),
                                            ),
                                        ],
                                      ),

                                // Timestamp
                                if (timeStr.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      timeStr,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (!isStudent) const SizedBox(width: 8),

                        // Admin avatar
                        if (!isStudent)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.adminProfile?['photoUrl'] != null
                                ? NetworkImage(widget.adminProfile!['photoUrl'])
                                : null,
                            child: widget.adminProfile?['photoUrl'] == null
                                ? const Icon(Icons.person, size: 18)
                                : null,
                          ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          /// ================== INPUT ==================
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                onPressed:
                _isRecording ? _stopRecording : _startRecording,
              ),
              Expanded(
                child: TextField(
                  controller: _messageCtrl,
                  decoration:
                  const InputDecoration(hintText: 'Type message...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable image
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              child: Image.network(imageUrl),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
