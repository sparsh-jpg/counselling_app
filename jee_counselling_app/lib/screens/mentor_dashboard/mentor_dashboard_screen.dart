import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connection_provider.dart';
import '../../screens/mentors/models/connection_model.dart';
import '../chat/chat_screen.dart';
import '../../services/storage_service.dart';
import '../../screens/mentors/models/app_user_model.dart';
import '../shared_widgets.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() =>
      _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final mentor = context.read<AuthProvider>().currentUser;
    if (mentor != null) {
      context.read<ConnectionProvider>().loadMentorConnections(mentor.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentor = context.watch<AuthProvider>().currentUser;
    final connProvider = context.watch<ConnectionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back 👋',
                          style: GoogleFonts.poppins(
                              color: Colors.white54, fontSize: 13)),
                      Text(mentor?.name ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          )),
                      Text(mentor?.college ?? '',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF00E5CC),
                              fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  if (connProvider.pendingRequests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active,
                              color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                              '${connProvider.pendingRequests.length} pending',
                              style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.white38, size: 20),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _statCard(
                      '${connProvider.pendingRequests.length}',
                      'Pending',
                      Colors.orange),
                  const SizedBox(width: 12),
                  _statCard(
                      '${connProvider.acceptedConnections.length}',
                      'Students',
                      const Color(0xFF00E5CC)),
                  const SizedBox(width: 12),
                  _statCard(
                    (mentor?.sessionPrice ?? 0) == 0
                        ? 'FREE'
                        : '₹${mentor?.sessionPrice}',
                    'Rate',
                    const Color(0xFF22C55E),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF00E5CC),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white54,
                labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Requests'),
                        if (connProvider.pendingRequests.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${connProvider.pendingRequests.length}',
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'My Students'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingRequests(connProvider),
                  _buildAcceptedStudents(connProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequests(ConnectionProvider connProvider) {
    final pending = connProvider.pendingRequests;
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 56, color: Colors.white12),
            const SizedBox(height: 12),
            Text('No pending requests',
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 15)),
            const SizedBox(height: 6),
            Text(
                'Students can connect with you\nfrom the Mentors section',
                style: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pending.length,
      itemBuilder: (context, i) => _RequestCard(request: pending[i]),
    );
  }

  Widget _buildAcceptedStudents(ConnectionProvider connProvider) {
    final accepted = connProvider.acceptedConnections;
    if (accepted.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined,
                size: 56, color: Colors.white12),
            const SizedBox(height: 12),
            Text('No students yet',
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 15)),
            Text('Accept requests to start connecting',
                style: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: accepted.length,
      itemBuilder: (context, i) {
        final conn = accepted[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00E5CC).withOpacity(0.2),
              child: Text(
                conn.studentName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(conn.studentName,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text('Connected',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF22C55E), fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconBtn(
                    Icons.chat_bubble_outline, const Color(0xFF00E5CC),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        connection: conn,
                        currentUserId:
                            context.read<AuthProvider>().currentUser!.id,
                        currentUserName: context
                            .read<AuthProvider>()
                            .currentUser!
                            .name,
                        otherName: conn.studentName,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                _iconBtn(Icons.videocam_outlined, Colors.purple, () {
                  Navigator.pushNamed(context, '/video-call', arguments: {
                    'channelName': 'jee_${conn.id}',
                    'otherName': conn.studentName,
                  });
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Virtual3DTilt(
        tiltIntensity: 0.2, // Stronger 3D on hover
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color.withOpacity(0.7), fontSize: 11)),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── REQUEST CARD ─────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ConnectionRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: StorageService().getUserById(request.studentId),
      builder: (context, snapshot) {
        final student = snapshot.data;
        
        return Virtual3DTilt(
          tiltIntensity: 0.06,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E), // slightly deeper background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    child: Text(
                      request.studentName.isNotEmpty ? request.studentName[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      )
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                request.studentName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Pending',
                                style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600
                                )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wants to connect with you',
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (student != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.email_outlined, 'Email', student.email),
                      if (student.jeeRank != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.leaderboard_outlined, 'JEE Rank', '#${student.jeeRank}'),
                      ],
                      if (student.jeeType != null && student.jeeType!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.category_outlined, 'Exam Type', student.jeeType!),
                      ],
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<ConnectionProvider>().rejectRequest(request.id),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.red.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Decline', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<ConnectionProvider>().acceptRequest(request.id),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF00E5CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Accept', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      }
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        Expanded(
          child: Text(
            value, 
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}