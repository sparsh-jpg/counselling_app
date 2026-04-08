import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'mentor_dashboard/mentor_dashboard_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _resendCooldown = false;
  int _cooldownSeconds = 0;

  static const _bg = Color(0xFF060912);
  static const _s1 = Color(0xFF0D1117);
  static const _cyan = Color(0xFF00E5FF);
  static const _t3 = Color(0xFF4D5B73);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth = context.read<AuthProvider>();
      await auth.reloadUser();
      if (auth.isEmailVerified && mounted) {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => auth.isMentor
                ? const MentorDashboardScreen()
                : const DashboardScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().sendEmailVerification();
    setState(() { _resendCooldown = true; _cooldownSeconds = 30; });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: _cyan,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _s1,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: _cyan.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.mark_email_unread_outlined, color: _cyan, size: 36),
                      ),
                      const SizedBox(height: 24),
                      Text('Verify your email',
                          style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text('We sent a verification link to',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.instrumentSans(color: _t3, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(email,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(color: _cyan, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Click the link in the email to unlock your account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.instrumentSans(color: _t3, fontSize: 13, height: 1.6)),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 14, height: 14,
                              child: CircularProgressIndicator(color: _cyan.withValues(alpha: 0.6), strokeWidth: 2)),
                          const SizedBox(width: 10),
                          Text('Checking automatically...',
                              style: GoogleFonts.instrumentSans(color: _t3, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: OutlinedButton(
                          onPressed: _resendCooldown ? null : _resendEmail,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _resendCooldown ? _t3 : _cyan),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _resendCooldown ? 'Resend in ${_cooldownSeconds}s' : 'Resend verification email',
                            style: GoogleFonts.instrumentSans(
                                color: _resendCooldown ? _t3 : _cyan, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          _timer?.cancel();
                          await context.read<AuthProvider>().logout();
                          if (mounted) Navigator.pop(context);
                        },
                        child: Text('← Back to login',
                            style: GoogleFonts.instrumentSans(color: _t3, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}