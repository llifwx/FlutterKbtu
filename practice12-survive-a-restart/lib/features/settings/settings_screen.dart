import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final city = s.city;
    final cities = {
      for (final u in context.watch<UsersModel>().items) u.address.city,
      // The saved city stays selectable even before the list has loaded.
      ?city,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: s.setDark,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: city,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem(child: Text('All cities')),
                for (final c in cities)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: s.setCity,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              context.read<AuthModel>().logout();
            },
          ),
        ],
      ),
    );
  }
}
