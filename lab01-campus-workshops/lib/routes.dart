import 'package:flutter/material.dart';
import 'models/profile.dart';
import 'models/workshop.dart';
import 'screens/detail_screen.dart';
import 'screens/workshop_form.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/workshop';
  static const form = '/workshop/form';

  static Route<dynamic>? generate(RouteSettings settings) => switch ((settings.name, settings.arguments)) {
    (detail, DetailArguments args) => MaterialPageRoute<void>(settings: settings, builder: (_) => DetailScreen(arguments: args)),
    (form, FormArguments args) => MaterialPageRoute<Workshop>(settings: settings, builder: (_) => WorkshopForm(initial: args.workshop)),
    _ => null,
  };

  static Route<void> unknown(RouteSettings settings) => MaterialPageRoute<void>(settings: settings, builder: (_) => Scaffold(appBar: AppBar(title: const Text('Not found')), body: const Center(child: Text('Not found'))));
}

class DetailArguments {
  const DetailArguments({required this.workshop, required this.profile, required this.onChanged, required this.onDelete, required this.onProfile});
  final Workshop workshop;
  final Profile profile;
  final ValueChanged<Workshop> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onProfile;
}

class FormArguments {
  const FormArguments({this.workshop});
  final Workshop? workshop;
}
