import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/customer/presentation/screens/customer_home_shell.dart';
import '../features/technician/presentation/screens/technician_home_shell.dart';
import '../i18n/app_localizations.dart';
import '../stores/session/session_cubit.dart';
import '../stores/settings/settings_cubit.dart';
import '../utils/types/app_role.dart';
import 'app_theme.dart';

class GasisApp extends StatelessWidget {
  const GasisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GASIS',
          theme: AppTheme.lightTheme,
          locale: settingsState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _RootView(),
        );
      },
    );
  }
}

class _RootView extends StatelessWidget {
  const _RootView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionInitial || state is SessionLoading) {
          return const SplashScreen();
        }

        if (state is SessionAuthenticated) {
          return state.user.role == AppRole.customer
              ? const CustomerHomeShell()
              : const TechnicianHomeShell();
        }

        return OnboardingScreen(
          errorKey: state is SessionFailure ? state.messageKey : null,
        );
      },
    );
  }
}
