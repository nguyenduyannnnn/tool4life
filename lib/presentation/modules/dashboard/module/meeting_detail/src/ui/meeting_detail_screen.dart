import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/data/models/meeting_detail_model.dart';
import 'package:changmeeting/data/models/meeting_transcript_model.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/meeting_detail/src/bloc/meeting_detail_bloc.dart';

class MeetingDetailScreen extends StatefulWidget {
  final MeetingModel meeting;

  MeetingDetailScreen({
    super.key,
    required this.meeting,
  }) {
    Utilities.customPrint("🏗️🏗️🏗️ CONSTRUCTOR: MeetingDetailScreen created for meeting: ${meeting.id}");
  }

  @override
  State<MeetingDetailScreen> createState() {
    Utilities.customPrint("🏗️ CONSTRUCTOR: createState called");
    return _MeetingDetailScreenState();
  }
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MeetingDetailBloc _bloc = MeetingDetailBloc();

  @override
  void initState() {
    Utilities.customPrint("🚀🚀🚀 SCREEN: initState STARTED for meeting: ${widget.meeting.id}");
    super.initState();
    
    try {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
      Utilities.customPrint("✅ SCREEN: TabController created");

      // Add tab listener for auto-loading transcripts
      _tabController.addListener(_onTabChanged);
      Utilities.customPrint("✅ SCREEN: Tab listener added");

      // Set meeting and load detail data
      _bloc.setMeeting(widget.meeting);
      Utilities.customPrint("✅ SCREEN: Meeting set in bloc");
      
      _bloc.onInit();
      Utilities.customPrint("✅ SCREEN: Bloc onInit called");
      
      Utilities.customPrint("🚀 SCREEN: About to call loadMeetingDetail with ID: ${widget.meeting.id}");
      _bloc.loadMeetingDetail(widget.meeting.id);
      Utilities.customPrint("✅ SCREEN: loadMeetingDetail called");
      
      Utilities.customPrint("🚀 SCREEN: About to call loadMeetingNotes with ID: ${widget.meeting.id}");
      _bloc.loadMeetingNotes(widget.meeting.id);
      Utilities.customPrint("✅ SCREEN: loadMeetingNotes called");
      
      Utilities.customPrint("🚀🚀🚀 SCREEN: initState COMPLETED");
    } catch (e, stackTrace) {
      Utilities.customPrint("❌❌❌ SCREEN: Exception in initState: $e");
      Utilities.customPrint("❌ Stack trace: $stackTrace");
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      // Transcript tab focused - load transcripts if not already loaded
      if (!_bloc.hasTranscripts) {
        _bloc.loadMeetingTranscripts(widget.meeting.id);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MeetingDetailModel?>(
      stream: _bloc.meetingDetailStream,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: _buildAppBar(context, snapshot.data),
          body: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Tóm tắt'),
                    Tab(text: 'Bản ghi'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _KeepAliveWrapper(child: _buildSummaryTabWithState()),
                    _KeepAliveWrapper(child: _buildTranscriptTab()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, MeetingDetailModel? meetingDetail) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: StreamBuilder<bool>(
        stream: _bloc.isLoadingStream,
        builder: (context, loadingSnapshot) {
          final isLoading = loadingSnapshot.data ?? false;

          if (isLoading) {
            return _buildSkeletonAppBarTitle();
          }

          return _buildAppBarTitle(meetingDetail);
        },
      ),
      actions: [
        // Share button
        StreamBuilder<bool>(
          stream: _bloc.isSharingStream,
          builder: (context, snapshot) {
            final isSharing = snapshot.data ?? false;
            
            return IconButton(
              icon: isSharing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.share, color: Colors.black),
              onPressed: isSharing ? null : () => _shareMeetingNotes(),
              tooltip: 'Chia sẻ meeting note',
            );
          },
        ),
        // Download button
        StreamBuilder<bool>(
          stream: _bloc.isDownloadingStream,
          builder: (context, snapshot) {
            final isDownloading = snapshot.data ?? false;
            
            return IconButton(
              icon: isDownloading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.download, color: Colors.black),
              onPressed: isDownloading ? null : () => _downloadMeetingNotes(),
              tooltip: 'Tải meeting note',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarTitle(MeetingDetailModel? meetingDetail) {
    final title = meetingDetail?.title ?? widget.meeting.title;

    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSummaryTabWithState() {
    return RefreshIndicator(
      onRefresh: () => _bloc.refreshCurrentTab(0),
      color: AppColors.primary,
      child: StreamBuilder<bool>(
        stream: _bloc.isLoadingNotesStream,
        builder: (context, loadingSnapshot) {
          final isLoadingNotes = loadingSnapshot.data ?? false;
          Utilities.customPrint('🔄 Summary tab - isLoading: $isLoadingNotes');

          if (isLoadingNotes) {
            return _buildNotesSkeletonLoading();
          }

          return StreamBuilder<String?>(
            stream: _bloc.notesErrorStream,
            builder: (context, errorSnapshot) {
              final notesError = errorSnapshot.data;
              Utilities.customPrint('❌ Summary tab - error: $notesError');

              if (notesError != null) {
                return _buildNotesErrorState(notesError);
              }

              return StreamBuilder<String?>(
                stream: _bloc.summaryMarkdownStream,
                builder: (context, markdownSnapshot) {
                  final markdown = markdownSnapshot.data;
                  Utilities.customPrint('📊 Summary tab - markdown length: ${markdown?.length ?? 0}');

                  if (markdown == null || markdown.isEmpty) {
                    return _buildNoNotesState();
                  }

                  return _buildSummaryMarkdownContent(markdown);
                },
              );
            },
          );
        },
      ),
    );
  }

  // NEW METHODS FOR NOTES FUNCTIONALITY

  Widget _buildSummaryMarkdownContent(String markdown) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: markdown,
          styleSheet: _buildMarkdownStyleSheet(),
          selectable: true,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1.2,
      ),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1.2,
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
      p: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
      listBullet: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
      strong: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      blockquotePadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSkeletonLoading() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown skeleton
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(height: 16),

          // Sub-tabs skeleton (only 1 tab now)
          Row(
            children: [
              Container(
                height: 32,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons skeleton (only 1 button + VI now)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                height: 36,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < 8; i++) ...[
                  Container(
                    height: 14,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesErrorState(String error) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _bloc.retryNotes(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Show basic meeting info as fallback
                    _showBasicMeetingInfo();
                  },
                  child: const Text(
                    'Xem thông tin cơ bản',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoNotesState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có ghi chú cuộc họp',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Show basic meeting info as fallback
                    _showBasicMeetingInfo();
                  },
                  child: const Text(
                    'Xem thông tin cơ bản',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBasicMeetingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin cuộc họp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiêu đề: ${widget.meeting.title}'),
            const SizedBox(height: 8),
            Text('Ngày: ${widget.meeting.formattedDate}'),
            const SizedBox(height: 8),
            Text('Thời gian: ${widget.meeting.formattedTime}'),
            const SizedBox(height: 8),
            Text('Trạng thái: ${widget.meeting.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptTab() {
    return RefreshIndicator(
      onRefresh: () => _bloc.refreshCurrentTab(1),
      color: AppColors.primary,
      child: Container(
        color: Colors.white,
        child: StreamBuilder<bool>(
          stream: _bloc.isLoadingTranscriptsStream,
          builder: (context, loadingSnapshot) {
            Utilities.customPrint('🔄 Transcript tab - isLoading: ${loadingSnapshot.data}');
            
            return StreamBuilder<String?>(
              stream: _bloc.transcriptsErrorStream,
              builder: (context, errorSnapshot) {
                Utilities.customPrint('❌ Transcript tab - error: ${errorSnapshot.data}');
                
                return StreamBuilder<List<MeetingTranscriptsResponse>>(
                  stream: _bloc.meetingTranscriptsStream,
                  builder: (context, transcriptsSnapshot) {
                    final isLoading = loadingSnapshot.data ?? false;
                    final error = errorSnapshot.data;
                    final transcripts = transcriptsSnapshot.data ?? [];
                    
                    Utilities.customPrint('📊 Transcript tab - transcripts count: ${transcripts.length}');

                    if (isLoading) {
                      return _buildTranscriptSkeletonLoading();
                    }

                    if (error != null) {
                      return _buildTranscriptErrorState(error);
                    }

                    if (transcripts.isEmpty) {
                      return _buildNoTranscriptsState();
                    }

                    return _buildTranscriptContent();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTranscriptContent() {
    Utilities.customPrint('🎯 Building transcript content');
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Dropdown đã bị ẩn
          // _buildTranscriptVersionDropdown(),
          _buildTranscriptTableHeader(),
          Expanded(
            child: _buildTranscriptList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptVersionDropdown() {
    return StreamBuilder<int>(
      stream: _bloc.selectedTranscriptVersionIndexStream,
      builder: (context, selectedIndexSnapshot) {
        final selectedIndex = selectedIndexSnapshot.data ?? 0;
        final versionItems = _bloc.transcriptVersionDropdownItems;

        if (versionItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              onChanged: (int? newIndex) {
                if (newIndex != null) {
                  _bloc.switchTranscriptVersion(newIndex);
                }
              },
              items: versionItems.asMap().entries.map((entry) {
                final int index = entry.key;
                final String versionName = entry.value;
                return DropdownMenuItem<int>(
                  value: index,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          versionName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptTableHeader() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Người nói',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Nội dung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptList() {
    if (_bloc.currentTranscriptIsProcessing) {
      return _buildTranscriptProcessingState();
    }

    if (_bloc.currentTranscriptIsFailed) {
      return _buildTranscriptFailedState();
    }

    final segments = _bloc.currentTranscriptSegments;

    if (segments.isEmpty) {
      return _buildEmptyTranscriptSegments();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return _buildTranscriptRow(segment.formattedSpeaker, segment.text);
      },
    );
  }

  Widget _buildTranscriptProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang xử lý bản ghi cuộc họp...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptFailedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Xử lý bản ghi thất bại',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _bloc.retryTranscripts(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTranscriptSegments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.voice_over_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có nội dung bản ghi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSkeletonLoading() {
    return Column(
      children: [
        // Skeleton Dropdown
        Container(
          width: double.infinity,
          height: 48,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Skeleton Table Header
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Skeleton Transcript Rows
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: double.infinity * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptErrorState(String error) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Lỗi tải bản ghi cuộc họp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _bloc.retryTranscripts(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTranscriptsState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.record_voice_over,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có bản ghi cuộc họp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bản ghi sẽ được tạo sau khi cuộc họp kết thúc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptRow(String speaker, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              speaker,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Download method
  void _downloadMeetingNotes() async {
    await _bloc.downloadMeetingNotes();
    
    // Listen for download message
    _bloc.downloadMessageStream.take(1).listen((message) {
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: message.contains('thành công') 
              ? Colors.green 
              : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  // Share method
  void _shareMeetingNotes() async {
    await _bloc.shareMeetingNotes();
    
    // Listen for share message
    _bloc.shareMessageStream.take(1).listen((message) {
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: message.contains('thành công') 
              ? Colors.green 
              : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }
}

// Keep alive wrapper for TabBarView children
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true; // Keep this tab alive
}
