import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showRetryOption = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization tasks
      await Future.wait([
        _checkAuthenticationStatus(),
        _loadConnectedAccounts(),
        _fetchEssentialConfiguration(),
        _prepareCachedData(),
      ]);

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    // Simulate authentication check
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _loadConnectedAccounts() async {
    // Simulate loading connected social accounts
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _fetchEssentialConfiguration() async {
    // Simulate fetching app configuration
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _prepareCachedData() async {
    // Simulate preparing cached analytics data
    await Future.delayed(const Duration(milliseconds: 700));
  }

  void _navigateToNextScreen() {
    // Navigation logic based on user state
    final isAuthenticated = _mockAuthenticationCheck();
    final hasConnectedAccounts = _mockConnectedAccountsCheck();

    String nextRoute;
    if (isAuthenticated && hasConnectedAccounts) {
      // Authenticated users with connected accounts go to dashboard
      nextRoute = '/dashboard-screen';
    } else if (isAuthenticated && !hasConnectedAccounts) {
      // Authenticated users without accounts go to social connection
      nextRoute = '/social-accounts-connection-screen';
    } else {
      // Non-authenticated users go to login
      nextRoute = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  bool _mockAuthenticationCheck() {
    // Mock authentication status - in real app, check stored tokens
    return false; // Default to not authenticated for demo
  }

  bool _mockConnectedAccountsCheck() {
    // Mock connected accounts check - in real app, check stored connections
    return false; // Default to no connected accounts for demo
  }

  void _handleInitializationError() {
    setState(() {
      _showRetryOption = true;
    });

    // Auto-hide retry option after 5 seconds and navigate to login
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showRetryOption) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    });
  }

  void _retryInitialization() {
    setState(() {
      _showRetryOption = false;
    });
    _animationController.reset();
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  AppTheme.background.withValues(alpha: 0.9),
                  AppTheme.surface.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo Section
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildLogo(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),

                      // App Name
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'ContentFlow Pro',
                              style: AppTheme.darkTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                color: AppTheme.textHighEmphasis,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 1.h),

                      // Tagline
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Social Media Management Made Simple',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textMediumEmphasis,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Loading Indicator Section
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Column(
                    children: [
                      _showRetryOption
                          ? _buildRetrySection()
                          : _buildLoadingIndicator(),

                      SizedBox(height: 3.h),

                      // Version Info
                      Text(
                        'Version 1.0.0',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDisabled,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
            AppTheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'dashboard',
          color: AppTheme.onPrimary,
          size: 12.w,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            backgroundColor: AppTheme.dividerColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Initializing your social media hub...',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRetrySection() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.warning,
          size: 8.w,
        ),
        SizedBox(height: 2.h),
        Text(
          'Connection timeout',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.warning,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Please check your internet connection',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Retry',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
