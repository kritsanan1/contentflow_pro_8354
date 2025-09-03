import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/character_counter_widget.dart';
import './widgets/media_picker_widget.dart';
import './widgets/optimization_suggestions_widget.dart';
import './widgets/platform_selector_widget.dart';
import './widgets/scheduling_widget.dart';

class PostComposerScreen extends StatefulWidget {
  const PostComposerScreen({Key? key}) : super(key: key);

  @override
  State<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends State<PostComposerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<String> _selectedPlatforms = [];
  List<XFile> _selectedMedia = [];
  bool _isScheduled = false;
  DateTime? _scheduledDateTime;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  List<Map<String, dynamic>> _dismissedSuggestions = [];

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data for connected platforms
  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'facebook',
      'name': 'Facebook',
      'icon': 'facebook',
      'isConnected': true,
      'followers': '2.5K',
    },
    {
      'id': 'twitter',
      'name': 'Twitter',
      'icon': 'alternate_email',
      'isConnected': true,
      'followers': '1.8K',
    },
    {
      'id': 'instagram',
      'name': 'Instagram',
      'icon': 'camera_alt',
      'isConnected': true,
      'followers': '3.2K',
    },
    {
      'id': 'linkedin',
      'name': 'LinkedIn',
      'icon': 'business',
      'isConnected': false,
      'followers': '0',
    },
    {
      'id': 'tiktok',
      'name': 'TikTok',
      'icon': 'music_note',
      'isConnected': true,
      'followers': '892',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDraft();
    _contentController.addListener(_onContentChanged);
    _contentFocusNode.addListener(_onFocusChanged);
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = _contentController.text.isNotEmpty ||
          _selectedMedia.isNotEmpty ||
          _selectedPlatforms.isNotEmpty;
    });
    _saveDraft();
  }

  void _onFocusChanged() {
    if (_contentFocusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 2,
      leading: IconButton(
        onPressed: () => _onCancelPressed(),
        icon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.textHighEmphasis,
          size: 24,
        ),
      ),
      title: Text(
        'Create Post',
        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.textHighEmphasis,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isLoading)
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ),
          )
        else
          TextButton(
            onPressed: _canPost() ? _onPostPressed : null,
            child: Text(
              _isScheduled ? 'Schedule' : 'Post',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: _canPost() ? AppTheme.primary : AppTheme.textDisabled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentInput(),
            CharacterCounterWidget(
              text: _contentController.text,
              selectedPlatforms: _selectedPlatforms,
              platforms: _platforms,
            ),
            PlatformSelectorWidget(
              platforms: _platforms,
              selectedPlatforms: _selectedPlatforms,
              onPlatformToggle: _onPlatformToggle,
            ),
            MediaPickerWidget(
              selectedMedia: _selectedMedia,
              onMediaSelected: _onMediaSelected,
              onMediaRemove: _onMediaRemove,
              onMediaEdit: _onMediaEdit,
            ),
            SchedulingWidget(
              isScheduled: _isScheduled,
              scheduledDateTime: _scheduledDateTime,
              onScheduleToggle: _onScheduleToggle,
              onDateTimeSelected: _onDateTimeSelected,
            ),
            OptimizationSuggestionsWidget(
              selectedPlatforms: _selectedPlatforms,
              content: _contentController.text,
              dismissedSuggestions: _dismissedSuggestions,
              onSuggestionDismiss: _onSuggestionDismiss,
            ),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s on your mind?',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHighEmphasis,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(
              minHeight: 20.h,
              maxHeight: 40.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _contentFocusNode.hasFocus
                    ? AppTheme.primary
                    : AppTheme.dividerColor,
                width: _contentFocusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Share your thoughts, ideas, or updates...',
                hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(4.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: _canPost() ? _onPostPressed : null,
        backgroundColor: _canPost() ? AppTheme.primary : AppTheme.textDisabled,
        foregroundColor: AppTheme.onPrimary,
        icon: CustomIconWidget(
          iconName: _isScheduled ? 'schedule' : 'send',
          color: AppTheme.onPrimary,
          size: 20,
        ),
        label: Text(
          _isScheduled ? 'Schedule Post' : 'Publish Now',
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onPlatformToggle(String platformId) {
    setState(() {
      if (_selectedPlatforms.contains(platformId)) {
        _selectedPlatforms.remove(platformId);
      } else {
        _selectedPlatforms.add(platformId);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onMediaSelected(List<XFile> media) {
    setState(() {
      _selectedMedia = media;
    });
  }

  void _onMediaRemove(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _onMediaEdit(XFile media) {
    _showMediaEditBottomSheet(media);
  }

  void _onScheduleToggle(bool value) {
    setState(() {
      _isScheduled = value;
      if (value && _scheduledDateTime == null) {
        _scheduledDateTime = DateTime.now().add(Duration(hours: 1));
      }
    });
  }

  void _onDateTimeSelected(DateTime dateTime) {
    setState(() {
      _scheduledDateTime = dateTime;
    });
  }

  void _onSuggestionDismiss(String suggestionId) {
    setState(() {
      _dismissedSuggestions
          .add({'id': suggestionId, 'timestamp': DateTime.now()});
    });
  }

  bool _canPost() {
    return _contentController.text.trim().isNotEmpty &&
        _selectedPlatforms.isNotEmpty &&
        !_isLoading &&
        _isContentValid();
  }

  bool _isContentValid() {
    final content = _contentController.text;
    final platformLimits = {
      'twitter': 280,
      'facebook': 63206,
      'instagram': 2200,
      'linkedin': 3000,
      'tiktok': 2200,
    };

    for (final platformId in _selectedPlatforms) {
      final limit = platformLimits[platformId] ?? 280;
      if (content.length > limit) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onPostPressed() async {
    if (!_canPost()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Clear draft
      await _clearDraft();

      // Show success message
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Failed to publish post. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCancelPressed() async {
    if (_hasUnsavedChanges) {
      final shouldDiscard = await _showDiscardDialog();
      if (shouldDiscard == true) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldDiscard = await _showDiscardDialog();
      return shouldDiscard ?? false;
    }
    return true;
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Discard post?',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textHighEmphasis,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard this post?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Editing',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.secondary,
                size: 32,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _isScheduled ? 'Post Scheduled!' : 'Post Published!',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _isScheduled
                  ? 'Your post has been scheduled successfully.'
                  : 'Your post has been published to selected platforms.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (_isScheduled)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                    context, '/content-calendar-screen');
              },
              child: Text(
                'View Calendar',
                style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.primary,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Error',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaEditBottomSheet(XFile media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 60.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Edit Media',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: CustomImageWidget(
                imageUrl: media.path,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEditOption('Crop', 'crop', () {}),
                _buildEditOption('Filter', 'filter', () {}),
                _buildEditOption('Adjust', 'tune', () {}),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.primary,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'content': _contentController.text,
        'selectedPlatforms': _selectedPlatforms,
        'isScheduled': _isScheduled,
        'scheduledDateTime': _scheduledDateTime?.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('post_draft', jsonEncode(draft));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString('post_draft');
      if (draftString != null) {
        final draft = jsonDecode(draftString) as Map<String, dynamic>;
        setState(() {
          _contentController.text = draft['content'] ?? '';
          _selectedPlatforms =
              List<String>.from(draft['selectedPlatforms'] ?? []);
          _isScheduled = draft['isScheduled'] ?? false;
          if (draft['scheduledDateTime'] != null) {
            _scheduledDateTime = DateTime.parse(draft['scheduledDateTime']);
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('post_draft');
    } catch (e) {
      // Handle error silently
    }
  }
}
