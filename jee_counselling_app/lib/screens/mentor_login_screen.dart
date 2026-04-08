import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import 'mentors/models/app_user_model.dart';
import 'mentor_dashboard/mentor_dashboard_screen.dart'; 
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

  static const _orange = Color(0xFF7C3AED);

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
        TextInput.finishAutofillContext();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MentorDashboardScreen()));
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
        TextInput.finishAutofillContext();
        final savedEmail = _emailC.text;
        setState(() {
          _isLogin = true;
          _success = 'Account created! A verification link was sent to your email. Please verify, then Log in.';
          _error = '';
          _passwordC.clear();
          _firstNameC.clear();
          _lastNameC.clear();
          _phoneC.clear();
          _collegeC.clear();
          _emailC.text = savedEmail;
        });
      } else {
        setState(() => _error = auth.error ?? 'Registration failed.');
      }
    }
  }

  void _forgotPassword() async {
    final email = _emailC.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email to reset password.');
      return;
    }
    
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(email);
    
    if (!mounted) return;
    if (success) {
      setState(() {
        _success = 'Password reset email sent. Please check your inbox.';
        _error = '';
      });
    } else {
      setState(() => _error = auth.error ?? 'Failed to send reset email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const LoginAIBg(accentColor: _orange),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top highlight
                              Container(height: 1, decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.transparent, _orange, Colors.transparent])
                              )),
                              Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.arrow_back, color: Color(0xFF94A3B8), size: 16),
                                          const SizedBox(width: 8),
                                          Text('Back',
                                              style: GoogleFonts.instrumentSans(
                                                  color: const Color(0xFF94A3B8), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: const BoxDecoration(
                                            color: _orange,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: _orange, blurRadius: 10)]
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('MENTOR NODE',
                                            style: GoogleFonts.jetBrainsMono(
                                                fontSize: 10,
                                                color: _orange,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 2.0)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                        _isLogin ? 'Initialize\nSession' : 'Initialize\nNode',
                                        style: GoogleFonts.syne(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                            color: Colors.white)),
                                    const SizedBox(height: 32),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(16)),
                                      child: Row(children: [
                                        LoginTab(
                                            label: 'Authenticate',
                                            active: _isLogin,
                                            color: _orange,
                                            onTap: () => setState(() {
                                                  _isLogin = true; _error = ''; _success = '';
                                                  context.read<AuthProvider>().clearError();
                                                })),
                                        LoginTab(
                                            label: 'New Node',
                                            active: !_isLogin,
                                            color: _orange,
                                            onTap: () => setState(() {
                                                  _isLogin = false; _error = ''; _success = '';
                                                  context.read<AuthProvider>().clearError();
                                                })),
                                      ]),
                                    ),
                                    const SizedBox(height: 32),
                                    if (!_isLogin) ...[
                                      Row(children: [
                                        Expanded(
                                            child: LoginField(label: 'FIRST NAME', controller: _firstNameC, accent: _orange)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: LoginField(label: 'LAST NAME', controller: _lastNameC, accent: _orange)),
                                      ]),
                                      const SizedBox(height: 16),
                                      LoginField(label: 'PHONE (+91)', controller: _phoneC, accent: _orange, keyboardType: TextInputType.phone),
                                      const SizedBox(height: 16),
                                      LoginField(label: 'COLLEGE / INSTITUTION', controller: _collegeC, accent: _orange),
                                      const SizedBox(height: 16),
                                    ],
                                    AutofillGroup(
                                      child: Column(
                                        children: [
                                          LoginField(
                                            label: 'EMAIL ADDRESS', 
                                            controller: _emailC, 
                                            accent: _orange, 
                                            keyboardType: TextInputType.emailAddress,
                                            autofillHints: const [AutofillHints.email],
                                          ),
                                          const SizedBox(height: 16),
                                          LoginField(
                                            label: 'ENCRYPTION KEY (PASSWORD)',
                                            controller: _passwordC,
                                            accent: _orange,
                                            obscure: _obscure,
                                            autofillHints: const [AutofillHints.password],
                                            suffix: GestureDetector(
                                              onTap: () => setState(() => _obscure = !_obscure),
                                              child: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                                                  size: 18, color: const Color(0xFF94A3B8)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isLogin) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _forgotPassword,
                                          style: TextButton.styleFrom(
                                            foregroundColor: _orange,
                                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text('Forgot Password?',
                                              style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                    if (_error.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3))),
                                        child: Row(children: [
                                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_error, style: GoogleFonts.instrumentSans(color: const Color(0xFFEF4444), fontSize: 13))),
                                        ]),
                                      ),
                                    ],
                                    if (_success.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3))),
                                        child: Row(children: [
                                          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_success, style: GoogleFonts.instrumentSans(color: const Color(0xFF10B981), fontSize: 13))),
                                        ]),
                                      ),
                                    ],
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: authLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _orange,
                                          foregroundColor: Colors.white,
                                          shadowColor: _orange.withValues(alpha: 0.5),
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: authLoading
                                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _isLogin ? 'EXECUTE LOGIN' : 'INITIALIZE NODE',
                                                    style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.5),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                                ],
                                              ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}