import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/message_model.dart';
import '../../../services/message_service.dart';

class ComposeMessageDialog extends StatefulWidget {
  final String? recipientId;
  final String? recipientName;
  final String? subject;
  final String? originalContent;
  final Function(String recipientId, String subject, String content,
      PriorityLevel priority) onSend;

  const ComposeMessageDialog({
    Key? key,
    this.recipientId,
    this.recipientName,
    this.subject,
    this.originalContent,
    required this.onSend,
  }) : super(key: key);

  @override
  State<ComposeMessageDialog> createState() => _ComposeMessageDialogState();
}

class _ComposeMessageDialogState extends State<ComposeMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageService = MessageService.instance;

  // Controllers
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  final _recipientController = TextEditingController();

  // State
  String? _selectedRecipientId;
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  List<UserProfile> _availableUsers = [];
  bool _isLoadingUsers = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadUsers();
  }

  void _initializeFields() {
    if (widget.recipientId != null) {
      _selectedRecipientId = widget.recipientId;
      _recipientController.text = widget.recipientName ?? '';
    }

    if (widget.subject != null) {
      _subjectController.text = widget.subject!;
    }

    if (widget.originalContent != null) {
      _contentController.text =
          '\n\n---\nOriginal message:\n${widget.originalContent}';
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final users = await _messageService.getAvailableUsers();
      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;
      });
    } catch (error) {
      setState(() => _isLoadingUsers = false);
      _showSnackBar('Failed to load users: $error');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      await _loadUsers();
      return;
    }

    setState(() => _isLoadingUsers = true);

    try {
      final users = await _messageService.getAvailableUsers(searchQuery: query);
      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;
      });
    } catch (error) {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || _selectedRecipientId == null) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() => _isSending = true);

    try {
      await widget.onSend(
        _selectedRecipientId!,
        _subjectController.text.trim(),
        _contentController.text.trim(),
        _selectedPriority,
      );
    } catch (error) {
      setState(() => _isSending = false);
      _showSnackBar('Failed to send message: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(4.w),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 90.h,
          minHeight: 70.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.sp),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 6.w),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      widget.recipientId != null
                          ? 'Reply Message'
                          : 'Compose Message',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      // Recipient Field
                      if (widget.recipientId == null) ...[
                        _buildRecipientField(),
                        SizedBox(height: 2.h),
                      ],
                      // Subject Field
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subject),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Subject is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      // Priority Selector
                      _buildPrioritySelector(),
                      SizedBox(height: 2.h),
                      // Message Content
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            labelText: 'Message *',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Message content is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSending ? 'Sending...' : 'Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _recipientController,
          decoration: const InputDecoration(
            labelText: 'To *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
            hintText: 'Search for users...',
          ),
          onChanged: _searchUsers,
          readOnly: _selectedRecipientId != null,
          validator: (value) {
            if (_selectedRecipientId == null) {
              return 'Please select a recipient';
            }
            return null;
          },
        ),
        if (_recipientController.text.isNotEmpty &&
            _selectedRecipientId == null &&
            !_isLoadingUsers) ...[
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(maxHeight: 20.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: _availableUsers.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(2.w),
                    child: const Text('No users found'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableUsers.length,
                    itemBuilder: (context, index) {
                      final user = _availableUsers[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 4.w,
                          backgroundColor:
                              Theme.of(context).primaryColor.withAlpha(26),
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        onTap: () {
                          setState(() {
                            _selectedRecipientId = user.id;
                            _recipientController.text = user.fullName;
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
        if (_isLoadingUsers)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Row(
          children: PriorityLevel.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = priority),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getPriorityColor(priority).withAlpha(26)
                        : Colors.grey[100],
                    border: Border.all(
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: isSelected
                            ? _getPriorityColor(priority)
                            : Colors.grey[600],
                        size: 5.w,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getPriorityLabel(priority),
                        style: TextStyle(
                          color: isSelected
                              ? _getPriorityColor(priority)
                              : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 3.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.urgent:
        return Colors.red;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.urgent:
        return Icons.priority_high;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.medium:
        return Icons.remove;
      case PriorityLevel.low:
        return Icons.arrow_downward;
    }
  }

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.urgent:
        return 'Urgent';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.low:
        return 'Low';
    }
  }
}
