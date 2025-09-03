import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BillingHistoryCard extends StatefulWidget {
  final List<Map<String, dynamic>> billingHistory;
  final Function(String) onDownloadInvoice;

  const BillingHistoryCard({
    Key? key,
    required this.billingHistory,
    required this.onDownloadInvoice,
  }) : super(key: key);

  @override
  State<BillingHistoryCard> createState() => _BillingHistoryCardState();
}

class _BillingHistoryCardState extends State<BillingHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Billing History',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textHighEmphasis,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.textMediumEmphasis,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              SizedBox(height: 2.h),
              ...widget.billingHistory
                  .map((invoice) => _buildInvoiceItem(invoice))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(Map<String, dynamic> invoice) {
    final Color statusColor = _getStatusColor(invoice['status'] as String);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (invoice['date'] as String),
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (invoice['status'] as String).toUpperCase(),
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (invoice['description'] as String),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                      ),
                    ),
                    Text(
                      '\$${(invoice['amount'] as double).toStringAsFixed(2)}',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasis,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: () => widget.onDownloadInvoice(invoice['id'] as String),
            icon: CustomIconWidget(
              iconName: 'download',
              color: AppTheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.secondary;
      case 'pending':
        return AppTheme.warning;
      case 'failed':
        return AppTheme.error;
      default:
        return AppTheme.textMediumEmphasis;
    }
  }
}
