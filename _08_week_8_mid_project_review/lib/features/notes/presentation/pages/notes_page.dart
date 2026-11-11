import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/note_card.dart';

/// Notes screen consuming [notesNotifierProvider] with zero direct data calls.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const AddNoteDialog(),
    );
    if (draft == null || !context.mounted) return;

    final result = await ref
        .read(notesNotifierProvider.notifier)
        .addNote(title: draft.title, body: draft.body);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Catatan berhasil ditambahkan'
              : (result.error ?? 'Gagal menambahkan catatan'),
        ),
        backgroundColor: result.success
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final noteId = note.id;
    if (noteId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Catatan "${note.title}" akan dihapus dari SQLite lokal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(notesNotifierProvider.notifier)
        .deleteNote(noteId);
    if (!context.mounted || result.success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.error ?? 'Gagal menghapus catatan'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesNotifierProvider);
    final clock = ref.watch(appClockProvider);
    final themeMode = ref.watch(themeModeProvider);

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
              'Minggu 8: Mid-Project & Code Review',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('theme-toggle-button'),
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Ubah Tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Catatan',
            onPressed: () => ref.read(notesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const _NotesLoadingView(),
        error: (error, _) => _NotesErrorView(
          error: error,
          onRetry: () => ref.read(notesNotifierProvider.notifier).refresh(),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return _EmptyNotesView(
              onAddPressed: () => _openAddDialog(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notesNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (_, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  clock: clock,
                  onDelete: () => _confirmAndDelete(context, ref, note),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-note-fab'),
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catatan Baru'),
      ),
    );
  }
}

class _NotesLoadingView extends StatelessWidget {
  const _NotesLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat catatan dari penyimpanan lokal...'),
        ],
      ),
    );
  }
}

class _NotesErrorView extends StatelessWidget {
  const _NotesErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is Failure ? (error as Failure).message : '$error';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Gagal Memuat Catatan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan catatan review atau ringkasan materi kuliah pertama Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Buat Catatan Baru'),
            ),
          ],
        ),
      ),
    );
  }
}
