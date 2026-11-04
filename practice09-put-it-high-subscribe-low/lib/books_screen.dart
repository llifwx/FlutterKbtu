import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final q = _query.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
          onChanged: (text) => setState(() => _query = text),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView(
        children: [
          for (final b in books)
            if (b.title.toLowerCase().contains(q)) _BookRow(b),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow(this.b);

  final Book b;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${b.title}');
    final added = context.select<Cart, bool>((c) => c.items.contains(b));
    return ListTile(
      title: Text(b.title),
      subtitle: Text(b.author),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(b);
                if (ok) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
