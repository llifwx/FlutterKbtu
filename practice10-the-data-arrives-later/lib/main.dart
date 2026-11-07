import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Students Async',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Data Arrives Later')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () => _open(context, const StudentsScreen()),
              child: const Text('By hand'),
            ),
            FilledButton(
              onPressed: () => _open(context, const StudentsFutureScreen()),
              child: const Text('FutureBuilder'),
            ),
            FilledButton(
              onPressed: () => _open(context, const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
