import 'package:flutter/foundation.dart';
import 'dart:math';
import '../screens/mentors/models/connection_model.dart';
import '../services/storage_service.dart';

class ConnectionProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<ConnectionRequest> _connections = [];
  bool _isLoading = false;

  List<ConnectionRequest> get connections => _connections;
  bool get isLoading => _isLoading;

  List<ConnectionRequest> get pendingRequests =>
      _connections.where((c) => c.status == ConnectionStatus.pending).toList();

  List<ConnectionRequest> get acceptedConnections =>
      _connections.where((c) => c.status == ConnectionStatus.accepted).toList();

  // Student: load all their connections
  Future<void> loadStudentConnections(String studentId) async {
    _isLoading = true;
    notifyListeners();
    _connections = await _storage.getConnectionsForStudent(studentId);
    _isLoading = false;
    notifyListeners();
  }

  // Mentor: load all requests they received
  Future<void> loadMentorConnections(String mentorId) async {
    _isLoading = true;
    notifyListeners();
    _connections = await _storage.getConnectionsForMentor(mentorId);
    _isLoading = false;
    notifyListeners();
  }

  // Student sends a connection request
  Future<void> sendRequest({
    required String studentId,
    required String studentName,
    required String mentorId,
    required String mentorName,
  }) async {
    // Avoid duplicate
    final existing = await _storage.getConnection(studentId, mentorId);
    if (existing != null) return;

    final req = ConnectionRequest(
      id: _generateId(),
      studentId: studentId,
      studentName: studentName,
      mentorId: mentorId,
      mentorName: mentorName,
      status: ConnectionStatus.pending,
      createdAt: DateTime.now(),
    );

    await _storage.saveConnection(req);
    _connections.add(req);
    notifyListeners();
  }

  // Mentor accepts a request
  Future<void> acceptRequest(String connectionId) async {
    final index = _connections.indexWhere((c) => c.id == connectionId);
    if (index == -1) return;
    final updated =
        _connections[index].copyWith(status: ConnectionStatus.accepted);
    _connections[index] = updated;
    await _storage.saveConnection(updated);
    notifyListeners();
  }

  // Mentor rejects a request
  Future<void> rejectRequest(String connectionId) async {
    final index = _connections.indexWhere((c) => c.id == connectionId);
    if (index == -1) return;
    final updated =
        _connections[index].copyWith(status: ConnectionStatus.rejected);
    _connections[index] = updated;
    await _storage.saveConnection(updated);
    notifyListeners();
  }

  ConnectionStatus? getStatusForMentor(String studentId, String mentorId) {
    try {
      return _connections
          .firstWhere(
              (c) => c.studentId == studentId && c.mentorId == mentorId)
          .status;
    } catch (_) {
      return null;
    }
  }

  ConnectionRequest? getConnection(String studentId, String mentorId) {
    try {
      return _connections.firstWhere(
          (c) => c.studentId == studentId && c.mentorId == mentorId);
    } catch (_) {
      return null;
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }
}