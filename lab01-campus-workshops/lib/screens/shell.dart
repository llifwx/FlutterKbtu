import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/workshop.dart';
import '../routes.dart';
import 'profile_tab.dart';
import 'workshop_list.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Workshop> _workshops = seedWorkshops();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  void _update(Workshop changed) => setState(() {
    _workshops = [
      for (final item in _workshops)
        if (item.id == changed.id) changed else item,
    ];
  });

  void _open(Workshop item) => Navigator.of(context).pushNamed<void>(
    Routes.detail,
    arguments: DetailArguments(
      workshop: item,
      profile: _profile,
      onChanged: _update,
      onDelete: () => setState(
        () => _workshops = _workshops
            .where((entry) => entry.id != item.id)
            .toList(),
      ),
      onProfile: () => _selectTab(2),
    ),
  );

  Future<void> _create() async {
    final result = await Navigator.of(context)
        .pushNamed<Workshop>(Routes.form, arguments: const FormArguments());
    if (!mounted || result == null) return;
    setState(() => _workshops = [..._workshops, result]);
  }

  Future<void> _reset() async {
    Navigator.pop(context);
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'Restore the twelve workshops and clear your profile. All changes in this session will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted || reset != true) return;
    setState(() {
      _workshops = seedWorkshops();
      _profile = const Profile.empty();
    });
  }

  void _about() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campus Atelier'),
        content: const Text(
          'A space for curious makers. Discover campus workshops, save your favourites and make something together.\n\nLab 01 · Flutter · All data stays in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('CAMPUS ATELIER'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.auto_awesome_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'A place to\nmake & meet.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: _about,
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restart_alt),
              onTap: _reset,
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          WorkshopList(
            workshops: _workshops,
            favouritesOnly: false,
            onOpen: _open,
            onFavourite: (item) =>
                _update(item.copyWith(favourite: !item.favourite)),
            onExplore: () => _selectTab(0),
          ),
          WorkshopList(
            workshops: _workshops,
            favouritesOnly: true,
            onOpen: _open,
            onFavourite: (item) =>
                _update(item.copyWith(favourite: !item.favourite)),
            onExplore: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            workshops: _workshops,
            onChanged: (profile) => setState(() => _profile = profile),
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
    ),
    floatingActionButton: _tab == 2
        ? null
        : FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.add),
            label: const Text('Workshop'),
          ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _selectTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
