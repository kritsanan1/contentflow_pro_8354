import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'dart:html' as html;

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/billing_history_card.dart';
import './widgets/current_plan_card.dart';
import './widgets/payment_method_card.dart';
import './widgets/plan_comparison_card.dart';
import './widgets/usage_analytics_card.dart';
import 'widgets/billing_history_card.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/payment_method_card.dart';
import 'widgets/plan_comparison_card.dart';
import 'widgets/usage_analytics_card.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  bool _isLoading = false;

  // Mock current plan data
  final Map<String, dynamic> _currentPlan = {
    "id": "pro_plan",
    "name": "Pro Plan",
    "price": 29.0,
    "nextBilling": "March 15, 2025",
    "autoRenewal": true,
  };

  // Mock usage analytics data
  final List<Map<String, dynamic>> _usageData = [
    {
      "title": "Posts Scheduled",
      "used": 145,
      "limit": 500,
    },
    {
      "title": "Platforms Connected",
      "used": 4,
      "limit": 10,
    },
    {
      "title": "Team Members",
      "used": 2,
      "limit": 5,
    },
    {
      "title": "Analytics Reports",
      "used": 8,
      "limit": 25,
    },
  ];

  // Mock subscription plans data
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      "id": "free_plan",
      "name": "Free",
      "price": 0.0,
      "features": [
        "Up to 10 posts per month",
        "2 social platforms",
        "Basic analytics",
        "Email support"
      ],
    },
    {
      "id": "pro_plan",
      "name": "Pro",
      "price": 29.0,
      "features": [
        "Up to 500 posts per month",
        "10 social platforms",
        "Advanced analytics",
        "Priority support",
        "Team collaboration (5 members)",
        "Custom branding"
      ],
    },
    {
      "id": "enterprise_plan",
      "name": "Enterprise",
      "price": 99.0,
      "features": [
        "Unlimited posts",
        "All social platforms",
        "White-label solution",
        "24/7 phone support",
        "Unlimited team members",
        "API access",
        "Custom integrations"
      ],
    },
  ];

  // Mock payment methods data
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "id": "pm_1",
      "type": "Visa",
      "lastFour": "4242",
      "expiry": "12/26",
      "isDefault": true,
    },
    {
      "id": "pm_2",
      "type": "Mastercard",
      "lastFour": "5555",
      "expiry": "08/25",
      "isDefault": false,
    },
  ];

  // Mock billing history data
  final List<Map<String, dynamic>> _billingHistory = [
    {
      "id": "inv_001",
      "date": "February 15, 2025",
      "description": "Pro Plan - Monthly Subscription",
      "amount": 29.0,
      "status": "paid",
    },
    {
      "id": "inv_002",
      "date": "January 15, 2025",
      "description": "Pro Plan - Monthly Subscription",
      "amount": 29.0,
      "status": "paid",
    },
    {
      "id": "inv_003",
      "date": "December 15, 2024",
      "description": "Pro Plan - Monthly Subscription",
      "amount": 29.0,
      "status": "paid",
    },
    {
      "id": "inv_004",
      "date": "November 15, 2024",
      "description": "Pro Plan - Monthly Subscription",
      "amount": 29.0,
      "status": "failed",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      // Initialize Stripe with publishable key
      Stripe.publishableKey = "pk_test_51234567890abcdef"; // Mock key
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization error: \$e');
    }
  }

  Future<void> _handleUpgrade(String planId) async {
    final plan =
        _subscriptionPlans.firstWhere((p) => (p['id'] as String) == planId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogColor,
        title: Text(
          'Upgrade Subscription',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasis,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are upgrading to ${plan['name']} Plan',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New monthly charge:',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                      Text(
                        '\$${(plan['price'] as double).toStringAsFixed(2)}',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textHighEmphasis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prorated amount:',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
                      ),
                      Text(
                        '\$${((plan['price'] as double) * 0.7).toStringAsFixed(2)}',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processUpgrade(planId);
            },
            child: Text('Confirm Upgrade'),
          ),
        ],
      ),
    );
  }

  Future<void> _processUpgrade(String planId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(Duration(seconds: 2));

      // Show success message
      Fluttertoast.showToast(
        msg: "Subscription upgraded successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.secondary,
        textColor: AppTheme.onSecondary,
      );

      // Provide haptic feedback
      if (!kIsWeb) {
        // HapticFeedback.lightImpact(); // Would be available with haptic feedback package
      }
    } catch (e) {
      _showErrorDialog('Upgrade Failed',
          'Unable to process upgrade. Please try again or contact support.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPaymentMethod() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (kIsWeb) {
        // Web implementation - show form dialog
        _showAddPaymentMethodDialog();
      } else {
        // Mobile implementation with Stripe payment sheet
        await _showStripePaymentSheet();
      }
    } catch (e) {
      _showErrorDialog('Payment Method Error',
          'Unable to add payment method. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showStripePaymentSheet() async {
    try {
      // Create payment intent (mock)
      final paymentIntentData = {
        'client_secret': 'pi_test_1234567890_secret_test',
        'amount': 0, // \$0 for setup
        'currency': 'usd',
      };

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              paymentIntentData['client_secret'] as String,
          merchantDisplayName: 'ContentFlow Pro',
          style: ThemeMode.dark,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(
        msg: "Payment method added successfully!",
        backgroundColor: AppTheme.secondary,
        textColor: AppTheme.onSecondary,
      );
    } on StripeException catch (e) {
      _showErrorDialog(
          'Payment Error', e.error.localizedMessage ?? 'Payment failed');
    }
  }

  void _showAddPaymentMethodDialog() {
    final _formKey = GlobalKey<FormState>();
    final _cardNumberController = TextEditingController();
    final _expiryController = TextEditingController();
    final _cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogColor,
        title: Text(
          'Add Payment Method',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasis,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.replaceAll(' ', '').length != 16) {
                    return 'Please enter valid card number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/26',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Payment method added successfully!",
                  backgroundColor: AppTheme.secondary,
                  textColor: AppTheme.onSecondary,
                );
              }
            },
            child: Text('Add Method'),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogColor,
        title: Text(
          'Delete Payment Method',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasis,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this payment method?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Payment method deleted",
                backgroundColor: AppTheme.warning,
                textColor: AppTheme.onPrimary,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(String invoiceId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Simulate download process
      await Future.delayed(Duration(seconds: 1));

      // Generate mock invoice content
      final invoice = _billingHistory
          .firstWhere((inv) => (inv['id'] as String) == invoiceId);
      final invoiceContent = """
CONTENTFLOW PRO INVOICE

Invoice ID: ${invoice['id']}
Date: ${invoice['date']}
Description: ${invoice['description']}
Amount: \$${(invoice['amount'] as double).toStringAsFixed(2)}
Status: ${(invoice['status'] as String).toUpperCase()}

Thank you for your business!
""";

      if (kIsWeb) {
        // Web download implementation
        final bytes = invoiceContent.codeUnits;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "invoice_${invoice['id']}.txt")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile download implementation would use path_provider
        // For demo purposes, just show success message
        Fluttertoast.showToast(
          msg: "Invoice downloaded to Documents folder",
          backgroundColor: AppTheme.secondary,
          textColor: AppTheme.onSecondary,
        );
      }
    } catch (e) {
      _showErrorDialog(
          'Download Error', 'Unable to download invoice. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogColor,
        title: Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.error,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textHighEmphasis,
            size: 24,
          ),
        ),
        title: Text(
          'Subscription Management',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasis,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.secondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Secure',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Processing...',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMediumEmphasis,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 1.h),

                  // Current Plan Section
                  CurrentPlanCard(currentPlan: _currentPlan),

                  // Usage Analytics Section
                  UsageAnalyticsCard(usageData: _usageData),

                  // Plan Comparison Section
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Available Plans',
                            style: AppTheme.darkTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.textHighEmphasis,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(
                          height: 35.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            itemCount: _subscriptionPlans.length,
                            itemBuilder: (context, index) {
                              final plan = _subscriptionPlans[index];
                              final isCurrentPlan = (plan['id'] as String) ==
                                  (_currentPlan['id'] as String);

                              return PlanComparisonCard(
                                plan: plan,
                                isCurrentPlan: isCurrentPlan,
                                onUpgrade: isCurrentPlan
                                    ? null
                                    : () =>
                                        _handleUpgrade(plan['id'] as String),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment Methods Section
                  PaymentMethodCard(
                    paymentMethods: _paymentMethods,
                    onAddNew: _addPaymentMethod,
                    onDeleteMethod: _deletePaymentMethod,
                  ),

                  // Billing History Section
                  BillingHistoryCard(
                    billingHistory: _billingHistory,
                    onDownloadInvoice: _downloadInvoice,
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}