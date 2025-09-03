import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import './widgets/calendar_grid_widget.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/calendar_list_view_widget.dart';
import './widgets/day_posts_bottom_sheet_widget.dart';
import './widgets/view_toggle_widget.dart';

class ContentCalendarScreen extends StatefulWidget {
  const ContentCalendarScreen({Key? key}) : super(key: key);

  @override
  State<ContentCalendarScreen> createState() => _ContentCalendarScreenState();
}

class _ContentCalendarScreenState extends State<ContentCalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarView _currentView = CalendarView.month;
  bool _isLoading = false;
  final PageController _pageController = PageController();
  late AnimationController _refreshController;

  // Mock data for scheduled posts
  final List<Map<String, dynamic>> _scheduledPosts = [
    {
      "id": 1,
      "platform": "Facebook",
      "content":
          "Exciting news! Our new product launch is just around the corner. Stay tuned for amazing updates and exclusive offers! 🚀",
      "scheduledDate": DateTime.now().add(Duration(days: 1, hours: 10)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 245, "comments": 32, "shares": 18}
    },
    {
      "id": 2,
      "platform": "Instagram",
      "content":
          "Behind the scenes of our creative process. Swipe to see the magic happen! ✨ #BehindTheScenes #Creative",
      "scheduledDate":
          DateTime.now().add(Duration(days: 2, hours: 14, minutes: 30)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 892, "comments": 67, "shares": 45}
    },
    {
      "id": 3,
      "platform": "Twitter",
      "content":
          "Quick tip Tuesday: Did you know that consistent posting can increase your engagement by up to 70%? 📈 #SocialMediaTips",
      "scheduledDate":
          DateTime.now().add(Duration(days: 3, hours: 9, minutes: 15)),
      "status": "scheduled",
      "hasMedia": false,
      "metrics": {"likes": 156, "comments": 23, "shares": 34}
    },
    {
      "id": 4,
      "platform": "LinkedIn",
      "content":
          "Thrilled to announce our partnership with industry leaders. This collaboration will bring innovative solutions to our clients. Looking forward to what we can achieve together!",
      "scheduledDate": DateTime.now().add(Duration(days: 5, hours: 16)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 423, "comments": 89, "shares": 67}
    },
    {
      "id": 5,
      "platform": "TikTok",
      "content":
          "POV: When you finally master that trending dance 💃 #TrendingDance #POV #Viral",
      "scheduledDate":
          DateTime.now().add(Duration(days: 7, hours: 19, minutes: 45)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 1234, "comments": 156, "shares": 89}
    },
    {
      "id": 6,
      "platform": "Instagram",
      "content":
          "Sunset vibes from our office rooftop. Sometimes the best inspiration comes from taking a moment to appreciate the beauty around us 🌅",
      "scheduledDate": DateTime.now().add(Duration(days: 8, hours: 18)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 567, "comments": 43, "shares": 21}
    },
    {
      "id": 7,
      "platform": "Facebook",
      "content":
          "Customer spotlight! Meet Sarah, who transformed her business using our platform. Her success story is truly inspiring and shows what's possible with dedication.",
      "scheduledDate":
          DateTime.now().add(Duration(days: 10, hours: 11, minutes: 30)),
      "status": "scheduled",
      "hasMedia": true,
      "metrics": {"likes": 678, "comments": 94, "shares": 52}
    },
    {
      "id": 8,
      "platform": "Twitter",
      "content":
          "Monday motivation: 'Success is not final, failure is not fatal: it is the courage to continue that counts.' - Winston Churchill 💪",
      "scheduledDate": DateTime.now().add(Duration(days: 14, hours: 8)),
      "status": "scheduled",
      "hasMedia": false,
      "metrics": {"likes": 289, "comments": 45, "shares": 67}
    }
  ];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshCalendar() async {
    setState(() => _isLoading = true);
    _refreshController.forward();

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() => _isLoading = false);
    _refreshController.reset();

    // Show success feedback
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendar updated successfully'),
        backgroundColor: AppTheme.darkTheme.colorScheme.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      HapticFeedback.selectionClick();

      // Show posts for selected day
      final postsForDay = _getPostsForDay(selectedDay);
      if (postsForDay.isNotEmpty) {
        _showDayPostsBottomSheet(selectedDay, postsForDay);
      }
    }
  }

  void _onDayLongPressed(DateTime day) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedDay = day;
      _focusedDay = day;
    });

    final postsForDay = _getPostsForDay(day);
    _showDayPostsBottomSheet(day, postsForDay);
  }

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return _scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      return isSameDay(postDate, day);
    }).toList();
  }

  void _showDayPostsBottomSheet(
      DateTime date, List<Map<String, dynamic>> posts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayPostsBottomSheetWidget(
        selectedDate: date,
        posts: posts,
        onPostTap: _handlePostTap,
        onPostEdit: _handlePostEdit,
        onPostDelete: _handlePostDelete,
      ),
    );
  }

  void _handlePostTap(Map<String, dynamic> post) {
    Navigator.pop(context);
    // Navigate to post details or edit screen
    Navigator.pushNamed(context, '/post-composer-screen');
  }

  void _handlePostEdit(Map<String, dynamic> post) {
    // Navigate to edit screen with post data
    Navigator.pushNamed(context, '/post-composer-screen');
  }

  void _handlePostDelete(Map<String, dynamic> post) {
    setState(() {
      _scheduledPosts.removeWhere((p) => p['id'] == post['id']);
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post deleted successfully'),
        backgroundColor: AppTheme.darkTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.darkTheme.colorScheme.onError,
          onPressed: () {
            setState(() {
              _scheduledPosts.add(post);
            });
          },
        ),
      ),
    );
  }

  void _navigateToToday() {
    final today = DateTime.now();
    setState(() {
      _focusedDay = today;
      _selectedDay = today;
    });

    HapticFeedback.lightImpact();
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
    HapticFeedback.selectionClick();
  }

  void _navigateToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
    HapticFeedback.selectionClick();
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _currentView = view;
    });
    HapticFeedback.selectionClick();
  }

  Widget _buildCalendarContent() {
    switch (_currentView) {
      case CalendarView.month:
        return CalendarGridWidget(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          scheduledPosts: _scheduledPosts,
          onDaySelected: _onDaySelected,
          onDayLongPressed: _onDayLongPressed,
          pageController: _pageController,
        );
      case CalendarView.week:
        // For now, show month view - week view would need additional implementation
        return CalendarGridWidget(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          scheduledPosts: _scheduledPosts,
          onDaySelected: _onDaySelected,
          onDayLongPressed: _onDayLongPressed,
          pageController: _pageController,
        );
      case CalendarView.list:
        return CalendarListViewWidget(
          scheduledPosts: _scheduledPosts,
          onPostTap: _handlePostTap,
          onPostEdit: _handlePostEdit,
          onPostDelete: _handlePostDelete,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.darkTheme.appBarTheme.elevation,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'menu',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_month',
              color: AppTheme.darkTheme.colorScheme.primary,
              size: 28,
            ),
            SizedBox(width: 2.w),
            Text(
              'Content Calendar',
              style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: _refreshCalendar,
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedBuilder(
                animation: _refreshController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _refreshController.value * 2 * 3.14159,
                    child: CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.darkTheme.colorScheme.secondary,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIconWidget(
                    iconName: 'dashboard',
                    color: AppTheme.darkTheme.colorScheme.onPrimary,
                    size: 40,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'ContentFlow Pro',
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Social Media Management',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onPrimary
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem('dashboard', 'Dashboard', '/splash-screen'),
                  _buildDrawerItem(
                      'edit', 'Post Composer', '/post-composer-screen'),
                  _buildDrawerItem('calendar_month', 'Content Calendar',
                      '/content-calendar-screen',
                      isSelected: true),
                  _buildDrawerItem('link', 'Social Accounts',
                      '/social-accounts-connection-screen'),
                  _buildDrawerItem('payment', 'Subscription',
                      '/subscription-management-screen'),
                  Divider(color: AppTheme.dividerColor),
                  _buildDrawerItem('logout', 'Logout', '/login-screen'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCalendar,
        color: AppTheme.darkTheme.colorScheme.primary,
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        child: Column(
          children: [
            // Calendar header with month navigation
            if (_currentView != CalendarView.list)
              CalendarHeaderWidget(
                currentDate: _focusedDay,
                onPreviousMonth: _navigateToPreviousMonth,
                onNextMonth: _navigateToNextMonth,
                onTodayTap: _navigateToToday,
              ),

            SizedBox(height: 2.h),

            // View toggle buttons
            ViewToggleWidget(
              currentView: _currentView,
              onViewChanged: _onViewChanged,
            ),

            // Calendar content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.darkTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Syncing calendar...',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildCalendarContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/post-composer-screen');
        },
        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.darkTheme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String iconName, String title, String route,
      {bool isSelected = false}) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isSelected
            ? AppTheme.darkTheme.colorScheme.primary
            : AppTheme.textMediumEmphasis,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary
              : AppTheme.textHighEmphasis,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      selectedTileColor:
          AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
