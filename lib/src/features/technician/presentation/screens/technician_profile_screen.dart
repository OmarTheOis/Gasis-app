import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/profile_option_tile.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../stores/session/session_cubit.dart';
import '../../../customer/presentation/screens/edit_profile_screen.dart';
import '../../../customer/presentation/screens/language_screen.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SessionCubit>().state;
    final user = state is SessionAuthenticated ? state.user : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.tr('profile'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person, size: 48),
          ),
          const SizedBox(height: 14),
          Text(
            user?.fullName ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ProfileOptionTile(
            icon: Icons.edit_outlined,
            title: context.tr('editProfile'),
            onTap: () {
              Navigator.of(context).push(
                AppRouter.route(const EditProfileScreen()),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.language_outlined,
            title: context.tr('language'),
            onTap: () {
              Navigator.of(context).push(
                AppRouter.route(const LanguageScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.read<SessionCubit>().logout(),
            icon: const Icon(Icons.logout),
            label: Text(context.tr('logout')),
          ),
        ],
      ),
    );
  }
}
