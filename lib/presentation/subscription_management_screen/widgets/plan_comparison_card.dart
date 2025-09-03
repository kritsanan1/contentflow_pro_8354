import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PlanComparisonCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrentPlan;
  final VoidCallback? onUpgrade;

  const PlanComparisonCard({
    Key? key,
    required this.plan,
    required this.isCurrentPlan,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentPlan
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (plan['name'] as String),
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textHighEmphasis,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CURRENT',
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(plan['price'] as double).toStringAsFixed(0)}',
                  style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '/month',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMediumEmphasis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Features:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...(plan['features'] as List)
                .map((feature) => _buildFeatureItem(feature as String))
                .toList(),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCurrentPlan ? AppTheme.dividerColor : AppTheme.primary,
                  foregroundColor: isCurrentPlan
                      ? AppTheme.textMediumEmphasis
                      : AppTheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Text(
                  isCurrentPlan ? 'Current Plan' : 'Upgrade',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.secondary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              feature,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
