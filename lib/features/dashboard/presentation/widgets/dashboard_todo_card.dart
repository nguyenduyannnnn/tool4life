import 'package:flutter/material.dart';

import 'package:changmeeting/common/theme.dart';
import '../../../todo/domain/entities/todo_entity.dart';

class DashboardTodoCard extends StatelessWidget {
  final List<TodoEntity> visibleTodos;
  final int totalTodos;
  final int completedTodos;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenTodoTab;

  const DashboardTodoCard({
    super.key,
    required this.visibleTodos,
    required this.totalTodos,
    required this.completedTodos,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onOpenTodoTab,
  });

  Color _priorityColor(TodoPriority p) {
    switch (p) {
      case TodoPriority.high:
        return const Color(0xFFE53935);
      case TodoPriority.medium:
        return const Color(0xFFFB8C00);
      case TodoPriority.low:
        return const Color(0xFF43A047);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenTodoTab,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Công việc hôm nay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.grey, size: 20),
                  ],
                ),
                if (totalTodos == 0) ...[
                  const SizedBox(height: 12),
                  _emptyState(),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(
                    'Hôm nay có $totalTodos công việc, đã hoàn thành $completedTodos',
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...visibleTodos.map(_buildTodoRow),
                ],
                if (totalTodos > 3) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onToggleExpand,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                      label: Text(isExpanded ? 'Thu gọn' : 'Xem tất cả'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoRow(TodoEntity todo) {
    final color = _priorityColor(todo.priority);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            todo.isCompleted
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 20,
            color: todo.isCompleted ? AppColors.primary : AppColors.hint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              todo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
                color:
                    todo.isCompleted ? AppColors.grey : AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              todo.priority.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined,
                size: 36, color: AppColors.hint),
            const SizedBox(height: 8),
            Text(
              'Hôm nay chưa có công việc nào',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
