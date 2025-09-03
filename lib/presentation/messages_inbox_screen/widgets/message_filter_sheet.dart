import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/message_model.dart';

class MessageFilterSheet extends StatefulWidget {
  final MessageStatus? currentStatus;
  final Function(MessageStatus?) onFilterApplied;

  const MessageFilterSheet({
    Key? key,
    this.currentStatus,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<MessageFilterSheet> createState() => _MessageFilterSheetState();
}

class _MessageFilterSheetState extends State<MessageFilterSheet> {
  MessageStatus? _selectedStatus;

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
                'Filter Messages',
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
            'Message Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          // All Status Option
          _buildStatusOption(null, 'All Messages', Icons.all_inbox),
          // Individual Status Options
          ...MessageStatus.values.map((status) => _buildStatusOption(
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
      MessageStatus? status, String label, IconData icon) {
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

  String _getStatusLabel(MessageStatus status) {
    switch (status) {
      case MessageStatus.unread:
        return 'Unread Messages';
      case MessageStatus.read:
        return 'Read Messages';
      case MessageStatus.archived:
        return 'Archived Messages';
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.unread:
        return Icons.mark_email_unread;
      case MessageStatus.read:
        return Icons.mark_email_read;
      case MessageStatus.archived:
        return Icons.archive;
    }
  }
}
