import 'package:flutter/material.dart';
import '../presentation/subscription_management_screen/subscription_management_screen.dart';
import '../presentation/post_composer_screen/post_composer_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/social_accounts_connection_screen/social_accounts_connection_screen.dart';
import '../presentation/content_calendar_screen/content_calendar_screen.dart';
import '../presentation/messages_inbox_screen/messages_inbox_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/comments_management_screen/comments_management_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String subscriptionManagement =
      '/subscription-management-screen';
  static const String postComposer = '/post-composer-screen';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String socialAccountsConnection =
      '/social-accounts-connection-screen';
  static const String contentCalendar = '/content-calendar-screen';
  static const String messagesInbox = '/messages-inbox';
  static const String dashboard = '/dashboard';
  static const String commentsManagement = '/comments-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    subscriptionManagement: (context) => const SubscriptionManagementScreen(),
    postComposer: (context) => const PostComposerScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    socialAccountsConnection: (context) =>
        const SocialAccountsConnectionScreen(),
    contentCalendar: (context) => const ContentCalendarScreen(),
    messagesInbox: (context) => const MessagesInboxScreen(),
    dashboard: (context) => const DashboardScreen(),
    commentsManagement: (context) => const CommentsManagementScreen(),
    // TODO: Add your other routes here
  };
}
