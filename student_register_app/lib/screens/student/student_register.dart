// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:flutter/material.dart';
// import '../../widgets/custom_textfield.dart';
// import 'student_home.dart';

// class StudentRegisterScreen extends StatefulWidget {
//   const StudentRegisterScreen({super.key});

//   @override
//   State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
// }

// class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
//   int _currentStep = 0;
//   final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
//   bool _isSubmitting = false;

//   // Controllers
//   final _lastNameCtrl = TextEditingController();
//   final _firstNameCtrl = TextEditingController();
//   final _dobCtrl = TextEditingController();
//   final _nationalityCtrl = TextEditingController();
//   final _fatherNameCtrl = TextEditingController();
//   final _motherNameCtrl = TextEditingController();

//   // final _bacCodeCtrl = TextEditingController();
//   final _bacYearCtrl = TextEditingController();
//   final _highSchoolCtrl = TextEditingController();
//   final _schoolLocationCtrl = TextEditingController();
//   // final _institutionCtrl = TextEditingController();

//   final _countryCtrl = TextEditingController();
//   final _provinceCtrl = TextEditingController();
//   final _districtCtrl = TextEditingController();
//   final _communeCtrl = TextEditingController();
//   final _villageCtrl = TextEditingController();

//   final _majorCtrl = TextEditingController();

//   final _phoneCtrl = TextEditingController();
//   final _guardianPhoneCtrl = TextEditingController();
//   // final _emergencyRelationCtrl = TextEditingController();
//   // final _emergencyContactCtrl = TextEditingController();
//   // final _emergencyWorkplaceCtrl = TextEditingController();

//   // Dropdowns

//   String? _selectedMajor;

//   String? _gender;
//   String? _educationLevel;
//   String? _bacGrade;
//   String? _careerType;
//   String? _degree;
//   String? _shift;
//   String? _programType;

//   @override
//   void dispose() {
//     final controllers = [
//       _lastNameCtrl,
//       _firstNameCtrl,
//       _dobCtrl,
//       _nationalityCtrl,
//       _fatherNameCtrl,
//       _motherNameCtrl,
//       // _bacCodeCtrl,
//       _bacYearCtrl,
//       _highSchoolCtrl,
//       _schoolLocationCtrl,
//       // _institutionCtrl,
//       _countryCtrl,
//       _provinceCtrl,
//       _districtCtrl,
//       _communeCtrl,
//       _villageCtrl,
//       _majorCtrl,
//       _phoneCtrl,
//       _guardianPhoneCtrl,
//       // _emergencyNameCtrl,
//       // _emergencyRelationCtrl,
//       // _emergencyContactCtrl,
//       // _emergencyWorkplaceCtrl,
//     ];
//     for (var c in controllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   // SUBMIT

//   // submit
//   Future<void> _submit() async {
//     if (!_formKeys.every((key) => key.currentState!.validate())) return;

//     setState(() => _isSubmitting = true);

//     // Combine last name + first name
//     // final joinName = '${_lastNameCtrl.text} ${_firstNameCtrl.text}';

//     final data = {
//       "lastName": _lastNameCtrl.text,
//       "firstName": _firstNameCtrl.text,
//       "gender": _gender,
//       "dateOfBirth": _dobCtrl.text,
//       "nationality": _nationalityCtrl.text,
//       "fatherName": _fatherNameCtrl.text,
//       "motherName": _motherNameCtrl.text,
//       "educationLevel": _educationLevel,
//       // "bacGrade": _bacGrade,
//       "bacYear": _bacYearCtrl.text,

//       "highSchoolName": _highSchoolCtrl.text,
//       "highSchoolLocation": _schoolLocationCtrl.text,
//       "careerType": _careerType,
//       "country": _countryCtrl.text,
//       "province": _provinceCtrl.text,
//       "district": _districtCtrl.text,
//       "commune": _communeCtrl.text,
//       "village": _villageCtrl.text,
//       "degree": _degree,
//       "major": _selectedMajor, // Use dropdown selected value
//       "shift": _shift,
//       "programType": _programType,
//       "phone": _phoneCtrl.text,
//       // "guardianPhone": _guardianPhoneCtrl.text,
//       // "emergencyContact": _emergencyContactCtrl.text,
//       // "emergencyWorkplace": _emergencyWorkplaceCtrl.text,
//     };

//     try {
//       await FirebaseFirestore.instance
//           .collection('students_joinName')
//           .add(data);

