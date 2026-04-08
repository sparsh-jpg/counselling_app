import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../screens/mentors/models/connection_model.dart';
import '../../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final ConnectionRequest connection;
  final String currentUserId;
  final String currentUserName;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.connection,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final StorageService _storage = StorageService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // ─── Real-time Firestore stream ────────────────────────────────
  late final Stream<QuerySnapshot> _msgStream;

  @override
  void initState() {
    super.initState();
    // Subscribe to live updates — any new message written to Firestore
    // will instantly push to this stream and rebuild the UI.
    _msgStream = FirebaseFirestore.instance
        .collection('messages')
        .where('connectionId', isEqualTo: widget.connection.id)
        .snapshots();

    // Also signal a call invite listener — see video call invite overlay
    _listenForCallInvite();
  }

  void _listenForCallInvite() {
    FirebaseFirestore.instance
        .collection('call_signals')
        .where('toUserId', isEqualTo: widget.currentUserId)
        .where('connectionId', isEqualTo: widget.connection.id)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      if (snapshot.docs.isNotEmpty) {
        final callDoc = snapshot.docs.first;
        final callerName = callDoc['callerName'] ?? widget.otherName;
        final channelName = callDoc['channelName'] ?? '';
        _showIncomingCallDialog(callDoc.id, callerName, channelName);
      }
    });
  }

  void _showIncomingCallDialog(String callId, String callerName, String channelName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12121F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF00E5CC).withOpacity(0.2),
              child: Text(
                callerName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Text('Incoming Video Call',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(callerName,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Mark call as declined
                      await FirebaseFirestore.instance
                          .collection('call_signals')
                          .doc(callId)
                          .update({'status': 'declined'});
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.call_end, size: 18),
                    label: Text('Decline', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Mark call as accepted
                      await FirebaseFirestore.instance
                          .collection('call_signals')
                          .doc(callId)
                          .update({'status': 'accepted'});
                      if (!mounted) return;
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/video-call',
                        arguments: {
                          'channelName': channelName,
                          'otherName': callerName,
                        },
                      );
                    },
                    icon: const Icon(Icons.videocam, size: 18),
                    label: Text('Accept', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString() +
          Random().nextInt(999).toString(),
      connectionId: widget.connection.id,
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      text: text,
      sentAt: DateTime.now(),
    );

    await _storage.saveMessage(msg);
    _scrollToBottom();
  }

  Future<void> _initiateVideoCall() async {
    final channelName = 'jee_${widget.connection.id}';
    final callId = DateTime.now().millisecondsSinceEpoch.toString();

    // Determine the other person's ID
    final otherUserId = widget.currentUserId == widget.connection.studentId
        ? widget.connection.mentorId
        : widget.connection.studentId;

    // Write a call signal to Firestore — the other device is listening
    await FirebaseFirestore.instance
        .collection('call_signals')
        .doc(callId)
        .set({
      'callId': callId,
      'callerName': widget.currentUserName,
      'toUserId': otherUserId,
      'connectionId': widget.connection.id,
      'channelName': channelName,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Caller navigates straight into the call
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/video-call',
      arguments: {
        'channelName': channelName,
        'otherName': widget.otherName,
        'callId': callId,
      },
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00E5CC).withOpacity(0.2),
              child: Text(
                widget.otherName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherName,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('Live',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF22C55E), fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined,
                color: Color(0xFF00E5CC)),
            onPressed: _initiateVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Real-time message list via StreamBuilder ───────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _msgStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00E5CC)));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return _buildEmptyChat();

                // Sort by sentAt locally (no composite index needed)
                final messages = docs.map((d) {
                  return ChatMessage.fromJson(d.data() as Map<String, dynamic>);
                }).toList()
                  ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

                // Auto-scroll on new message
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _MessageBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == widget.currentUserId,
                  ),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            color: const Color(0xFF12121F),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5CC),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 56, color: Colors.white12),
          const SizedBox(height: 12),
          Text('Start the conversation!',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 14)),
          Text('Say hi to ${widget.otherName} 👋',
              style: GoogleFonts.poppins(
                  color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF00E5CC).withOpacity(0.2),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF00E5CC)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(message.sentAt),
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.black45 : Colors.white24,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}