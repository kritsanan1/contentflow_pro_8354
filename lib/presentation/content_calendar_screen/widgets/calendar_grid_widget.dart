import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';

class CalendarGridWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onDayLongPressed;
  final PageController pageController;

  const CalendarGridWidget({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.scheduledPosts,
    required this.onDaySelected,
    required this.onDayLongPressed,
    required this.pageController,
  }) : super(key: key);

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      return isSameDay(postDate, day);
    }).toList();
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Color(0xFF1877F2);
      case 'instagram':
        return Color(0xFFE4405F);
      case 'twitter':
        return Color(0xFF1DA1F2);
      case 'linkedin':
        return Color(0xFF0A66C2);
      case 'tiktok':
        return Color(0xFF000000);
      default:
        return AppTheme.darkTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: _getPostsForDay,
        onDaySelected: onDaySelected,
        onDayLongPressed: (day, focusedDay) => onDayLongPressed(day),
        onPageChanged: (focusedDay) {},
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false,
        daysOfWeekVisible: true,
        pageJumpingEnabled: true,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ) ?? TextStyle(color: AppTheme.textMediumEmphasis),
          holidayTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.secondary,
          ) ?? TextStyle(color: AppTheme.darkTheme.colorScheme.secondary),
          defaultTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textHighEmphasis,
          ) ?? TextStyle(color: AppTheme.textHighEmphasis),
          selectedTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ) ?? TextStyle(color: AppTheme.darkTheme.colorScheme.onPrimary, fontWeight: FontWeight.w600),
          todayTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ) ?? TextStyle(color: AppTheme.darkTheme.colorScheme.onSecondary, fontWeight: FontWeight.w600),
          selectedDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: true,
          markersOffset: PositionedOffset(bottom: 1),
          markersAlignment: Alignment.bottomCenter,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
            fontWeight: FontWeight.w500,
          ) ?? TextStyle(color: AppTheme.textMediumEmphasis, fontWeight: FontWeight.w500),
          weekendStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
            fontWeight: FontWeight.w500,
          ) ?? TextStyle(color: AppTheme.textMediumEmphasis, fontWeight: FontWeight.w500),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  final post = event;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getPlatformColor(post['platform'] as String),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final posts = _getPostsForDay(day);
            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: posts.isNotEmpty
                    ? AppTheme.darkTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '${day.day}',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasis,
                      ),
                    ),
                  ),
                  if (posts.isEmpty)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.textDisabled.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.textDisabled,
                          size: 8,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}