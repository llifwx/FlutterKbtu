import 'package:flutter/material.dart';

import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProfileHeader(name: myName, university: myUniversity),
                const SizedBox(height: 24),
                for (final fact in facts)
                  InfoRow(label: fact.label, value: fact.value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
