import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/comment_model.dart';

class CommentFilterSheet extends StatefulWidget {
  final CommentStatus? currentStatus;
  final Function(CommentStatus?) onFilterApplied;

  const CommentFilterSheet({
    Key? key,
    this.currentStatus,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<CommentFilterSheet> createState() => _CommentFilterSheetState();
}

class _CommentFilterSheetState extends State<CommentFilterSheet> {
  CommentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.sp),
            ),
          ),
          SizedBox(height: 2.h),
          // Title
          Row(
            children: [
              Icon(Icons.filter_list, size: 6.w),
              SizedBox(width: 2.w),
              Text(
                'Filter Comments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _selectedStatus = null);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Status Filter
          Text(
            'Comment Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          // All Status Option
          _buildStatusOption(null, 'All Comments', Icons.comment),
          // Individual Status Options
          ...CommentStatus.values.map((status) => _buildStatusOption(
                status,
                _getStatusLabel(status),
                _getStatusIcon(status),
              )),
          SizedBox(height: 3.h),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterApplied(_selectedStatus);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
      CommentStatus? status, String label, IconData icon) {
    final isSelected = _selectedStatus == status;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: InkWell(
        onTap: () => setState(() => _selectedStatus = status),
        borderRadius: BorderRadius.circular(10.sp),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withAlpha(26)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 5.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(CommentStatus status) {
    switch (status) {
      case CommentStatus.pending:
        return 'Pending Comments';
      case CommentStatus.approved:
        return 'Approved Comments';
      case CommentStatus.rejected:
        return 'Rejected Comments';
    }
  }

  IconData _getStatusIcon(CommentStatus status) {
    switch (status) {
      case CommentStatus.pending:
        return Icons.pending;
      case CommentStatus.approved:
        return Icons.check_circle;
      case CommentStatus.rejected:
        return Icons.cancel;
    }
  }
}
