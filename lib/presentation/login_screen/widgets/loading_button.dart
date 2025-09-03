import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const LoadingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 6.h,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPress
              ? (backgroundColor ?? AppTheme.darkTheme.colorScheme.primary)
              : AppTheme.darkTheme.colorScheme.surface,
          foregroundColor: canPress
              ? (textColor ?? AppTheme.darkTheme.colorScheme.onPrimary)
              : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          elevation: canPress ? 2.0 : 0,
          shadowColor: canPress
              ? AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppTheme.darkTheme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: canPress
                      ? (textColor ?? AppTheme.darkTheme.colorScheme.onPrimary)
                      : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
      ),
    );
  }
}
