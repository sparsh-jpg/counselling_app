import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../mentors/models/app_user_model.dart';
import '../shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser user;
  
  // Controllers
  late TextEditingController nameC;
  late TextEditingController rankC;
  late TextEditingController collegeC;
  late TextEditingController branchC;
  late TextEditingController yearC;
  late TextEditingController priceC;
  late TextEditingController bioC;
  late TextEditingController expertiseC;
  
  String? _successMsg;
  String? _errorMsg;
  bool _isSaving = false;

  final Color _accent = const Color(0xFF00E5FF);
  final Color _s1 = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    user = context.read<AuthProvider>().currentUser!;
    
    nameC = TextEditingController(text: user.name);
    // Student uses jeeRank, Mentor uses mentorJeeRank
    rankC = TextEditingController(text: (user.role == UserRole.student ? user.jeeRank : user.mentorJeeRank)?.toString() ?? '');
    collegeC = TextEditingController(text: user.college ?? '');
    branchC = TextEditingController(text: user.branch ?? '');
    yearC = TextEditingController(text: user.year?.toString() ?? '');
    priceC = TextEditingController(text: user.sessionPrice?.toString() ?? '');
    bioC = TextEditingController(text: user.bio ?? '');
    expertiseC = TextEditingController(text: user.expertise.join(', '));
  }

  @override
  void dispose() {
    nameC.dispose();
    rankC.dispose();
    collegeC.dispose();
    branchC.dispose();
    yearC.dispose();
    priceC.dispose();
    bioC.dispose();
    expertiseC.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() {
      _isSaving = true;
      _successMsg = null;
      _errorMsg = null;
    });

    try {
      AppUser updatedUser;
      
      if (user.role == UserRole.student) {
        updatedUser = user.copyWith(
          name: nameC.text.trim(),
          jeeRank: int.tryParse(rankC.text.trim()),
        );
      } else {
        final expList = expertiseC.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        updatedUser = user.copyWith(
          name: nameC.text.trim(),
          college: collegeC.text.trim(),
          branch: branchC.text.trim(),
          year: int.tryParse(yearC.text.trim()),
          sessionPrice: int.tryParse(priceC.text.trim()),
          mentorJeeRank: int.tryParse(rankC.text.trim()),
          bio: bioC.text.trim(),
          expertise: expList,
        );
      }

      final success = await context.read<AuthProvider>().updateProfile(updatedUser);
      
      if (success) {
        setState(() {
          _successMsg = "Profile updated successfully!";
          user = updatedUser; // update local ref
        });
      } else {
        setState(() {
          _errorMsg = context.read<AuthProvider>().error ?? "Failed to save.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "An error occurred while saving.";
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMentor = user.role == UserRole.mentor;
    
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: Stack(
        children: [
          const LoginAIBg(accentColor: Color(0xFF00E5FF)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: _s1.withValues(alpha: 0.6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text('← Back',
                                      style: GoogleFonts.instrumentSans(color: const Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.12),
                                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(isMentor ? 'MENTOR PROFILE' : 'STUDENT PROFILE',
                                      style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11, color: _accent,
                                          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            
                            // Email (Read-only)
                            Text("EMAIL (READ ONLY)", style: _labelStyle()),
                            const SizedBox(height: 8),
                            _readOnlyBox(user.email),
                            const SizedBox(height: 20),

                            LoginField(label: 'FULL NAME', controller: nameC, accent: _accent),
                            const SizedBox(height: 20),
                            
                            LoginField(label: 'JEE RANK', controller: rankC, accent: _accent, keyboardType: TextInputType.number),
                            
                            if (isMentor) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(child: LoginField(label: 'COLLEGE', controller: collegeC, accent: _accent)),
                                  const SizedBox(width: 12),
                                  Expanded(child: LoginField(label: 'BRANCH', controller: branchC, accent: _accent)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(child: LoginField(label: 'YEAR', controller: yearC, accent: _accent, keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: LoginField(label: 'PRICE (₹)', controller: priceC, accent: _accent, keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              LoginField(label: 'EXPERTISE TAGS (comma separated)', controller: expertiseC, accent: _accent),
                              const SizedBox(height: 20),
                              LoginField(label: 'BIO', controller: bioC, accent: _accent),
                            ],

                            if (_errorMsg != null) ...[
                              const SizedBox(height: 16),
                              Text(_errorMsg!, style: GoogleFonts.instrumentSans(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                            ],
                            if (_successMsg != null) ...[
                              const SizedBox(height: 16),
                              Text(_successMsg!, style: GoogleFonts.instrumentSans(color: Colors.greenAccent, fontSize: 13), textAlign: TextAlign.center),
                            ],
                            
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity, height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent, foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                    : Text('Save Changes', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 15)),
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
        ],
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.jetBrainsMono(
    fontSize: 10, color: const Color(0xFF94A3B8),
    fontWeight: FontWeight.w600, letterSpacing: 1.2,
  );

  Widget _readOnlyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.instrumentSans(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
      ),
    );
  }
}
