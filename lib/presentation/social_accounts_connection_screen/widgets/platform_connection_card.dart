import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformConnectionCard extends StatelessWidget {
  final Map<String, dynamic> platform;
  final VoidCallback onTap;

  const PlatformConnectionCard({
    Key? key,
    required this.platform,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isConnected = platform['isConnected'] as bool;
    final String status = platform['status'] as String;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              // Platform Logo
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Color(platform['brandColor'] as int),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: platform['icon'] as String,
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Platform Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          platform['name'] as String,
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        _buildStatusBadge(status),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    if (isConnected && platform['accountInfo'] != null) ...[
                      Text(
                        '@${(platform['accountInfo'] as Map<String, dynamic>)['username']}',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'people',
                            color: AppTheme.textMediumEmphasis,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${(platform['accountInfo'] as Map<String, dynamic>)['followers']} followers',
                            style: AppTheme.darkTheme.textTheme.bodySmall,
                          ),
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'sync',
                            color: AppTheme.textMediumEmphasis,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            (platform['accountInfo']
                                as Map<String, dynamic>)['lastSync'] as String,
                            style: AppTheme.darkTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ] else if (!isConnected) ...[
                      Text(
                        'Connect your ${platform['name']} account to start managing posts',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Button or Settings
              if (isConnected) ...[
                PopupMenuButton<String>(
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.textMediumEmphasis,
                    size: 5.w,
                  ),
                  onSelected: (value) {
                    if (value == 'manage') {
                      _showManageDialog(context);
                    } else if (value == 'disconnect') {
                      _showDisconnectDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'manage',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'tune',
                            color: AppTheme.textHighEmphasis,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text('Manage Account'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'disconnect',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'link_off',
                            color: AppTheme.error,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Disconnect',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text(
                    'Connect',
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData badgeIcon;

    switch (status.toLowerCase()) {
      case 'connected':
        badgeColor = AppTheme.secondary;
        badgeIcon = Icons.check_circle;
        break;
      case 'error':
        badgeColor = AppTheme.error;
        badgeIcon = Icons.error;
        break;
      default:
        badgeColor = AppTheme.textDisabled;
        badgeIcon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 3.w,
            color: badgeColor,
          ),
          SizedBox(width: 1.w),
          Text(
            status,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showManageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${platform['name']} Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.textMediumEmphasis,
                size: 5.w,
              ),
              title: Text('Notification Settings'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'sync',
                color: AppTheme.textMediumEmphasis,
                size: 5.w,
              ),
              title: Text('Auto Sync'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'security',
                color: AppTheme.textMediumEmphasis,
                size: 5.w,
              ),
              title: Text('Posting Permissions'),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textMediumEmphasis,
                size: 5.w,
              ),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect ${platform['name']}?'),
        content: Text(
          'Are you sure you want to disconnect your ${platform['name']} account? You will no longer be able to manage posts for this platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle disconnect logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
