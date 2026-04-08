import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'student_login_screen.dart';
import 'mentor_login_screen.dart';
import 'shared_widgets.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030509),
      body: Stack(
        children: [
          // Animated Background Grid
          CustomPaint(painter: _RoleGridPainter(), child: const SizedBox.expand()),
          
          // Animated Orbs
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (_bgController.value * 50),
                    left: -150 + (_bgController.value * 30),
                    child: Container(
                      width: 600, height: 600,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150 - (_bgController.value * 40),
                    right: -100 - (_bgController.value * 60),
                    child: Container(
                      width: 500, height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E5FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12, spreadRadius: 2)
                              ]
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('WELCOME TO THE FUTURE OF LEARNING',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10, color: Colors.white70,
                                  fontWeight: FontWeight.w600, letterSpacing: 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'JEE',
                                style: GoogleFonts.montserrat(
                                    fontSize: 48, fontWeight: FontWeight.w800,
                                    color: Colors.white, letterSpacing: 2.0),
                              ),
                              TextSpan(
                                text: 'GUIDE',
                                style: GoogleFonts.montserrat(
                                    fontSize: 48, fontWeight: FontWeight.w300,
                                    color: const Color(0xFF00E5FF), letterSpacing: 6.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 60,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    
                    // Cards
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 550;
                          final cards = [
                            _RoleCard(
                              icon: '👨‍🎓', title: 'I am a Student',
                              desc: 'Access curated study materials, track your progress, and take mock tests.',
                              accentColor: const Color(0xFF00E5FF),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const StudentLoginScreen())),
                            ),
                            if (isDesktop) const SizedBox(width: 16) else const SizedBox(height: 16),
                            _RoleCard(
                              icon: '👨‍🏫', title: 'I am a Mentor',
                              desc: 'Connect with students, clear doubts, and guide the next generation.',
                              accentColor: const Color(0xFF7C3AED),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const MentorLoginScreen())),
                            ),
                          ];
                          
                          return isDesktop 
                            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: cards.map((c) => Expanded(child: c)).toList())
                            : Column(children: cards);
                        }
                      ),
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
  
  const _RoleCard({
    required this.icon, required this.title, required this.desc,
    required this.accentColor, required this.onTap
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic)
    );
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _animController.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _animController.reverse();
      },
      child: Virtual3DTilt(
        tiltIntensity: 0.2, // Make it very noticeable on login screen
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
          scale: _scaleAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _hovered ? 0.08 : 0.03),
                  border: Border.all(
                    color: _hovered
                        ? widget.accentColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: _hovered
                      ? [BoxShadow(color: widget.accentColor.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: -10)]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(widget.icon, style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.title,
                        style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(widget.desc,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white70, height: 1.5)),
                    const SizedBox(height: 24),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _hovered ? widget.accentColor : Colors.transparent,
                        border: Border.all(color: widget.accentColor),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Get Started', style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _hovered ? Colors.black : widget.accentColor,
                            fontWeight: FontWeight.bold,
                          )),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: _hovered ? Colors.black : widget.accentColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _RoleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    const step = 80.0;
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