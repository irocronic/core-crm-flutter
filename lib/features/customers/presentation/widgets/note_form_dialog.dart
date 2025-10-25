// lib/features/customers/presentation/widgets/note_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../providers/note_provider.dart';

class NoteFormDialog extends StatefulWidget {
  final int customerId;
  final VoidCallback? onSuccess;

  const NoteFormDialog({
    super.key,
    required this.customerId,
    this.onSuccess,
  });

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isImportant = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'customer': widget.customerId,
      'content': _contentController.text.trim(),
      'is_important': _isImportant,
    };

    final provider = context.read<NoteProvider>();
    final success = await provider.createNote(data);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Not eklenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Not Ekle',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Not İçeriği *',
                    hintText: 'Müşteriyle ilgili notunuzu yazın...',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 6,
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Not içeriği'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Önemli olarak işaretle'),
                  value: _isImportant,
                  onChanged: (bool value) {
                    setState(() {
                      _isImportant = value;
                    });
                  },
                  secondary: Icon(
                    _isImportant ? Icons.star : Icons.star_border,
                    color: _isImportant ? Colors.amber : Colors.grey,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                Consumer<NoteProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Notu Kaydet'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}