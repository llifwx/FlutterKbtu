import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/auth/auth_model.dart';
import 'package:users_api/features/profile/profile_screen.dart';
import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/main.dart';

Future<ByteData> _windowsFont(String file) async =>
    ByteData.sublistView(await File('C:/Windows/Fonts/$file').readAsBytes());

// Run with --update-goldens to regenerate the submission screenshots.
void main() {
  const capture = ValueKey('capture');

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({'token': 'tok_1'});
  });

  Future<void> setUpView(WidgetTester t) async {
    await t.runAsync(() async {
      await (FontLoader('Segoe UI')
            ..addFont(_windowsFont('segoeui.ttf'))
            ..addFont(_windowsFont('segoeuib.ttf')))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    // A touch screen: no keyboard focus ring on the FAB.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    debugDisableShadows = false; // real shadows, not test outlines
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(390, 844);
    addTearDown(t.view.reset);
  }

  testWidgets('offline banner over the saved list', (t) async {
    await setUpView(t);
    final tmp = Directory.systemTemp.createTempSync('shot');
    addTearDown(() => tmp.deleteSync(recursive: true));
    // Yesterday's good answer, saved where the app saves it.
    File('${tmp.path}/users.json')
        .writeAsBytesSync(File('test/users_fixture.json').readAsBytesSync());
    final users = UsersModel(
      UserRepository(
        ApiClient(
          MockClient((_) => throw const SocketException('airplane mode')),
          const SecureStore(),
        ),
        UsersCache(() async => tmp),
      ),
    );
    await t.runAsync(users.load);
    expect(users.fromCache, isTrue);

    await t.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  SettingsModel(SharedPreferencesAsync(), dark: false),
            ),
            ChangeNotifierProvider(
              create: (_) => AuthModel(const SecureStore(), token: 'tok_1'),
            ),
            ChangeNotifierProvider.value(value: users),
          ],
          child: const App(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Saved data · no connection'), findsOneWidget);
    await expectLater(
      find.byKey(capture),
      matchesGoldenFile('../screenshot_offline_banner.png'),
    );
    debugDefaultTargetPlatformOverride = null;
    debugDisableShadows = true;
  }, skip: !Platform.isWindows);

  testWidgets('our dialog for permanentlyDenied', (t) async {
    await setUpView(t);
    await t.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: ChangeNotifierProvider(
          create: (_) => SettingsModel(SharedPreferencesAsync(), dark: false),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(colorSchemeSeed: Colors.teal),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    // What the third "Take photo" tap shows once the OS stops asking.
    unawaited(showCameraSettingsDialog(t.element(find.byType(ProfileScreen))));
    await t.pumpAndSettle();
    expect(find.text('Open settings'), findsOneWidget);
    await expectLater(
      find.byKey(capture),
      matchesGoldenFile('../screenshot_permission_dialog.png'),
    );
    debugDefaultTargetPlatformOverride = null;
    debugDisableShadows = true;
  }, skip: !Platform.isWindows);
}
