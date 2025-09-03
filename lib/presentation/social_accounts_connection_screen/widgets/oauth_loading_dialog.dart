import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OAuthLoadingDialog extends StatefulWidget {
  final String platformName;
  final Color platformColor;
  final String platformIcon;

  const OAuthLoadingDialog({
    Key? key,
    required this.platformName,
    required this.platformColor,
    required this.platformIcon,
  }) : super(key: key);

  @override
  State<OAuthLoadingDialog> createState() => _OAuthLoadingDialogState();
}

class _OAuthLoadingDialogState extends State<OAuthLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.dialogColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Platform Logo with Loading Animation
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: widget.platformColor,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomIconWidget(
                    iconName: widget.platformIcon,
                    color: Colors.white,
                    size: 10.w,
                  ),
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.w),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: LoadingPainter(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Loading Text
            Text(
              'Connecting to ${widget.platformName}',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),

            Text(
              'Please complete the authentication process in your browser',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMediumEmphasis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LoadingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw partial circle (loading indicator)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      3.14159, // Draw half circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
