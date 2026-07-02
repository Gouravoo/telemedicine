/// Time slot for doctor availability
class TimeSlot {
  final String startTime; // "09:00"
  final String endTime; // "09:30"
  final bool isBooked;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'isBooked': isBooked,
      };
}

/// Doctor profile model stored in Firestore `doctors` collection
class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String specialty;
  final String? qualifications;
  final int experienceYears;
  final double consultationFee;
  final double rating;
  final int ratingCount;
  final String? bio;
  final bool isActive;
  final Map<String, List<TimeSlot>> availability; // { "Monday": [slots] }

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.specialty,
    this.qualifications,
    this.experienceYears = 0,
    this.consultationFee = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.bio,
    this.isActive = true,
    this.availability = const {},
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final availMap = <String, List<TimeSlot>>{};
    if (json['availability'] != null) {
      (json['availability'] as Map<String, dynamic>).forEach((day, slots) {
        availMap[day] = (slots as List<dynamic>)
            .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
            .toList();
      });
    }

    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      specialty: json['specialty'] as String? ?? 'General',
      qualifications: json['qualifications'] as String?,
      experienceYears: json['experienceYears'] as int? ?? 0,
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      bio: json['bio'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      availability: availMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'specialty': specialty,
        'qualifications': qualifications,
        'experienceYears': experienceYears,
        'consultationFee': consultationFee,
        'rating': rating,
        'ratingCount': ratingCount,
        'bio': bio,
        'isActive': isActive,
        'availability': availability.map(
          (day, slots) => MapEntry(day, slots.map((s) => s.toJson()).toList()),
        ),
      };

  DoctorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? specialty,
    String? qualifications,
    int? experienceYears,
    double? consultationFee,
    double? rating,
    int? ratingCount,
    String? bio,
    bool? isActive,
    Map<String, List<TimeSlot>>? availability,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      specialty: specialty ?? this.specialty,
      qualifications: qualifications ?? this.qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      consultationFee: consultationFee ?? this.consultationFee,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      availability: availability ?? this.availability,
    );
  }
}
