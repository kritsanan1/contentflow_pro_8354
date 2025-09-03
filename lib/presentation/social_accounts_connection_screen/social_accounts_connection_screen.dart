import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_progress_indicator.dart';
import './widgets/oauth_loading_dialog.dart';
import './widgets/platform_connection_card.dart';

class SocialAccountsConnectionScreen extends StatefulWidget {
  const SocialAccountsConnectionScreen({Key? key}) : super(key: key);

  @override
  State<SocialAccountsConnectionScreen> createState() =>
      _SocialAccountsConnectionScreenState();
}

class _SocialAccountsConnectionScreenState
    extends State<SocialAccountsConnectionScreen> {
  bool _isLoading = false;

  // Mock data for social media platforms
  final List<Map<String, dynamic>> _platforms = [
    {
      "id": "facebook",
      "name": "Facebook",
      "icon": "facebook",
      "brandColor": 0xFF1877F2,
      "isConnected": true,
      "status": "Connected",
      "accountInfo": {
        "username": "contentflow_business",
        "followers": "2.5K",
        "lastSync": "2 min ago",
      },
      "oauthUrl": "https://www.facebook.com/v18.0/dialog/oauth",
    },
    {
      "id": "instagram",
      "name": "Instagram",
      "icon": "camera_alt",
      "brandColor": 0xFFE4405F,
      "isConnected": true,
      "status": "Connected",
      "accountInfo": {
        "username": "contentflow.pro",
        "followers": "8.2K",
        "lastSync": "5 min ago",
      },
      "oauthUrl": "https://api.instagram.com/oauth/authorize",
    },
    {
      "id": "twitter",
      "name": "Twitter",
      "icon": "alternate_email",
      "brandColor": 0xFF1DA1F2,
      "isConnected": false,
      "status": "Disconnected",
      "accountInfo": null,
      "oauthUrl": "https://twitter.com/i/oauth2/authorize",
    },
    {
      "id": "linkedin",
      "name": "LinkedIn",
      "icon": "work",
      "brandColor": 0xFF0A66C2,
      "isConnected": true,
      "status": "Connected",
      "accountInfo": {
        "username": "contentflow-solutions",
        "followers": "1.2K",
        "lastSync": "1 hour ago",
      },
      "oauthUrl": "https://www.linkedin.com/oauth/v2/authorization",
    },
    {
      "id": "tiktok",
      "name": "TikTok",
      "icon": "music_note",
      "brandColor": 0xFF000000,
      "isConnected": false,
      "status": "Disconnected",
      "accountInfo": null,
      "oauthUrl": "https://www.tiktok.com/auth/authorize/",
    },
  ];

  int get _connectedCount =>
      _platforms.where((p) => p['isConnected'] as bool).length;
  int get _totalCount => _platforms.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshConnections,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Connection Progress
                    ConnectionProgressIndicator(
                      connectedCount: _connectedCount,
                      totalCount: _totalCount,
                    ),

                    SizedBox(height: 2.h),

                    // Section Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Social Media Platforms',
                            style: AppTheme.darkTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_connectedCount > 0)
                            PopupMenuButton<String>(
                              icon: CustomIconWidget(
                                iconName: 'more_vert',
                                color: AppTheme.textMediumEmphasis,
                                size: 5.w,
                              ),
                              onSelected: (value) {
                                if (value == 'disconnect_all') {
                                  _showBulkDisconnectDialog();
                                } else if (value == 'refresh') {
                                  _refreshConnections();
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'refresh',
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'refresh',
                                        color: AppTheme.textHighEmphasis,
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text('Refresh All'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'disconnect_all',
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'link_off',
                                        color: AppTheme.error,
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Disconnect All',
                                        style: TextStyle(color: AppTheme.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Platform Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _platforms.length,
                      itemBuilder: (context, index) {
                        final platform = _platforms[index];
                        return PlatformConnectionCard(
                          platform: platform,
                          onTap: () => _handlePlatformTap(platform),
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Help Section
                    _buildHelpSection(),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Connect Accounts'),
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textHighEmphasis,
          size: 6.w,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_connectedCount == _totalCount)
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/post-composer-screen'),
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.primary,
                size: 4.w,
              ),
              label: Text(
                'Create Post',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading connections...',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Need Help?',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Having trouble connecting your accounts? Check our troubleshooting guide or contact support for assistance.',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTroubleshootingDialog(),
                  icon: CustomIconWidget(
                    iconName: 'build',
                    color: AppTheme.primary,
                    size: 4.w,
                  ),
                  label: Text('Troubleshoot'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactSupport(),
                  icon: CustomIconWidget(
                    iconName: 'support_agent',
                    color: AppTheme.onPrimary,
                    size: 4.w,
                  ),
                  label: Text('Contact Support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlatformTap(Map<String, dynamic> platform) async {
    final bool isConnected = platform['isConnected'] as bool;

    if (!isConnected) {
      await _initiateOAuthFlow(platform);
    }
  }

  Future<void> _initiateOAuthFlow(Map<String, dynamic> platform) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OAuthLoadingDialog(
          platformName: platform['name'] as String,
          platformColor: Color(platform['brandColor'] as int),
          platformIcon: platform['icon'] as String,
        ),
      );

      // Simulate OAuth flow with real web authentication
      final String oauthUrl = platform['oauthUrl'] as String;
      final String callbackUrl = 'contentflow://oauth/callback';

      // Build OAuth URL with parameters
      final String fullUrl = '$oauthUrl?'
          'client_id=demo_client_id&'
          'redirect_uri=$callbackUrl&'
          'response_type=code&'
          'scope=read_insights,manage_pages,publish_pages';

      final result = await FlutterWebAuth.authenticate(
        url: fullUrl,
        callbackUrlScheme: 'contentflow',
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result.contains('code=')) {
        // OAuth successful - update platform status
        await _updatePlatformConnection(platform, true);

        // Show success feedback
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully connected to ${platform['name']}!'),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('OAuth cancelled or failed');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      _showErrorDialog(
        'Connection Failed',
        'Unable to connect to ${platform['name']}. Please try again or check your internet connection.',
      );
    }
  }

  Future<void> _updatePlatformConnection(
      Map<String, dynamic> platform, bool isConnected) async {
    setState(() {
      platform['isConnected'] = isConnected;
      platform['status'] = isConnected ? 'Connected' : 'Disconnected';

      if (isConnected) {
        // Add mock account info for newly connected platforms
        platform['accountInfo'] = {
          'username': '${platform['name'].toString().toLowerCase()}_user',
          'followers': '${(1000 + (platform['name'].toString().length * 100))}',
          'lastSync': 'Just now',
        };
      } else {
        platform['accountInfo'] = null;
      }
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _refreshConnections() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 2));

    // Update last sync times for connected platforms
    for (var platform in _platforms) {
      if (platform['isConnected'] as bool && platform['accountInfo'] != null) {
        (platform['accountInfo'] as Map<String, dynamic>)['lastSync'] =
            'Just now';
      }
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connections refreshed successfully'),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBulkDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect All Platforms?'),
        content: Text(
          'Are you sure you want to disconnect all connected social media platforms? This will remove access to post scheduling and management features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Disconnect all platforms
              for (var platform in _platforms) {
                if (platform['isConnected'] as bool) {
                  await _updatePlatformConnection(platform, false);
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All platforms disconnected'),
                  backgroundColor: AppTheme.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Disconnect All'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Troubleshooting Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTroubleshootingItem(
                'Connection Timeout',
                'Check your internet connection and try again.',
              ),
              _buildTroubleshootingItem(
                'Permission Denied',
                'Make sure you grant all required permissions during the OAuth process.',
              ),
              _buildTroubleshootingItem(
                'Account Already Connected',
                'The account might already be connected to another ContentFlow account.',
              ),
              _buildTroubleshootingItem(
                'Browser Issues',
                'Clear your browser cache or try using a different browser.',
              ),
            ],
          ),
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

  Widget _buildTroubleshootingItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening support chat...'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.error,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