//       setState(() => _isSubmitting = false);

//       if (!mounted) return;

//       await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Success"),
//           content: const Text("Registration completed successfully!"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );

//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => StudentHomeScreen(student: data, studentName: '', openChatStudent: null),
//         ),
//       );
//     } catch (e) {
//       setState(() => _isSubmitting = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       body: Theme(
//         data: Theme.of(
//           context,
//         ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.blue)),
//         child: Stepper(
//           type: isWide ? StepperType.horizontal : StepperType.vertical,
//           currentStep: _currentStep,

//           // onStepContinue: () {
//           //   final form = _formKeys[_currentStep].currentState!;
//           //   if (form.validate()) {
//           //     if (_currentStep < 4) {
//           //       setState(() => _currentStep++);
//           //     } else {
//           //       _submit();
//           //     }
//           //   }
//           // },
//           onStepContinue: () {
//             final form = _formKeys[_currentStep].currentState!;
//             if (form.validate()) {
//               if (_currentStep < 4) {
//                 setState(() => _currentStep++);
//               } else {
//                 // Disable multiple submits
//                 if (!_isSubmitting) {
//                   _submit();
//                 }
//               }
//             }
//           },

//           // Loading indicator on the submit button
//           controlsBuilder: (context, details) {
//             final isLastStep = _currentStep == 4;
//             return Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: details.onStepContinue,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(
//                       0xFF1A237E,
//                     ), // new background color
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isSubmitting && isLastStep
//                       ? SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(isLastStep ? "Submit" : "Next"),
//                 ),
//                 if (_currentStep > 0)
//                   TextButton(
//                     onPressed: details.onStepCancel,
//                     child: const Text("Back"),
//                   ),
//               ],
//             );
//           },

//           onStepCancel: () =>
//               _currentStep > 0 ? setState(() => _currentStep--) : null,
//           steps: [
//             _buildStep(0, 'Personal', _buildPersonalInfoForm()),
//             _buildStep(1, 'Education', _buildEducationForm()),
//             _buildStep(2, 'Address', _buildAddressForm()),
//             _buildStep(3, 'Program', _buildProgramForm()),
//             _buildStep(4, 'Contact', _buildContactForm()),
//           ],
//         ),
//       ),
//     );
//   }

//   Step _buildStep(int index, String title, Widget content) {
//     return Step(
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//       isActive: _currentStep >= index,
//       state: _currentStep > index
//           ? StepState.complete
//           : (_currentStep == index ? StepState.editing : StepState.indexed),
//       content: Form(
//         key: _formKeys[index],
//         child: Padding(padding: const EdgeInsets.all(16), child: content),
//       ),
//     );
//   }

//   // ───── STEP 1: Personal Info ─────
//   Widget _buildPersonalInfoForm() {
//     return _Section(
//       title: "Personal Information",
//       children: [
//         _Row(
//           children: [
//             _Field(_lastNameCtrl, 'Last Name', required: true),
//             _Field(_firstNameCtrl, 'First Name', required: true),
//           ],
//         ),
//         _Dropdown(
//           value: _gender,
//           label: 'Gender',
//           items: ['Male', 'Female'],
//           onChanged: (v) => setState(() => _gender = v),
//           required: true,
//         ),
//         _DateField(_dobCtrl, 'Date of Birth', required: true),
//         _Field(_nationalityCtrl, 'Nationality', required: true),
//         // _Field(_telegramCtrl, 'Telegram ID'),
//         _Field(_fatherNameCtrl, 'Father\'s Name'),
//         _Field(_motherNameCtrl, 'Mother\'s Name'),
//       ],
//     );
//   }

//   // ───── STEP 2: Education ─────
//   Widget _buildEducationForm() {
//     return _Section(
//       title: "Education Background",
//       children: [
//         _Dropdown(
//           value: _educationLevel,
//           label: 'Education Level',
//           items: ['High School', 'Bachelor', 'Failed High School'],
//           onChanged: (v) => setState(() => _educationLevel = v),
//           required: true,
//         ),
//         _Dropdown(
//           value: _bacGrade,
//           label: 'BacII Grade',
//           items: ['NA', 'A', 'B', 'C', 'D', 'E', 'F', 'Auto'],
//           onChanged: (v) => setState(() => _bacGrade = v),
//           required: true,
//         ),
//         // _Field(_bacCodeCtrl, 'BacII Certificate Code', required: true),
//         _Field(
//           _bacYearCtrl,
//           'BacII Year',
//           required: true,
//           keyboardType: TextInputType.number,
//         ),
//         _Field(_highSchoolCtrl, 'High School Name', required: true),
//         _Field(_schoolLocationCtrl, 'High School Location', required: true),
//         _Dropdown(
//           value: _careerType,
//           label: 'Career Type',
//           items: ['Student', 'Staff'],
//           onChanged: (v) => setState(() => _careerType = v),
//           required: true,
//         ),
//         // _Field(_institutionCtrl, 'Institution'),
//       ],
//     );
//   }

