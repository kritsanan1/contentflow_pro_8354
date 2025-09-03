import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './scheduled_post_card_widget.dart';

class DayPostsBottomSheetWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> posts;
  final Function(Map<String, dynamic>) onPostTap;
  final Function(Map<String, dynamic>) onPostEdit;
  final Function(Map<String, dynamic>) onPostDelete;

  const DayPostsBottomSheetWidget({
    Key? key,
    required this.selectedDate,
    required this.posts,
    required this.onPostTap,
    required this.onPostEdit,
    required this.onPostDelete,
  }) : super(key: key);

  @override
  State<DayPostsBottomSheetWidget> createState() =>
      _DayPostsBottomSheetWidgetState();
}

class _DayPostsBottomSheetWidgetState extends State<DayPostsBottomSheetWidget> {
  Set<String> selectedPosts = {};
  bool isMultiSelectMode = false;

  void _togglePostSelection(String postId) {
    setState(() {
      if (selectedPosts.contains(postId)) {
        selectedPosts.remove(postId);
      } else {
        selectedPosts.add(postId);
      }

      if (selectedPosts.isEmpty) {
        isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(String postId) {
    setState(() {
      isMultiSelectMode = true;
      selectedPosts.add(postId);
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      isMultiSelectMode = false;
      selectedPosts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                if (isMultiSelectMode) ...[
                  GestureDetector(
                    onTap: _exitMultiSelectMode,
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textHighEmphasis,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '${selectedPosts.length} selected',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textHighEmphasis,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Handle bulk delete
                      for (String postId in selectedPosts) {
                        final post =
                            widget.posts.firstWhere((p) => p['id'] == postId);
                        widget.onPostDelete(post);
                      }
                      _exitMultiSelectMode();
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.error
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.darkTheme.colorScheme.error,
                        size: 20,
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${monthNames[widget.selectedDate.month - 1]} ${widget.selectedDate.day}, ${widget.selectedDate.year}',
                          style:
                              AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.textHighEmphasis,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.posts.length} scheduled post${widget.posts.length != 1 ? 's' : ''}',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textMediumEmphasis,
                      size: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(color: AppTheme.dividerColor, height: 1),

          // Posts list
          Expanded(
            child: widget.posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'event_note',
                          color: AppTheme.textDisabled,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No posts scheduled',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Tap the + button to schedule a post',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: widget.posts.length,
                    itemBuilder: (context, index) {
                      final post = widget.posts[index];
                      final postId = post['id'].toString();
                      final isSelected = selectedPosts.contains(postId);

                      return ScheduledPostCardWidget(
                        post: post,
                        isSelected: isSelected,
                        onTap: () {
                          if (isMultiSelectMode) {
                            _togglePostSelection(postId);
                          } else {
                            widget.onPostTap(post);
                          }
                        },
                        onLongPress: () {
                          if (!isMultiSelectMode) {
                            _enterMultiSelectMode(postId);
                          }
                        },
                      );
                    },
                  ),
          ),

          // Bottom actions
          if (!isMultiSelectMode && widget.posts.isNotEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: AppTheme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/post-composer-screen');
                      },
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.darkTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      label: Text('Schedule Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                        foregroundColor:
                            AppTheme.darkTheme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
