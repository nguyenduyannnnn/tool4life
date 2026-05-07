/*
* Created by: tranly
* Created at: 2025/03/07 16:21
*/
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomNotificationCard extends StatelessWidget {
  final String? title;
  final String? content;
  final String? time;
  final bool? isRead;
  final Function()? onTap;
  final NotificationType type;
  final Function()? onDelete;

  const CustomNotificationCard(
      {super.key,
      this.title,
      this.content,
      this.time,
      this.isRead,
      this.onTap,
      this.onDelete,
      required this.type});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (isRead ?? false) ? Colors.white : Colors.grey[50]!;

    return Slidable(
      key: const Key(""),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              if (onDelete != null) {
                onDelete!();
              }
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            icon: Icons.delete,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
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
              // Avatar
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time in same row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          time ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Content
                    Text(
                      content ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // dismissal: SlidableDismissal(
      //   child: SlidableDrawerDismissal(),
      //   // dismissThresholds: {
      //   //   SlideActionType.secondary: 0.5
      //   // },
      //   // onWillDismiss: (e) {
      //   //   if(e == SlideActionType.secondary){
      //   //     return false;
      //   //   }
      //   //   return true;
      //   // },
      // ),
      // secondaryActions: [
      //   _buildAction1(context),
      //   _buildAction2(),
      // ],
    );
  }
}

enum NotificationType {
  debtPending, // tồn công nợ
  debtPaid, // đã thanh toán công nợ
  orderStatusChange, // thay đổi trạng thái đơn hàng
  general, // thông báo thông thường
}
