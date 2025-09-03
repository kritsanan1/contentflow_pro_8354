import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MediaPickerWidget extends StatelessWidget {
  final List<XFile> selectedMedia;
  final Function(List<XFile>) onMediaSelected;
  final Function(int) onMediaRemove;
  final Function(XFile) onMediaEdit;

  const MediaPickerWidget({
    Key? key,
    required this.selectedMedia,
    required this.onMediaSelected,
    required this.onMediaRemove,
    required this.onMediaEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Media',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selectedMedia.length < 4)
                TextButton.icon(
                  onPressed: () => _showMediaPicker(context),
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Add Media',
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          selectedMedia.isEmpty ? _buildEmptyState() : _buildMediaGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'photo_library',
            color: AppTheme.textMediumEmphasis,
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            'Add photos or videos',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Tap to select from gallery or camera',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return SizedBox(
      height: 25.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selectedMedia.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final media = selectedMedia[index];
          return _buildMediaItem(media, index);
        },
      ),
    );
  }

  Widget _buildMediaItem(XFile media, int index) {
    return Container(
      width: 40.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.surface,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImageWidget(
              imageUrl: media.path,
              width: 40.w,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 1.h,
            right: 2.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onMediaEdit(media),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.textHighEmphasis,
                      size: 18,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => onMediaRemove(index),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (media.path.toLowerCase().contains('.mp4') ||
              media.path.toLowerCase().contains('.mov'))
            Positioned(
              bottom: 1.h,
              left: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'play_arrow',
                      color: AppTheme.textHighEmphasis,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Video',
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.textHighEmphasis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              'Add Media',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context,
                  'Camera',
                  'camera_alt',
                  () => _pickMedia(ImageSource.camera),
                ),
                _buildPickerOption(
                  context,
                  'Gallery',
                  'photo_library',
                  () => _pickMedia(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 35.w,
        padding: EdgeInsets.symmetric(vertical: 3.h),
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
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textHighEmphasis,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final List<XFile> newMedia = [...selectedMedia];
        for (final file in pickedFiles) {
          if (newMedia.length < 4) {
            newMedia.add(file);
          }
        }
        onMediaSelected(newMedia);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
