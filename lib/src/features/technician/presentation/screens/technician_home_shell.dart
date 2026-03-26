import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../shared/notifications/notifications_screen.dart';
import '../../stores/jobs/technician_jobs_cubit.dart';
import 'technician_dashboard_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianHomeShell extends StatefulWidget {
  const TechnicianHomeShell({super.key});

  @override
  State<TechnicianHomeShell> createState() => _TechnicianHomeShellState();
}

class _TechnicianHomeShellState extends State<TechnicianHomeShell> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => TechnicianJobsCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      )..load(),
      child: Builder(
        builder: (context) {
          final pages = [
            const NotificationsScreen(),
            const TechnicianDashboardScreen(),
            const TechnicianProfileScreen(),
          ];

          return Scaffold(
            body: SafeArea(child: pages[_selectedIndex]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              indicatorColor: theme.primary.withOpacity(0.12),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.notifications_outlined),
                  label: context.tr('notifications'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  label: context.tr('home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  label: context.tr('profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
