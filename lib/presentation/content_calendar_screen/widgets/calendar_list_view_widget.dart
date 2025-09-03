import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './scheduled_post_card_widget.dart';

class CalendarListViewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(Map<String, dynamic>) onPostTap;
  final Function(Map<String, dynamic>) onPostEdit;
  final Function(Map<String, dynamic>) onPostDelete;

  const CalendarListViewWidget({
    Key? key,
    required this.scheduledPosts,
    required this.onPostTap,
    required this.onPostEdit,
    required this.onPostDelete,
  }) : super(key: key);

  Map<String, List<Map<String, dynamic>>> _groupPostsByDate() {
    final Map<String, List<Map<String, dynamic>>> groupedPosts = {};

    for (final post in scheduledPosts) {
      final date = post['scheduledDate'] as DateTime;
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!groupedPosts.containsKey(dateKey)) {
        groupedPosts[dateKey] = [];
      }
      groupedPosts[dateKey]!.add(post);
    }

    // Sort posts within each date by time
    groupedPosts.forEach((key, posts) {
      posts.sort((a, b) {
        final dateA = a['scheduledDate'] as DateTime;
        final dateB = b['scheduledDate'] as DateTime;
        return dateA.compareTo(dateB);
      });
    });

    return groupedPosts;
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == tomorrow) {
      return 'Tomorrow';
    } else {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedPosts = _groupPostsByDate();
    final sortedKeys = groupedPosts.keys.toList()..sort();

    if (scheduledPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'event_note',
              color: AppTheme.textDisabled,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No scheduled posts',
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Create your first post to get started',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/post-composer-screen');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.darkTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                foregroundColor: AppTheme.darkTheme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final posts = groupedPosts[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              margin: EdgeInsets.only(bottom: 2.h, top: index > 0 ? 3.h : 0),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.darkTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _formatDateHeader(dateKey),
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${posts.length} post${posts.length != 1 ? 's' : ''}',
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Posts for this date
            ...posts
                .map((post) => ScheduledPostCardWidget(
                      post: post,
                      onTap: () => onPostTap(post),
                      onLongPress: () => _showPostOptions(context, post),
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Edit Post',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onPostEdit(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.darkTheme.colorScheme.secondary,
                size: 24,
              ),
              title: Text(
                'Reschedule',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle reschedule
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.darkTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete Post',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onPostDelete(post);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
