import 'package:flutter/material.dart';

import 'stopwatch_card.dart';
import 'tap_card.dart';
import 'two_way_counter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('A screen that reacts')),
    body: const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TapCard(),
          SizedBox(height: 16),
          TwoWayCounter(),
          SizedBox(height: 16),
          StopwatchCard(),
        ],
      ),
    ),
  );
}
