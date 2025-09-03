import 'package:json_annotation/json_annotation.dart';

enum MessageStatus { unread, read, archived }

enum PriorityLevel { low, medium, high, urgent }

@JsonSerializable()
class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String subject;
  final String content;
  final MessageStatus status;
  final PriorityLevel priority;
  final bool hasAttachments;
  final String? repliedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data from user_profiles
  final UserProfile? sender;
  final UserProfile? recipient;

  const Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.subject,
    required this.content,
    required this.status,
    required this.priority,
    required this.hasAttachments,
    this.repliedTo,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.recipient,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      subject: json['subject'] as String,
      content: json['content'] as String,
      status: MessageStatus.values.byName(json['status'] as String),
      priority: PriorityLevel.values.byName(json['priority'] as String),
      hasAttachments: json['hasAttachments'] as bool,
      repliedTo: json['repliedTo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sender: json['sender'] != null ? UserProfile.fromJson(json['sender'] as Map<String, dynamic>) : null,
      recipient: json['recipient'] != null ? UserProfile.fromJson(json['recipient'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'subject': subject,
      'content': content,
      'status': status.name,
      'priority': priority.name,
      'hasAttachments': hasAttachments,
      'repliedTo': repliedTo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sender': sender?.toJson(),
      'recipient': recipient?.toJson(),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? subject,
    String? content,
    MessageStatus? status,
    PriorityLevel? priority,
    bool? hasAttachments,
    String? repliedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? sender,
    UserProfile? recipient,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      repliedTo: repliedTo ?? this.repliedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
    );
  }

  bool get isUnread => status == MessageStatus.unread;
  bool get isHighPriority =>
      priority == PriorityLevel.high || priority == PriorityLevel.urgent;
}

enum UserRole { admin, moderator, member }

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? username;
  final UserRole role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    required this.role,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String?,
      role: UserRole.values.byName(json['role'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'username': username,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;
}