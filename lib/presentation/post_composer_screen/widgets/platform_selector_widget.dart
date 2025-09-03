import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> platforms;
  final List<String> selectedPlatforms;
  final Function(String) onPlatformToggle;

  const PlatformSelectorWidget({
    Key? key,
    required this.platforms,
    required this.selectedPlatforms,
    required this.onPlatformToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Platforms',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHighEmphasis,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 6.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: platforms.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final platform = platforms[index];
                final isSelected = selectedPlatforms.contains(platform['id']);
                final isConnected = platform['isConnected'] as bool;

                return GestureDetector(
                  onTap: isConnected
                      ? () => onPlatformToggle(platform['id'])
                      : null,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : isConnected
                                ? AppTheme.dividerColor
                                : AppTheme.error.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: platform['icon'],
                          color: isConnected
                              ? (isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textMediumEmphasis)
                              : AppTheme.error,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          platform['name'],
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isConnected
                                ? (isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textMediumEmphasis)
                                : AppTheme.error,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        if (!isConnected) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'warning',
                            color: AppTheme.error,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
