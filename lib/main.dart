import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'src/app/app.dart';
import 'src/services/auth_service.dart';
import 'src/services/firestore_service.dart';
import 'src/services/location_service.dart';
import 'src/services/preferences_service.dart';
import 'src/stores/session/session_cubit.dart';
import 'src/stores/settings/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final preferencesService = PreferencesService();
  final initialLocaleCode = await preferencesService.getSavedLocaleCode();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PreferencesService>.value(
          value: preferencesService,
        ),
        RepositoryProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        RepositoryProvider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        RepositoryProvider<LocationService>(
          create: (_) => LocationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(
              preferencesService: preferencesService,
              initialLocaleCode: initialLocaleCode,
            ),
          ),
          BlocProvider<SessionCubit>(
            create: (context) => SessionCubit(
              authService: context.read<AuthService>(),
              firestoreService: context.read<FirestoreService>(),
            )..restoreSession(),
          ),
        ],
        child: const GasisApp(),
      ),
    ),
  );
}
