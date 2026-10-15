import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;
  bool _confirming = false;

  bool get _dirty => _name != widget.student.name;

  Future<void> _onPopInvoked(bool didPop, String? result) async {
    if (didPop || _confirming) return;
    _confirming = true;
    final context = this.context;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes to the name have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    _confirming = false;

    // Explicit pop completes the confirmed action; user Back uses maybePop.
    if (discard == true) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit student')),
      body: PopScope<String>(
        canPop: !_dirty,
        onPopInvokedWithResult: _onPopInvoked,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Current name: ${widget.student.name}'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'New name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) => setState(() => _name = value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  // Save intentionally pops with a result, bypassing Back.
                  onPressed: () => Navigator.of(context).pop(_name),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
