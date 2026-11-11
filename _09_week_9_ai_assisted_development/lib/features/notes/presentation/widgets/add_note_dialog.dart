import 'package:flutter/material.dart';

/// Stateful modal dialog for composing a new note with properly disposed controllers.
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.note_add_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Tambah Catatan Baru')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('note-title-field'),
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  hintText: 'Misal: Rapat Review Kode PR #12',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (trimmed.length > 100) {
                    return 'Judul maksimal 100 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('note-body-field'),
                controller: _bodyController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan (Opsional)',
                  hintText: 'Ringkasan tindak lanjut...',
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          key: const Key('save-note-button'),
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Simpan'),
        ),
      ],
    );
  }
}
