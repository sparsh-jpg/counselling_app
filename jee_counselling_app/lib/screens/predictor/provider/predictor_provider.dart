import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/cutoff_model.dart';
import '../models/prediction_model.dart';

class PredictorProvider extends ChangeNotifier {
  int rank = 0;
  String category = "OPEN";
  String quota = "OS";

  // ✅ FIXED (was GN)
  String gender = "Gender-Neutral";

  String selectedType = "All";
  String selectedState = "All";

  List<CollegePrediction> results = [];
  bool isLoading = false;

  void setRank(int r) { rank = r; notifyListeners(); }
  void setCategory(String c) { category = c; notifyListeners(); }
  void setQuota(String q) { quota = q; notifyListeners(); }
  void setGender(String g) { gender = g; notifyListeners(); }
  void setType(String t) { selectedType = t; notifyListeners(); }
  void setState2(String s) { selectedState = s; notifyListeners(); }

  Future<void> generatePredictions() async {
    isLoading = true;
    notifyListeners();

    final jsonStr = await rootBundle.loadString('assets/cutoffs.json');
    final List jsonList = jsonDecode(jsonStr);
    final cutoffs = jsonList.map((e) => Cutoff.fromJson(e)).toList();

    results.clear();

    for (var c in cutoffs) {

      // ✅ Safer category match
      if (c.category.replaceAll('-', '').toUpperCase() != 
          category.replaceAll('-', '').toUpperCase()) continue;

      if (c.quota != quota) continue;
      if (c.gender != gender) continue;
      if (selectedType != "All" && c.type != selectedType) continue;

      // ❌ TEMP FIX (remove if state not in JSON)
      // if (selectedState != "All" && c.state != selectedState) continue;

      double prob;

      // ✅ Improved probability logic
      if (rank < c.opening) {
        prob = 95;
      } else if (rank <= c.closing) {
        double ratio = (c.closing - rank) / (c.closing - c.opening);
        prob = 60 + (ratio * 35);
      } else if (rank <= c.closing * 1.15) {
        prob = 35;
      } else if (rank <= c.closing * 1.3) {
        prob = 15;
      } else {
        continue;
      }

      results.add(CollegePrediction(
        c.college,
        c.branch,
        c.type,
        c.state, // keep if your model has it
        prob,    // already in %
        c.opening,
        c.closing,
      ));
    }

    // ✅ Sort by highest probability
    results.sort((a, b) => b.probability.compareTo(a.probability));

    isLoading = false;
    notifyListeners();
  }
}