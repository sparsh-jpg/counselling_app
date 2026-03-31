import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/mentors/models/app_user_model.dart';
import '../screens/mentors/models/connection_model.dart';

class StorageService {
  static const _usersKey = 'registered_users';
  static const _loggedInUserKey = 'logged_in_user';
  static const _connectionsKey = 'connections';
  static const _messagesKey = 'messages';

  // ─── USER AUTH ───────────────────────────────────────────────

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();
    users.removeWhere((u) => u.email == user.email);
    users.add(user);
    final encoded = users.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_usersKey, encoded);
  }

  Future<List<AppUser>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_usersKey) ?? [];
    return raw.map((s) => AppUser.fromJson(jsonDecode(s))).toList();
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<void> saveLoggedInUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, jsonEncode(user.toJson()));
  }

  Future<AppUser?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_loggedInUserKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

  // ─── MENTORS ─────────────────────────────────────────────────

  Future<List<AppUser>> getMentors() async {
    final users = await getAllUsers();
    return users.where((u) => u.role == UserRole.mentor).toList();
  }

  // ─── CONNECTIONS ─────────────────────────────────────────────

  Future<void> saveConnection(ConnectionRequest req) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllConnections();
    all.removeWhere((c) => c.id == req.id);
    all.add(req);
    final encoded = all.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_connectionsKey, encoded);
  }

  Future<List<ConnectionRequest>> getAllConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_connectionsKey) ?? [];
    return raw.map((s) => ConnectionRequest.fromJson(jsonDecode(s))).toList();
  }

  Future<List<ConnectionRequest>> getConnectionsForStudent(
      String studentId) async {
    final all = await getAllConnections();
    return all.where((c) => c.studentId == studentId).toList();
  }

  Future<List<ConnectionRequest>> getConnectionsForMentor(
      String mentorId) async {
    final all = await getAllConnections();
    return all.where((c) => c.mentorId == mentorId).toList();
  }

  Future<ConnectionRequest?> getConnection(
      String studentId, String mentorId) async {
    final all = await getAllConnections();
    try {
      return all.firstWhere(
          (c) => c.studentId == studentId && c.mentorId == mentorId);
    } catch (_) {
      return null;
    }
  }

  // ─── MESSAGES ────────────────────────────────────────────────

  Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getMessages(message.connectionId);
    all.add(message);
    final key = '${_messagesKey}_${message.connectionId}';
    final encoded = all.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  Future<List<ChatMessage>> getMessages(String connectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_messagesKey}_$connectionId';
    final raw = prefs.getStringList(key) ?? [];
    return raw.map((s) => ChatMessage.fromJson(jsonDecode(s))).toList();
  }
}