import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'books_screen.dart';
import 'cart_screen.dart';
import 'models/cart.dart';

void main() =>
    runApp(ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()));

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Shop',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    routes: {
      '/': (_) => const BooksScreen(),
      '/cart': (_) => const CartScreen(),
    },
  );
}
