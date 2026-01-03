// // lib/models/student_registration.dart
// import 'package:equatable/equatable.dart';

// class StudentRegistration extends Equatable {
//   // ────────────────────── Step 1: Personal Info ──────────────────────
//   final String lastName;
//   final String firstName;
//   final String gender; // Male / Female
//   final String dateOfBirth; // e.g., "15/3/2000"
//   final String nationality;
//   // final String? telegram;
//   final String? fatherName;
//   final String? motherName;

//   // ────────────────────── Step 2: Education ──────────────────────
//   final String? educationLevel; // High School, Bachelor, Failed High School
//   final String? bacGrade; // NA, A, B, C, D, E, F, Auto
//   final String? bacCode;
//   final String? bacYear;
//   final String? highSchoolName;
//   final String? highSchoolLocation;
//   final String? careerType; // Student, Staff

//   // ────────────────────── Step 3: Address ──────────────────────
//   final String country;
//   final String? province;
//   final String? district;
//   final String? commune;
//   final String? village;

//   // ────────────────────── Step 4: Program ──────────────────────
//   final String? degree; // Associate, Bachelor, Master
//   final String? major;
//   final String? shift; // Morning, Afternoon, Evening
//   final String? programType; // Full-time, Part-time

//   // ────────────────────── Step 5: Contact ──────────────────────
//   final String phoneNumber;
//   final String? guardianNumber;
//   final String? emergencyName;
//   final String? emergencyRelation;
//   final String? emergencyContact;
//   final String? emergencyWorkplace;

//   const StudentRegistration({
//     required this.lastName,
//     required this.firstName,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.nationality,
//     // this.telegram,
//     this.fatherName,
//     this.motherName,
//     this.educationLevel,
//     this.bacGrade,
//     this.bacCode,
//     this.bacYear,
//     this.highSchoolName,
//     this.highSchoolLocation,
//     this.careerType,
//     // this.institution,
//     required this.country,
//     this.province,
//     this.district,
//     this.commune,
//     this.village,
//     this.degree,
//     this.major,
//     this.shift,
//     this.programType,
//     required this.phoneNumber,
//     this.guardianNumber,
//     this.emergencyName,
//     this.emergencyRelation,
//     this.emergencyContact,
//     this.emergencyWorkplace,
//   });

//   // ────────────────────── Copy With ──────────────────────
//   StudentRegistration copyWith({
//     String? lastName,
//     String? firstName,
//     String? gender,
//     String? dateOfBirth,
//     String? nationality,
//     // String? telegram,
//     String? fatherName,
//     String? motherName,
//     String? educationLevel,
//     String? bacGrade,
//     String? bacCode,
//     String? bacYear,
//     String? highSchoolName,
//     String? highSchoolLocation,
//     String? careerType,
//     String? institution,
//     String? country,
//     String? province,
//     String? district,
//     String? commune,
//     String? village,
//     String? degree,
//     String? major,
//     String? shift,
//     String? programType,
//     String? phoneNumber,
//     String? guardianNumber,
//     String? emergencyName,
//     // String? emergencyRelation,
//     // String? emergencyContact,
//     // String? emergencyWorkplace,
//   }) {
//     return StudentRegistration(
//       lastName: lastName ?? this.lastName,
//       firstName: firstName ?? this.firstName,
//       gender: gender ?? this.gender,
//       dateOfBirth: dateOfBirth ?? this.dateOfBirth,
//       nationality: nationality ?? this.nationality,
//       //telegram: telegram ?? this.telegram,
//       fatherName: fatherName ?? this.fatherName,
//       motherName: motherName ?? this.motherName,
//       educationLevel: educationLevel ?? this.educationLevel,
//       bacGrade: bacGrade ?? this.bacGrade,
//       bacCode: bacCode ?? this.bacCode,
//       bacYear: bacYear ?? this.bacYear,
//       highSchoolName: highSchoolName ?? this.highSchoolName,
//       highSchoolLocation: highSchoolLocation ?? this.highSchoolLocation,
//       careerType: careerType ?? this.careerType,
//       // institution: institution ?? this.institution,
//       country: country ?? this.country,
//       province: province ?? this.province,
//       district: district ?? this.district,
//       commune: commune ?? this.commune,
//       village: village ?? this.village,
//       degree: degree ?? this.degree,
//       major: major ?? this.major,
//       shift: shift ?? this.shift,
//       programType: programType ?? this.programType,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       guardianNumber: guardianNumber ?? this.guardianNumber,
//       emergencyName: emergencyName ?? this.emergencyName,
//       // emergencyRelation: emergencyRelation ?? this.emergencyRelation,
//       // emergencyContact: emergencyContact ?? this.emergencyContact,
//       // emergencyWorkplace: emergencyWorkplace ?? this.emergencyWorkplace,
//     );
//   }

