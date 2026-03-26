import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._localizedValues);

  final Locale locale;
  final Map<String, String> _localizedValues;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    assert(
      localization != null,
      'AppLocalizations was not found in the widget tree.',
    );

    return localization!;
  }

  String tr(
    String key, {
    Map<String, String> params = const {},
  }) {
    var value = _localizedValues[key] ?? key;

    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }

    return value;
  }

  bool get isArabic => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final normalizedCode = isSupported(locale) ? locale.languageCode : 'en';
    final jsonString = await rootBundle.loadString(
      'lib/src/i18n/$normalizedCode.json',
    );
    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    final values = decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return AppLocalizations(
      Locale(normalizedCode),
      values,
    );
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(
    String key, {
    Map<String, String> params = const {},
  }) {
    return l10n.tr(key, params: params);
  }
}
