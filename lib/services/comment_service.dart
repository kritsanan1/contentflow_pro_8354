import '../models/comment_model.dart';
import './supabase_service.dart';

class CommentService {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();

  CommentService._();

  final _client = SupabaseService.instance.client;

  /// Fetch comments with filter options for management
  Future<List<Comment>> getComments({
    CommentStatus? status,
    String? postId,
    String? authorId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('comments').select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug, author_id)
          ''');

      // Apply filters
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (postId != null) {
        query = query.eq('post_id', postId);
      }
      if (authorId != null) {
        query = query.eq('author_id', authorId);
      }

      final response = await query
          .isFilter('parent_id', null) // Only get top-level comments
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch comments: $error');
    }
  }

  /// Get comment replies
  Future<List<Comment>> getCommentReplies(String parentCommentId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            *,
            author:user_profiles!comments_author_id_fkey(*)
          ''')
          .eq('parent_id', parentCommentId)
          .order('created_at', ascending: true);

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch comment replies: $error');
    }
  }

  /// Approve comment
  Future<Comment> approveComment(String commentId) async {
    try {
      final response = await _client
          .from('comments')
          .update({'status': CommentStatus.approved.name})
          .eq('id', commentId)
          .select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug, author_id)
          ''')
          .single();

      return Comment.fromJson(response);
    } catch (error) {
      throw Exception('Failed to approve comment: $error');
    }
  }

  /// Reject comment
  Future<Comment> rejectComment(String commentId) async {
    try {
      final response = await _client
          .from('comments')
          .update({'status': CommentStatus.rejected.name})
          .eq('id', commentId)
          .select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug, author_id)
          ''')
          .single();

      return Comment.fromJson(response);
    } catch (error) {
      throw Exception('Failed to reject comment: $error');
    }
  }

  /// Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _client.from('comments').delete().eq('id', commentId);
    } catch (error) {
      throw Exception('Failed to delete comment: $error');
    }
  }

  /// Bulk update comment statuses
  Future<void> bulkUpdateComments({
    required List<String> commentIds,
    required CommentStatus status,
  }) async {
    try {
      await _client
          .from('comments')
          .update({'status': status.name}).inFilter('id', commentIds);
    } catch (error) {
      throw Exception('Failed to bulk update comments: $error');
    }
  }

  /// Get comment statistics
  Future<Map<String, int>> getCommentStats() async {
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

      return {
        'pending': pendingResponse.count ?? 0,
        'approved': approvedResponse.count ?? 0,
        'rejected': rejectedResponse.count ?? 0,
        'total': totalResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch comment statistics: $error');
    }
  }

  /// Search comments
  Future<List<Comment>> searchComments({
    required String query,
    CommentStatus? status,
    int limit = 50,
  }) async {
    try {
      var supabaseQuery = _client.from('comments').select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug, author_id)
          ''').ilike('content', '%$query%');

      if (status != null) {
        supabaseQuery = supabaseQuery.eq('status', status.name);
      }

      final response = await supabaseQuery
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to search comments: $error');
    }
  }

  /// Get posts for comment filtering
  Future<List<Post>> getPosts({int limit = 50}) async {
    try {
      final response = await _client
          .from('posts')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Post>((json) => Post.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch posts: $error');
    }
  }

  /// Create new comment (for testing purposes)
  Future<Comment> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final commentData = {
        'post_id': postId,
        'author_id': userId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      };

      final response =
          await _client.from('comments').insert(commentData).select('''
            *,
            author:user_profiles!comments_author_id_fkey(*),
            post:posts!comments_post_id_fkey(title, slug, author_id)
          ''').single();

      return Comment.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create comment: $error');
    }
  }
}
