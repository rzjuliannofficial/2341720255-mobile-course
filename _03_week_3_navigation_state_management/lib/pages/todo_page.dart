import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

/// Halaman TodoPage yang menampilkan daftar tugas dengan filter dan aksi tambah tugas
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas ToDo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Semua'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: TodoFilter.active,
                  label: Text('Aktif'),
                  icon: Icon(Icons.pending_outlined),
                ),
                ButtonSegment(
                  value: TodoFilter.completed,
                  label: Text('Selesai'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {currentFilter},
              onSelectionChanged: (newSelection) {
                ref
                    .read(todoFilterProvider.notifier)
                    .setFilter(newSelection.first);
              },
            ),
          ),
        ),
      ),
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada tugas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  todo: todo,
                  onTap: () => context.go('/detail/${todo.id}'),
                  onToggle: (_) =>
                      ref.read(todoListProvider.notifier).toggle(todo.id),
                  onDelete: () =>
                      ref.read(todoListProvider.notifier).remove(todo.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tugas Baru'),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Kerjakan PR minggu 3',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
