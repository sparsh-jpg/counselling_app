import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../predictor/predictor_screen.dart';
import '../mentors/mentors_screen.dart';
import '../role_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  String _studentName = 'Student';
  String _studentRank = '';

  final primary = const Color(0xff1E3A8A);
  final purple = const Color(0xff7C3AED);
  final accent = Colors.orange;

  final features = [
    Feature("Predict College", Icons.analytics, "AI prediction"),
    Feature("Colleges", Icons.school, "Browse IIT/NIT/IIIT"),
    Feature("Mentors", Icons.people, "Connect seniors"),
    Feature("Chat", Icons.chat_bubble, "Talk instantly"),
    Feature("Curriculum", Icons.menu_book, "Course insights"),
    Feature("Profile", Icons.person, "Settings"),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('student_name') ?? 'Student';
      _studentRank = prefs.getString('student_rank') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  List<MentorPreview> get mentors => [
    MentorPreview("Veenu Kaushik", "NIT Jalandhar", "ECE"),
    MentorPreview("Tarun Singh", "NIT Jalandhar", "CSE"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.chat),
        onPressed: () {},
      ),
      bottomNavigationBar: _bottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 20),
              _heroSection(),
              const SizedBox(height: 24),
              _featureGrid(),
              const SizedBox(height: 24),
              _journeyTracker(),
              const SizedBox(height: 24),
              _mentorCarousel(),
              const SizedBox(height: 24),
              _quickActions(),
              const SizedBox(height: 24),
              _insightsFeed(),
              const SizedBox(height: 24),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search colleges or mentors",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            const Icon(Icons.notifications, size: 30),
            Positioned(
              right: 0,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: accent,
                child: const Text("3",
                    style: TextStyle(fontSize: 9, color: Colors.white)),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _heroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, purple]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Welcome back, $_studentName 👋",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (_studentRank.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "JEE Rank: $_studentRank",
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white70, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard("12", "Predictions"),
              _statCard("2", "Mentors"),
              _statCard("5", "Messages"),
            ],
          )
        ],
      ),
    );
  }

  Widget _statCard(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70))
      ],
    );
  }

  Widget _featureGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: features.length,
      itemBuilder: (context, i) {
        final f = features[i];
        return OpenContainer(
          closedElevation: 0,
          closedColor: Colors.transparent,
          openBuilder: (_, __) {
            if (f.title == "Predict College") {
              return const PredictorScreen();
            } else if (f.title == "Mentors") {
              return const MentorsScreen();
            } else {
              return const Scaffold(
                body: Center(child: Text("Coming Soon")),
              );
            }
          },
          closedBuilder: (_, open) => GestureDetector(
            onTap: open,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(f.icon, size: 30, color: primary),
                  const SizedBox(height: 10),
                  Text(f.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(f.subtitle,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _journeyTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your College Journey",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const LinearProgressIndicator(value: 0.6, minHeight: 10),
        const SizedBox(height: 8),
        const Text("Step 3 of 4 completed",
            style: TextStyle(color: Colors.grey))
      ],
    );
  }

  Widget _mentorCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Featured Mentors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mentors.length,
            itemBuilder: (_, i) {
              final m = mentors[i];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ]),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primary,
                      child: Text(
                        m.name[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text(m.college,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                    Text(m.branch,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _quickActions() {
    return Wrap(
      spacing: 10,
      children: [
        _chip("Book Session"),
        _chip("Ask Question"),
        _chip("Rankings"),
      ],
    );
  }

  Widget _chip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: accent.withValues(alpha: 0.15),
    );
  }

  Widget _insightsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Campus Insights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(
          title: Text("How to choose branch smartly"),
          subtitle: Text("By IIT Senior"),
        ),
        ListTile(
          title: Text("Top hostels in NITs"),
          subtitle: Text("Student experiences"),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => setState(() => currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Colleges"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
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