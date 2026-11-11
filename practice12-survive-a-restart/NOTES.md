# Notes: Survive a Restart

This continues Practice 11 (the users app from `jsonplaceholder.typicode.com`). The pub.dev numbers were read from the pub.dev API on 2026-11-11, and the GitHub numbers from the GitHub API on the same day. Everything marked "test" comes from `flutter test` on Windows.

## Level 1: six packages in two minutes

Order: publisher → last release → platforms → pub points → issues vs. commits → dependencies → licence.

| Package | Verdict |
|---|---|
| `shared_preferences` 2.5.6 | Verified publisher flutter.dev (Flutter Favorite), released Oct 2026, all six platforms, 160/160 points, 16 open issues on flutter/flutter against commits to flutter/packages today, depends only on its own per-platform plugins, BSD-3. |
| `flutter_secure_storage` 11.2.0 | Verified publisher steenbakker.dev (the community maintainer, not Google), released Sep 2026, all six platforms, 160/160 points, 24 open issues+PRs with a push today, depends only on its own per-platform plugins plus `meta`, BSD-3. **The one to watch:** a single maintainer looks after the place where the token lives. |
| `path_provider` 2.1.6 | Verified publisher flutter.dev (Flutter Favorite), released Jun 2026, five platforms (no web, because a browser has no Documents folder), 160/160 points, 22 open issues with commits today, only its own per-platform plugins, BSD-3. |
| `image_picker` 1.2.4 | Verified publisher flutter.dev, released Oct 2026, all six platforms (desktop has no camera without a delegate), 160/160 points, 86 open issues (the most of the six) with commits today, only its own per-platform plugins, Apache-2.0 + BSD-3. |
| `permission_handler` 13.0.2 | Verified publisher baseflow.com (a company), released Sep 2026, four platforms (Android, iOS, Windows, web; no macOS or Linux), 160/160 points, 155 open issues+PRs against a push on 2026-11-06, depends on its own platform packages plus `meta`, MIT. It needs extra setup: iOS Podfile macros (see `ios/Podfile`). |
| `url_launcher` 6.3.3 | Verified publisher flutter.dev (Flutter Favorite), released Oct 2026, all six platforms, 160/160 points, 34 open issues with commits today, only its own per-platform plugins, BSD-3. |

All six were added with one `flutter pub add …` command. Pub wrote carets on all of them: `shared_preferences: ^2.5.6`, `flutter_secure_storage: ^11.2.0`, `path_provider: ^2.1.6`, `image_picker: ^1.2.4`, `permission_handler: ^13.0.2`, `url_launcher: ^6.3.3`.

**`http` in `pubspec.lock`:** `version: "1.6.0"` (the constraint is `^1.6.0`).

**What `^1.2.0` means:** `>=1.2.0 <2.0.0`. It accepts 1.2.0, 1.2.1, 1.6.0 and 1.99.0. It refuses 1.1.x (too old) and 2.0.0 (a major version can break the API). The caret trusts semantic versioning inside one major version.

**Why `pubspec.lock` is committed for an app:** the caret is a range, and the lock is the exact answer pub chose inside it. With the lock committed, a teammate, CI and the build for the store all get the same `http 1.6.0` byte-for-byte (the sha256 is in the lock). Without it, "works on my machine" comes back the day a new patch version is published. A *library* does not commit it, because its users resolve their own versions.

**`flutter pub outdated`:** `cupertino_icons` is on 1.0.9 while 2.0.0 is out. The constraint `^1.0.8` refuses a new major version, so it would take `flutter pub upgrade --major-versions` (and reading the changelog). Seven transitive packages (for example `shared_preferences_foundation` 2.5.7 → 2.6.1) are "upgradable". They fit the carets, but the lock keeps them where they were until someone runs `flutter pub upgrade` on purpose.

**Break it: `http: 1.2.0` without the caret.** This did not just pin 1.2.0. `flutter pub get` **failed**:

```
permission_handler ^13.0.2 is incompatible with http >=1.1.2 <1.2.1.
So, because users_api depends on both http 1.2.0 and permission_handler ^13.0.2, version solving failed.
```

`http 1.2.0` needs `web <0.5.0`, while `permission_handler_html` needs `web >=0.5.1`. An exact pin removes the room pub uses to satisfy everyone. The caret was put back, and `pubspec.lock` is byte-identical to before.

## Level 2: settings before the first frame

`main()`: `ensureInitialized()` → `SharedPreferencesAsync` reads `darkMode ?? false`, `cityFilter` (a `String?`) and `avatarPath` (a `String?`) → `runApp`. `SettingsModel.setDark` calls `notifyListeners()` first and then awaits `setBool`. `setCity(null)` calls `remove('cityFilter')`.

