# Practice 12: Survive a Restart

This is the Practice 11 users app, and it now survives a restart, the metro and a user who says No:
- settings in `shared_preferences`, read before `runApp`;
- a fake-login token in `flutter_secure_storage`, sent as `Authorization: Bearer …` by `ApiClient`;
- the last good list in `Documents/users.json`, shown with a "Saved data" banner when offline;
- a profile photo with the full permission flow;
- `mailto:` / `tel:` / `https:` links.

Notes and package verdicts are in [NOTES.md](NOTES.md).

```
lib/
  core/api/          api_client.dart, api_exception.dart
  core/storage/      secure_store.dart
  features/auth/     auth_model.dart, login_screen.dart
  features/settings/ settings_model.dart, settings_screen.dart
  features/profile/  profile_screen.dart
  features/users/    user.dart, user_repository.dart, users_cache.dart,
                     users_model.dart, users_screen.dart, new_user_screen.dart
  main.dart          composition root
```

```powershell
flutter pub get
flutter run            # Android or Windows (Windows needs Developer Mode for plugins)
```

## Verification

```powershell
dart format .
flutter analyze
flutter test                                       # includes live network tests
flutter test --exclude-tags live                   # offline only
flutter test test/screenshots_test.dart --update-goldens   # regenerate screenshots (Windows)
```
