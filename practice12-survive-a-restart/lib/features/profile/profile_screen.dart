import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _say(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return; // Cancel is an answer, not an error
    final path =
        '${(await getApplicationDocumentsDirectory()).path}/avatar.jpg';
    await file.saveTo(path);
    await FileImage(File(path)).evict(); // same path, new picture
    if (!context.mounted) return;
    await context.read<SettingsModel>().setAvatar(path);
  }

  // Asked at the tap, never in initState: the user knows why.
  Future<void> _takePhoto(BuildContext context) async {
    if (!ImagePicker().supportsImageSource(ImageSource.camera)) {
      _say(context, 'This device has no camera. Choose a photo instead.');
      return;
    }
    final status = await Permission.camera.request();
    if (!context.mounted) return;
    switch (status) {
      case PermissionStatus.granted || PermissionStatus.limited:
        await _pick(context, ImageSource.camera);
      case PermissionStatus.denied:
        _say(context, 'Without the camera you can still choose a photo.');
      case PermissionStatus.restricted:
        _say(context, 'The camera is blocked on this device.');
      case PermissionStatus.permanentlyDenied:
        await showCameraSettingsDialog(context);
      case PermissionStatus.provisional:
        await _pick(context, ImageSource.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<SettingsModel>().avatar;
    final hasPhoto = avatar != null && File(avatar).existsSync();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              foregroundImage: hasPhoto ? FileImage(File(avatar)) : null,
              child: const Text('A', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _takePhoto(context),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The OS will not ask again; only the user can change it, in Settings.
Future<void> showCameraSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.no_photography),
      title: const Text('Camera is off for this app'),
      content: const Text(
        'You said No to the camera earlier, so the system will not ask again. '
        'Turn it on in Settings → Permissions → Camera, or choose a photo '
        'from the gallery instead.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('Open settings'),
        ),
      ],
    ),
  );
}
