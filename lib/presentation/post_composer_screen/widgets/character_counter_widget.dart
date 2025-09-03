import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CharacterCounterWidget extends StatelessWidget {
  final String text;
  final List<String> selectedPlatforms;
  final List<Map<String, dynamic>> platforms;

  const CharacterCounterWidget({
    Key? key,
    required this.text,
    required this.selectedPlatforms,
    required this.platforms,
  }) : super(key: key);

  Map<String, int> get platformLimits => {
        'twitter': 280,
        'facebook': 63206,
        'instagram': 2200,
        'linkedin': 3000,
        'tiktok': 2200,
      };

  @override
  Widget build(BuildContext context) {
    if (selectedPlatforms.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Wrap(
        spacing: 3.w,
        runSpacing: 1.h,
        children: selectedPlatforms.map((platformId) {
          final platform = platforms.firstWhere((p) => p['id'] == platformId);
          final limit = platformLimits[platformId] ?? 280;
          final currentLength = text.length;
          final isOverLimit = currentLength > limit;
          final percentage = currentLength / limit;

          Color counterColor;
          if (percentage >= 1.0) {
            counterColor = AppTheme.error;
          } else if (percentage >= 0.8) {
            counterColor = AppTheme.warning;
          } else {
            counterColor = AppTheme.textMediumEmphasis;
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverLimit ? AppTheme.error : AppTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: platform['icon'],
                  color: counterColor,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  '$currentLength/$limit',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: counterColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isOverLimit) ...[
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'error',
                    color: AppTheme.error,
                    size: 14,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
