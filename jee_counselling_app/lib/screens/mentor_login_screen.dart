import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'mentors/models/app_user_model.dart';
import 'mentor_dashboard/mentor_dashboard_screen.dart';
import 'email_verification_screen.dart';
import 'shared_widgets.dart';

class MentorLoginScreen extends StatefulWidget {
  const MentorLoginScreen({super.key});

  @override
  State<MentorLoginScreen> createState() => _MentorLoginScreenState();
}

class _MentorLoginScreenState extends State<MentorLoginScreen> {
  bool _isLogin = true;
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _collegeC = TextEditingController();
  final _passwordC = TextEditingController();
  String _error = '';
  String _success = '';
  bool _obscure = true;

  static const _orange = Color(0xFFFF6240);
  static const _bg = Color(0xFF060912);
  static const _s1 = Color(0xFF0D1117);
  static const _s2 = Color(0xFF111827);
  static const _t3 = Color(0xFF4D5B73);

  void _submit() async {
    setState(() { _error = ''; _success = ''; });
    final auth = context.read<AuthProvider>();

    if (_isLogin) {
      if (_emailC.text.isEmpty || _passwordC.text.isEmpty) {
        setState(() => _error = 'Please fill in all fields.');
        return;
      }

      final success = await auth.login(
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
        expectedRole: UserRole.mentor,
      );

      if (!mounted) return;

      if (success) {
        if (!auth.isEmailVerified) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const EmailVerificationScreen()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MentorDashboardScreen()));
        }
      } else {
        setState(() => _error = auth.error ?? 'Invalid email or password.');
      }

    } else {
      if (_firstNameC.text.isEmpty || _lastNameC.text.isEmpty ||
          _emailC.text.isEmpty || _passwordC.text.isEmpty) {
        setState(() => _error = 'Please fill in all required fields.');
        return;
      }

      final success = await auth.register(
        name: '${_firstNameC.text} ${_lastNameC.text}'.trim(),
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
        role: UserRole.mentor,
        college: _collegeC.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // After registration, go straight to verification screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const EmailVerificationScreen()));
      } else {
        setState(() => _error = auth.error ?? 'Registration failed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomPaint(painter: LoginGridPainter(), child: const SizedBox.expand()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            color: _orange,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text('← Back',
                                    style: GoogleFonts.instrumentSans(color: _t3, fontSize: 13)),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: 0.12),
                                  border: Border.all(color: _orange.withValues(alpha: 0.25)),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('MENTOR',
                                    style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10, color: _orange,
                                        fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                              ),
                              const SizedBox(height: 10),
                              Text(_isLogin ? 'Welcome back' : 'Join as Mentor',
                                  style: GoogleFonts.syne(
                                      fontSize: 28, fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: _s2, borderRadius: BorderRadius.circular(12)),
                                child: Row(children: [
                                  LoginTab(
                                      label: 'Sign In', active: _isLogin, color: _orange,
                                      onTap: () => setState(() {
                                        _isLogin = true; _error = ''; _success = '';
                                        context.read<AuthProvider>().clearError();
                                      })),
                                  LoginTab(
                                      label: 'Register', active: !_isLogin, color: _orange,
                                      onTap: () => setState(() {
                                        _isLogin = false; _error = ''; _success = '';
                                        context.read<AuthProvider>().clearError();
                                      })),
                                ]),
                              ),
                              const SizedBox(height: 20),
                              if (!_isLogin) ...[
                                Row(children: [
                                  Expanded(child: LoginField(label: 'FIRST NAME', controller: _firstNameC, accent: _orange)),
                                  const SizedBox(width: 12),
                                  Expanded(child: LoginField(label: 'LAST NAME', controller: _lastNameC, accent: _orange)),
                                ]),
                                const SizedBox(height: 12),
                                LoginField(label: 'PHONE', controller: _phoneC, accent: _orange, keyboardType: TextInputType.phone),
                                const SizedBox(height: 12),
                                LoginField(label: 'COLLEGE / INSTITUTION', controller: _collegeC, accent: _orange),
                                const SizedBox(height: 12),
                              ],
                              LoginField(label: 'EMAIL', controller: _emailC, accent: _orange, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              LoginField(
                                label: 'PASSWORD', controller: _passwordC,
                                accent: _orange, obscure: _obscure,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscure = !_obscure),
                                  child: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: _t3),
                                ),
                              ),
                              if (_error.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(_error,
                                    style: GoogleFonts.instrumentSans(color: const Color(0xFFF87171), fontSize: 13),
                                    textAlign: TextAlign.center),
                              ],
                              if (_success.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(_success,
                                    style: GoogleFonts.instrumentSans(color: const Color(0xFF00E676), fontSize: 13),
                                    textAlign: TextAlign.center),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity, height: 50,
                                child: ElevatedButton(
                                  onPressed: authLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _orange, foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: authLoading
                                      ? const SizedBox(width: 20, height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(_isLogin ? 'Sign In →' : 'Join as Mentor →',
                                          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 15)),
                                ),
                              ),
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
        ],
      ),
    );
  }
}