//   // ────────────────────── toJson / fromJson ──────────────────────
//   Map<String, dynamic> toJson() {
//     return {
//       'last_name': lastName,
//       'first_name': firstName,
//       'gender': gender,
//       'date_of_birth': dateOfBirth,
//       'nationality': nationality,
//       //'telegram': telegram,
//       'father_name': fatherName,
//       'mother_name': motherName,
//       'education_level': educationLevel,
//       'bac_grade': bacGrade,
//       'bac_code': bacCode,
//       'bac_year': bacYear,
//       'high_school_name': highSchoolName,
//       'high_school_location': highSchoolLocation,
//       'career_type': careerType,
//       // 'institution': institution,
//       'country': country,
//       'province': province,
//       'district': district,
//       'commune': commune,
//       'village': village,
//       'degree': degree,
//       'major': major,
//       'shift': shift,
//       'program_type': programType,
//       'phone_number': phoneNumber,
//       'guardian_number': guardianNumber,
//       'emergency_name': emergencyName,
//       'emergency_relation': emergencyRelation,
//       'emergency_contact': emergencyContact,
//       'emergency_workplace': emergencyWorkplace,
//     };
//   }

//   factory StudentRegistration.fromJson(Map<String, dynamic> json) {
//     return StudentRegistration(
//       lastName: json['last_name'] as String,
//       firstName: json['first_name'] as String,
//       gender: json['gender'] as String,
//       dateOfBirth: json['date_of_birth'] as String,
//       nationality: json['nationality'] as String,
//      // telegram: json['telegram'] as String?,
//       fatherName: json['father_name'] as String?,
//       motherName: json['mother_name'] as String?,
//       educationLevel: json['education_level'] as String?,
//       bacGrade: json['bac_grade'] as String?,
//       // bacCode: json['bac_code'] as String?,
//       bacYear: json['bac_year'] as String?,
//       highSchoolName: json['high_school_name'] as String?,
//       highSchoolLocation: json['high_school_location'] as String?,
//       careerType: json['career_type'] as String?,
//       // institution: json['institution'] as String?,
//       country: json['country'] as String,
//       province: json['province'] as String?,
//       district: json['district'] as String?,
//       commune: json['commune'] as String?,
//       village: json['village'] as String?,
//       degree: json['degree'] as String?,
//       major: json['major'] as String?,
//       shift: json['shift'] as String?,
//       programType: json['program_type'] as String?,
//       phoneNumber: json['phone_number'] as String,
//       guardianNumber: json['guardian_number'] as String?,
//       emergencyName: json['emergency_name'] as String?,
//       // emergencyRelation: json['emergency_relation'] as String?,
//       // emergencyContact: json['emergency_contact'] as String?,
//       // emergencyWorkplace: json['emergency_workplace'] as String?,
//     );
//   }

//   // ────────────────────── Validation Helper ──────────────────────
//   bool get isValid {
//     return lastName.isNotEmpty &&
//         firstName.isNotEmpty &&
//         gender.isNotEmpty &&
//         dateOfBirth.isNotEmpty &&
//         nationality.isNotEmpty &&
//         country.isNotEmpty &&
//         phoneNumber.isNotEmpty;
//   }

