import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mentor_model.dart';

enum MentorFilter { all, iit, nit, iiit, free }

class MentorProvider extends ChangeNotifier {
  List<Mentor> _allMentors = [];
  List<Mentor> _filteredMentors = [];
  MentorFilter _activeFilter = MentorFilter.all;
  String _searchQuery = '';
  bool _isLoading = false;
  Mentor? _selectedMentor;
  final Set<String> _connectedMentors = {};
  final List<ConnectRequest> _connectRequests = [];

  List<Mentor> get mentors => _filteredMentors;
  MentorFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  Mentor? get selectedMentor => _selectedMentor;
  List<ConnectRequest> get connectRequests => _connectRequests;

  bool isConnected(String mentorId) => _connectedMentors.contains(mentorId);

  MentorProvider() {
    loadMentors();
  }

  Future<void> loadMentors() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _allMentors = _getMockMentors();
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(MentorFilter filter) {
    _activeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void selectMentor(Mentor mentor) {
    _selectedMentor = mentor;
    notifyListeners();
  }

  Future<void> toggleConnect(String mentorId) async {
    final prefs = await SharedPreferences.getInstance();
    final studentName = prefs.getString('student_name') ?? 'Student';
    final studentEmail = prefs.getString('student_email') ?? '';
    final studentRank = prefs.getString('student_rank') ?? 'N/A';

    if (_connectedMentors.contains(mentorId)) {
      _connectedMentors.remove(mentorId);
    } else {
      _connectedMentors.add(mentorId);
      // Add connect request so mentor can see it
      _connectRequests.add(ConnectRequest(
        studentName: studentName,
        studentEmail: studentEmail,
        studentRank: studentRank,
        requestedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  void acceptRequest(int index) {
    _connectRequests[index].isAccepted = true;
    notifyListeners();
  }

  void _applyFilters() {
    List<Mentor> result = List.from(_allMentors);
    switch (_activeFilter) {
      case MentorFilter.iit:
        result = result.where((m) => m.college.toUpperCase().contains('IIT')).toList();
        break;
      case MentorFilter.nit:
        result = result.where((m) => m.college.toUpperCase().contains('NIT')).toList();
        break;
      case MentorFilter.iiit:
        result = result.where((m) => m.college.toUpperCase().contains('IIIT')).toList();
        break;
      case MentorFilter.free:
        result = result.where((m) => m.sessionPrice == 0).toList();
        break;
      case MentorFilter.all:
        break;
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((m) =>
          m.name.toLowerCase().contains(_searchQuery) ||
          m.college.toLowerCase().contains(_searchQuery) ||
          m.branch.toLowerCase().contains(_searchQuery) ||
          m.expertise.any((e) => e.toLowerCase().contains(_searchQuery))).toList();
    }
    _filteredMentors = result;
  }

  List<Mentor> _getMockMentors() {
    return [
      const Mentor(
        id: '1',
        name: 'Veenu Kaushik',
        college: 'NIT Jalandhar',
        branch: 'Electronics & Communication',
        year: 3,
        rating: 4.8,
        reviewCount: 34,
        bio: 'NIT Jalandhar ECE student with JEE Main rank 19,480. I help students understand NIT counselling, JoSAA process, and ECE branch prospects. Feel free to connect!',
        expertise: ['JoSAA Counselling', 'ECE Branch', 'NIT Admission', 'Category Counselling'],
        avatarUrl: '',
        isAvailable: true,
        sessionPrice: 0,
        jeeRank: 19480,
        jeeType: 'JEE Main',
      ),
      const Mentor(
        id: '2',
        name: 'Tarun Singh',
        college: 'NIT Jalandhar',
        branch: 'Computer Science Engineering',
        year: 3,
        rating: 4.9,
        reviewCount: 51,
        bio: 'NIT Jalandhar CSE student with JEE Main rank 9,340. Expert in college selection, JoSAA rounds, and CS branch guidance. Happy to help you navigate your JEE journey!',
        expertise: ['JoSAA', 'CS Branch', 'NIT Jalandhar', 'College Selection'],
        avatarUrl: '',
        isAvailable: true,
        sessionPrice: 0,
        jeeRank: 9340,
        jeeType: 'JEE Main',
      ),
    ];
  }
}