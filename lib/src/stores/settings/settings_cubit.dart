import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/preferences_service.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required PreferencesService preferencesService,
    required String initialLocaleCode,
  })  : _preferencesService = preferencesService,
        super(SettingsState(locale: Locale(initialLocaleCode)));

  final PreferencesService _preferencesService;

  Future<void> changeLocale(String localeCode) async {
    final normalized = localeCode == 'ar' ? 'ar' : 'en';
    await _preferencesService.saveLocaleCode(normalized);
    emit(SettingsState(locale: Locale(normalized)));
  }
}

class SettingsState {
  const SettingsState({
    required this.locale,
  });

  final Locale locale;
}
