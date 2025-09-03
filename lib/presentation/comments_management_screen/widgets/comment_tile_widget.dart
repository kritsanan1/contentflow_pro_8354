import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/comment_model.dart';

class CommentTileWidget extends StatelessWidget {
  final Comment comment;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const CommentTileWidget({
    Key? key,
    required this.comment,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onApprove,
    this.onReject,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.sp),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.sp),
            color: isSelected
                ? Theme.of(context).primaryColor.withAlpha(13)
                : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Selection Checkbox
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap?.call(),
                      activeColor: Theme.of(context).primaryColor,
                    )
                  else
                    // Avatar
                    CircleAvatar(
                      radius: 5.w,
                      backgroundColor: _getStatusColor().withAlpha(51),
                      backgroundImage: comment.author?.avatarUrl != null
                          ? NetworkImage(comment.author!.avatarUrl!)
                          : null,
                      child: comment.author?.avatarUrl == null
                          ? Text(
                              _getInitials(),
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 4.w,
                              ),
                            )
                          : null,
                    ),
                  SizedBox(width: 3.w),
                  // Comment Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.author?.fullName ?? 'Unknown Author',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            _buildStatusBadge(),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'On: ${comment.post?.title ?? 'Unknown Post'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(comment.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Like Count
                  if (comment.likeCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.thumb_up,
                              size: 3.w, color: Colors.grey[600]),
                          SizedBox(width: 1.w),
                          Text(
                            '${comment.likeCount}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 2.5.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 1.5.h),
              // Comment Content
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10.sp),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 1.h),
              // Action Buttons (only when not in selection mode)
              if (!isSelectionMode) _buildActionButtons(context),
              // Edited Indicator
              if (comment.isEdited)
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 3.w, color: Colors.grey[500]),
                      SizedBox(width: 1.w),
                      Text(
                        'Edited',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
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

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    switch (comment.status) {
      case CommentStatus.approved:
        color = Colors.green;
        label = 'APPROVED';
        icon = Icons.check_circle;
        break;
      case CommentStatus.pending:
        color = Colors.orange;
        label = 'PENDING';
        icon = Icons.pending;
        break;
      case CommentStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 3.w, color: color),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 2.5.w,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> actions = [];

    if (onApprove != null) {
      actions.add(
        TextButton.icon(
          onPressed: onApprove,
          icon: Icon(Icons.check, size: 4.w, color: Colors.green),
          label: const Text('Approve'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (onReject != null) {
      actions.add(
        TextButton.icon(
          onPressed: onReject,
          icon: Icon(Icons.close, size: 4.w, color: Colors.orange),
          label: const Text('Reject'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        TextButton.icon(
          onPressed: () => _showDeleteConfirmation(context),
          icon: Icon(Icons.delete, size: 4.w, color: Colors.red),
          label: const Text('Delete'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions
          .map((action) => [action, SizedBox(width: 1.w)])
          .expand((element) => element)
          .toList()
        ..removeLast(), // Remove last spacing
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.'),
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

  Color _getStatusColor() {
    switch (comment.status) {
      case CommentStatus.approved:
        return Colors.green;
      case CommentStatus.pending:
        return Colors.orange;
      case CommentStatus.rejected:
        return Colors.red;
    }
  }

  String _getInitials() {
    final name = comment.author?.fullName ?? 'U';
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
