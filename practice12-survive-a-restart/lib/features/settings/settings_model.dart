import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this.dark, this.city, this.avatar});

  final SharedPreferencesAsync _prefs;

  bool dark;
  String? city;
  String? avatar; // path of avatar.jpg in Documents

  // The screen changes first; the disk catches up.
  Future<void> setDark(bool v) async {
    dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  Future<void> setAvatar(String path) async {
    avatar = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}
