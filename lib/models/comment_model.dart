import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

enum CommentStatus { approved, pending, rejected }

@JsonSerializable()
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String? parentId;
  final String content;
  final CommentStatus status;
  final int likeCount;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserProfile? author;
  final Post? post;
  final List<Comment>? replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentId,
    required this.content,
    required this.status,
    required this.likeCount,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.post,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      parentId: json['parentId'] as String?,
      content: json['content'] as String,
      status: CommentStatus.values.firstWhere((e) => e.name == json['status']),
      likeCount: json['likeCount'] as int,
      isEdited: json['isEdited'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      author: json['author'] != null ? UserProfile.fromJson(json['author'] as Map<String, dynamic>) : null,
      post: json['post'] != null ? Post.fromJson(json['post'] as Map<String, dynamic>) : null,
      replies: json['replies'] != null 
        ? (json['replies'] as List).map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList()
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'parentId': parentId,
      'content': content,
      'status': status.name,
      'likeCount': likeCount,
      'isEdited': isEdited,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': author?.toJson(),
      'post': post?.toJson(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? parentId,
    String? content,
    CommentStatus? status,
    int? likeCount,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? author,
    Post? post,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      post: post ?? this.post,
      replies: replies ?? this.replies,
    );
  }

  bool get isPending => status == CommentStatus.pending;
  bool get isApproved => status == CommentStatus.approved;
  bool get isRejected => status == CommentStatus.rejected;
  bool get isReply => parentId != null;
}

@JsonSerializable()
class Post {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? excerpt;
  final String? slug;
  final bool isPublished;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserProfile? author;

  const Post({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.excerpt,
    this.slug,
    required this.isPublished,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      slug: json['slug'] as String?,
      isPublished: json['isPublished'] as bool,
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      author: json['author'] != null ? UserProfile.fromJson(json['author'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'slug': slug,
      'isPublished': isPublished,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': author?.toJson(),
    };
  }
}

@JsonSerializable()
class UserAnalytics {
  final String id;
  final String userId;
  final int messagesSent;
  final int messagesReceived;
  final int commentsPosted;
  final int postsCreated;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAnalytics({
    required this.id,
    required this.userId,
    required this.messagesSent,
    required this.messagesReceived,
    required this.commentsPosted,
    required this.postsCreated,
    required this.lastActivity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      id: json['id'] as String,
      userId: json['userId'] as String,
      messagesSent: json['messagesSent'] as int,
      messagesReceived: json['messagesReceived'] as int,
      commentsPosted: json['commentsPosted'] as int,
      postsCreated: json['postsCreated'] as int,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messagesSent': messagesSent,
      'messagesReceived': messagesReceived,
      'commentsPosted': commentsPosted,
      'postsCreated': postsCreated,
      'lastActivity': lastActivity.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get totalActivity =>
      messagesSent + messagesReceived + commentsPosted + postsCreated;
}