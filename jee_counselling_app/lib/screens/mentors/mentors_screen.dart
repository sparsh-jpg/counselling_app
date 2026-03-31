import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connection_provider.dart';
import 'models/app_user_model.dart';
import 'models/connection_model.dart';
import '../../services/storage_service.dart';

// COMMENTED OUT UNTIL YOU CREATE THE FILE:
// import 'mentor_detail_screen.dart';

class MentorsScreen extends StatefulWidget {
  const MentorsScreen({super.key});

  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  final StorageService _storage = StorageService();
  List<AppUser> _mentors = [];
  List<AppUser> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMentors();
    final student = context.read<AuthProvider>().currentUser;
    if (student != null) {
      context.read<ConnectionProvider>().loadStudentConnections(student.id);
    }
  }

  Future<void> _loadMentors() async {
    setState(() => _loading = true);
    _mentors = await _storage.getMentors();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    List<AppUser> result = List.from(_mentors);
    if (_filter == 'IIT') {
      result = result
          .where((m) => (m.college ?? '').toUpperCase().contains('IIT'))
          .toList();
    } else if (_filter == 'NIT') {
      result = result
          .where((m) => (m.college ?? '').toUpperCase().contains('NIT'))
          .toList();
    } else if (_filter == 'IIIT') {
      result = result
          .where((m) => (m.college ?? '').toUpperCase().contains('IIIT'))
          .toList();
    } else if (_filter == 'Free') {
      result =
          result.where((m) => (m.sessionPrice ?? 0) == 0).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery) ||
              (m.college ?? '').toLowerCase().contains(_searchQuery) ||
              (m.branch ?? '').toLowerCase().contains(_searchQuery))
          .toList();
    }
    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mentors',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      _searchQuery = v.toLowerCase();
                      _applyFilter();
                    },
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search mentors, colleges, branches...',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF00E5CC), size: 18),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              // Filter chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'IIT', 'NIT', 'IIIT', 'Free']
                      .map((f) => _filterChip(f))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5CC)))
          : _filtered.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadMentors,
                  color: const Color(0xFF00E5CC),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) =>
                        _MentorCard(mentor: _filtered[i]),
                  ),
                ),
    );
  }

  Widget _filterChip(String label) {
    final isActive = _filter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = label);
        _applyFilter();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00E5CC)
              : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline,
              size: 60, color: Colors.white12),
          const SizedBox(height: 16),
          Text('No mentors found',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Mentors appear here after they register',
              style: GoogleFonts.poppins(
                  color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── MENTOR CARD ─────────────────────────────────────────────

class _MentorCard extends StatelessWidget {
  final AppUser mentor;
  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    final student = context.read<AuthProvider>().currentUser;
    final connProvider = context.watch<ConnectionProvider>();

    ConnectionRequest? conn;
    ConnectionStatus? status;
    if (student != null) {
      conn = connProvider.getConnection(student.id, mentor.id);
      status = conn?.status;
    }

    return GestureDetector(
      onTap: () {
        // CHANGED: Added a snackbar temporarily since MentorDetailScreen doesn't exist yet!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mentor detail screen coming soon!',
                style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF00E5CC).withOpacity(0.9),
          ),
        );
        
        // UNCOMMENT THIS ONCE YOU CREATE mentor_detail_screen.dart
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (_) => MentorDetailScreen(mentor: mentor)),
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF12121F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _avatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mentor.name,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        Text(mentor.college ?? '',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF00E5CC),
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        Text(mentor.branch ?? '',
                            style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Available',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF22C55E),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Stats
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '${mentor.mentorJeeType ?? "JEE Main"} AIR ${_fmt(mentor.mentorJeeRank ?? 0)}',
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 3),
                  Text('4.8',
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 11)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (mentor.sessionPrice ?? 0) == 0
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF00E5CC)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (mentor.sessionPrice ?? 0) == 0
                          ? 'FREE'
                          : '₹${mentor.sessionPrice}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (mentor.sessionPrice ?? 0) == 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF00E5CC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Expertise
              if (mentor.expertise.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: mentor.expertise
                      .take(3)
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(e,
                                style: GoogleFonts.poppins(
                                    color: Colors.white60, fontSize: 10)),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),

              // Connect / Pending / Message button
              _connectButton(context, student, conn, status, connProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectButton(
    BuildContext context,
    AppUser? student,
    ConnectionRequest? conn,
    ConnectionStatus? status,
    ConnectionProvider connProvider,
  ) {
    if (student == null) return const SizedBox();

    if (status == ConnectionStatus.pending) {
      return Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time,
                  color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              Text('Pending...',
                  style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (status == ConnectionStatus.accepted) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/chat', arguments: {
              'connection': conn,
              'otherName': mentor.name,
            });
          },
          icon: const Icon(Icons.chat_bubble_outline,
              size: 16, color: Colors.black),
          label: Text('Message',
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5CC),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      );
    }

    if (status == ConnectionStatus.rejected) {
      return Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Center(
          // FIXED COLOR TYPO HERE:
          child: Text('Request Declined',
              style: GoogleFonts.poppins(
                  color: Colors.red.withOpacity(0.54), fontSize: 13)), 
        ),
      );
    }

    // No connection yet - show Connect button
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () async {
          await connProvider.sendRequest(
            studentId: student.id,
            studentName: student.name,
            mentorId: mentor.id,
            mentorName: mentor.name,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Request sent to ${mentor.name}!',
                  style: GoogleFonts.poppins()),
              backgroundColor:
                  const Color(0xFF00E5CC).withOpacity(0.9),
            ));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text('Connect →',
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _avatar() {
    final initials = mentor.name
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join('');
    final colors = [
      [const Color(0xFF7C3AED), const Color(0xFF4A3AFF)],
      [const Color(0xFF059669), const Color(0xFF10B981)],
      [const Color(0xFFDC2626), const Color(0xFFF87171)],
      [const Color(0xFFD97706), const Color(0xFFFBBF24)],
    ];
    final pair = colors[mentor.id.hashCode % colors.length];
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: pair),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ),
    );
  }

  String _fmt(int rank) {
    if (rank == 0) return 'N/A';
    if (rank < 1000) return '$rank';
    return '${(rank / 1000).toStringAsFixed(1)}K';
  }
}