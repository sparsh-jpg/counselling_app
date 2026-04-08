import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;

class LoginTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const LoginTab({super.key,
      required this.label, required this.active,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active ? LinearGradient(
              colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.5) : Colors.transparent,
            ),
            boxShadow: active
                ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : const Color(0xFF6B7280),
              )),
        ),
      ),
    );
  }
}

class LoginField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color accent;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final bool enabled;
  final Iterable<String>? autofillHints;
  const LoginField({super.key,
      required this.label, required this.controller,
      required this.accent, this.keyboardType,
      this.obscure = false, this.suffix, this.enabled = true,
      this.autofillHints});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(label,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              enabled: enabled,
              autofillHints: autofillHints,
              style: GoogleFonts.instrumentSans(color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.4), fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.01),
                suffixIcon: suffix,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoginAIBg extends StatefulWidget {
  final Color accentColor;
  const LoginAIBg({super.key, required this.accentColor});
  @override
  State<LoginAIBg> createState() => _LoginAIBgState();
}

class _LoginAIBgState extends State<LoginAIBg> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          children: [
            Container(color: const Color(0xFF02040A)), // Deep AI dark
            // Neural Grid
            CustomPaint(painter: _AIGridPainter(_ctrl.value), child: const SizedBox.expand()),
            // Floating Plasma 1
            Positioned(
              left: MediaQuery.of(context).size.width * 0.2 * math.cos(_ctrl.value * 2 * math.pi),
              top: MediaQuery.of(context).size.height * 0.2 * math.sin(_ctrl.value * 2 * math.pi),
              child: _Plasma(color: widget.accentColor, size: 600),
            ),
            // Floating Plasma 2
            Positioned(
              right: MediaQuery.of(context).size.width * 0.2 * math.sin(_ctrl.value * 2 * math.pi),
              bottom: MediaQuery.of(context).size.height * 0.2 * math.cos(_ctrl.value * 2 * math.pi),
              child: _Plasma(color: const Color(0xFF7C3AED), size: 500), // Purple mix
            ),
          ],
        );
      }
    );
  }
}

class _Plasma extends StatelessWidget {
  final Color color;
  final double size;
  const _Plasma({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: 0.2),
          Colors.transparent,
        ]),
      ),
    );
  }
}

class _AIGridPainter extends CustomPainter {
  final double progress;
  _AIGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;
    const step = 40.0;
    
    // Draw dots at intersections
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);

    // Animate lines to give a 3D moving-forward / scrolling effect
    final double offset = progress * step;
    
    for (double x = offset; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = offset; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    for (double x = offset; x < size.width; x += step) {
      for (double y = offset; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _AIGridPainter oldDelegate) => progress != oldDelegate.progress;
}

/// A wrapper to provide an interactive 3D "tilt" parallax effect on hover, 
/// making the design feel extremely virtual and innovative.
class Virtual3DTilt extends StatefulWidget {
  final Widget child;
  final double tiltIntensity;
  const Virtual3DTilt({super.key, required this.child, this.tiltIntensity = 0.15});

  @override
  State<Virtual3DTilt> createState() => _Virtual3DTiltState();
}

class _Virtual3DTiltState extends State<Virtual3DTilt> {
  double x = 0.0;
  double y = 0.0;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          // Calculate relative position (-1 to 1)
          final dx = (e.localPosition.dx / size.width) * 2 - 1;
          final dy = (e.localPosition.dy / size.height) * 2 - 1;
          setState(() {
            x = dx;
            y = dy;
          });
        }
      },
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() {
        isHovered = false;
        x = 0;
        y = 0;
      }),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset(x, y)),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective
            ..rotateX(-val.dy * widget.tiltIntensity) 
            ..rotateY(val.dx * widget.tiltIntensity);
          
          return Transform(
            alignment: FractionalOffset.center,
            transform: transform,
            child: widget.child,
          );
        },
      ),
    );
  }
}