import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();
  bool _compact = false;

  // Set once in initState so rebuilds reuse it. Not final: _retry is the one
  // place allowed to replace it with a fresh request.
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() {
    // A block, not an arrow: setState must not get a Future back.
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students — FutureBuilder'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
          ),
          const Text('Compact'),
          Switch(
            value: _compact,
            onChanged: (v) => setState(() => _compact = v),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorView(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const [];
          if (list.isEmpty) return const EmptyView();
          return StudentList(list, compact: _compact);
        },
      ),
    );
  }
}
