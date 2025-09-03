import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                context,
                'Messages',
                Icons.inbox,
                Colors.blue,
                () => Navigator.pushNamed(context, '/messages-inbox'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildQuickAction(
                context,
                'Comments',
                Icons.comment,
                Colors.orange,
                () => Navigator.pushNamed(context, '/comments-management'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildQuickAction(
                context,
                'Content',
                Icons.article,
                Colors.green,
                () => Navigator.pushNamed(context, '/content-calendar'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildQuickAction(
                context,
                'Users',
                Icons.people,
                Colors.purple,
                () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.sp),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withAlpha(26),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
