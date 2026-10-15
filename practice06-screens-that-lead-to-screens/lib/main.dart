import 'package:flutter/material.dart';

import 'routes.dart';
import 'students_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practice 06 - Students',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: Routes.students,
      routes: {Routes.students: (_) => const StudentsScreen()},
      onGenerateRoute: generateRoute,
    );
  }
}