//   @override
//   List<Object?> get props => [
//         lastName,
//         firstName,
//         gender,
//         dateOfBirth,
//         nationality,
//        // telegram,
//         fatherName,
//         motherName,
//         educationLevel,
//         bacGrade,
//         bacCode,
//         bacYear,
//         highSchoolName,
//         highSchoolLocation,
//         careerType,
//         // institution,
//         country,
//         province,
//         district,
//         commune,
//         village,
//         degree,
//         major,
//         shift,
//         programType,
//         phoneNumber,
//         guardianNumber,
//         emergencyName,
//         // emergencyRelation,
//         // emergencyContact,
//         // emergencyWorkplace,
//       ];
// }

// lib/models/student_registration.dart
import 'package:equatable/equatable.dart';

class StudentRegistration extends Equatable {
  // ────────────────────── Step 1: Personal Info ──────────────────────
  final String lastName;
  final String firstName;
  final String gender; // Male / Female
  final String dateOfBirth; // e.g., "15/3/2000"
  final String nationality;
  final String? telegram; // new
  final String? fatherName;
  final String? motherName;

  // ────────────────────── Step 2: Education ──────────────────────
  final String? educationLevel; // High School, Bachelor, Failed High School
  final String? bacGrade; // NA, A, B, C, D, E, F, Auto
  final String? bacCode;
  final String? bacYear;
  final String? highSchoolName;
  final String? highSchoolLocation;
  final String? careerType; // Student, Staff

  // ────────────────────── Step 3: Address ──────────────────────
  final String country;
  final String? province;
  final String? district;
  final String? commune;
  final String? village;

  // ────────────────────── Step 4: Program ──────────────────────
  final String? degree; // Associate, Bachelor, Master
  final String? major;
  final String? shift; // Morning, Afternoon, Evening
  final String? programType; // Full-time, Part-time

  // ────────────────────── Step 5: Contact ──────────────────────
  final String phoneNumber;
  final String? guardianNumber;
  final String? emergencyName;
  final String? emergencyRelation;
  final String? emergencyContact;
  final String? emergencyWorkplace;

  // ────────────────────── Files / Uploads ──────────────────────
  final List<String>? photoUrls; // new
  final String? idCardImageUrl; // new
  final String? degreeDocumentUrl; // new

  const StudentRegistration({
    required this.lastName,
    required this.firstName,
    required this.gender,
    required this.dateOfBirth,
    required this.nationality,
    this.telegram,
    this.fatherName,
    this.motherName,
    this.educationLevel,
    this.bacGrade,
    this.bacCode,
    this.bacYear,
    this.highSchoolName,
    this.highSchoolLocation,
    this.careerType,
    required this.country,
    this.province,
    this.district,
    this.commune,
    this.village,
    this.degree,
    this.major,
    this.shift,
    this.programType,
    required this.phoneNumber,
    this.guardianNumber,
    this.emergencyName,
    this.emergencyRelation,
    this.emergencyContact,
    this.emergencyWorkplace,
    this.photoUrls,
    this.idCardImageUrl,
    this.degreeDocumentUrl,
  });

  // ────────────────────── Copy With ──────────────────────
  StudentRegistration copyWith({
    String? lastName,
    String? firstName,
    String? gender,
    String? dateOfBirth,
    String? nationality,
    String? telegram,
    String? fatherName,
    String? motherName,
    String? educationLevel,
    String? bacGrade,
    String? bacCode,
    String? bacYear,
    String? highSchoolName,
    String? highSchoolLocation,
    String? careerType,
    String? country,
    String? province,
    String? district,
    String? commune,
    String? village,
    String? degree,
    String? major,
    String? shift,
    String? programType,
    String? phoneNumber,
    String? guardianNumber,
    String? emergencyName,
    String? emergencyRelation,
    String? emergencyContact,
    String? emergencyWorkplace,
    List<String>? photoUrls,
    String? idCardImageUrl,
    String? degreeDocumentUrl,
  }) {
    return StudentRegistration(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      telegram: telegram ?? this.telegram,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      educationLevel: educationLevel ?? this.educationLevel,
      bacGrade: bacGrade ?? this.bacGrade,
      bacCode: bacCode ?? this.bacCode,
      bacYear: bacYear ?? this.bacYear,
      highSchoolName: highSchoolName ?? this.highSchoolName,
      highSchoolLocation: highSchoolLocation ?? this.highSchoolLocation,
      careerType: careerType ?? this.careerType,
      country: country ?? this.country,
      province: province ?? this.province,
      district: district ?? this.district,
      commune: commune ?? this.commune,
      village: village ?? this.village,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      shift: shift ?? this.shift,
      programType: programType ?? this.programType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      guardianNumber: guardianNumber ?? this.guardianNumber,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyWorkplace: emergencyWorkplace ?? this.emergencyWorkplace,
      photoUrls: photoUrls ?? this.photoUrls,
      idCardImageUrl: idCardImageUrl ?? this.idCardImageUrl,
      degreeDocumentUrl: degreeDocumentUrl ?? this.degreeDocumentUrl,
    );
  }

