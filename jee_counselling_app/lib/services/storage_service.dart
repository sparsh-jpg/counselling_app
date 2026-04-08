import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/mentors/models/app_user_model.dart';
import '../screens/mentors/models/connection_model.dart';

class StorageService {
  static const _loggedInUserKey = 'logged_in_user';
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER AUTH ───────────────────────────────────────────────

  Future<void> saveUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    return AppUser.fromJson(snapshot.docs.first.data());
  }

  Future<AppUser?> getUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!);
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
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'mentor')
        .get();
    return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
  }

  // ─── CONNECTIONS ─────────────────────────────────────────────

  Future<void> saveConnection(ConnectionRequest req) async {
    await _db.collection('connections').doc(req.id).set(req.toJson(), SetOptions(merge: true));
  }

  Future<List<ConnectionRequest>> getAllConnections() async {
    final snapshot = await _db.collection('connections').get();
    return snapshot.docs.map((d) => ConnectionRequest.fromJson(d.data())).toList();
  }

  Future<List<ConnectionRequest>> getConnectionsForStudent(String studentId) async {
    final snapshot = await _db
        .collection('connections')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map((d) => ConnectionRequest.fromJson(d.data())).toList();
  }

  Future<List<ConnectionRequest>> getConnectionsForMentor(String mentorId) async {
    final snapshot = await _db
        .collection('connections')
        .where('mentorId', isEqualTo: mentorId)
        .get();
    return snapshot.docs.map((d) => ConnectionRequest.fromJson(d.data())).toList();
  }

  Future<ConnectionRequest?> getConnection(String studentId, String mentorId) async {
    final snapshot = await _db
        .collection('connections')
        .where('studentId', isEqualTo: studentId)
        .where('mentorId', isEqualTo: mentorId)
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    return ConnectionRequest.fromJson(snapshot.docs.first.data());
  }

  // ─── MESSAGES ────────────────────────────────────────────────

  Future<void> saveMessage(ChatMessage message) async {
    await _db.collection('messages').doc(message.id).set(message.toJson());
  }

  Future<List<ChatMessage>> getMessages(String connectionId) async {
    final snapshot = await _db
        .collection('messages')
        .where('connectionId', isEqualTo: connectionId)
        .get();
        
    final msgs = snapshot.docs.map((d) => ChatMessage.fromJson(d.data())).toList();
    // Sort locally to avoid needing complex Firebase composite indices from the start
    msgs.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return msgs;
  }

  // ─── STATS HELPERS ───────────────────────────────────────────

  Future<int> getPredictionCount(String userId) async {
    final doc = await _db.collection('stats').doc(userId).get();
    if (!doc.exists) return 0;
    return doc.data()?['predictions'] ?? 0;
  }

  Future<void> incrementPredictionCount(String userId) async {
    final count = await getPredictionCount(userId);
    await _db.collection('stats').doc(userId).set({'predictions': count + 1}, SetOptions(merge: true));
  }

  Future<int> getTotalMessagesCount(String userId) async {
    final connectionsStudent = await getConnectionsForStudent(userId);
    final connectionsMentor = await getConnectionsForMentor(userId);
    final allConns = [...connectionsStudent, ...connectionsMentor];
    
    int total = 0;
    for (var c in allConns) {
      if (c.status == ConnectionStatus.accepted) {
        final snapshot = await _db
            .collection('messages')
            .where('connectionId', isEqualTo: c.id)
            .get(); // Using .get() locally because count() is a relatively newer aggregate method 
        total += snapshot.docs.length;
      }
    }
    return total;
  }
}