# Practice 09 — Put It High, Subscribe Low

A small book shop: a Books screen, a badge on the cart icon and a Cart screen, sharing one `Cart` through `provider`. The project targets Windows and web. Measurements and answers are in [NOTES.md](NOTES.md).

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
