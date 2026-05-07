import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/meetings_bloc.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/widgets/platform_logo_widget.dart';

class MeetingItemWidget extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onTap;
  final VoidCallback? onOptions;
  final bool isDeleting;
  final Function(String)? onDelete;
  final Function(MeetingModel)? onEdit;
  final MeetingAnimationState animationState;

  const MeetingItemWidget({
    super.key,
    required this.meeting,
    this.onTap,
    this.onOptions,
    this.isDeleting = false,
    this.onDelete,
    this.onEdit,
    this.animationState = MeetingAnimationState.normal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimation.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildAnimatedContent(context),
    );
  }

  Widget _buildAnimatedContent(BuildContext context) {
    // Handle animation states
    if (animationState == MeetingAnimationState.removed) {
      return const SizedBox.shrink(); // Hidden during removed state
    }

    double opacity = 1.0;
    if (animationState == MeetingAnimationState.animating_out) {
      opacity = 0.0; // Fade out
    } else if (animationState == MeetingAnimationState.animating_in) {
      opacity = 1.0; // Fade in
    }

    return Opacity(
      opacity: opacity,
      key: ValueKey('meeting_${meeting.id}_${animationState.toString()}'),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDeleting ? null : onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Meeting platform logo
                      PlatformLogoWidget(
                        platform: meeting.type,
                        size: 40,
                      ),

                      const SizedBox(width: 12),

                      // Meeting info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title only
                            Text(
                              meeting.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Date, time and status in same row
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        meeting.formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        meeting.formattedTime,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    meeting.status,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Options popup menu
                      PopupMenuButton<String>(
                        enabled: !isDeleting,
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(context);
                          } else if (value == 'edit') {
                            onEdit?.call(meeting);
                          }
                        },
                        itemBuilder: (context) => [
                          // const PopupMenuItem(
                          //   value: 'edit',
                          //   child: Row(
                          //     children: [
                          //       Icon(Icons.edit, color: Colors.blue, size: 16),
                          //       SizedBox(width: 8),
                          //       Text('Chỉnh sửa'),
                          //     ],
                          //   ),
                          // ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Text('Xóa'),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_vert,
                          color: isDeleting ? Colors.grey[300] : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Loading overlay
          if (isDeleting)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Xác nhận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Bạn có muốn xóa cuộc họp này không?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete?.call(meeting.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xóa',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
