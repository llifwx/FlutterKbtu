import 'dart:async';
import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../models/workshop.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});
  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Workshop _workshop;
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _workshop = widget.arguments.workshop;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(Workshop item) {
    setState(() => _workshop = item);
    widget.arguments.onChanged(item);
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).pushNamed<Workshop>(Routes.form, arguments: FormArguments(workshop: _workshop));
    if (!mounted || changed == null) return;
    _update(changed);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete workshop?'), content: Text('Remove “${_workshop.title}” and its registrations?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
    if (!mounted || confirmed != true) return;
    widget.arguments.onDelete();
    Navigator.pop(context);
  }

  Future<void> _joinOrLeave() async {
    final name = widget.arguments.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Add your name to your profile first.'), action: SnackBarAction(label: 'Profile', onPressed: widget.arguments.onProfile)));
      return;
    }
    final joined = _workshop.contains(name);
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(joined ? 'Leave this workshop?' : 'Join this workshop?'), content: Text(joined ? 'Your place will be available to another maker.' : 'Reserve one place for $name?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(joined ? 'Leave' : 'Join'))]));
    if (!mounted || confirmed != true) return;
    _update(_workshop.copyWith(attendees: joined ? _workshop.attendees.where((entry) => entry != name).toList() : [..._workshop.attendees, name]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = _workshop.places;
    final joined = _workshop.contains(widget.arguments.profile.name);
    final started = !_workshop.startsAt.isAfter(_now);
    Widget pill(String text) => DecoratedBox(decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(text, style: theme.textTheme.labelMedium)));
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(title: const Text('Workshop'), actions: [PopupMenuButton<String>(tooltip: 'Workshop actions', onSelected: (action) { if (action == 'edit') { _edit(); } else { _delete(); } }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))])]),
      body: SafeArea(child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          AspectRatio(aspectRatio: 3.8, child: Image.asset('assets/atelier.png', fit: BoxFit.cover, excludeFromSemantics: true)),
          CircleAvatar(radius: 28, backgroundColor: theme.colorScheme.surface, child: Icon(_workshop.category.icon, size: 32)),
          Positioned(top: 12, left: 12, child: pill(_workshop.category.label)),
          Positioned(bottom: 12, right: 12, child: pill(countdownLabel(Countdown.at(_workshop.startsAt, _now)))),
        ]),
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Align(alignment: Alignment.centerLeft, child: Text(_workshop.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleLarge))),
        TabBar(tabs: [const Tab(text: 'About'), Tab(text: 'Makers ($taken)')]),
        Expanded(child: TabBarView(children: [
          ListView(padding: const EdgeInsets.all(20), children: [
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_month_outlined), title: Text(formatDateTime(_workshop.startsAt)), subtitle: Text(started ? 'This workshop has started' : 'See you at the studio')),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(_workshop.online ? Icons.link : Icons.place_outlined), title: Text(_workshop.location), subtitle: Text(_workshop.online ? 'Online workshop link' : 'On campus')),
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.groups_outlined), title: Text('$taken of ${_workshop.capacity} places taken'), subtitle: Text('$free free places')),
            if (_workshop.description case final description?) ...[
              const SizedBox(height: 16),
              Text('What we will make', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description),
            ],
          ]),
          _workshop.attendees.isEmpty ? const EmptyState(icon: Icons.groups_outlined, message: 'Nobody on the list yet. Be the first maker here.') : ListView(children: [for (final name in _workshop.attendees) ListTile(selected: name == widget.arguments.profile.name, leading: const Icon(Icons.person_outline), title: Text(name), trailing: name == widget.arguments.profile.name ? const Chip(label: Text('You')) : null)]),
        ])),
      ])),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 16), child: FilledButton.icon(onPressed: joined || (!_workshop.isFull && !started) ? _joinOrLeave : null, icon: Icon(joined ? Icons.logout : Icons.add_task), label: Text(joined ? 'Leave workshop' : started ? 'Workshop started' : _workshop.isFull ? 'Workshop full' : 'Join workshop')))),
    ));
  }
}
