import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OptimizationSuggestionsWidget extends StatelessWidget {
  final List<String> selectedPlatforms;
  final String content;
  final List<Map<String, dynamic>> dismissedSuggestions;
  final Function(String) onSuggestionDismiss;

  const OptimizationSuggestionsWidget({
    Key? key,
    required this.selectedPlatforms,
    required this.content,
    required this.dismissedSuggestions,
    required this.onSuggestionDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestions = _generateSuggestions();
    final activeSuggestions = suggestions
        .where((suggestion) => !dismissedSuggestions
            .any((dismissed) => dismissed['id'] == suggestion['id']))
        .toList();

    if (activeSuggestions.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.secondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Optimization Tips',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...activeSuggestions
              .map((suggestion) => _buildSuggestionCard(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: suggestion['icon'],
                  color: AppTheme.secondary,
                  size: 16,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['title'],
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHighEmphasis,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      suggestion['description'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                      ),
                    ),
                    if (suggestion['platforms'] != null) ...[
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        children: (suggestion['platforms'] as List<String>)
                            .map((platform) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              platform,
                              style: AppTheme.darkTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => onSuggestionDismiss(suggestion['id']),
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textMediumEmphasis,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateSuggestions() {
    List<Map<String, dynamic>> suggestions = [];

    // Content length suggestions
    if (content.isNotEmpty && content.length < 50) {
      suggestions.add({
        'id': 'content_length',
        'icon': 'edit',
        'title': 'Add more content',
        'description':
            'Posts with 50+ characters typically get better engagement.',
        'platforms': selectedPlatforms,
      });
    }

    // Hashtag suggestions
    if (content.isNotEmpty && !content.contains('#')) {
      suggestions.add({
        'id': 'hashtags',
        'icon': 'tag',
        'title': 'Add hashtags',
        'description':
            'Include 3-5 relevant hashtags to increase discoverability.',
        'platforms': selectedPlatforms
            .where((p) => ['twitter', 'instagram', 'linkedin'].contains(p))
            .toList(),
      });
    }

    // Platform-specific suggestions
    if (selectedPlatforms.contains('twitter')) {
      if (content.length > 200) {
        suggestions.add({
          'id': 'twitter_thread',
          'icon': 'format_list_numbered',
          'title': 'Consider a Twitter thread',
          'description': 'Long content performs better as a thread on Twitter.',
          'platforms': ['Twitter'],
        });
      }
    }

    if (selectedPlatforms.contains('instagram')) {
      suggestions.add({
        'id': 'instagram_visual',
        'icon': 'photo_camera',
        'title': 'Add visual content',
        'description': 'Instagram posts with images get 2.3x more engagement.',
        'platforms': ['Instagram'],
      });
    }

    if (selectedPlatforms.contains('linkedin')) {
      if (!content.toLowerCase().contains('professional') &&
          !content.toLowerCase().contains('business') &&
          !content.toLowerCase().contains('career')) {
        suggestions.add({
          'id': 'linkedin_professional',
          'icon': 'business',
          'title': 'Add professional context',
          'description':
              'LinkedIn content performs better with professional insights.',
          'platforms': ['LinkedIn'],
        });
      }
    }

    // Timing suggestions
    final now = DateTime.now();
    if (now.hour < 9 || now.hour > 17) {
      suggestions.add({
        'id': 'optimal_timing',
        'icon': 'schedule',
        'title': 'Consider optimal timing',
        'description':
            'Posts between 9 AM - 5 PM typically get better engagement.',
        'platforms': selectedPlatforms,
      });
    }

    // Call-to-action suggestions
    if (content.isNotEmpty &&
        !content.toLowerCase().contains('?') &&
        !content.toLowerCase().contains('comment') &&
        !content.toLowerCase().contains('share') &&
        !content.toLowerCase().contains('like')) {
      suggestions.add({
        'id': 'call_to_action',
        'icon': 'question_answer',
        'title': 'Add a call-to-action',
        'description':
            'Ask a question or encourage engagement to boost interaction.',
        'platforms': selectedPlatforms,
      });
    }

    return suggestions;
  }
}
