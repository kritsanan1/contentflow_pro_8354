import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum CalendarView { month, week, list }

class ViewToggleWidget extends StatelessWidget {
  final CalendarView currentView;
  final Function(CalendarView) onViewChanged;

  const ViewToggleWidget({
    Key? key,
    required this.currentView,
    required this.onViewChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildViewButton(
            view: CalendarView.month,
            icon: 'calendar_month',
            label: 'Month',
          ),
          _buildViewButton(
            view: CalendarView.week,
            icon: 'view_week',
            label: 'Week',
          ),
          _buildViewButton(
            view: CalendarView.list,
            icon: 'list',
            label: 'List',
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required CalendarView view,
    required String icon,
    required String label,
  }) {
    final isSelected = currentView == view;

    return Expanded(
      child: GestureDetector(
        onTap: () => onViewChanged(view),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.darkTheme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.onPrimary
                    : AppTheme.textMediumEmphasis,
                size: 20,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppTheme.darkTheme.colorScheme.onPrimary
                      : AppTheme.textMediumEmphasis,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
