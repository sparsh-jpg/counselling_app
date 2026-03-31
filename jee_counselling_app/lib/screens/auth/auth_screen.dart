import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../screens/mentors/models/app_user_model.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/mentor_dashboard/mentor_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final UserRole initialRole;
  const AuthScreen({super.key, required this.initialRole});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserRole _role;
  bool _isLoginTab = true;

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;

  // Register Step 1
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  bool _regPassVisible = false;

  // Register Step 2 Student
  final _jeeRankCtrl = TextEditingController();
  String _jeeType = 'JEE Main';

  // Register Step 2 Mentor
  final _collegeCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _mentorRankCtrl = TextEditingController();
  String _mentorJeeType = 'JEE Main';
  final _priceCtrl = TextEditingController();
  final _expertiseCtrl = TextEditingController();

  int _registerStep = 1;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _isLoginTab = _tabController.index == 0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _jeeRankCtrl.dispose();
    _collegeCtrl.dispose();
    _branchCtrl.dispose();
    _yearCtrl.dispose();
    _bioCtrl.dispose();
    _mentorRankCtrl.dispose();
    _priceCtrl.dispose();
    _expertiseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text('Back',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00E5CC)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _role == UserRole.student ? 'STUDENT' : 'MENTOR',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isLoginTab ? 'Welcome back' : 'Create Account',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // Tab bar
              Container(
                height: 48,
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
                      fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab views
              _isLoginTab ? _buildLoginForm() : _buildRegisterForm(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── LOGIN ───────────────────────────────────────────────────

  Widget _buildLoginForm() {
    final auth = context.watch<AuthProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('EMAIL'),
        _inputField(controller: _loginEmailCtrl, hint: 'your@email.com'),
        const SizedBox(height: 16),
        _label('PASSWORD'),
        _inputField(
          controller: _loginPassCtrl,
          hint: '••••••••',
          obscure: !_loginPassVisible,
          suffix: IconButton(
            icon: Icon(
              _loginPassVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _loginPassVisible = !_loginPassVisible),
          ),
        ),
        if (auth.error != null) ...[
          const SizedBox(height: 10),
          Text(auth.error!,
              style: GoogleFonts.poppins(
                  color: const Color(0xFFFF4D4D), fontSize: 12)),
        ],
        if (_successMessage != null) ...[
          const SizedBox(height: 10),
          Text(_successMessage!,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF00E5CC), fontSize: 12)),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          label: 'Sign In →',
          isLoading: auth.isLoading,
          onTap: _doLogin,
        ),
      ],
    );
  }

  // ─── REGISTER ────────────────────────────────────────────────

  Widget _buildRegisterForm() {
    final auth = context.watch<AuthProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_registerStep == 1) ..._registerStep1(auth),
        if (_registerStep == 2 && _role == UserRole.student)
          ..._registerStep2Student(auth),
        if (_registerStep == 2 && _role == UserRole.mentor)
          ..._registerStep2Mentor(auth),
      ],
    );
  }

  List<Widget> _registerStep1(AuthProvider auth) {
    return [
      _label('FULL NAME'),
      _inputField(controller: _regNameCtrl, hint: 'Your full name'),
      const SizedBox(height: 12),
      _label('EMAIL'),
      _inputField(controller: _regEmailCtrl, hint: 'your@email.com'),
      const SizedBox(height: 12),
      _label('PASSWORD'),
      _inputField(
        controller: _regPassCtrl,
        hint: '••••••••',
        obscure: !_regPassVisible,
        suffix: IconButton(
          icon: Icon(
            _regPassVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white38,
            size: 18,
          ),
          onPressed: () =>
              setState(() => _regPassVisible = !_regPassVisible),
        ),
      ),
      if (auth.error != null) ...[
        const SizedBox(height: 8),
        Text(auth.error!,
            style: GoogleFonts.poppins(
                color: const Color(0xFFFF4D4D), fontSize: 12)),
      ],
      const SizedBox(height: 20),
      _primaryButton(
        label: 'Next →',
        isLoading: false,
        onTap: () {
          if (_regNameCtrl.text.trim().isEmpty ||
              _regEmailCtrl.text.trim().isEmpty ||
              _regPassCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }
          context.read<AuthProvider>().clearError();
          setState(() => _registerStep = 2);
        },
      ),
    ];
  }

  List<Widget> _registerStep2Student(AuthProvider auth) {
    return [
      GestureDetector(
        onTap: () => setState(() => _registerStep = 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios_new,
                color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text('Back',
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text('Your JEE Details',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15)),
      const SizedBox(height: 16),
      _label('JEE TYPE'),
      _dropdown(
        value: _jeeType,
        items: ['JEE Main', 'JEE Advanced'],
        onChanged: (v) => setState(() => _jeeType = v!),
      ),
      const SizedBox(height: 12),
      _label('YOUR JEE RANK'),
      _inputField(
          controller: _jeeRankCtrl,
          hint: 'e.g. 14744',
          keyboardType: TextInputType.number),
      if (auth.error != null) ...[
        const SizedBox(height: 8),
        Text(auth.error!,
            style: GoogleFonts.poppins(
                color: const Color(0xFFFF4D4D), fontSize: 12)),
      ],
      const SizedBox(height: 20),
      _primaryButton(
        label: 'Create Account →',
        isLoading: auth.isLoading,
        onTap: _doRegisterStudent,
      ),
    ];
  }

  List<Widget> _registerStep2Mentor(AuthProvider auth) {
    return [
      GestureDetector(
        onTap: () => setState(() => _registerStep = 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios_new,
                color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text('Back',
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text('Mentor Details',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15)),
      const SizedBox(height: 16),
      _label('COLLEGE'),
      _inputField(controller: _collegeCtrl, hint: 'e.g. NIT Jalandhar'),
      const SizedBox(height: 10),
      _label('BRANCH'),
      _inputField(
          controller: _branchCtrl,
          hint: 'e.g. Computer Science Engineering'),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('YEAR'),
                _inputField(
                    controller: _yearCtrl,
                    hint: '1-5',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('PRICE (₹, 0=Free)'),
                _inputField(
                    controller: _priceCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _label('JEE TYPE'),
      _dropdown(
        value: _mentorJeeType,
        items: ['JEE Main', 'JEE Advanced'],
        onChanged: (v) => setState(() => _mentorJeeType = v!),
      ),
      const SizedBox(height: 10),
      _label('YOUR JEE RANK'),
      _inputField(
          controller: _mentorRankCtrl,
          hint: 'e.g. 9300',
          keyboardType: TextInputType.number),
      const SizedBox(height: 10),
      _label('EXPERTISE (comma separated)'),
      _inputField(
          controller: _expertiseCtrl,
          hint: 'JoSAA, NIT Admission, CS Branch'),
      const SizedBox(height: 10),
      _label('BIO'),
      _inputField(
          controller: _bioCtrl,
          hint: 'Tell students about yourself...',
          maxLines: 2),
      if (auth.error != null) ...[
        const SizedBox(height: 8),
        Text(auth.error!,
            style: GoogleFonts.poppins(
                color: const Color(0xFFFF4D4D), fontSize: 12)),
      ],
      const SizedBox(height: 16),
      _primaryButton(
        label: 'Register as Mentor →',
        isLoading: auth.isLoading,
        onTap: _doRegisterMentor,
      ),
    ];
  }

  // ─── ACTIONS ─────────────────────────────────────────────────

  Future<void> _doLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPassCtrl.text.trim(),
      expectedRole: _role,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _role == UserRole.student
              ? const DashboardScreen()
              : const MentorDashboardScreen(),
        ),
      );
    }
  }

  Future<void> _doRegisterStudent() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _regNameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text.trim(),
      role: UserRole.student,
      jeeRank: int.tryParse(_jeeRankCtrl.text.trim()),
      jeeType: _jeeType,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _successMessage = 'Account created! Please sign in.';
        _registerStep = 1;
        _tabController.animateTo(0);
      });
    }
  }

  Future<void> _doRegisterMentor() async {
    final auth = context.read<AuthProvider>();
    final expertiseList = _expertiseCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = await auth.register(
      name: _regNameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text.trim(),
      role: UserRole.mentor,
      college: _collegeCtrl.text.trim(),
      branch: _branchCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()),
      sessionPrice: int.tryParse(_priceCtrl.text.trim()) ?? 0,
      mentorJeeRank: int.tryParse(_mentorRankCtrl.text.trim()),
      mentorJeeType: _mentorJeeType,
      expertise: expertiseList,
      bio: _bioCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _successMessage = 'Mentor account created! Please sign in.';
        _registerStep = 1;
        _tabController.animateTo(0);
      });
    }
  }

  // ─── UI HELPERS ──────────────────────────────────────────────

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          )),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: obscure ? 1 : maxLines,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: const Color(0xFF1A1A2E),
        underline: const SizedBox(),
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2))
            : Text(
                label,
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
      ),
    );
  }
}