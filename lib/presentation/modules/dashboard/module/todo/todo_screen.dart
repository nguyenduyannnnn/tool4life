import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/features/todo/data/datasources/local_database_service.dart';
import 'package:changmeeting/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:changmeeting/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:changmeeting/features/todo/domain/repositories/todo_repository.dart';
import 'package:changmeeting/features/todo/domain/usecases/create_todo.dart';
import 'package:changmeeting/features/todo/domain/usecases/delete_todo.dart';
import 'package:changmeeting/features/todo/domain/usecases/get_todos_by_date.dart';
import 'package:changmeeting/features/todo/domain/usecases/toggle_todo_status.dart';
import 'package:changmeeting/features/todo/domain/usecases/update_todo.dart';
import 'package:changmeeting/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:changmeeting/features/todo/presentation/pages/todo_page.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>(
      create: (_) {
        final db = LocalDatabaseService.instance.db;
        final TodoRepository repository = TodoRepositoryImpl(
          TodoLocalDataSourceImpl(db),
        );
        return TodoBloc(
          getTodosByDate: GetTodosByDate(repository),
          createTodo: CreateTodo(repository),
          updateTodo: UpdateTodo(repository),
          deleteTodo: DeleteTodo(repository),
          toggleTodoStatus: ToggleTodoStatus(repository),
        );
      },
      child: const TodoPage(),
    );
  }
}
