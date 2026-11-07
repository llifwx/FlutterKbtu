import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Not awaited: initState is synchronous; _load handles its own errors.
    _load();
  }

  Future<void> _load() async {
    // From initState both fields are already null, and setState is not
    // allowed there yet; only Retry needs the reset.
    if (_students != null || _error != null) {
      setState(() {
        _students = null;
        _error = null;
      });
    }
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _error == null && _students != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students — by hand'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (_students) {
        _ when _error != null => ErrorView(onRetry: _load),
        null => const LoadingView(),
        final list when list.isEmpty => const EmptyView(),
        final list => StudentList(list),
      },
      floatingActionButton: ready
          ? FloatingActionButton(
              tooltip: 'Save',
              onPressed: _saving ? null : () => _save(context),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            )
          : null,
    );
  }
}
