import 'package:flutter/material.dart';

import 'library_screen.dart';
import 'models/book.dart';

void main() {
  debugPrint('${totalPages(seed)} pages, ${unread(seed).length} unread');
  debugPrint(
    Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Reading list',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: const LibraryScreen(),
  );
}
