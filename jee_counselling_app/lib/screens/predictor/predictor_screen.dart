import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'provider/predictor_provider.dart';
import 'models/prediction_model.dart';
import '../../providers/auth_provider.dart';

class PredictorScreen extends StatelessWidget {
  const PredictorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictorProvider(),
      child: const _PredictorBody(),
    );
  }
}

class _PredictorBody extends StatefulWidget {
  const _PredictorBody();

  @override
  State<_PredictorBody> createState() => _PredictorBodyState();
}

class _PredictorBodyState extends State<_PredictorBody> {
  final rankController = TextEditingController();

  static const _bg = Color(0xFF060912);
  static const _s1 = Color(0xFF0D1117);
  static const _s2 = Color(0xFF111827);
  static const _cyan = Color(0xFF00E5FF);
  static const _t2 = Color(0xFF8B99B5);
  static const _t3 = Color(0xFF4D5B73);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictorProvider>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _s1,
        title: Text('College Predictor',
            style: GoogleFonts.syne(
                color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: _s1,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildField(
                  label: 'JEE RANK',
                  child: TextField(
                    controller: rankController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.jetBrainsMono(
                        color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your rank',
                      hintStyle: GoogleFonts.instrumentSans(
                          color: _t3, fontSize: 13),
                      filled: true,
                      fillColor: _s2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.07))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.07))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _cyan)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // CATEGORY + QUOTA
                Row(children: [
                  Expanded(
                    child: _buildField(
                      label: 'CATEGORY',
                      child: _buildDropdown(
                        value: provider.category,
                        items: const ['OPEN', 'OBC-NCL', 'SC', 'ST'],
                        onChanged: (v) => provider.setCategory(v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      label: 'QUOTA',
                      child: _buildDropdown(
                        value: provider.quota,
                        items: const ['OS', 'HS'],
                        onChanged: (v) => provider.setQuota(v!),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),

                // GENDER + TYPE
                Row(children: [
                  Expanded(
                    child: _buildField(
                      label: 'GENDER',
                      child: _buildDropdown(
                        value: provider.gender,
                        items: const ['Gender-Neutral', 'Female-only'], // ✅ FIXED
                        onChanged: (v) => provider.setGender(v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      label: 'COLLEGE TYPE',
                      child: _buildDropdown(
                        value: provider.selectedType,
                        items: const ['All', 'IIT', 'NIT', 'IIIT', 'GFTI'],
                        onChanged: (v) => provider.setType(v!),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final rank = int.tryParse(rankController.text);
                            if (rank == null || rank <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Enter a valid rank',
                                      style: GoogleFonts.instrumentSans()),
                                  backgroundColor: const Color(0xFFFF6240),
                                ),
                              );
                              return;
                            }
                            provider.setRank(rank);
                            final user = context.read<AuthProvider>().currentUser;
                            await provider.generatePredictions(userId: user?.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : Text('Predict Colleges →',
                            style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),

          // RESULTS
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _cyan))
                : provider.results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎓',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text('Enter your rank and predict',
                                style: GoogleFonts.instrumentSans(
                                    color: _t2, fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.results.length + 1, // +1 for the AI Card at the top
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return _AiInsightCard(provider: provider);
                          }
                          return _ResultCard(result: provider.results[i - 1], index: i - 1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: _t3,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _s2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: _s2,
          style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: _t3, size: 18),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// RESULT CARD
class _ResultCard extends StatelessWidget {
  final CollegePrediction result;
  final int index;

  const _ResultCard({required this.result, required this.index});

  Color get _chanceColor {
    if (result.probability >= 70) return const Color(0xFF00E676);
    if (result.probability >= 40) return const Color(0xFFFFD740);
    return const Color(0xFFFF6240);
  }

  String get _chanceLabel {
    if (result.probability >= 70) return 'High';
    if (result.probability >= 40) return 'Medium';
    return 'Low';
  }

  Color get _typeColor {
    switch (result.type) {
      case 'IIT': return const Color(0xFF00E5FF);
      case 'NIT': return const Color(0xFFB388FF);
      case 'IIIT': return const Color(0xFFFFD740);
      default: return const Color(0xFF00E676);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chip(result.type, _typeColor),
              _chip(
                '${result.probability.toInt()}% · $_chanceLabel',
                _chanceColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.college,
              style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(result.branch,
              style: GoogleFonts.instrumentSans(
                  fontSize: 13, color: const Color(0xFF8B99B5))),
          const SizedBox(height: 10),
          Row(children: [
            _rankChip('Opening', result.opening),
            const SizedBox(width: 8),
            _rankChip('Closing', result.closing),
            const Spacer(),
            Text(result.state,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, color: const Color(0xFF4D5B73))),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _rankChip(String label, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: GoogleFonts.instrumentSans(
                  fontSize: 11, color: const Color(0xFF4D5B73))),
          TextSpan(
              text: rank.toString(),
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// AI INSIGHT CARD
class _AiInsightCard extends StatelessWidget {
  final PredictorProvider provider;
  const _AiInsightCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isAiLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117), // Match ResultCard bg
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text("Gemini is analyzing your options...", 
              style: GoogleFonts.instrumentSans(color: const Color(0xFF00E5FF), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    if (provider.aiInsight == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), 
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 18),
              const SizedBox(width: 8),
              Text("Gemini Insight", 
                style: GoogleFonts.syne(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(provider.aiInsight!, 
            style: GoogleFonts.instrumentSans(color: Colors.white70, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}