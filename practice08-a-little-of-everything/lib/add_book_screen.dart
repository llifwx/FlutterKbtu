import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() == false) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Enter at least 2 characters'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _author,
                    decoration: const InputDecoration(labelText: 'Author'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Enter an author' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pages,
                    decoration: const InputDecoration(labelText: 'Pages'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      final n = int.tryParse(value ?? '');
                      if (n == null || n <= 0) return 'A whole number above 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _year,
                    decoration: const InputDecoration(
                      labelText: 'Year (optional)',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) return null;
                      final year = int.tryParse(value ?? '');
                      final currentYear = DateTime.now().year;
                      if (year == null || year < 1450 || year > currentYear) {
                        return 'Enter a year from 1450 to $currentYear';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
