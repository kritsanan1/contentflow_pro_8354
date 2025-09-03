import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentMethodCard extends StatelessWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final VoidCallback onAddNew;
  final Function(String) onDeleteMethod;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethods,
    required this.onAddNew,
    required this.onDeleteMethod,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Methods',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textHighEmphasis,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.secondary,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...paymentMethods
                .map((method) => _buildPaymentMethodItem(method))
                .toList(),
            SizedBox(height: 1.h),
            OutlinedButton.icon(
              onPressed: onAddNew,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.primary,
                size: 20,
              ),
              label: Text(
                'Add New Payment Method',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: (method['isDefault'] as bool)
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getCardIcon(method['type'] as String),
                color: AppTheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '**** **** **** ${method['lastFour']}',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (method['isDefault'] as bool) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DEFAULT',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Expires ${method['expiry']}',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumEmphasis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onDeleteMethod(method['id'] as String),
            icon: CustomIconWidget(
              iconName: 'delete_outline',
              color: AppTheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'credit_card';
      case 'mastercard':
        return 'credit_card';
      case 'amex':
        return 'credit_card';
      default:
        return 'payment';
    }
  }
}
