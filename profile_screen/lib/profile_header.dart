import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Image.asset(
          'assets/images/profile.jpg',
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: textTheme.headlineSmall?.copyWith(fontFamily: 'MyFont'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          university,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
