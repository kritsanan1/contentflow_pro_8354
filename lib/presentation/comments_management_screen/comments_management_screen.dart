import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/bulk_action_dialog.dart';
import './widgets/comment_filter_sheet.dart';
import './widgets/comment_tile_widget.dart';

class CommentsManagementScreen extends StatefulWidget {
  const CommentsManagementScreen({Key? key}) : super(key: key);

  @override
  State<CommentsManagementScreen> createState() =>
      _CommentsManagementScreenState();
}

class _CommentsManagementScreenState extends State<CommentsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentService = CommentService.instance;

  // State management
  List<Comment> _allComments = [];
  List<Comment> _pendingComments = [];
  List<Comment> _approvedComments = [];
  List<Comment> _rejectedComments = [];
  Map<String, int> _commentStats = {};
  bool _isLoading = true;
  String? _error;

  // Selection and bulk actions
  final Set<String> _selectedComments = {};
  bool _isSelectionMode = false;

  // Filters
  CommentStatus? _selectedStatus;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _commentService.getComments(),
        _commentService.getComments(status: CommentStatus.pending),
        _commentService.getComments(status: CommentStatus.approved),
        _commentService.getComments(status: CommentStatus.rejected),
        _commentService.getCommentStats(),
      ]);

      setState(() {
        _allComments = results[0] as List<Comment>;
        _pendingComments = results[1] as List<Comment>;
        _approvedComments = results[2] as List<Comment>;
        _rejectedComments = results[3] as List<Comment>;
        _commentStats = results[4] as Map<String, int>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshComments() async {
    await _loadInitialData();
    _clearSelection();
  }

  void _clearSelection() {
    setState(() {
      _selectedComments.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelection(String commentId) {
    setState(() {
      if (_selectedComments.contains(commentId)) {
        _selectedComments.remove(commentId);
        if (_selectedComments.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedComments.add(commentId);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll(List<Comment> comments) {
    setState(() {
      for (final comment in comments) {
        _selectedComments.add(comment.id);
      }
      _isSelectionMode = _selectedComments.isNotEmpty;
    });
  }

  Future<void> _approveComment(String commentId) async {
    try {
      await _commentService.approveComment(commentId);
      _showSnackBar('Comment approved successfully');
      await _refreshComments();
    } catch (error) {
      _showSnackBar('Failed to approve comment: $error');
    }
  }

  Future<void> _rejectComment(String commentId) async {
    try {
      await _commentService.rejectComment(commentId);
      _showSnackBar('Comment rejected successfully');
      await _refreshComments();
    } catch (error) {
      _showSnackBar('Failed to reject comment: $error');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      _showSnackBar('Comment deleted successfully');
      await _refreshComments();
    } catch (error) {
      _showSnackBar('Failed to delete comment: $error');
    }
  }

  void _showBulkActionDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkActionDialog(
        selectedCount: _selectedComments.length,
        onApprove: () async {
          try {
            await _commentService.bulkUpdateComments(
              commentIds: _selectedComments.toList(),
              status: CommentStatus.approved,
            );
            Navigator.pop(context);
            _showSnackBar('${_selectedComments.length} comments approved');
            await _refreshComments();
          } catch (error) {
            _showSnackBar('Failed to approve comments: $error');
          }
        },
        onReject: () async {
          try {
            await _commentService.bulkUpdateComments(
              commentIds: _selectedComments.toList(),
              status: CommentStatus.rejected,
            );
            Navigator.pop(context);
            _showSnackBar('${_selectedComments.length} comments rejected');
            await _refreshComments();
          } catch (error) {
            _showSnackBar('Failed to reject comments: $error');
          }
        },
        onDelete: () async {
          try {
            for (final commentId in _selectedComments) {
              await _commentService.deleteComment(commentId);
            }
            Navigator.pop(context);
            _showSnackBar('${_selectedComments.length} comments deleted');
            await _refreshComments();
          } catch (error) {
            _showSnackBar('Failed to delete comments: $error');
          }
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (context) => CommentFilterSheet(
        currentStatus: _selectedStatus,
        onFilterApplied: (status) {
          setState(() {
            _selectedStatus = status;
          });
          _performSearch();
        },
      ),
    );
  }

  void _performSearch() async {
    if (_searchQuery.isEmpty && _selectedStatus == null) {
      await _refreshComments();
      return;
    }

    try {
      setState(() => _isLoading = true);

      final searchResults = await _commentService.searchComments(
        query: _searchQuery,
        status: _selectedStatus,
      );

      setState(() {
        _allComments = searchResults;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedComments.length} selected'
            : 'Comments'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _showBulkActionDialog,
              icon: const Icon(Icons.more_vert),
            ),
          ] else ...[
            IconButton(
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.filter_list),
            ),
            IconButton(
              onPressed: _refreshComments,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSelectionMode ? 8.h : 16.h),
          child: Column(
            children: [
              if (!_isSelectionMode) ...[
                // Stats Row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Pending',
                        _commentStats['pending']?.toString() ?? '0',
                        Icons.pending,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        'Approved',
                        _commentStats['approved']?.toString() ?? '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        'Rejected',
                        _commentStats['rejected']?.toString() ?? '0',
                        Icons.cancel,
                        Colors.red,
                      ),
                      _buildStatItem(
                        'Total',
                        _commentStats['total']?.toString() ?? '0',
                        Icons.comment,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
                // Search Bar
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search comments...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _refreshComments();
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.sp),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ],
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? CustomErrorWidget(
                  errorDetails:
                      FlutterErrorDetails(exception: Exception(_error!)),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCommentsTab(_allComments),
                    _buildCommentsTab(_pendingComments),
                    _buildCommentsTab(_approvedComments),
                    _buildCommentsTab(_rejectedComments),
                  ],
                ),
    );
  }

  Widget _buildStatItem(
      String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 5.w),
        SizedBox(height: 0.5.h),
        Text(
          count,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildCommentsTab(List<Comment> comments) {
    if (comments.isEmpty) {
      return _buildEmptyState('No comments found', Icons.comment_outlined);
    }

    return Column(
      children: [
        // Select All Button
        if (!_isSelectionMode && comments.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${comments.length} comments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                TextButton.icon(
                  onPressed: () => _selectAll(comments),
                  icon: Icon(Icons.select_all, size: 4.w),
                  label: const Text('Select All'),
                ),
              ],
            ),
          ),
        // Comments List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshComments,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentTileWidget(
                  comment: comment,
                  isSelected: _selectedComments.contains(comment.id),
                  isSelectionMode: _isSelectionMode,
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(comment.id)
                      : null,
                  onLongPress: () => _toggleSelection(comment.id),
                  onApprove: comment.isPending
                      ? () => _approveComment(comment.id)
                      : null,
                  onReject: comment.isPending
                      ? () => _rejectComment(comment.id)
                      : null,
                  onDelete: () => _deleteComment(comment.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15.w, color: Colors.grey),
          SizedBox(height: 2.h),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
