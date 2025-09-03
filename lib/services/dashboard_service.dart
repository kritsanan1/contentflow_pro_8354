import '../models/comment_model.dart';
import '../models/message_model.dart';
import './supabase_service.dart';

class DashboardService {
  static DashboardService? _instance;
  static DashboardService get instance => _instance ??= DashboardService._();

  DashboardService._();

  final _client = SupabaseService.instance.client;

  /// Get comprehensive dashboard analytics
  Future<DashboardAnalytics> getDashboardAnalytics() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Fetch user analytics
      final analyticsResponse = await _client
          .from('user_analytics')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      UserAnalytics? userAnalytics;
      if (analyticsResponse != null) {
        userAnalytics = UserAnalytics.fromJson(analyticsResponse);
      }

      // Get recent activity counts
      final recentMessages = await _getRecentMessages();
      final recentComments = await _getRecentComments();
      final messageStats = await _getMessageStatistics();
      final commentStats = await _getCommentStatistics();
      final systemStats = await _getSystemStatistics();

      return DashboardAnalytics(
        userAnalytics: userAnalytics,
        recentMessages: recentMessages,
        recentComments: recentComments,
        messageStats: messageStats,
        commentStats: commentStats,
        systemStats: systemStats,
      );
    } catch (error) {
      throw Exception('Failed to fetch dashboard analytics: $error');
    }
  }

  /// Get recent messages for dashboard
  Future<List<Message>> _getRecentMessages() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('messages')
          .select('''
            *,
            sender:user_profiles!messages_sender_id_fkey(*)
          ''')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      return response.map<Message>((json) => Message.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }

  /// Get recent comments for dashboard
  Future<List<Comment>> _getRecentComments() async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug)
          ''')
          .eq('status', CommentStatus.pending.name)
          .order('created_at', ascending: false)
          .limit(5);

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (error) {
      return [];
    }
  }

  /// Get message statistics
  Future<MessageStatistics> _getMessageStatistics() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const MessageStatistics(
          unread: 0,
          totalReceived: 0,
          sent: 0,
          archived: 0,
        );
      }

      // Get unread count
      final unreadResponse = await _client
          .from('messages')
          .select('id')
          .eq('recipient_id', userId)
          .eq('status', MessageStatus.unread.name)
          .count();

      // Get total received count
      final receivedResponse = await _client
          .from('messages')
          .select('id')
          .eq('recipient_id', userId)
          .count();

      // Get sent count
      final sentResponse = await _client
          .from('messages')
          .select('id')
          .eq('sender_id', userId)
          .count();

      // Get archived count
      final archivedResponse = await _client
          .from('messages')
          .select('id')
          .eq('recipient_id', userId)
          .eq('status', MessageStatus.archived.name)
          .count();

      return MessageStatistics(
        unread: unreadResponse.count ?? 0,
        totalReceived: receivedResponse.count ?? 0,
        sent: sentResponse.count ?? 0,
        archived: archivedResponse.count ?? 0,
      );
    } catch (error) {
      return const MessageStatistics(
        unread: 0,
        totalReceived: 0,
        sent: 0,
        archived: 0,
      );
    }
  }

  /// Get comment statistics
  Future<CommentStatistics> _getCommentStatistics() async {
    try {
      // Get pending count
      final pendingResponse = await _client
          .from('comments')
          .select('id')
          .eq('status', CommentStatus.pending.name)
          .count();

      // Get approved count
      final approvedResponse = await _client
          .from('comments')
          .select('id')
          .eq('status', CommentStatus.approved.name)
          .count();

      // Get rejected count
      final rejectedResponse = await _client
          .from('comments')
          .select('id')
          .eq('status', CommentStatus.rejected.name)
          .count();

      // Get total count
      final totalResponse = await _client.from('comments').select('id').count();

      return CommentStatistics(
        pending: pendingResponse.count ?? 0,
        approved: approvedResponse.count ?? 0,
        rejected: rejectedResponse.count ?? 0,
        total: totalResponse.count ?? 0,
      );
    } catch (error) {
      return const CommentStatistics(
        pending: 0,
        approved: 0,
        rejected: 0,
        total: 0,
      );
    }
  }

  /// Get system-wide statistics
  Future<SystemStatistics> _getSystemStatistics() async {
    try {
      // Get total users
      final usersResponse = await _client
          .from('user_profiles')
          .select('id')
          .eq('is_active', true)
          .count();

      // Get total posts
      final postsResponse = await _client.from('posts').select('id').count();

      // Get active users (users with activity in last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activeUsersResponse = await _client
          .from('user_analytics')
          .select('user_id')
          .gte('last_activity', thirtyDaysAgo.toIso8601String())
          .count();

      return SystemStatistics(
        totalUsers: usersResponse.count ?? 0,
        totalPosts: postsResponse.count ?? 0,
        activeUsers: activeUsersResponse.count ?? 0,
      );
    } catch (error) {
      return const SystemStatistics(
        totalUsers: 0,
        totalPosts: 0,
        activeUsers: 0,
      );
    }
  }

  /// Get activity timeline for dashboard
  Future<List<ActivityItem>> getActivityTimeline({int limit = 10}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      List<ActivityItem> activities = [];

      // Get recent messages
      final messages = await _client
          .from('messages')
          .select('''
            id, subject, created_at,
            sender:user_profiles!messages_sender_id_fkey(full_name)
          ''')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit ~/ 2);

      for (final message in messages) {
        activities.add(ActivityItem(
          id: message['id'],
          type: ActivityType.message,
          title: 'New message: ${message['subject']}',
          subtitle: 'From ${message['sender']['full_name']}',
          timestamp: DateTime.parse(message['created_at']),
        ));
      }

      // Get recent comments (if user is admin/moderator)
      final currentUser = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (currentUser != null &&
          (currentUser['role'] == 'admin' ||
              currentUser['role'] == 'moderator')) {
        final comments = await _client
            .from('comments')
            .select('''
              id, content, created_at, status,
              author:user_profiles!comments_author_id_fkey(full_name),
              post:posts!comments_post_id_fkey(title)
            ''')
            .eq('status', CommentStatus.pending.name)
            .order('created_at', ascending: false)
            .limit(limit ~/ 2);

        for (final comment in comments) {
          activities.add(ActivityItem(
            id: comment['id'],
            type: ActivityType.comment,
            title: 'New comment pending approval',
            subtitle:
                'On "${comment['post']['title']}" by ${comment['author']['full_name']}',
            timestamp: DateTime.parse(comment['created_at']),
          ));
        }
      }

      // Sort all activities by timestamp
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities.take(limit).toList();
    } catch (error) {
      return [];
    }
  }
}

// Dashboard-specific models
class DashboardAnalytics {
  final UserAnalytics? userAnalytics;
  final List<Message> recentMessages;
  final List<Comment> recentComments;
  final MessageStatistics messageStats;
  final CommentStatistics commentStats;
  final SystemStatistics systemStats;

  const DashboardAnalytics({
    this.userAnalytics,
    required this.recentMessages,
    required this.recentComments,
    required this.messageStats,
    required this.commentStats,
    required this.systemStats,
  });
}

class MessageStatistics {
  final int unread;
  final int totalReceived;
  final int sent;
  final int archived;

  const MessageStatistics({
    required this.unread,
    required this.totalReceived,
    required this.sent,
    required this.archived,
  });
}

class CommentStatistics {
  final int pending;
  final int approved;
  final int rejected;
  final int total;

  const CommentStatistics({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });
}

class SystemStatistics {
  final int totalUsers;
  final int totalPosts;
  final int activeUsers;

  const SystemStatistics({
    required this.totalUsers,
    required this.totalPosts,
    required this.activeUsers,
  });
}

enum ActivityType { message, comment, post, user }

class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}
