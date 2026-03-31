class Cutoff {
  final String college;
  final String branch;
  final String type;
  final String state;
  final String category;
  final String quota;
  final String gender;
  final int opening;
  final int closing;

  Cutoff({
    required this.college,
    required this.branch,
    required this.type,
    required this.state,
    required this.category,
    required this.quota,
    required this.gender,
    required this.opening,
    required this.closing,
  });

  factory Cutoff.fromJson(Map<String, dynamic> j) {
    return Cutoff(
      college: j["college"] ?? "",
      branch: j["branch"] ?? "",
      type: j["type"] ?? "",
      state: j["state"] ?? "",

      // ✅ cleaned category
      category: j["category"]
          .toString()
          .replaceAll("\n", "")
          .replaceAll(" ", "")
          .toUpperCase(),

      quota: j["quota"] ?? "",

      // ✅ safe gender
      gender: j["gender"] ?? "Gender-Neutral",

      // ✅ safe int parsing
      opening: int.tryParse(j["opening"].toString()) ?? 0,
      closing: int.tryParse(j["closing"].toString()) ?? 0,
    );
  }
}