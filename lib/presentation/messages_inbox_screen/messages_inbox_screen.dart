import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/message_model.dart';
import '../../services/message_service.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/compose_message_dialog.dart';
import './widgets/message_filter_sheet.dart';
import './widgets/message_tile_widget.dart';

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({Key? key}) : super(key: key);

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageService = MessageService.instance;

  // State management
  List<Message> _inboxMessages = [];
  List<Message> _sentMessages = [];
  Map<String, int> _messageStats = {};
  bool _isLoading = true;
  String? _error;

  // Filters
  MessageStatus? _selectedStatus;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _messageService.getInboxMessages(status: _selectedStatus),
        _messageService.getSentMessages(),
        _messageService.getMessageStats(),
      ]);

      setState(() {
        _inboxMessages = results[0] as List<Message>;
        _sentMessages = results[1] as List<Message>;
        _messageStats = results[2] as Map<String, int>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMessages() async {
    await _loadInitialData();
  }

  void _onMessageTap(Message message) {
    if (message.isUnread && _tabController.index == 0) {
      _markAsRead(message);
    }
    _showMessageDetails(message);
  }

  Future<void> _markAsRead(Message message) async {
    try {
      await _messageService.markAsRead(message.id);
      await _refreshMessages();
    } catch (error) {
      _showSnackBar('Failed to mark message as read: $error');
    }
  }

  void _showMessageDetails(Message message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(4.w),
        child: Container(
          constraints: BoxConstraints(maxHeight: 80.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.sp),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.subject,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'From: ${message.sender?.fullName ?? 'Unknown'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          Text(
                            'Date: ${_formatDate(message.createdAt)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: SingleChildScrollView(
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReplyDialog(message);
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _archiveMessage(message.id);
                      },
                      icon: const Icon(Icons.archive),
                      label: const Text('Archive'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteMessage(message.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(Message originalMessage) {
    showDialog(
      context: context,
      builder: (context) => ComposeMessageDialog(
        recipientId: originalMessage.senderId,
        recipientName: originalMessage.sender?.fullName,
        subject: 'Re: ${originalMessage.subject}',
        originalContent: originalMessage.content,
        onSend: (recipientId, subject, content, priority) async {
          try {
            await _messageService.sendMessage(
              recipientId: recipientId,
              subject: subject,
              content: content,
              priority: priority,
              repliedToId: originalMessage.id,
            );
            Navigator.pop(context);
            _showSnackBar('Reply sent successfully');
            await _refreshMessages();
          } catch (error) {
            _showSnackBar('Failed to send reply: $error');
          }
        },
      ),
    );
  }

  Future<void> _archiveMessage(String messageId) async {
    try {
      await _messageService.archiveMessage(messageId);
      _showSnackBar('Message archived');
      await _refreshMessages();
    } catch (error) {
      _showSnackBar('Failed to archive message: $error');
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _messageService.deleteMessage(messageId);
      _showSnackBar('Message deleted');
      await _refreshMessages();
    } catch (error) {
      _showSnackBar('Failed to delete message: $error');
    }
  }

  void _showComposeDialog() {
    showDialog(
      context: context,
      builder: (context) => ComposeMessageDialog(
        onSend: (recipientId, subject, content, priority) async {
          try {
            await _messageService.sendMessage(
              recipientId: recipientId,
              subject: subject,
              content: content,
              priority: priority,
            );
            Navigator.pop(context);
            _showSnackBar('Message sent successfully');
            await _refreshMessages();
          } catch (error) {
            _showSnackBar('Failed to send message: $error');
          }
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (context) => MessageFilterSheet(
        currentStatus: _selectedStatus,
        onFilterApplied: (status) {
          setState(() {
            _selectedStatus = status;
          });
          _refreshMessages();
        },
      ),
    );
  }

  void _performSearch() async {
    if (_searchQuery.isEmpty) {
      await _refreshMessages();
      return;
    }

    try {
      setState(() => _isLoading = true);

      final searchResults = await _messageService.searchMessages(
        query: _searchQuery,
        status: _selectedStatus,
      );

      setState(() {
        if (_tabController.index == 0) {
          _inboxMessages = searchResults
              .where((msg) =>
                  msg.recipientId ==
                  _messageService._client.auth.currentUser?.id)
              .toList();
        } else {
          _sentMessages = searchResults
              .where((msg) =>
                  msg.senderId == _messageService._client.auth.currentUser?.id)
              .toList();
        }
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes;

      if (hours > 0) return '${hours}h ago';
      if (minutes > 0) return '${minutes}m ago';
      return 'Just now';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _refreshMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              // Stats Row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Unread',
                      _messageStats['unread']?.toString() ?? '0',
                      Icons.mark_email_unread,
                      Colors.red,
                    ),
                    _buildStatItem(
                      'Received',
                      _messageStats['total_received']?.toString() ?? '0',
                      Icons.inbox,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Sent',
                      _messageStats['sent']?.toString() ?? '0',
                      Icons.send,
                      Colors.green,
                    ),
                  ],
                ),
              ),
              // Search Bar
              Container(
                padding: EdgeInsets.all(4.w),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _refreshMessages();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.sp),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Inbox'),
                  Tab(text: 'Sent'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? CustomErrorWidget(
                  errorDetails:
                      FlutterErrorDetails(exception: Exception(_error!)),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInboxTab(),
                    _buildSentTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposeDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 6.w),
        SizedBox(height: 0.5.h),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildInboxTab() {
    if (_inboxMessages.isEmpty) {
      return _buildEmptyState('No messages in inbox', Icons.inbox);
    }

    return RefreshIndicator(
      onRefresh: _refreshMessages,
      child: ListView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: _inboxMessages.length,
        itemBuilder: (context, index) {
          final message = _inboxMessages[index];
          return MessageTileWidget(
            message: message,
            onTap: () => _onMessageTap(message),
            onArchive: () => _archiveMessage(message.id),
            onDelete: () => _deleteMessage(message.id),
          );
        },
      ),
    );
  }

  Widget _buildSentTab() {
    if (_sentMessages.isEmpty) {
      return _buildEmptyState('No sent messages', Icons.send);
    }

    return RefreshIndicator(
      onRefresh: _refreshMessages,
      child: ListView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: _sentMessages.length,
        itemBuilder: (context, index) {
          final message = _sentMessages[index];
          return MessageTileWidget(
            message: message,
            onTap: () => _onMessageTap(message),
            showSentIndicator: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15.w, color: Colors.grey),
          SizedBox(height: 2.h),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}