  // ────────────────────── toJson / fromJson ──────────────────────
  Map<String, dynamic> toJson() {
    return {
      'last_name': lastName,
      'first_name': firstName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'nationality': nationality,
      'telegram': telegram,
      'father_name': fatherName,
      'mother_name': motherName,
      'education_level': educationLevel,
      'bac_grade': bacGrade,
      'bac_code': bacCode,
      'bac_year': bacYear,
      'high_school_name': highSchoolName,
      'high_school_location': highSchoolLocation,
      'career_type': careerType,
      'country': country,
      'province': province,
      'district': district,
      'commune': commune,
      'village': village,
      'degree': degree,
      'major': major,
      'shift': shift,
      'program_type': programType,
      'phone_number': phoneNumber,
      'guardian_number': guardianNumber,
      'emergency_name': emergencyName,
      'emergency_relation': emergencyRelation,
      'emergency_contact': emergencyContact,
      'emergency_workplace': emergencyWorkplace,
      'photo_urls': photoUrls,
      'id_card_image_url': idCardImageUrl,
      'degree_document_url': degreeDocumentUrl,
    };
  }

  factory StudentRegistration.fromJson(Map<String, dynamic> json) {
    return StudentRegistration(
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      nationality: json['nationality'] as String,
      telegram: json['telegram'] as String?,
      fatherName: json['father_name'] as String?,
      motherName: json['mother_name'] as String?,
      educationLevel: json['education_level'] as String?,
      bacGrade: json['bac_grade'] as String?,
      bacCode: json['bac_code'] as String?,
      bacYear: json['bac_year'] as String?,
      highSchoolName: json['high_school_name'] as String?,
      highSchoolLocation: json['high_school_location'] as String?,
      careerType: json['career_type'] as String?,
      country: json['country'] as String,
      province: json['province'] as String?,
      district: json['district'] as String?,
      commune: json['commune'] as String?,
      village: json['village'] as String?,
      degree: json['degree'] as String?,
      major: json['major'] as String?,
      shift: json['shift'] as String?,
      programType: json['program_type'] as String?,
      phoneNumber: json['phone_number'] as String,
      guardianNumber: json['guardian_number'] as String?,
      emergencyName: json['emergency_name'] as String?,
      emergencyRelation: json['emergency_relation'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyWorkplace: json['emergency_workplace'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      idCardImageUrl: json['id_card_image_url'] as String?,
      degreeDocumentUrl: json['degree_document_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    lastName,
    firstName,
    gender,
    dateOfBirth,
    nationality,
    telegram,
    fatherName,
    motherName,
    educationLevel,
    bacGrade,
    bacCode,
    bacYear,
    highSchoolName,
    highSchoolLocation,
    careerType,
    country,
    province,
    district,
    commune,
    village,
    degree,
    major,
    shift,
    programType,
    phoneNumber,
    guardianNumber,
    emergencyName,
    emergencyRelation,
    emergencyContact,
    emergencyWorkplace,
    photoUrls,
    idCardImageUrl,
    degreeDocumentUrl,
  ];
}
