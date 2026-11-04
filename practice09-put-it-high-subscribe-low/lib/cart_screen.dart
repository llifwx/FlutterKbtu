import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Every book will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (yes == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        IconButton(
          tooltip: 'Clear cart',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmClear(context),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) => ListView(
              children: [
                for (final b in cart.items)
                  ListTile(
                    title: Text(b.title),
                    subtitle: Text('${b.author} · ${b.price} ₸'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('×${cart.qtyOf(b)}'),
                        IconButton(
                          tooltip: 'More',
                          icon: const Icon(Icons.add),
                          onPressed: () => cart.increment(b),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close),
                          onPressed: () => cart.remove(b),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<Cart>(
            builder: (context, cart, child) => Row(
              children: [child!, const Spacer(), Text('${cart.total} ₸')],
            ),
            child: const _TotalLabel(),
          ),
        ),
      ],
    ),
  );
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();

  @override
  Widget build(BuildContext context) {
    debugPrint('total label build');
    return const Row(
      children: [Icon(Icons.receipt_long), SizedBox(width: 8), Text('Total')],
    );
  }
}
