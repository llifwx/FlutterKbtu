import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final tiles = [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(name),
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Group'),
                  subtitle: Text(group),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Date of birth'),
                  subtitle: Text(birthDate),
                ),
              ];
              return constraints.maxWidth >= 600
                  ? GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: tiles,
                    )
                  : Column(children: tiles);
            },
          ),
        ],
      ),
    ),
  );
}
