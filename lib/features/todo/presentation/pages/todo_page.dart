import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/todo_date_selector.dart';
import '../widgets/todo_filter_chips.dart';
import '../widgets/todo_item.dart';
import '../widgets/todo_month_calendar.dart';
import '../widgets/todo_progress_card.dart';
import 'todo_form_bottom_sheet.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    context
        .read<TodoBloc>()
        .add(LoadTodosByDate(DateTime(today.year, today.month, today.day)));
  }

  Future<void> _openForm({TodoEntity? initial}) async {
    final state = context.read<TodoBloc>().state;
    final result = await TodoFormBottomSheet.show(
      context,
      initial: initial,
      defaultDate: state.selectedDate,
    );
    if (!mounted || result == null) return;
    if (initial == null) {
      context.read<TodoBloc>().add(CreateTodoEvent(result));
    } else {
      context.read<TodoBloc>().add(UpdateTodoEvent(result));
    }
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: const Text('Bạn chắc chắn muốn xóa công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      context.read<TodoBloc>().add(DeleteTodoEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Todo',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            buildWhen: (p, c) => p.viewMode != c.viewMode,
            builder: (context, state) {
              final isMonth = state.viewMode == TodoViewMode.month;
              return IconButton(
                tooltip: isMonth ? 'Xem theo ngày' : 'Xem theo tháng',
                icon: Icon(
                  isMonth
                      ? Icons.view_day_outlined
                      : Icons.calendar_month_outlined,
                  color: AppColors.primary,
                ),
                onPressed: () => context.read<TodoBloc>().add(
                      ChangeViewMode(
                        isMonth ? TodoViewMode.day : TodoViewMode.month,
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state.status == TodoStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.viewMode == TodoViewMode.month) {
            return _buildMonthView(state);
          }
          return _buildDayView(state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDayView(TodoState state) {
    return Column(
      children: [
        TodoDateSelector(
          selectedDate: state.selectedDate,
          onDateChanged: (d) =>
              context.read<TodoBloc>().add(ChangeSelectedDate(d)),
        ),
        TodoProgressCard(
          completed: state.completedCount,
          total: state.totalCount,
          progress: state.progress,
        ),
        TodoFilterChips(
          selected: state.filter,
          onChanged: (f) =>
              context.read<TodoBloc>().add(ChangeTodoFilter(f)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildList(state),
        ),
      ],
    );
  }

  Widget _buildMonthView(TodoState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          TodoMonthCalendar(
            monthAnchor: state.monthAnchor,
            selectedDate: state.selectedDate,
            counts: state.monthCounts,
            onMonthChanged: (m) =>
                context.read<TodoBloc>().add(ChangeMonthAnchor(m)),
            onDayTapped: (d) {
              final bloc = context.read<TodoBloc>();
              bloc.add(ChangeSelectedDate(d));
              bloc.add(const ChangeViewMode(TodoViewMode.day));
            },
          ),
          const SizedBox(height: 8),
          const _MonthLegend(),
        ],
      ),
    );
  }

  Widget _buildList(TodoState state) {
    if (state.status == TodoStatus.loading && state.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = state.filteredTodos;
    if (items.isEmpty) {
      return _emptyState(state);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final todo = items[index];
        return TodoItem(
          todo: todo,
          onToggle: (v) => context
              .read<TodoBloc>()
              .add(ToggleTodoStatusEvent(todo.id, v)),
          onEdit: () => _openForm(initial: todo),
          onDelete: () => _confirmDelete(todo.id),
        );
      },
    );
  }

  Widget _emptyState(TodoState state) {
    final message = state.totalCount == 0
        ? 'Hôm nay chưa có công việc nào'
        : 'Không có công việc khớp với bộ lọc';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Thêm công việc',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthLegend extends StatelessWidget {
  const _MonthLegend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(color: AppColors.warning, label: 'Chưa hoàn thành'),
          SizedBox(width: 16),
          _LegendDot(color: Color(0xFF52C41A), label: 'Đã hoàn thành'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }
}
