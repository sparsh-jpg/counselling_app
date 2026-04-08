import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../predictor/predictor_screen.dart';
import '../mentors/mentors_screen.dart';
import '../role_selection_screen.dart';
import '../shared_widgets.dart';
import '../../services/storage_service.dart';
import '../../providers/connection_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  final primary = const Color(0xff1E3A8A);
  final purple = const Color(0xff7C3AED);
  final accent = const Color(0xFF00E5FF); // Match student node accent

  final features = [
    Feature("Predict College", Icons.analytics, "AI prediction"),
    Feature("Colleges", Icons.school, "Browse IIT/NIT/IIIT"),
    Feature("Mentors", Icons.people, "Connect seniors"),
    Feature("Chat", Icons.chat_bubble, "Talk instantly"),
    Feature("Curriculum", Icons.menu_book, "Course insights"),
    Feature("Profile", Icons.person, "Settings"),
  ];

  int _predictionsCount = 0;
  int _messagesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Slight delay to ensure context is ready
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final pCount = await StorageService().getPredictionCount(user.id);
      final mCount = await StorageService().getTotalMessagesCount(user.id);
      if (mounted) {
        setState(() {
          _predictionsCount = pCount;
          _messagesCount = mCount;
        });
      }
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    String name = user?.name ?? 'Student';
    if (name == 'Recovered User' &&
        user?.email != null &&
        user!.email.contains('@')) {
      final prefix = user.email.split('@')[0];
      name = prefix[0].toUpperCase() + prefix.substring(1);
    }

    final rank = user?.jeeRank?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.chat, color: Colors.black),
        onPressed: () {},
      ),
      body: Stack(
        children: [
          const LoginAIBg(accentColor: Color(0xFF00E5FF)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 24),
                  _heroSection(name, rank),
                  const SizedBox(height: 24),
                  _featureGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _topBar() {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.instrumentSans(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search colleges or mentors",
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _heroSection(String name, String rank) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: _glassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Welcome back, $name 👋",
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (rank.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "JEE Rank: $rank",
                  style: GoogleFonts.jetBrainsMono(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem("$_predictionsCount", "Predictions"),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                _statItem(
                  "${context.watch<ConnectionProvider>().acceptedConnections.length}",
                  "Mentors",
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                _statItem("$_messagesCount", "Messages"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.jetBrainsMono(
            color: accent,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _featureGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: features.length,
      itemBuilder: (context, i) {
        final f = features[i];
        return Virtual3DTilt(
          tiltIntensity: 0.15,
          child: OpenContainer(
            closedElevation: 0,
            closedColor: Colors.transparent,
            openBuilder: (_, _) {
              if (f.title == "Predict College") {
                return const PredictorScreen();
              } else if (f.title == "Mentors") {
                return const MentorsScreen();
              } else {
                return Scaffold(
                  backgroundColor: const Color(0xFF02040A),
                  appBar: AppBar(
                    title: Text(f.title),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  body: Center(
                    child: Text(
                      "Coming Soon: ${f.title}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            closedBuilder: (_, open) => GestureDetector(
              onTap: open,
              child: _glassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f.icon, size: 28, color: accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f.title,
                      style: GoogleFonts.syne(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.subtitle,
                      style: GoogleFonts.instrumentSans(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Feature {
  final String title;
  final IconData icon;
  final String subtitle;
  Feature(this.title, this.icon, this.subtitle);
}

class MentorPreview {
  final String name;
  final String college;
  final String branch;
  MentorPreview(this.name, this.college, this.branch);
}
