class Mentor {
  final String id;
  final String name;
  final String college;
  final String branch;
  final int year;
  final double rating;
  final int reviewCount;
  final String bio;
  final List<String> expertise;
  final String avatarUrl;
  final bool isAvailable;
  final int sessionPrice;
  final int jeeRank;
  final String jeeType;

  const Mentor({
    required this.id,
    required this.name,
    required this.college,
    required this.branch,
    required this.year,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.expertise,
    required this.avatarUrl,
    required this.isAvailable,
    required this.sessionPrice,
    required this.jeeRank,
    required this.jeeType,
  });
}

class MentorReview {
  final String id;
  final String reviewerName;
  final String comment;
  final double rating;
  final DateTime date;

  const MentorReview({
    required this.id,
    required this.reviewerName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}

class ConnectRequest {
  final String studentName;
  final String studentEmail;
  final String studentRank;
  final DateTime requestedAt;
  bool isAccepted;

  ConnectRequest({
    required this.studentName,
    required this.studentEmail,
    required this.studentRank,
    required this.requestedAt,
    this.isAccepted = false,
  });
}