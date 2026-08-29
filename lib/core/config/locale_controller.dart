import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app locale (English / Kiswahili) and persists the choice.
/// Provided at the root; `MaterialApp.locale` watches it, so switching in the
/// Profile screen re-renders the whole app instantly.
class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs)
      : _locale = Locale(_prefs.getString(_key) ?? 'en');

  static const _key = 'app_locale';
  static const supported = [Locale('en'), Locale('sw')];

  final SharedPreferences _prefs;
  Locale _locale;

  Locale get locale => _locale;
  bool get isSwahili => _locale.languageCode == 'sw';

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    await _prefs.setString(_key, languageCode);
  }
}
