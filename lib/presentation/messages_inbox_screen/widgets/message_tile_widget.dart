import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/message_model.dart';

class MessageTileWidget extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final bool showSentIndicator;

  const MessageTileWidget({
    Key? key,
    required this.message,
    required this.onTap,
    this.onArchive,
    this.onDelete,
    this.showSentIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      elevation: message.isUnread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
        side: BorderSide(
          color: message.isUnread
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: message.isUnread ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.sp),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 5.w,
                    backgroundColor: _getPriorityColor().withAlpha(51),
                    backgroundImage: (showSentIndicator
                                ? message.recipient?.avatarUrl
                                : message.sender?.avatarUrl) !=
                            null
                        ? NetworkImage(showSentIndicator
                            ? message.recipient!.avatarUrl!
                            : message.sender!.avatarUrl!)
                        : null,
                    child: (showSentIndicator
                                ? message.recipient?.avatarUrl
                                : message.sender?.avatarUrl) ==
                            null
                        ? Text(
                            _getInitials(),
                            style: TextStyle(
                              color: _getPriorityColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 4.w,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  // Message Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                showSentIndicator
                                    ? 'To: ${message.recipient?.fullName ?? 'Unknown'}'
                                    : message.sender?.fullName ?? 'Unknown',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: message.isUnread
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            _buildPriorityIndicator(),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatDate(message.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Status Indicators
                  Column(
                    children: [
                      if (message.isUnread && !showSentIndicator)
                        Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (message.hasAttachments)
                        Padding(
                          padding: EdgeInsets.only(top: 0.5.h),
                          child: Icon(
                            Icons.attach_file,
                            size: 4.w,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              // Subject
              Text(
                message.subject,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight:
                          message.isUnread ? FontWeight.bold : FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              // Content Preview
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              // Action Buttons (only for inbox messages)
              if (!showSentIndicator) _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    if (message.priority == PriorityLevel.low) return const SizedBox.shrink();

    Color color;
    String label;

    switch (message.priority) {
      case PriorityLevel.urgent:
        color = Colors.red;
        label = 'URGENT';
        break;
      case PriorityLevel.high:
        color = Colors.orange;
        label = 'HIGH';
        break;
      case PriorityLevel.medium:
        color = Colors.blue;
        label = 'MED';
        break;
      case PriorityLevel.low:
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 2.5.w,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onArchive != null)
          TextButton.icon(
            onPressed: onArchive,
            icon: Icon(Icons.archive, size: 4.w),
            label: const Text('Archive'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        SizedBox(width: 2.w),
        if (onDelete != null)
          TextButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: Icon(Icons.delete, size: 4.w),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
            'Are you sure you want to delete this message? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (message.priority) {
      case PriorityLevel.urgent:
        return Colors.red;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.low:
        return Colors.green;
    }
  }

  String _getInitials() {
    final name = showSentIndicator
        ? message.recipient?.fullName ?? 'U'
        : message.sender?.fullName ?? 'U';

    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
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
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
