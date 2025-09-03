import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/message_model.dart';

class RecentMessagesWidget extends StatelessWidget {
  final List<Message> messages;
  final VoidCallback onViewAll;

  const RecentMessagesWidget({
    Key? key,
    required this.messages,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inbox,
                      size: 5.w, color: Theme.of(context).primaryColor),
                  SizedBox(width: 2.w),
                  Text(
                    'Recent Messages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          messages.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: messages
                      .take(3)
                      .map((message) => _buildMessageItem(context, message))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, Message message) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: message.isUnread ? Colors.blue.withAlpha(13) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(
          color:
              message.isUnread ? Colors.blue.withAlpha(51) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 3.w,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(51),
                backgroundImage: message.sender?.avatarUrl != null
                    ? NetworkImage(message.sender!.avatarUrl!)
                    : null,
                child: message.sender?.avatarUrl == null
                    ? Text(
                        _getInitials(message.sender?.fullName ?? 'U'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 3.w,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender?.fullName ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatTime(message.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (message.isUnread)
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              if (message.isHighPriority)
                Padding(
                  padding: EdgeInsets.only(left: 1.w),
                  child: Icon(
                    Icons.priority_high,
                    size: 4.w,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            message.subject,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            message.content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 15.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 8.w, color: Colors.grey[400]),
            SizedBox(height: 1.h),
            Text(
              'No recent messages',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
