import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_login_screen.dart';
import 'mentor_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060912),
      body: Stack(
        children: [
          CustomPaint(painter: _RoleGridPainter(), child: const SizedBox.expand()),
          Positioned(
            top: -150, left: -150,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFF6240).withValues(alpha: 0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E5FF), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text('JEE COUNSELLING PLATFORM',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10, color: const Color(0xFF00E5FF),
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFCCDDEE), Color(0xFF00E5FF), Color(0xFFB388FF)],
                        stops: [0.0, 0.35, 0.65, 1.0],
                      ).createShader(bounds),
                      child: Text('JEEGuide',
                          style: GoogleFonts.syne(
                              fontSize: 64, fontWeight: FontWeight.w800,
                              color: Colors.white, height: 0.95, letterSpacing: -2)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Smart counselling platform to help you\nnavigate your JEE journey with confidence.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSans(
                          fontSize: 15, color: const Color(0xFF8B99B5),
                          height: 1.7, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            icon: '🎓', title: 'Student',
                            desc: 'Explore colleges, predict admission chances & get expert guidance.',
                            accentColor: const Color(0xFF00E5FF),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const StudentLoginScreen())),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RoleCard(
                            icon: '🧑‍💼', title: 'Mentor',
                            desc: 'Guide students through their counselling journey.',
                            accentColor: const Color(0xFFFF6240),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const MentorLoginScreen())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RoleStatItem(num: '12K+', label: 'STUDENTS'),
                        Container(width: 1, height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.white.withValues(alpha: 0.08)),
                        _RoleStatItem(num: '850+', label: 'MENTORS'),
                        Container(width: 1, height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.white.withValues(alpha: 0.08)),
                        _RoleStatItem(num: '98%', label: 'SUCCESS RATE'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String icon, title, desc;
  final Color accentColor;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.desc,
      required this.accentColor, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.07),
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.accentColor.withValues(alpha: 0.15), blurRadius: 40)]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(widget.title,
                  style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700,
                      color: widget.accentColor)),
              const SizedBox(height: 8),
              Text(widget.desc,
                  style: GoogleFonts.instrumentSans(
                      fontSize: 12, color: const Color(0xFF8B99B5), height: 1.6)),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text('→', style: TextStyle(fontSize: 20, color: widget.accentColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleStatItem extends StatelessWidget {
  final String num, label;
  const _RoleStatItem({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: num.replaceAll(RegExp(r'[^0-9.]'), ''),
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            TextSpan(
              text: num.replaceAll(RegExp(r'[0-9.]'), ''),
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF00E5FF)),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 10, color: const Color(0xFF4D5B73), letterSpacing: 1.2)),
      ],
    );
  }
}

class _RoleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}