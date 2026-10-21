import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/workshop.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.profile, required this.workshops, required this.onChanged, required this.themeMode, required this.onThemeChanged});
  final Profile profile;
  final List<Workshop> workshops;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();
  final _key = GlobalKey<FormState>();

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _group.dispose();
    _nameFocus.dispose(); _groupFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (_key.currentState?.validate() != true) return;
    widget.onChanged(widget.profile.copyWith(name: _name.text.trim(), group: _group.text.trim().toUpperCase()));
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final joined = widget.workshops.fold<int>(0, (total, item) => total + (widget.profile.name.isNotEmpty && item.contains(widget.profile.name) ? 1 : 0));
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Form(key: _key, autovalidateMode: AutovalidateMode.onUserInteraction, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CircleAvatar(radius: 36, child: Icon(Icons.person_outline, size: 36)),
      const SizedBox(height: 20),
      Text('Your maker profile', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text('You are on $joined lists', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
      const SizedBox(height: 12),
      const Text('Set your name before joining. Press Done or Save profile to keep your changes for this session.'),
      const SizedBox(height: 24),
      TextFormField(controller: _name, focusNode: _nameFocus, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.badge_outlined)), keyboardType: TextInputType.name, textInputAction: TextInputAction.next, validator: (value) => (value ?? '').trim().length < 2 ? 'Enter at least 2 characters' : null, onFieldSubmitted: (_) { _save(); _groupFocus.requestFocus(); }, onTapOutside: (_) => FocusScope.of(context).unfocus()),
      const SizedBox(height: 16),
      TextFormField(controller: _group, focusNode: _groupFocus, decoration: const InputDecoration(labelText: 'Group', hintText: 'KBTU-24', prefixIcon: Icon(Icons.groups_outlined)), textCapitalization: TextCapitalization.characters, keyboardType: TextInputType.text, textInputAction: TextInputAction.done, validator: (value) => RegExp(r'^[A-Za-z]{2,8}-\d{2,4}$').hasMatch((value ?? '').trim()) ? null : 'Use 2–8 letters, a dash and 2–4 digits', onFieldSubmitted: (_) => _save(), onTapOutside: (_) => FocusScope.of(context).unfocus()),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save profile')),
      const SizedBox(height: 32),
      Text('Make yourself comfortable', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final mode in ThemeMode.values)
          ChoiceChip(label: Text(switch (mode) {ThemeMode.system => 'System', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark'}), selected: widget.themeMode == mode, onSelected: (_) => widget.onThemeChanged(mode)),
      ]),
      const SizedBox(height: 24),
      Text('A little space to learn together.\nYour profile and registrations reset when the app restarts.', style: theme.textTheme.bodySmall),
    ])))));
  }
}
