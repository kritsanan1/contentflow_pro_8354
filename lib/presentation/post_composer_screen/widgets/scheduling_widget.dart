import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SchedulingWidget extends StatelessWidget {
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final Function(bool) onScheduleToggle;
  final Function(DateTime) onDateTimeSelected;

  const SchedulingWidget({
    Key? key,
    required this.isScheduled,
    this.scheduledDateTime,
    required this.onScheduleToggle,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule Post',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isScheduled,
                onChanged: onScheduleToggle,
                activeColor: AppTheme.primary,
                inactiveThumbColor: AppTheme.textMediumEmphasis,
                inactiveTrackColor: AppTheme.dividerColor,
              ),
            ],
          ),
          if (isScheduled) ...[
            SizedBox(height: 2.h),
            _buildSchedulingOptions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulingOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Text(
                'Scheduled for:',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () => _showDateTimePicker(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduledDateTime != null
                            ? _formatDate(scheduledDateTime!)
                            : 'Select Date',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textHighEmphasis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        scheduledDateTime != null
                            ? _formatTime(scheduledDateTime!)
                            : 'Select Time',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildQuickScheduleOptions(context),
          if (scheduledDateTime != null) ...[
            SizedBox(height: 2.h),
            _buildTimezoneInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickScheduleOptions(BuildContext context) {
    final now = DateTime.now();
    final quickOptions = [
      {'label': 'In 1 hour', 'dateTime': now.add(Duration(hours: 1))},
      {
        'label': 'Tomorrow 9 AM',
        'dateTime': DateTime(now.year, now.month, now.day + 1, 9)
      },
      {'label': 'Next week', 'dateTime': now.add(Duration(days: 7))},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Schedule:',
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: quickOptions.map((option) {
            return GestureDetector(
              onTap: () => onDateTimeSelected(option['dateTime'] as DateTime),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  option['label'] as String,
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimezoneInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.secondary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Post will be published in your local timezone',
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: scheduledDateTime ?? DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppTheme.primary,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            scheduledDateTime ?? DateTime.now().add(Duration(hours: 1)),
          ),
          builder: (context, child) {
            return Theme(
              data: AppTheme.darkTheme.copyWith(
                colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
                  primary: AppTheme.primary,
                  surface: AppTheme.surface,
                ),
              ),
              child: child!,
            );
          },
        ).then((time) {
          if (time != null) {
            final dateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            onDateTimeSelected(dateTime);
          }
        });
      }
    });
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
