enum UserRole { student, mentor }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final UserRole role;

  // Student fields
  final int? jeeRank;
  final String? jeeType;

  // Mentor fields
  final String? college;
  final String? branch;
  final int? year;
  final List<String> expertise;
  final int? sessionPrice;
  final int? mentorJeeRank;
  final String? mentorJeeType;
  final String? bio;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.jeeRank,
    this.jeeType,
    this.college,
    this.branch,
    this.year,
    this.expertise = const [],
    this.sessionPrice,
    this.mentorJeeRank,
    this.mentorJeeType,
    this.bio,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      role: json['role'] == 'mentor' ? UserRole.mentor : UserRole.student,
      jeeRank: json['jeeRank'],
      jeeType: json['jeeType'],
      college: json['college'],
      branch: json['branch'],
      year: json['year'],
      expertise: List<String>.from(json['expertise'] ?? []),
      sessionPrice: json['sessionPrice'],
      mentorJeeRank: json['mentorJeeRank'],
      mentorJeeType: json['mentorJeeType'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'role': role == UserRole.mentor ? 'mentor' : 'student',
      'jeeRank': jeeRank,
      'jeeType': jeeType,
      'college': college,
      'branch': branch,
      'year': year,
      'expertise': expertise,
      'sessionPrice': sessionPrice,
      'mentorJeeRank': mentorJeeRank,
      'mentorJeeType': mentorJeeType,
      'bio': bio,
    };
  }

  AppUser copyWith({
    String? name,
    String? college,
    String? branch,
    int? year,
    List<String>? expertise,
    int? sessionPrice,
    int? mentorJeeRank,
    String? mentorJeeType,
    String? bio,
    int? jeeRank,
    String? jeeType,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      passwordHash: passwordHash,
      role: role,
      jeeRank: jeeRank ?? this.jeeRank,
      jeeType: jeeType ?? this.jeeType,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      expertise: expertise ?? this.expertise,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      mentorJeeRank: mentorJeeRank ?? this.mentorJeeRank,
      mentorJeeType: mentorJeeType ?? this.mentorJeeType,
      bio: bio ?? this.bio,
    );
  }
}