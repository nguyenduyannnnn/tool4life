import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/meetings_bloc.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/widgets/meeting_item_widget.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/meeting_detail/src/ui/meeting_detail_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  final MeetingsBloc _meetingsBloc = MeetingsBloc();
  final ScrollController _scrollController = ScrollController();

  String get _getUserName {
    final userName = Globals.prefs.getString(SharedPrefsKey.userName);
    if (userName.isNotEmpty) {
      // Lấy tên đầu tiên nếu có nhiều từ
      final nameParts = userName.split(' ');
      return nameParts.isNotEmpty ? nameParts.first : 'User';
    }
    return 'User';
  }

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void refreshUserInfo() {
    if (mounted) {
      setState(() {
        // Trigger rebuild to update user name
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final currentScroll = position.pixels;

      // Debug logs
      Utilities.customPrint(
          "📱 SCROLL: current=$currentScroll, max=$maxScroll");

      // Trigger load more with multiple conditions
      final shouldLoadMore =
          (currentScroll >= maxScroll * 0.8 && maxScroll > 0) ||
              (currentScroll >= maxScroll - 50 && maxScroll > 0);

      if (shouldLoadMore) {
        print(
            "🔄 SCROLL DEBUG: Load more triggered - current: $currentScroll, max: $maxScroll");
        Utilities.customPrint("🔄 SCROLL: Triggering load more...");
        _meetingsBloc.loadMoreMeetings();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _meetingsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Custom Header - Fixed at top
            _buildCustomHeader(),

            // Scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _meetingsBloc.refreshMeetings,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildMeetingSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const SizedBox(height: 16),

        // Search bar
        _buildSearchBar(),
        const SizedBox(height: 16),

        // Meeting list
        _buildMeetingList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _meetingsBloc.searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm cuộc họp...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // Date filter button
              StreamBuilder<DateTime?>(
                stream: _meetingsBloc.startDateStream,
                builder: (context, startSnapshot) {
                  return StreamBuilder<DateTime?>(
                    stream: _meetingsBloc.endDateStream,
                    builder: (context, endSnapshot) {
                      final hasFilter = startSnapshot.data != null || endSnapshot.data != null;
                      
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clear filter button
                          if (hasFilter)
                            IconButton(
                              onPressed: () => _meetingsBloc.clearDateFilter(),
                              icon: const Icon(Icons.close, size: 20),
                              color: Colors.red,
                              tooltip: 'Xóa bộ lọc',
                            ),
                          // Date filter button
                          IconButton(
                            onPressed: () => _showDateFilterDialog(),
                            icon: Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: hasFilter ? AppColors.primary : Colors.grey,
                            ),
                            tooltip: 'Lọc theo ngày',
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        // Filter info
        StreamBuilder<DateTime?>(
          stream: _meetingsBloc.startDateStream,
          builder: (context, startSnapshot) {
            return StreamBuilder<DateTime?>(
              stream: _meetingsBloc.endDateStream,
              builder: (context, endSnapshot) {
                final startDate = startSnapshot.data;
                final endDate = endSnapshot.data;
                
                if (startDate == null && endDate == null) {
                  return const SizedBox.shrink();
                }
                
                String filterText = '';
                if (startDate != null && endDate != null) {
                  filterText = 'Từ ${_formatDate(startDate)} đến ${_formatDate(endDate)}';
                } else if (startDate != null) {
                  filterText = 'Từ ${_formatDate(startDate)}';
                } else if (endDate != null) {
                  filterText = 'Đến ${_formatDate(endDate)}';
                }
                
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          filterText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showDateFilterDialog() async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Lọc theo ngày',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start date
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                    title: const Text('Từ ngày'),
                    subtitle: Text(
                      startDate != null ? _formatDate(startDate!) : 'Chọn ngày bắt đầu',
                      style: TextStyle(
                        color: startDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),
                  // End date
                  ListTile(
                    leading: const Icon(Icons.event, color: AppColors.primary),
                    title: const Text('Đến ngày'),
                    subtitle: Text(
                      endDate != null ? _formatDate(endDate!) : 'Chọn ngày kết thúc',
                      style: TextStyle(
                        color: endDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _meetingsBloc.applyDateFilter(startDate, endDate);
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMeetingList() {
    return StreamBuilder<bool>(
      stream: _meetingsBloc.isLoadingStream,
      builder: (context, loadingSnapshot) {
        final isLoading = loadingSnapshot.data ?? false;

        return StreamBuilder<String?>(
          stream: _meetingsBloc.errorStream,
          builder: (context, errorSnapshot) {
            final error = errorSnapshot.data;

            if (error != null && !isLoading) {
              return _buildErrorState(error);
            }

            return StreamBuilder<List<MeetingModel>>(
              stream: _meetingsBloc.meetingsStream,
              builder: (context, meetingsSnapshot) {
                if (isLoading &&
                    (!meetingsSnapshot.hasData ||
                        meetingsSnapshot.data!.isEmpty)) {
                  return _buildSkeletonLoading();
                }

                if (meetingsSnapshot.hasData) {
                  final meetings = meetingsSnapshot.data!;

                  if (meetings.isEmpty && !isLoading) {
                    return _buildEmptyState();
                  }

                  return StreamBuilder<Set<String>>(
                    stream: _meetingsBloc.deletingMeetingsStream,
                    builder: (context, deletingSnapshot) {
                      final deletingIds = deletingSnapshot.data ?? <String>{};

                      return StreamBuilder<Map<String, MeetingAnimationState>>(
                        stream: _meetingsBloc.animationStatesStream,
                        builder: (context, animationSnapshot) {
                          final animationStates = animationSnapshot.data ??
                              <String, MeetingAnimationState>{};

                          return Column(
                            children: [
                              ...meetings.map((meeting) {
                                final isDeleting =
                                    deletingIds.contains(meeting.id);
                                final animationState =
                                    animationStates[meeting.id] ??
                                        MeetingAnimationState.normal;

                                return MeetingItemWidget(
                                  meeting: meeting,
                                  isDeleting: isDeleting,
                                  animationState: animationState,
                                  onTap: () {
                                    Utilities.customPrint("🎯🎯🎯 NAVIGATION: Tapped on meeting: ${meeting.id}, title: ${meeting.title}");
                                    Utilities.customPrint("🎯 NAVIGATION: About to push MeetingDetailScreen");
                                    CustomNavigator.push(
                                      context,
                                      MeetingDetailScreen(meeting: meeting),
                                    );
                                    Utilities.customPrint("🎯 NAVIGATION: Push completed");
                                  },
                                  onDelete: (meetingId) =>
                                      _meetingsBloc.deleteMeeting(meetingId),
                                  onEdit: (meeting) =>
                                      _meetingsBloc.onEditMeeting(meeting),
                                  onOptions: () =>
                                      _meetingsBloc.onMeetingOptions(meeting),
                                );
                              }),
                              _buildLoadMoreIndicator(),
                            ],
                          );
                        },
                      );
                    },
                  );
                }

                return _buildSkeletonLoading();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: List.generate(5, (index) => _buildSkeletonItem()),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _meetingsBloc.retryLoad(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy cuộc họp nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return StreamBuilder<bool>(
      stream: _meetingsBloc.isLoadingMoreStream,
      builder: (context, snapshot) {
        final isLoadingMore = snapshot.data ?? false;

        print(
            "🔄 UI DEBUG: Load more indicator - isLoadingMore: $isLoadingMore");

        if (isLoadingMore) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  'Đang tải thêm cuộc họp...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Show "End of list" indicator when no more pages
        return StreamBuilder<List<MeetingModel>>(
          stream: _meetingsBloc.meetingsStream,
          builder: (context, meetingsSnapshot) {
            final meetings = meetingsSnapshot.data ?? [];
            if (meetings.length >= 10) {
              // Show only if we have some meetings
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Kéo xuống để tải thêm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/image/chang_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào ${_getUserName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chào mừng đến với Chang Meeting',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification icon - HIDDEN
          // GestureDetector(
          //   onTap: () => CustomNavigator.push(
          //     context,
          //     NotificationListScreen(),
          //   ),
          //   child: Container(
          //     padding: const EdgeInsets.all(6),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.1),
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Stack(
          //       children: [
          //         const Icon(
          //           Icons.notifications_outlined,
          //           color: Colors.white,
          //           size: 20,
          //         ),
          //         Positioned(
          //           right: 0,
          //           top: 0,
          //           child: Container(
          //             padding: const EdgeInsets.all(1),
          //             decoration: BoxDecoration(
          //               color: Colors.red,
          //               borderRadius: BorderRadius.circular(5),
          //             ),
          //             constraints: const BoxConstraints(
          //               minWidth: 10,
          //               minHeight: 10,
          //             ),
          //             child: const Text(
          //               '2',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 8,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
