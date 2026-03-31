import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/predictor_provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = context.watch<PredictorProvider>().results;

    if (results.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No predictions found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Predicted Colleges")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 BAR CHART
            _BarChart(results),

            const SizedBox(height: 24),

            /// 🔥 CARDS
            ...results.map((r) => _PredictionCard(r)).toList(),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// BEAUTIFUL CARD
////////////////////////////////////////////////////////////

class _PredictionCard extends StatelessWidget {
  final dynamic college;

  const _PredictionCard(this.college);

  @override
  Widget build(BuildContext context) {
    final p = college.probability;

    Color color;

    if (p >= 0.7)
      color = Colors.green;
    else if (p >= 0.4)
      color = Colors.orange;
    else
      color = Colors.blue;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text("${(p * 100).toInt()}%"),
        ),
        title: Text("${college.college}"),
        subtitle: Text(college.branch),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// BAR CHART
////////////////////////////////////////////////////////////

class _BarChart extends StatelessWidget {
  final List results;

  const _BarChart(this.results);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: List.generate(
            results.length > 6 ? 6 : results.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: results[i].probability * 100,
                  width: 18,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
