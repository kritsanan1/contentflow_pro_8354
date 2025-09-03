import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    Key? key,
    required this.iconName,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? AppTheme.darkTheme.colorScheme.surface,
          foregroundColor:
              textColor ?? AppTheme.darkTheme.colorScheme.onSurface,
          elevation: 0,
          side: BorderSide(
            color: AppTheme.darkTheme.colorScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: textColor ?? AppTheme.darkTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: textColor ?? AppTheme.darkTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
