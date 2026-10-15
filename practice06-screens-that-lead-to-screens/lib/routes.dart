import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'students.dart';

abstract final class Routes {
  static const students = '/';
  static const student = '/student';
  static const edit = '/edit';
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.student:
      final student = settings.arguments as Student;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(student: student),
      );
    case Routes.edit:
      final student = settings.arguments as Student;
      return MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => EditScreen(student: student),
      );
    default:
      return null;
  }
}
