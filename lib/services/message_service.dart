import '../models/message_model.dart';
import './supabase_service.dart';

class MessageService {
  static MessageService? _instance;
  static MessageService get instance => _instance ??= MessageService._();

  MessageService._();

  final _client = SupabaseService.instance.client;

  /// Fetch inbox messages for current user
  Future<List<Message>> getInboxMessages({
    MessageStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client.from('messages').select('''
            *,
            sender:user_profiles!messages_sender_id_fkey(*),
            recipient:user_profiles!messages_recipient_id_fkey(*)
          ''').eq('recipient_id', userId);

      // Apply status filter if provided
      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Message>((json) => Message.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch inbox messages: $error');
    }
  }

  /// Fetch sent messages for current user
  Future<List<Message>> getSentMessages({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('messages')
          .select('''
            *,
            sender:user_profiles!messages_sender_id_fkey(*),
            recipient:user_profiles!messages_recipient_id_fkey(*)
          ''')
          .eq('sender_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Message>((json) => Message.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch sent messages: $error');
    }
  }

  /// Send a new message
  Future<Message> sendMessage({
    required String recipientId,
    required String subject,
    required String content,
    PriorityLevel priority = PriorityLevel.medium,
    String? repliedToId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final messageData = {
        'sender_id': userId,
        'recipient_id': recipientId,
        'subject': subject,
        'content': content,
        'priority': priority.name,
        if (repliedToId != null) 'replied_to': repliedToId,
      };

      final response =
          await _client.from('messages').insert(messageData).select('''
            *,
            sender:user_profiles!messages_sender_id_fkey(*),
            recipient:user_profiles!messages_recipient_id_fkey(*)
          ''').single();

      return Message.fromJson(response);
    } catch (error) {
      throw Exception('Failed to send message: $error');
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('messages')
          .update({'status': MessageStatus.read.name})
          .eq('id', messageId)
          .eq('recipient_id', userId);
    } catch (error) {
      throw Exception('Failed to mark message as read: $error');
    }
  }

  /// Archive message
  Future<void> archiveMessage(String messageId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('messages')
          .update({'status': MessageStatus.archived.name})
          .eq('id', messageId)
          .eq('recipient_id', userId);
    } catch (error) {
      throw Exception('Failed to archive message: $error');
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('messages')
          .delete()
          .eq('id', messageId)
          .or('sender_id.eq.$userId,recipient_id.eq.$userId');
    } catch (error) {
      throw Exception('Failed to delete message: $error');
    }
  }

  /// Get message statistics
  Future<Map<String, int>> getMessageStats() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get unread count
      final unreadResponse = await _client
          .from('messages')
          .select('id')
          .eq('recipient_id', userId)
          .eq('status', MessageStatus.unread.name)
          .count();

      // Get total received count
      final totalReceivedResponse = await _client
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

      return {
        'unread': unreadResponse.count ?? 0,
        'total_received': totalReceivedResponse.count ?? 0,
        'sent': sentResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch message statistics: $error');
    }
  }

  /// Search messages
  Future<List<Message>> searchMessages({
    required String query,
    MessageStatus? status,
    int limit = 50,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var supabaseQuery = _client
          .from('messages')
          .select('''
            *,
            sender:user_profiles!messages_sender_id_fkey(*),
            recipient:user_profiles!messages_recipient_id_fkey(*)
          ''')
          .or('sender_id.eq.$userId,recipient_id.eq.$userId')
          .or('subject.ilike.%$query%,content.ilike.%$query%');

      if (status != null) {
        supabaseQuery = supabaseQuery.eq('status', status.name);
      }

      final response = await supabaseQuery
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Message>((json) => Message.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to search messages: $error');
    }
  }

  /// Get users for message composition
  Future<List<UserProfile>> getAvailableUsers({String? searchQuery}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('user_profiles')
          .select('*')
          .neq('id', userId)
          .eq('is_active', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      final response =
          await query.order('full_name', ascending: true).limit(50);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch users: $error');
    }
  }
}