//   // ───── STEP 3: Address ─────
//   Widget _buildAddressForm() {
//     return _Section(
//       title: "Permanent Address",
//       children: [
//         _Field(_countryCtrl, 'Country', required: true),
//         _Field(_provinceCtrl, 'Province', required: true),
//         _Field(_districtCtrl, 'District', required: true),
//         _Field(_communeCtrl, 'Commune', required: true),
//         _Field(_villageCtrl, 'Village', required: true),
//       ],
//     );
//   }

//   // ───── STEP 4: Program ─────
//   Widget _buildProgramForm() {
//     return _Section(
//       title: "Academic Program",
//       children: [
//         _Dropdown(
//           value: _degree,
//           label: 'Degree',
//           items: ['Associate', 'Bachelor', 'Master'],
//           onChanged: (v) => setState(() => _degree = v),
//           required: true,
//         ),
//         // _Field(_majorCtrl, 'Major', required: true),
//         DropdownButtonFormField<String>(
//           value: _selectedMajor,
//           decoration: InputDecoration(
//             labelText: 'Major',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//           ),
//           items:
//               // ['FN', 'EE', 'ME', 'CS', 'Data Science'] // Major
//               ['FN', 'EE', 'ME', 'CS', 'Data Science','Makating','Accounting','Finances'] // Major
//                   .map(
//                     (major) =>
//                         DropdownMenuItem(value: major, child: Text(major)),
//                   )
//                   .toList(),
//           onChanged: (value) {
//             setState(() => _selectedMajor = value);
//           },
//           validator: (value) {
//             if (value == null || value.isEmpty) return 'Please select a major';
//             return null;
//           },
//         ),

//         _Dropdown(
//           value: _shift,
//           label: 'Shift',
//           items: ['Morning', 'Afternoon', 'Evening'],
//           onChanged: (v) => setState(() => _shift = v),
//           required: true,
//         ),
//         _Dropdown(
//           value: _programType,
//           label: 'Program Type',
//           items: ['Full-time', 'Part-time'],
//           onChanged: (v) => setState(() => _programType = v),
//           required: true,
//         ),
//       ],
//     );
//   }

//   // ───── STEP 5: Contact ─────
//   Widget _buildContactForm() {
//     return _Section(
//       title: "Contact Information",
//       children: [
//         _Field(
//           _phoneCtrl,
//           'Phone Number',
//           required: true,
//           keyboardType: TextInputType.phone,
//         ),
//         _Field(_guardianPhoneCtrl, 'Guardian Phone'),
//         // _Field(_emergencyNameCtrl, 'Emergency Contact Name'),
//         // _Field(_emergencyRelationCtrl, 'Relationship'),
//         // _Field(
//         //   _emergencyContactCtrl,
//         //   'Emergency Contact Number',
//         //   keyboardType: TextInputType.phone,
//         // ),
//         // _Field(_emergencyWorkplaceCtrl, 'Emergency Workplace'),
//       ],
//     );
//   }

//   // ───── REUSABLE WIDGETS ─────
//   Widget _Section({required String title, required List<Widget> children}) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const Divider(height: 24),
//             ...children
//                 .map(
//                   (w) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: w,
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _Row({required List<Widget> children}) {
//     return Row(
//       children: children
//           .map(
//             (c) => Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 6),
//                 child: c,
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }

//   Widget _Field(
//     TextEditingController controller,
//     String label, {
//     bool required = false,
//     TextInputType? keyboardType,
//   }) {
//     return CustomTextField(
//       controller: controller,
//       label: label,
//       required: required,
//       keyboardType: keyboardType,
//       validator: required
//           ? (value) =>
//                 value?.trim().isEmpty ?? true ? 'This field is required' : null
//           : null,
//     );
//   }

