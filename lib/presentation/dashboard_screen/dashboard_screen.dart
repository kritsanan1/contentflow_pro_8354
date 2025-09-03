import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/dashboard_service.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/activity_timeline_widget.dart';
import './widgets/analytics_card_widget.dart';
import './widgets/pending_comments_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_messages_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardService = DashboardService.instance;

  // State management
  DashboardAnalytics? _analytics;
  List<ActivityItem> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _dashboardService.getDashboardAnalytics(),
        _dashboardService.getActivityTimeline(),
      ]);

      setState(() {
        _analytics = results[0] as DashboardAnalytics;
        _activities = results[1] as List<ActivityItem>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? CustomErrorWidget(
                  errorDetails:
                      FlutterErrorDetails(exception: Exception(_error!)),
                )
              : RefreshIndicator(
                  onRefresh: _refreshDashboard,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Welcome Section
                        _buildWelcomeSection(),
                        SizedBox(height: 3.h),

                        // Quick Actions
                        QuickActionsWidget(),
                        SizedBox(height: 3.h),

                        // Analytics Cards
                        _buildAnalyticsSection(),
                        SizedBox(height: 3.h),

                        // Charts Section
                        _buildChartsSection(),
                        SizedBox(height: 3.h),

                        // Recent Activity
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  RecentMessagesWidget(
                                    messages: _analytics?.recentMessages ?? [],
                                    onViewAll: () => _navigateToMessages(),
                                  ),
                                  SizedBox(height: 2.h),
                                  PendingCommentsWidget(
                                    comments: _analytics?.recentComments ?? [],
                                    onViewAll: () => _navigateToComments(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: ActivityTimelineWidget(
                                activities: _activities,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Here is your content management overview',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          SizedBox(height: 2.h),
          if (_analytics?.userAnalytics != null)
            Text(
              'Last activity: ${_formatLastActivity(_analytics!.userAnalytics!.lastActivity)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    if (_analytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Messages',
                value: _analytics!.messageStats.totalReceived.toString(),
                subtitle: '${_analytics!.messageStats.unread} unread',
                icon: Icons.inbox,
                color: Colors.blue,
                trend: _analytics!.userAnalytics?.messagesReceived.toString(),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Comments',
                value: _analytics!.commentStats.total.toString(),
                subtitle: '${_analytics!.commentStats.pending} pending',
                icon: Icons.comment,
                color: Colors.orange,
                trend: _analytics!.userAnalytics?.commentsPosted.toString(),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: AnalyticsCardWidget(
                title: 'System Users',
                value: _analytics!.systemStats.totalUsers.toString(),
                subtitle: '${_analytics!.systemStats.activeUsers} active',
                icon: Icons.people,
                color: Colors.green,
                trend: null,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: AnalyticsCardWidget(
                title: 'Total Posts',
                value: _analytics!.systemStats.totalPosts.toString(),
                subtitle: 'Published content',
                icon: Icons.article,
                color: Colors.purple,
                trend: _analytics!.userAnalytics?.postsCreated.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    if (_analytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(child: _buildMessagesChart()),
            SizedBox(width: 2.w),
            Expanded(child: _buildCommentsChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesChart() {
    final stats = _analytics!.messageStats;
    final total = stats.totalReceived + stats.sent;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Messages Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 30.w,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats.totalReceived.toDouble(),
                    title: '${stats.totalReceived}',
                    color: Colors.blue,
                    radius: 15.w,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.sent.toDouble(),
                    title: '${stats.sent}',
                    color: Colors.green,
                    radius: 15.w,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 8.w,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Received', Colors.blue),
              _buildLegendItem('Sent', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsChart() {
    final stats = _analytics!.commentStats;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Comments Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 30.w,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats.approved.toDouble(),
                    title: '${stats.approved}',
                    color: Colors.green,
                    radius: 15.w,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.pending.toDouble(),
                    title: '${stats.pending}',
                    color: Colors.orange,
                    radius: 15.w,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.rejected.toDouble(),
                    title: '${stats.rejected}',
                    color: Colors.red,
                    radius: 15.w,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 8.w,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('Approved', Colors.green),
                  _buildLegendItem('Pending', Colors.orange),
                ],
              ),
              SizedBox(height: 1.h),
              _buildLegendItem('Rejected', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _navigateToMessages() {
    Navigator.pushNamed(context, '/messages-inbox');
  }

  void _navigateToComments() {
    Navigator.pushNamed(context, '/comments-management');
  }
}
