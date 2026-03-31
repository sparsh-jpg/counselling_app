class CollegePrediction {
  final String college;
  final String branch;
  final String type;
  final String state;
  final double probability;
  final int opening;
  final int closing;

  CollegePrediction(
    this.college,
    this.branch,
    this.type,
    this.state,
    this.probability,
    this.opening,
    this.closing,
  );

  // ✅ formatted percentage (important for UI)
  String get probabilityText => "${probability.toStringAsFixed(0)}%";
}