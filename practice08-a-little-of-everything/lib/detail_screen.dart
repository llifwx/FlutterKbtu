import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});
  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        content: const Text(
          'This book will be removed from your reading list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (context.mounted == false) return;
    if (confirmed == true) Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(book.title, style: text.headlineSmall),
                  const SizedBox(height: 12),
                  Text(book.author, style: text.titleMedium),
                  const SizedBox(height: 24),
                  Text('${book.pages} pages', style: text.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    book.year == null ? 'Year unknown' : 'Year: ${book.year}',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.read ? 'Status: Read' : 'Status: Unread',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pop(BookAction.toggleRead),
                    icon: Icon(book.read ? Icons.remove_done : Icons.done),
                    label: Text(book.read ? 'Mark as unread' : 'Mark as read'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
