import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final n = context.select<Cart, int>((c) => c.count);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BadgeTotal(),
        IconButton(
          tooltip: 'Cart',
          icon: Badge(
            label: Text('$n'),
            child: const Icon(Icons.shopping_cart),
          ),
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
        ),
      ],
    );
  }
}

// Its own subscription: a price change must not rebuild CartBadge.
class _BadgeTotal extends StatelessWidget {
  const _BadgeTotal();

  @override
  Widget build(BuildContext context) =>
      Text('${context.select<Cart, int>((c) => c.total)} ₸');
}