//   Widget _Dropdown({
//     String? value,
//     required String label,
//     required List<String> items,
//     required Function(String?) onChanged,
//     bool required = false,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       items: items
//           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//           .toList(),
//       onChanged: onChanged,
//       validator: required ? (v) => v == null ? 'Required' : null : null,
//     );
//   }

//   Widget _DateField(
//     TextEditingController controller,
//     String label, {
//     bool required = false,
//   }) {
//     return CustomTextField(
//       controller: controller,
//       label: label,
//       readOnly: true,
//       required: required,
//       prefixIcon: Icons.calendar_today,
//       suffixIcon: const Icon(Icons.arrow_drop_down),
//       validator: required
//           ? (v) => v?.isEmpty ?? true ? 'Date is required' : null
//           : null,
//       onTap: () async {
//         final date = await showDatePicker(
//           context: context,
//           initialDate: DateTime(2000),
//           firstDate: DateTime(1950),
//           lastDate: DateTime.now(),
//         );
//         if (date != null) {
//           controller.text = '${date.day}/${date.month}/${date.year}';
//         }
//       },
//     );
//   }
// }

// lib/screens/student/student_register_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_textfield.dart';
import 'student_home.dart';

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Use your Cloudinary credentials
  static const String cloudName = 'dxqkcp1hu';
  static const String uploadPreset = 'student_profiles';

  /// Uploads a receipt image to Cloudinary and returns the secure URL
  static Future<String?> uploadReceipt(Uint8List bytes, String fileName) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

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

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  bool _isSubmitting = false;

  // Controllers
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _bacYearCtrl = TextEditingController();
  final _highSchoolCtrl = TextEditingController();
  final _schoolLocationCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guardianPhoneCtrl = TextEditingController();
  final _telegramCtrl = TextEditingController();
  // final _idCardNumberCtrl = TextEditingController();

  // Dropdowns
  String? _selectedMajor;
  String? _gender;
  String? _educationLevel;
  String? _bacGrade;
  String? _careerType;
  String? _degree;
  String? _shift;
  String? _programType;

  // Uploads
  List<XFile>? _selectedImages;
  XFile? _idCardFile;
  XFile? _degreeFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    final controllers = [
      _lastNameCtrl,
      _firstNameCtrl,
      _dobCtrl,
      _nationalityCtrl,
      _fatherNameCtrl,
      _motherNameCtrl,
      _bacYearCtrl,
      _highSchoolCtrl,
      _schoolLocationCtrl,
      _countryCtrl,
      _provinceCtrl,
      _districtCtrl,
      _communeCtrl,
      _villageCtrl,
      _phoneCtrl,
      _guardianPhoneCtrl,
      _telegramCtrl,
      // _idCardNumberCtrl,
    ];
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ───── PICK IMAGES / FILES ─────
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null) setState(() => _selectedImages = images);
  }

  Future<void> _pickSingleFile(String type) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (type == 'id') _idCardFile = file;
        if (type == 'degree') _degreeFile = file;
      });
    }
  }

  // ───── UPLOAD FILE TO CLOUDINARY ─────
  Future<String?> _uploadFileToCloudinary(XFile file, String folder) async {
    final bytes = await file.readAsBytes();
    final fileName =
        '${folder}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    return await CloudinaryService.uploadReceipt(bytes, fileName);
  }

  // ───── SUBMIT ─────
  Future<void> _submit() async {
    if (!_formKeys.every((key) => key.currentState!.validate())) return;

    setState(() => _isSubmitting = true);

    // Upload files to Cloudinary
    List<String> photoUrls = [];
    String? idCardUrl;
    String? degreeUrl;

    try {
      if (_selectedImages != null) {
        for (var img in _selectedImages!) {
          final url = await _uploadFileToCloudinary(img, 'student_photos');
          if (url != null) photoUrls.add(url);
        }
      }

      if (_idCardFile != null) {
        idCardUrl = await _uploadFileToCloudinary(_idCardFile!, 'id_cards');
      }

      if (_degreeFile != null) {
        degreeUrl = await _uploadFileToCloudinary(_degreeFile!, 'degrees');
      }

      // Prepare data including registration date
      final data = {
        "lastName": _lastNameCtrl.text,
        "firstName": _firstNameCtrl.text,
        "gender": _gender,
        "dateOfBirth": _dobCtrl.text,
        "nationality": _nationalityCtrl.text,
        "fatherName": _fatherNameCtrl.text,
        "motherName": _motherNameCtrl.text,
        "educationLevel": _educationLevel,
        "bacYear": _bacYearCtrl.text,
        "highSchoolName": _highSchoolCtrl.text,
        "highSchoolLocation": _schoolLocationCtrl.text,
        "careerType": _careerType,
        "country": _countryCtrl.text,
        "province": _provinceCtrl.text,
        "district": _districtCtrl.text,
        "commune": _communeCtrl.text,
        "village": _villageCtrl.text,
        "degree": _degree,
        "major": _selectedMajor,
        "shift": _shift,
        "programType": _programType,
        "phone": _phoneCtrl.text,
        "guardianPhone": _guardianPhoneCtrl.text,
        "telegram": _telegramCtrl.text,
        // "idCardNumber": _idCardNumberCtrl.text,
        "photoUrls": photoUrls,
        "idCardImageUrl": idCardUrl,
        "degreeDocumentUrl": degreeUrl,
        "registrationDate": FieldValue.serverTimestamp(), // <-- Add date
      };

      await FirebaseFirestore.instance.collection('students_joinName').add(data); 

      setState(() => _isSubmitting = false);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Registration completed successfully!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHomeScreen(
            student: data,
            studentName: '',
            openChatStudent: null,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }

  // ───── BUILD ─────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // appBar: AppBar(title: const Text("Student Registration")),
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.blue)),
        child: Stepper(
          type: isWide ? StepperType.horizontal : StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            final form = _formKeys[_currentStep].currentState!;
            if (form.validate()) {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else if (!_isSubmitting) {
                _submit();
              }
            }
          },
          onStepCancel: () =>
              _currentStep > 0 ? setState(() => _currentStep--) : null,
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 4;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: _isSubmitting && isLastStep
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isLastStep ? "Submit" : "Next"),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Back"),
                  ),
              ],
            );
          },
          steps: [
            _buildStep(0, 'Personal', _buildPersonalInfoForm()),
            _buildStep(1, 'Education', _buildEducationForm()),
            _buildStep(2, 'Address', _buildAddressForm()),
            _buildStep(3, 'Program', _buildProgramForm()),
            _buildStep(4, 'Contact', _buildContactForm()),
          ],
        ),
      ),
    );
  }

  Step _buildStep(int index, String title, Widget content) {
    return Step(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      isActive: _currentStep >= index,
      state: _currentStep > index
          ? StepState.complete
          : (_currentStep == index ? StepState.editing : StepState.indexed),
      content: Form(
        key: _formKeys[index],
        child: Padding(padding: const EdgeInsets.all(16), child: content),
      ),
    );
  }

  // ───── FORM SECTIONS ─────
  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        _Field(_lastNameCtrl, 'Last Name', required: true),
        _Field(_firstNameCtrl, 'First Name', required: true),
        _Dropdown(
          value: _gender,
          label: 'Gender',
          items: ['Male', 'Female'],
          onChanged: (v) => setState(() => _gender = v),
          required: true,
        ),
        _DateField(_dobCtrl, 'Date of Birth', required: true),
        _Field(_nationalityCtrl, 'Nationality', required: true),
        _Field(_fatherNameCtrl, 'Father\'s Name'),
        _Field(_motherNameCtrl, 'Mother\'s Name'),
        // _Field(_telegramCtrl, 'Telegram ID'),
      ],
    );
  }

  Widget _buildEducationForm() {
    return Column(
      children: [
        _Dropdown(
          value: _educationLevel,
          label: 'Education Level',
          items: ['High School', 'Bachelor', 'Failed High School'],
          onChanged: (v) => setState(() => _educationLevel = v),
          required: true,
        ),
        _Field(_bacYearCtrl, 'Bac Year', required: true),
        _Field(_highSchoolCtrl, 'High School Name', required: true),
        _Field(_schoolLocationCtrl, 'High School Location', required: true),
        _Dropdown(
          value: _careerType,
          label: 'Career Type',
          items: ['Student', 'Staff'],
          onChanged: (v) => setState(() => _careerType = v),
          required: true,
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        _Field(_countryCtrl, 'Country', required: true),
        _Field(_provinceCtrl, 'Province', required: true),
        _Field(_districtCtrl, 'District', required: true),
        _Field(_communeCtrl, 'Commune', required: true),
        _Field(_villageCtrl, 'Village', required: true),
      ],
    );
  }

  Widget _buildProgramForm() {
    return Column(
      children: [
        _Dropdown(
          value: _degree,
          label: 'Degree',
          items: ['Associate', 'Bachelor', 'Master'],
          onChanged: (v) => setState(() => _degree = v),
          required: true,
        ),
        DropdownButtonFormField<String>(
          value: _selectedMajor,
          decoration: const InputDecoration(
            labelText: 'Major',
            border: OutlineInputBorder(),
          ),
          items:
              [
                    'FN',
                    'EE',
                    'ME',
                    'CS',
                    'Data Science',
                    'Marketing',
                    'Accounting',
                    'Finance',
                  ]
                  .map(
                    (major) =>
                        DropdownMenuItem(value: major, child: Text(major)),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _selectedMajor = v),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        _Dropdown(
          value: _shift,
          label: 'Shift',
          items: ['Morning', 'Afternoon', 'Evening'],
          onChanged: (v) => setState(() => _shift = v),
          required: true,
        ),
        _Dropdown(
          value: _programType,
          label: 'Program Type',
          items: ['Full-time', 'Part-time'],
          onChanged: (v) => setState(() => _programType = v),
          required: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickImages,
          child: const Text('Upload Photos'),
        ),
        if (_selectedImages != null)
          Text('${_selectedImages!.length} photos selected'),
        ElevatedButton(
          onPressed: () => _pickSingleFile('id'),
          child: const Text('Upload ID Card'),
        ),
        if (_idCardFile != null) Text('ID Card: ${_idCardFile!.name}'),
        ElevatedButton(
          onPressed: () => _pickSingleFile('degree'),
          child: const Text('Upload Degree Document'),
        ),
        if (_degreeFile != null) Text('Degree: ${_degreeFile!.name}'),
      ],
    );
  }

  Widget _buildContactForm() {
    return Column(
      children: [
        _Field(
          _phoneCtrl,
          'Phone Number',
          required: true,
          keyboardType: TextInputType.phone,
        ),
        _Field(
          _guardianPhoneCtrl,
          'Guardian Phone',
          keyboardType: TextInputType.phone,
        ),
        // _Field(_idCardNumberCtrl, 'ID Card Number'),
      ],
    );
  }

  // ───── REUSABLE WIDGETS ─────
  Widget _Field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      required: required,
      keyboardType: keyboardType,
    );
  }

  Widget _Dropdown({
    String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null ? 'Required' : null : null,
    );
  }

  Widget _DateField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      readOnly: true,
      required: required,
      prefixIcon: Icons.calendar_today,
      suffixIcon: const Icon(Icons.arrow_drop_down),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null)
          controller.text = '${date.day}/${date.month}/${date.year}';
      },
    );
  }
}

