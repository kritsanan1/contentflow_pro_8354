import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScheduledPostCardWidget extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;

  const ScheduledPostCardWidget({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Color(0xFF1877F2);
      case 'instagram':
        return Color(0xFFE4405F);
      case 'twitter':
        return Color(0xFF1DA1F2);
      case 'linkedin':
        return Color(0xFF0A66C2);
      case 'tiktok':
        return Color(0xFF000000);
      default:
        return AppTheme.darkTheme.colorScheme.primary;
    }
  }

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'facebook';
      case 'instagram':
        return 'camera_alt';
      case 'twitter':
        return 'alternate_email';
      case 'linkedin':
        return 'business';
      case 'tiktok':
        return 'music_note';
      default:
        return 'share';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduledTime = post['scheduledDate'] as DateTime;
    final timeString =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.2)
              : AppTheme.darkTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.darkTheme.colorScheme.primary, width: 2)
              : Border.all(color: AppTheme.dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with platform and time
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: _getPlatformColor(post['platform'] as String),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getPlatformIcon(post['platform'] as String),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['platform'] as String,
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: _getPlatformColor(post['platform'] as String),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeString,
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post['status'] == 'scheduled')
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Scheduled',
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Post content preview
            Text(
              post['content'] as String,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (post['hasMedia'] == true) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'image',
                    color: AppTheme.textMediumEmphasis,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Media attached',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMediumEmphasis,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 1.h),

            // Engagement metrics (if available)
            if (post['metrics'] != null) ...[
              Row(
                children: [
                  _buildMetric('favorite',
                      (post['metrics'] as Map)['likes']?.toString() ?? '0'),
                  SizedBox(width: 4.w),
                  _buildMetric('comment',
                      (post['metrics'] as Map)['comments']?.toString() ?? '0'),
                  SizedBox(width: 4.w),
                  _buildMetric('share',
                      (post['metrics'] as Map)['shares']?.toString() ?? '0'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String iconName, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.textMediumEmphasis,
          size: 14,
        ),
        SizedBox(width: 1.w),
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
      ],
    );
  }
}
