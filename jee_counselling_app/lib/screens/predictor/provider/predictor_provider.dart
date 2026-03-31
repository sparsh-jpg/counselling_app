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

    try {
      final jsonStr = await rootBundle.loadString('assets/cutoffs.json');
      final List jsonList = jsonDecode(jsonStr);
      final cutoffs = jsonList.map((e) => Cutoff.fromJson(e)).toList();

      results.clear();

      // Helper function to strip spaces and hyphens for foolproof matching
      String normalize(String str) {
        return str.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
      }

      for (var c in cutoffs) {
        // Apply Filters
        if (normalize(c.category) != normalize(category)) continue;
        if (c.quota != quota) continue;
        if (c.gender != gender) continue;
        if (selectedType != "All" && c.type != selectedType) continue;
        
        // Note: State filtering remains skipped as 'state' is not in cutoffs.json

        double prob;

        // Calculate Probability safely
        if (rank < c.opening) {
          prob = 95.0;
        } else if (rank <= c.closing) {
          if (c.closing == c.opening) {
             // Safeguard against Division by Zero if opening and closing are identical
             prob = 80.0; 
          } else {
             double ratio = (c.closing - rank) / (c.closing - c.opening);
             prob = 60.0 + (ratio * 35.0);
          }
        } else if (rank <= c.closing * 1.15) {
          prob = 35.0;
        } else if (rank <= c.closing * 1.3) {
          prob = 15.0;
        } else {
          continue; // Completely out of range
        }

        results.add(CollegePrediction(
          c.college,
          c.branch,
          c.type,
          c.state, // Ensure your Cutoff.fromJson handles this safely if missing in JSON
          prob,
          c.opening,
          c.closing,
        ));
      }

      // Sort by highest probability first
      results.sort((a, b) => b.probability.compareTo(a.probability));

    } catch (e) {
      print("Error generating predictions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}