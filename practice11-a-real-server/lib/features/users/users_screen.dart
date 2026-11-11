import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    if (m.loading && m.items.isEmpty) return const LoadingView();
    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => MessageView(
        icon: Icons.wifi_off,
        text: 'No connection',
        onRetry: m.load,
      ),
      NotFoundException() || UnauthorizedException() => const MessageView(
        icon: Icons.block,
        text: 'Not available',
      ),
      ServerException(:final status) => MessageView(
        icon: Icons.dns,
        text: 'Server error $status',
        onRetry: m.load,
      ),
      BadResponseException() => const MessageView(
        icon: Icons.bug_report,
        text: 'Something went wrong on our side',
      ),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.text,
    this.onRetry,
  });

  final IconData icon;
  final String text;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(text),
          if (retry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<UsersModel>().load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.name[0])),
            title: Text(u.name),
            subtitle: Text('${u.email} · ${u.address.city}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            ),
          );
        },
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final a = u.address;
    final website = u.website;
    return Scaffold(
      appBar: AppBar(title: Text(u.name)),
      body: ListView(
        children: [
          ListTile(title: const Text('Username'), subtitle: Text(u.username)),
          ListTile(title: const Text('Email'), subtitle: Text(u.email)),
          // Practice 12 gives these two url_launcher.
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(u.phone),
            subtitle: Text(u.phoneDigits),
            onTap: () {},
          ),
          if (website != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(website),
              onTap: () {},
            ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text(
              '${a.city} ${a.zipcode}\n${a.geo.lat}, ${a.geo.lng}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(u.company.name),
            subtitle: Text(u.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}
