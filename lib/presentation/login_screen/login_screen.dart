import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/app_logo_widget.dart';
import './widgets/custom_text_field.dart';
import './widgets/loading_button.dart';
import './widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  String? _emailError;
  String? _passwordError;

  // Mock credentials for different user types
  final List<Map<String, dynamic>> _mockCredentials = [
    {
      "userType": "Business Owner",
      "email": "business@contentflow.com",
      "password": "Business123!",
    },
    {
      "userType": "Social Media Manager",
      "email": "manager@contentflow.com",
      "password": "Manager123!",
    },
    {
      "userType": "Content Creator",
      "email": "creator@contentflow.com",
      "password": "Creator123!",
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void _validateForm() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _showEmailError = _emailError != null;
      _showPasswordError = _passwordError != null;
    });
  }

  bool get _isFormValid {
    return _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    _validateForm();

    if (!_isFormValid) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _showEmailError = false;
      _showPasswordError = false;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      final isValidCredentials = _mockCredentials.any((cred) =>
          cred["email"] == _emailController.text &&
          cred["password"] == _passwordController.text);

      if (isValidCredentials) {
        // Success - navigate to dashboard
        HapticFeedback.mediumImpact();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard-screen');
        }
      } else {
        // Invalid credentials
        HapticFeedback.heavyImpact();
        setState(() {
          _showEmailError = true;
          _showPasswordError = true;
          _emailError = 'Invalid email or password';
          _passwordError = 'Please check your credentials';
        });
      }
    } catch (e) {
      // Handle network or other errors
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: AppTheme.darkTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    HapticFeedback.lightImpact();

    // Simulate OAuth flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login will be available soon'),
        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Reset Password',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Password reset functionality will be available soon. Please contact support for assistance.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.darkTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/signup-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),

                      // App Logo
                      const AppLogoWidget(),

                      SizedBox(height: 2.h),

                      // App Name
                      Text(
                        'ContentFlow Pro',
                        style: AppTheme.darkTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // Subtitle
                      Text(
                        'Manage your social media like a pro',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 6.h),

                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        iconName: 'email',
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: _validateEmail,
                        showError: _showEmailError,
                        errorText: _emailError,
                      ),

                      SizedBox(height: 3.h),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        iconName: 'lock',
                        isPassword: true,
                        controller: _passwordController,
                        validator: _validatePassword,
                        showError: _showPasswordError,
                        errorText: _passwordError,
                      ),

                      SizedBox(height: 2.h),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.darkTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Login Button
                      LoadingButton(
                        text: 'Login',
                        onPressed: _isFormValid ? _handleLogin : null,
                        isLoading: _isLoading,
                        isEnabled: _isFormValid,
                      ),

                      SizedBox(height: 4.h),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.darkTheme.colorScheme.outline,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'Or continue with',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .darkTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.darkTheme.colorScheme.outline,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Social Login Buttons
                      SocialLoginButton(
                        iconName: 'g_translate',
                        label: 'Continue with Google',
                        onTap: () => _handleSocialLogin('Google'),
                      ),

                      SocialLoginButton(
                        iconName: 'facebook',
                        label: 'Continue with Facebook',
                        onTap: () => _handleSocialLogin('Facebook'),
                      ),

                      SocialLoginButton(
                        iconName: 'alternate_email',
                        label: 'Continue with Apple',
                        onTap: () => _handleSocialLogin('Apple'),
                      ),

                      SizedBox(height: 4.h),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New user? ',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .darkTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _handleSignUp,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign Up',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.darkTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
