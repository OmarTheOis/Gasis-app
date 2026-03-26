import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../components/profile_option_tile.dart';
import '../../../../i18n/app_localizations.dart';
import 'change_password_screen.dart';
import 'edit_name_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('editProfile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProfileOptionTile(
            icon: Icons.person_outline,
            title: context.tr('editName'),
            onTap: () {
              Navigator.of(context).push(
                AppRouter.route(const EditNameScreen()),
              );
            },
          ),
          ProfileOptionTile(
            icon: Icons.lock_outline,
            title: context.tr('changePassword'),
            onTap: () {
              Navigator.of(context).push(
                AppRouter.route(const ChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
