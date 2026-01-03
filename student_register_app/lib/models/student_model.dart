// import 'package:cloud_firestore/cloud_firestore.dart';

// class Student {
//   final int id;
//   final String firstName;
//   final String lastName;
//   final String photoUrl;
//   DateTime? createdAt; // Add this line

//   // final String email;
//   final String gender;
//   final String? major;
//   final String? year;
//   final String status;
//   final String? nationality;
//   final String? dateOfBirth;
//   final String? degree;
//   final String? shift;
//   final String? village;
//   final String? commune;
//   final String? district;
//   final String? province;

//   // Student account
//   final String? studentId;
//   final String? password;
//   // final String? status;

//   Student({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     this.photoUrl = '',

//     this.createdAt, // Add this to the constructor
//     // required this.email,
//     required this.gender,
//     this.major,
//     // this.yearLevel,
//     this.year,
//     this.status = 'Pending',
//     this.nationality,
//     this.dateOfBirth,
//     this.degree,
//     this.shift,
//     this.village,
//     this.commune,
//     this.district,
//     this.province,

//     // Student account
//     this.studentId,
//     this.password,
//   });

//   // CORRECTED copyWith
//   Student copyWith({
//     String? firstName,
//     String? lastName,
//     required String status,
//     String? studentId,
//     String? password,
//     required String docId,
//   }) {
//     return Student(
//       id: id, // Fixed: was 'studentId'
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       photoUrl: photoUrl,
//       // email: email ?? this.email,
//       gender: gender,
//       major: major,
//       // yearLevel: yearLevel,
//       year: year,
//       status: status,
//       nationality: nationality,
//       dateOfBirth: dateOfBirth,
//       degree: degree,
//       shift: shift,
//       village: village,
//       commune: commune,
//       district: district,
//       province: province,

//       // Student account
//       studentId: studentId ?? this.studentId,
//       password: password ?? this.password,
//     );
//   }

//   // Optional: toMap / fromMap for JSON
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'firstName': firstName,
//       'lastName': lastName,
//       'photoUrl': photoUrl,

//       'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,

//       // 'email': email,
//       'gender': gender,
//       'major': major,
//       // 'yearLevel': yearLevel,
//       'Years': year,
//       'status': status,
//       'nationality': nationality,
//       'dateOfBirth': dateOfBirth,
//       'degree': degree,
//       'shift': shift,
//       'village': village,
//       'commune': commune,
//       'district': district,
//       'province': province,

//       // Student account
//       'studentId': studentId,
//       'password': password,
//     };
//   }

//   factory Student.fromMap(Map<String, dynamic> map, {required String docId}) {
//     return Student(
//       // id: map['id'] as int,
//       id: map['id'] is int
//           ? map['id'] as int
//           : int.tryParse(map['id']?.toString() ?? '0') ?? 0,

//       createdAt: map['createdAt'] != null
//           ? (map['createdAt'] as Timestamp).toDate()
//           : DateTime.now(),

//       firstName: map['firstName'] as String,
//       lastName: map['lastName'] as String,
//       // email: map['email'] as String,
//       photoUrl: map['photoUrl'] ?? '', // 🔥 IMPORTANT

//       gender: map['gender'] as String,
//       major: map['major'] as String?,
//       // yearLevel: map['yearLevel'] as String?,
//       year: map['Years'] as String?,
//       status: map['status'] as String? ?? 'Pending',
//       nationality: map['nationality'] as String?,
//       dateOfBirth: map['dateOfBirth'] as String?,
//       degree: map['degree'] as String?,
//       shift: map['shift'] as String?,
//       village: map['village'] as String?,
//       commune: map['commune'] as String?,
//       district: map['district'] as String?,
//       province: map['province'] as String?,

//       // Student account
//       studentId: map['studentId'] as String?,
//       password: map['password'] as String?,
//     );
//   }

//   get docId => null;
// }

// // Optional: Keep Address if you want to group later
// class Address {
//   final String country;
//   final String province;
//   final String district;
//   final String commune;
//   final String village;

//   Address({
//     required this.country,
//     required this.province,
//     required this.district,
//     required this.commune,
//     required this.village,
//   });

