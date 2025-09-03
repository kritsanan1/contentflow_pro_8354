import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  final double? size;

  const AppLogoWidget({
    Key? key,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 25.w,
      height: size ?? 25.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkTheme.colorScheme.primary,
            AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.darkTheme.colorScheme.onPrimary,
            size: (size ?? 25.w) * 0.4,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'CF',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: (size ?? 25.w) * 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
