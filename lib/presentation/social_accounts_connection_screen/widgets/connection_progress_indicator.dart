import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionProgressIndicator extends StatelessWidget {
  final int connectedCount;
  final int totalCount;

  const ConnectionProgressIndicator({
    Key? key,
    required this.connectedCount,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = totalCount > 0 ? connectedCount / totalCount : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connection Progress',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: progress == 1.0
                      ? AppTheme.secondary.withValues(alpha: 0.2)
                      : AppTheme.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  '$connectedCount/$totalCount',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color:
                        progress == 1.0 ? AppTheme.secondary : AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Progress Bar
          Container(
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      progress == 1.0 ? AppTheme.secondary : AppTheme.primary,
                  borderRadius: BorderRadius.circular(0.5.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Progress Text
          Text(
            progress == 1.0
                ? 'All platforms connected! You\'re ready to manage your social media.'
                : 'Connect ${totalCount - connectedCount} more platform${totalCount - connectedCount == 1 ? '' : 's'} to unlock full functionality.',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),

          if (progress == 1.0) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.secondary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'All set! You can now create and schedule posts across all your connected platforms.',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
