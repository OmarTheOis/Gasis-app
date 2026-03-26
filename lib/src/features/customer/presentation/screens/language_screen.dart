import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../i18n/app_localizations.dart';
import '../../../../stores/settings/settings_cubit.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCode =
        context.watch<SettingsCubit>().state.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('language')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _LanguageTile(
            title: context.tr('english'),
            code: 'en',
            selected: selectedCode == 'en',
          ),
          _LanguageTile(
            title: context.tr('arabic'),
            code: 'ar',
            selected: selectedCode == 'ar',
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.code,
    required this.selected,
  });

  final String title;
  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        trailing: selected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () async {
          await context.read<SettingsCubit>().changeLocale(code);

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('languageSaved'))),
          );
        },
      ),
    );
  }
}