//   Map<String, dynamic> toMap() => {
//     'country': country,
//     'province': province,
//     'district': district,
//     'commune': commune,
//     'village': village,
//   };
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final int id;
  final String firstName;
  final String lastName;
  final String photoUrl;
  DateTime? createdAt;
  final String? telegramChatId;


  // Image fields
  final String? idCardImageUrl;
  final String? degreeDocumentUrl;
  final List<String>? photoUrls;

  // Additional info
  final String? fatherName;
  final String? motherName;
  final String? phone;
  final String? guardianPhone;
  final String? telegram;
  final String? idCardNumber;
  final String? educationLevel;
  final String? programType;
  final String? careerType;
  final String? bacYear;
  final String? highSchoolName;
  final String? highSchoolLocation;

  final String gender;
  final String? major;
  final String? year;
  final String status;
  final String? nationality;
  final String? dateOfBirth;
  final String? degree;
  final String? shift;
  final String? village;
  final String? commune;
  final String? district;
  final String? province;

  final String? studentId;
  final String? password;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl = '',
    this.createdAt,
    this.telegramChatId,

    this.idCardImageUrl,
    this.degreeDocumentUrl,
    this.photoUrls,

    required this.gender,
    this.major,
    this.year,
    this.status = 'Pending',
    this.nationality,
    this.dateOfBirth,
    this.degree,
    this.shift,
    this.village,
    this.commune,
    this.district,
    this.province,
    this.studentId,
    this.password,
    this.fatherName,
    this.motherName,
    this.phone,
    this.guardianPhone,
    this.telegram,
    this.idCardNumber,
    this.educationLevel,
    this.programType,
    this.careerType,
    this.bacYear,
    this.highSchoolName,
    this.highSchoolLocation,
  });

  Student copyWith({
    String? firstName,
    String? lastName,
    String? status,
    String? studentId,
    String? password,
    String? idCardImageUrl,
    String? degreeDocumentUrl,
    List<String>? photoUrls,
    String? fatherName,
    String? motherName,
    String? phone,
    String? guardianPhone,
    String? telegram,
    String? idCardNumber,
    String? educationLevel,
    String? programType,
    String? careerType,
    String? bacYear,
    String? highSchoolName,
    String? highSchoolLocation,
    required String docId,
  }) {
    return Student(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      idCardImageUrl: idCardImageUrl ?? this.idCardImageUrl,
      degreeDocumentUrl: degreeDocumentUrl ?? this.degreeDocumentUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      gender: gender,
      major: major,
      year: year,
      status: status ?? this.status,
      nationality: nationality,
      dateOfBirth: dateOfBirth,
      degree: degree,
      shift: shift,
      village: village,
      commune: commune,
      district: district,
      province: province,
      studentId: studentId ?? this.studentId,
      password: password ?? this.password,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      phone: phone ?? this.phone,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      telegram: telegram ?? this.telegram,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      educationLevel: educationLevel ?? this.educationLevel,
      programType: programType ?? this.programType,
      careerType: careerType ?? this.careerType,
      bacYear: bacYear ?? this.bacYear,
      highSchoolName: highSchoolName ?? this.highSchoolName,
      highSchoolLocation: highSchoolLocation ?? this.highSchoolLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'idCardImageUrl': idCardImageUrl,
      'degreeDocumentUrl': degreeDocumentUrl,
      'photoUrls': photoUrls,
      'gender': gender,
      'major': major,
      'Years': year,
      'status': status,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth,
      'degree': degree,
      'shift': shift,
      'village': village,
      'commune': commune,
      'district': district,
      'province': province,
      'studentId': studentId,
      'password': password,
      'fatherName': fatherName,
      'motherName': motherName,
      'phone': phone,
      'guardianPhone': guardianPhone,
      'telegram': telegram,
      'idCardNumber': idCardNumber,
      'educationLevel': educationLevel,
      'programType': programType,
      'careerType': careerType,
      'bacYear': bacYear,
      'highSchoolName': highSchoolName,
      'highSchoolLocation': highSchoolLocation,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, {required String docId}) {
    return Student(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      photoUrl: map['photoUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      idCardImageUrl: map['idCardImageUrl'] as String?,
      degreeDocumentUrl: map['degreeDocumentUrl'] as String?,
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls']) : null,
      // idCardImageUrl: map['idCardImageUrl'] as String?,
      // degreeDocumentUrl: map['degreeDocumentUrl'] as String?,

      // photoUrls: map['photoUrls'] != null
      //     ? List<String>.from(map['photoUrls'])
      //     : [],

      gender: map['gender'] as String,
      major: map['major'] as String?,
      year: map['Years'] as String?,
      status: map['status'] as String? ?? 'Pending',
      nationality: map['nationality'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      degree: map['degree'] as String?,
      shift: map['shift'] as String?,
      village: map['village'] as String?,
      commune: map['commune'] as String?,
      district: map['district'] as String?,
      province: map['province'] as String?,
      studentId: map['studentId'] as String?,
      password: map['password'] as String?,
      fatherName: map['fatherName'] as String?,
      motherName: map['motherName'] as String?,
      phone: map['phone'] as String?,
      guardianPhone: map['guardianPhone'] as String?,
      telegram: map['telegram'] as String?,
      idCardNumber: map['idCardNumber'] as String?,
      educationLevel: map['educationLevel'] as String?,
      programType: map['programType'] as String?,
      careerType: map['careerType'] as String?,
      bacYear: map['bacYear'] as String?,
      highSchoolName: map['highSchoolName'] as String?,
      highSchoolLocation: map['highSchoolLocation'] as String?,
    );
  }

  get docId => null;
}
