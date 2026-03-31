import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'mentors/models/app_user_model.dart';
import 'dashboard/dashboard_screen.dart';
import 'shared_widgets.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  bool _isLogin = true;
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _rankC = TextEditingController();
  final _passwordC = TextEditingController();
  String _error = '';
  String _success = '';
  bool _obscure = true;

  static const _cyan = Color(0xFF00E5FF);
  static const _bg = Color(0xFF060912);
  static const _s1 = Color(0xFF0D1117);
  static const _s2 = Color(0xFF111827);
  static const _t3 = Color(0xFF4D5B73);

  void _submit() async {
    setState(() { _error = ''; _success = ''; });
    
    // Grab the AuthProvider
    final auth = context.read<AuthProvider>();

    if (_isLogin) {
      if (_emailC.text.isEmpty || _passwordC.text.isEmpty) {
        setState(() => _error = 'Please fill in all fields.');
        return;
      }
      
      // Use the proper login method
      final success = await auth.login(
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
        expectedRole: UserRole.student,
      );

      if (!mounted) return;
      
      if (success) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        setState(() => _error = auth.error ?? 'Invalid email or password.');
      }
      
    } else {
      if (_firstNameC.text.isEmpty || _lastNameC.text.isEmpty ||
          _emailC.text.isEmpty || _rankC.text.isEmpty ||
          _passwordC.text.isEmpty) {
        setState(() => _error = 'Please fill in all required fields.');
        return;
      }
      
      // Use the proper register method to save to the global database
      final success = await auth.register(
        name: '${_firstNameC.text} ${_lastNameC.text}'.trim(),
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
        role: UserRole.student,
        jeeRank: int.tryParse(_rankC.text.trim()),
      );

      if (!mounted) return;
      
      if (success) {
        final savedEmail = _emailC.text; // save email before clearing
        setState(() {
          _isLogin = true;
          _success = 'Account created! Please sign in.';
          _error = '';
          _passwordC.clear();
          _firstNameC.clear();
          _lastNameC.clear();
          _phoneC.clear();
          _rankC.clear();
          _emailC.text = savedEmail; // keep email filled
        });
      } else {
        setState(() => _error = auth.error ?? 'Registration failed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading state to show a spinner
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
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.07)),
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
                                    style: GoogleFonts.instrumentSans(
                                        color: _t3, fontSize: 13)),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _cyan.withValues(alpha: 0.12),
                                  border: Border.all(
                                      color: _cyan.withValues(alpha: 0.25)),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('STUDENT',
                                    style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        color: _cyan,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  _isLogin ? 'Welcome back' : 'Create account',
                                  style: GoogleFonts.syne(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: _s2,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(children: [
                                  LoginTab(
                                      label: 'Sign In',
                                      active: _isLogin,
                                      color: _cyan,
                                      onTap: () => setState(() {
                                            _isLogin = true;
                                            _error = '';
                                            _success = '';
                                            context.read<AuthProvider>().clearError();
                                          })),
                                  LoginTab(
                                      label: 'Register',
                                      active: !_isLogin,
                                      color: _cyan,
                                      onTap: () => setState(() {
                                            _isLogin = false;
                                            _error = '';
                                            _success = '';
                                            context.read<AuthProvider>().clearError();
                                          })),
                                ]),
                              ),
                              const SizedBox(height: 20),
                              if (!_isLogin) ...[
                                Row(children: [
                                  Expanded(
                                      child: LoginField(
                                          label: 'FIRST NAME',
                                          controller: _firstNameC,
                                          accent: _cyan)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: LoginField(
                                          label: 'LAST NAME',
                                          controller: _lastNameC,
                                          accent: _cyan)),
                                ]),
                                const SizedBox(height: 12),
                                LoginField(
                                    label: 'PHONE',
                                    controller: _phoneC,
                                    accent: _cyan,
                                    keyboardType: TextInputType.phone),
                                const SizedBox(height: 12),
                                LoginField(
                                    label: 'JEE RANK',
                                    controller: _rankC,
                                    accent: _cyan,
                                    keyboardType: TextInputType.number),
                                const SizedBox(height: 12),
                              ],
                              LoginField(
                                  label: 'EMAIL',
                                  controller: _emailC,
                                  accent: _cyan,
                                  keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              LoginField(
                                label: 'PASSWORD',
                                controller: _passwordC,
                                accent: _cyan,
                                obscure: _obscure,
                                suffix: GestureDetector(
                                  onTap: () =>
                                      setState(() => _obscure = !_obscure),
                                  child: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 18,
                                      color: _t3),
                                ),
                              ),
                              if (_error.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(_error,
                                    style: GoogleFonts.instrumentSans(
                                        color: const Color(0xFFF87171),
                                        fontSize: 13),
                                    textAlign: TextAlign.center),
                              ],
                              if (_success.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(_success,
                                    style: GoogleFonts.instrumentSans(
                                        color: const Color(0xFF00E676),
                                        fontSize: 13),
                                    textAlign: TextAlign.center),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _cyan,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: authLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isLogin
                                              ? 'Sign In →'
                                              : 'Create Account →',
                                          style: GoogleFonts.instrumentSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
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
        ],
      ),
    );
  }
}