// Future<void> handleTelegramUpdate(Map<String, dynamic> update) async {
//   if (update.containsKey('message')) {
//     final message = update['message'];
//     final chat = message['chat'];
//     final chatId = chat['id'].toString(); // Telegram chatId (numeric ID)
//     final firstName = chat['first_name'] ?? '';
//     final lastName = chat['last_name'] ?? '';
//
//     print('🔹 Received Telegram /start from $firstName $lastName, chatId: $chatId');
//
//     // Update Firestore
//     final studentsCollection = FirebaseFirestore.instance.collection('students_joinName');
//
//     // Option 1: Find student by Telegram username if available
//     final username = message['from']['username'] ?? '';
//     QuerySnapshot querySnapshot;
//
//     if (username.isNotEmpty) {
//       querySnapshot = await studentsCollection
//           .where('telegram', isEqualTo: username)
//           .limit(1)
//           .get();
//     } else {
//       // Option 2: Fallback: match by first + last name
//       querySnapshot = await studentsCollection
//           .where('firstName', isEqualTo: firstName)
//           .where('lastName', isEqualTo: lastName)
//           .limit(1)
//           .get();
//     }
//
//     if (querySnapshot.docs.isNotEmpty) {
//       final studentDoc = querySnapshot.docs.first;
//       await studentDoc.reference.update({
//         'telegramChatId': chatId, // ✅ Save numeric Telegram ID
//       });
//       print('✅ Updated telegramChatId for ${studentDoc['firstName']} ${studentDoc['lastName']}');
//     } else {
//       print('⚠️ Student not found for Telegram user: $firstName $lastName');
//     }
//   }
// }