| Check | Result |
|---|---|
| Dark on, city picked, kill, reopen: dark from the first frame, filter applied | _TODO on a device_ |
| Break it: read `getBool` later in `SettingsModel`: one light frame | _TODO on a device_ |

## Level 3: the token

`SecureStore` wraps `const FlutterSecureStorage()`. `ApiClient(Client(), store)` builds `Authorization: Bearer …` itself:

```dart
if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
```

The test "the token becomes a header only when there is one" sees the header go `null` → `Bearer tok_42` (after `saveToken`) → `null` (after `clear()`). The repository and the screens never touch the header. The token is never printed. The debug-only "Copy token to clipboard" tile is the only way to see it.

**Where `prefs.setString('token', …)` would have put it:**
- Android: a plain file in the app's private folder. With `SharedPreferencesAsync` that is the DataStore file `/data/data/<package>/files/datastore/FlutterSharedPreferences.preferences_pb`; the legacy API used `shared_prefs/FlutterSharedPreferences.xml`.
- iOS: `Library/Preferences/<bundle id>.plist`.
- Windows: a JSON file in `%APPDATA%`.

It is plain text, so anyone who gets the file can read it:
- a device backup (`adb backup` / Auto Backup to the cloud, an unencrypted iTunes/Finder backup);
- anyone with root or a jailbreak;
- anyone with a cable and a debuggable build (`adb shell run-as <package> cat …`).

With the token, they *are* the user.

**The two platform surprises:**
- **iOS:** Keychain items are **not deleted when the app is uninstalled**. After a reinstall the old token is still there, and the app opens already signed in. The usual fix is a "first run" flag in `shared_preferences`, which *is* wiped on uninstall: if the flag is missing, clear the Keychain.
- **Android:** the token is encrypted with a key from the Android Keystore. If the user **removes or changes the lock screen**, the OS may invalidate that key. The stored value can then no longer be decrypted, and the read throws or returns nothing. The app must treat that as "signed out", never crash.

## Level 4: the offline list

`UsersCache` writes `users.json` in `getApplicationDocumentsDirectory()`. `getAll()` returns `({List<User> items, bool fromCache})`. On `NoConnectionException` it returns the saved list, or `rethrow`s when there is none.

| Check | Result |
|---|---|
| Offline with nothing saved: `NoConnectionException`, the Offline screen, not an empty list | test: "offline with nothing saved" ✔ |
| One good load, then offline: the same users, `fromCache: true`, banner | test: "offline after one good load" ✔, `screenshot_offline_banner.png` |
| Airplane mode, kill, reopen: list instantly with banner; Retry keeps both; online Retry removes the banner | _TODO on a device_ |
| Break it: `getTemporaryDirectory()` + Clear cache: list gone, no error | _TODO on the Android emulator_ |

On Windows, "Documents" is the user's real `C:\Users\<name>\Documents`, so `users.json` and `avatar.jpg` show up there. On Android/iOS it is the app's private folder.

## Level 5: a photo and a No

Declared:
- `CAMERA` in `AndroidManifest.xml`, plus a `<queries>` block for `https` (VIEW), `mailto` (SENDTO) and `tel` (DIAL);
- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`;
- `PERMISSION_CAMERA=1` in `ios/Podfile`.

"Take photo" calls `Permission.camera.request()` at the tap. The `switch` covers all six `PermissionStatus` values:
- `granted` / `limited` / `provisional` → pick;
- `denied` → a SnackBar;
- `restricted` → a SnackBar;
- `permanentlyDenied` → our dialog → `openAppSettings()` (`screenshot_permission_dialog.png`).

`pickImage` returning `null` (Cancel) just returns. The picked file is saved as `Documents/avatar.jpg`, and the path is kept under `avatarPath` in prefs.

**Android sequence (Android 11+):** No → `denied` (SnackBar). No again → `permanentlyDenied`. The third tap shows no system dialog, only ours at once. _TODO: confirm on the emulator._

**iOS sequence:** iOS asks **once**. The first "Don't Allow" is already final, so `request()` returns `permanentlyDenied` on the very next tap. One No, not two. The fourth Photos state is **Limited** (`PHAuthorizationStatusLimited`, "Selected Photos", iOS 14+), which `permission_handler` reports as `PermissionStatus.limited`.

**Break it: `launchUrl(Uri.parse('kbtu.edu.kz'))`** has no scheme, so it is just a relative path. _TODO: confirm the `false` → "No app can open this" on a device._ With `https://` the browser opens.
