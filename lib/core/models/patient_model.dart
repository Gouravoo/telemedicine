/// Patient profile data — extends user info with medical details
class PatientModel {
  final String uid;
  final int? age;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final List<String> medicalHistory;

  const PatientModel({
    required this.uid,
    this.age,
    this.gender,
    this.bloodGroup,
    this.address,
    this.medicalHistory = const [],
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      uid: json['uid'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      address: json['address'] as String?,
      medicalHistory: (json['medicalHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'age': age,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'address': address,
        'medicalHistory': medicalHistory,
      };

  PatientModel copyWith({
    String? uid,
    int? age,
    String? gender,
    String? bloodGroup,
    String? address,
    List<String>? medicalHistory,
  }) {
    return PatientModel(
      uid: uid ?? this.uid,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }
}
