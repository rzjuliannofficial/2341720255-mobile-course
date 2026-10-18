import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

/// Clean Architecture Notes Screen.
/// Free of SQL, Dio, raw JSON parsing, or database instances.
/// Relies purely on domain usecases via Riverpod.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.note_add_outlined, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Tambah Catatan Baru'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Judul Catatan',
                    hintText: 'Misal: Rapat Arsitektur Clean',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (val.trim().length > 100) {
                      return 'Judul maksimal 100 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan (Opsional)',
                    hintText: 'Deskripsi singkat...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subject),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final nav = Navigator.of(dialogCtx);
                final scaffold = ScaffoldMessenger.of(context);
                final title = titleController.text;
                final body = bodyController.text;

                nav.pop();

                final result = await ref
                    .read(notesNotifierProvider.notifier)
                    .addNote(title: title, body: body);

                if (!result.success && result.error != null) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(result.error!),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                } else {
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text('Catatan berhasil ditambahkan'),
                      backgroundColor: Colors.teal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clean Architecture Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Feature-first: Domain | Data | Presentation',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Catatan',
            onPressed: () =>
                ref.read(notesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat catatan melalui Clean Architecture...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(
                  'Terjadi Kesalahan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(notesNotifierProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.note_alt_outlined,
                        size: 64, color: Colors.indigo.shade200),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada catatan.',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan tombol + di bawah untuk menambahkan catatan pertama Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => _showAddNoteDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Catatan Baru'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notesNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (ctx, index) {
                final note = notes[index];
                return _NoteCard(
                  note: note,
                  onDelete: () async {
                    if (note.id != null) {
                      final scaffold = ScaffoldMessenger.of(context);
                      final result = await ref
                          .read(notesNotifierProvider.notifier)
                          .deleteNote(note.id!);
                      if (!result.success && result.error != null) {
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text(result.error!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Catatan Baru'),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onDelete});

  final Note note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: note.dirty
                        ? Colors.amber.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: note.dirty
                          ? Colors.amber.shade700
                          : Colors.green.shade700,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    note.dirty ? 'Offline / Dirty' : 'Tersinkron',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: note.dirty
                          ? Colors.amber.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  tooltip: 'Hapus Catatan',
                  onPressed: onDelete,
                ),
              ],
            ),
            if (note.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.body,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  formatTimeAgo(note.updatedAt),
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  'ID: #${note.id ?? "-"}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
