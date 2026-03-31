enum ConnectionStatus { pending, accepted, rejected }

class ConnectionRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String mentorId;
  final String mentorName;
  final ConnectionStatus status;
  final DateTime createdAt;

  const ConnectionRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.mentorId,
    required this.mentorName,
    required this.status,
    required this.createdAt,
  });

  ConnectionRequest copyWith({ConnectionStatus? status}) {
    return ConnectionRequest(
      id: id,
      studentId: studentId,
      studentName: studentName,
      mentorId: mentorId,
      mentorName: mentorName,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      mentorId: json['mentorId'] ?? '',
      mentorName: json['mentorName'] ?? '',
      status: _statusFromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ConnectionStatus _statusFromString(String? s) {
    switch (s) {
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'rejected':
        return ConnectionStatus.rejected;
      default:
        return ConnectionStatus.pending;
    }
  }

  static String _statusToString(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.accepted:
        return 'accepted';
      case ConnectionStatus.rejected:
        return 'rejected';
      case ConnectionStatus.pending:
        return 'pending';
    }
  }
}

class ChatMessage {
  final String id;
  final String connectionId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      connectionId: json['connectionId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      sentAt: DateTime.parse(json['sentAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connectionId': connectionId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}