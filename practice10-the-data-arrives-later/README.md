# Practice 10 — The Data Arrives Later

A Students screen built around a fake API that waits 2 seconds and fails every third call. It is built two ways (by hand and with `FutureBuilder`), plus a countdown and a Save button that does not lose its errors. The project targets Windows and web. Observations are in [NOTES.md](NOTES.md).

```powershell
flutter pub get
flutter run -d windows   # or: flutter run -d chrome
```

## Verification

```powershell
dart format .
flutter analyze
flutter test
```

To regenerate the screenshots on Windows:

```powershell
flutter test test/screenshots_test.dart --update-goldens
```
