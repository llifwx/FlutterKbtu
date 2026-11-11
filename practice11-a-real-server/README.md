# Practice 11: A Real Server

Ten users from `jsonplaceholder.typicode.com`. The flow is repository → `ChangeNotifier` → screen, and the screen switches on a sealed `ApiException`. Only `api_client.dart` and `user_repository.dart` know `package:http`. Observations are in [NOTES.md](NOTES.md).

```
lib/
  core/api/        api_client.dart, api_exception.dart
  features/users/  user.dart, user_repository.dart, users_model.dart,
                   users_screen.dart, new_user_screen.dart
  main.dart        composition root
```

```powershell
flutter pub get
flutter run                                   # Android, Windows or Chrome
flutter run -d windows --dart-define=CHECKS=true   # Level 2–3 prints before runApp
```

## Verification

```powershell
dart format .
flutter analyze
flutter test                                  # includes live network tests
flutter test --exclude-tags live              # offline only
```
