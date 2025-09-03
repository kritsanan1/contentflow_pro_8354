import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/comment_model.dart';

class PendingCommentsWidget extends StatelessWidget {
  final List<Comment> comments;
  final VoidCallback onViewAll;

  const PendingCommentsWidget({
    Key? key,
    required this.comments,
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
                  Icon(Icons.pending, size: 5.w, color: Colors.orange),
                  SizedBox(width: 2.w),
                  Text(
                    'Pending Comments',
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
          comments.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: comments
                      .take(3)
                      .map((comment) => _buildCommentItem(context, comment))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(13),
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: Colors.orange.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 3.w,
                backgroundColor: Colors.orange.withAlpha(51),
                backgroundImage: comment.author?.avatarUrl != null
                    ? NetworkImage(comment.author!.avatarUrl!)
                    : null,
                child: comment.author?.avatarUrl == null
                    ? Text(
                        _getInitials(comment.author?.fullName ?? 'U'),
                        style: TextStyle(
                          color: Colors.orange,
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
                      comment.author?.fullName ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'On: ${comment.post?.title ?? 'Unknown Post'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(51),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 2.5.w,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            comment.content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                _formatTime(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const Spacer(),
              if (comment.likeCount > 0) ...[
                Icon(Icons.thumb_up, size: 3.w, color: Colors.grey[500]),
                SizedBox(width: 0.5.w),
                Text(
                  '${comment.likeCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ],
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
            Icon(Icons.comment_outlined, size: 8.w, color: Colors.grey[400]),
            SizedBox(height: 1.h),
            Text(
              'No pending comments',
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
