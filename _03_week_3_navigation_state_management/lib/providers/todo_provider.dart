import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model item ToDo bersifat immutable
class Todo {
  final String id;
  final String title;
  final bool done;

  const Todo({
    required this.id,
    required this.title,
    this.done = false,
  });

  Todo copyWith({String? id, String? title, bool? done}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}

/// Filter enum untuk daftar ToDo
enum TodoFilter {
  all,
  active,
  completed,
}

/// State filter aktif
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Notifier utama untuk mengelola list ToDo
class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    // Immutability: buat list baru
    state = [...state, newTodo];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(done: !todo.done) else todo,
    ];
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

/// Provider turunan untuk menyaring daftar ToDo berdasarkan filter aktif
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.done).toList();
    case TodoFilter.all:
      return todos;
  }
});

/// Provider turunan statistik ToDo
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoListProvider);
  final total = todos.length;
  final completed = todos.where((t) => t.done).length;
  final active = total - completed;

  return {
    'total': total,
    'completed': completed,
    'active': active,
  };
});
