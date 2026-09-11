import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';

/// Halaman DetailPage yang menampilkan detail item ToDo berdasarkan ID
class DetailPage extends ConsumerWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final todoIndex = todos.indexWhere((t) => t.id == id);
    final todo = todoIndex != -1 ? todos[todoIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(todo != null ? 'Detail Tugas' : 'Tugas Tidak Ditemukan'),
      ),
      body: todo == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Tugas dengan ID $id tidak ditemukan.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Kembali ke Daftar'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Chip(
                                avatar: Icon(
                                  todo.done
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color:
                                      todo.done ? Colors.green : Colors.orange,
                                ),
                                label: Text(
                                  todo.done ? 'Selesai' : 'Belum Selesai',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: todo.done
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ID: ${todo.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              decoration: todo.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    todo.done
                                        ? Icons.undo
                                        : Icons.check_circle_outline,
                                  ),
                                  label: Text(
                                    todo.done
                                        ? 'Tandai Belum'
                                        : 'Tandai Selesai',
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(todoListProvider.notifier)
                                        .toggle(todo.id);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                tooltip: 'Hapus Tugas',
                                onPressed: () {
                                  ref
                                      .read(todoListProvider.notifier)
                                      .remove(todo.id);
                                  context.go('/');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}