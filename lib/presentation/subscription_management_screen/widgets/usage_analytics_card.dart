import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class UsageAnalyticsCard extends StatelessWidget {
  final List<Map<String, dynamic>> usageData;

  const UsageAnalyticsCard({
    Key? key,
    required this.usageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Analytics',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textHighEmphasis,
              ),
            ),
            SizedBox(height: 2.h),
            ...usageData.map((usage) => _buildUsageItem(usage)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem(Map<String, dynamic> usage) {
    final double percentage = (usage['used'] as int) / (usage['limit'] as int);
    final Color progressColor = percentage >= 0.9
        ? AppTheme.error
        : percentage >= 0.7
            ? AppTheme.warning
            : AppTheme.secondary;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (usage['title'] as String),
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${usage['used']}/${usage['limit']}',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 0.8.h,
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}% used',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }
}
