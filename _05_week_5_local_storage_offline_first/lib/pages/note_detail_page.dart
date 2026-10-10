import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late Future<Note?> _noteFuture;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() {
    _noteFuture = ref.read(noteRepositoryProvider).getNoteById(widget.noteId);
  }

  void _showEditDialog(Note note) {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Catatan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Isi Catatan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isEmpty) return;

              final updated = note.copyWith(
                title: newTitle,
                body: bodyController.text.trim(),
              );
              await ref.read(notesProvider.notifier).updateNote(updated);
              if (!mounted) return;
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              }
              setState(() {
                _loadNote();
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          FutureBuilder<Note?>(
            future: _noteFuture,
            builder: (context, snapshot) {
              final note = snapshot.data;
              if (note == null) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Catatan',
                    onPressed: () => _showEditDialog(note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus Catatan',
                    onPressed: () async {
                      await ref.read(notesProvider.notifier).deleteNote(note.id!);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Note?>(
        future: _noteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan memuat catatan: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          final note = snapshot.data;
          if (note == null) {
            return const Center(
              child: Text('Catatan tidak ditemukan di penyimpanan lokal.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: note.dirty
                            ? Colors.amber.shade100
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: note.dirty
                              ? Colors.amber.shade700
                              : Colors.green.shade500,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            note.dirty
                                ? Icons.sync_problem
                                : Icons.check_circle_outline,
                            size: 14,
                            color: note.dirty
                                ? Colors.amber.shade900
                                : Colors.green.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            note.dirty ? 'Belum Tersinkron' : 'Tersinkron',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: note.dirty
                                  ? Colors.amber.shade900
                                  : Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: theme.hintColor),
                    const SizedBox(width: 6),
                    Text(
                      'Terakhir diubah: ${note.updatedAt.toLocal()}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  note.body.isEmpty ? '(Tidak ada deskripsi)' : note.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
