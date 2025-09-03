import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BulkActionDialog extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const BulkActionDialog({
    Key? key,
    required this.selectedCount,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: Theme.of(context).primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bulk Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$selectedCount comments selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Approve All
                ElevatedButton.icon(
                  onPressed: () => _showConfirmation(
                    context,
                    'Approve Comments',
                    'Are you sure you want to approve $selectedCount comments?',
                    onApprove,
                    Colors.green,
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
                SizedBox(height: 1.h),

                // Reject All
                ElevatedButton.icon(
                  onPressed: () => _showConfirmation(
                    context,
                    'Reject Comments',
                    'Are you sure you want to reject $selectedCount comments?',
                    onReject,
                    Colors.orange,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Reject All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
                SizedBox(height: 1.h),

                // Delete All
                ElevatedButton.icon(
                  onPressed: () => _showConfirmation(
                    context,
                    'Delete Comments',
                    'Are you sure you want to permanently delete $selectedCount comments? This action cannot be undone.',
                    onDelete,
                    Colors.red,
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog
              onConfirm(); // Execute action
            },
            style: TextButton.styleFrom(foregroundColor: color),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
