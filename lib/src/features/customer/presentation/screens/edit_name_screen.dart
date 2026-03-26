import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../stores/session/session_cubit.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../stores/profile/profile_cubit.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    final session = context.read<SessionCubit>().state;
    if (session is SessionAuthenticated) {
      _firstNameController.text = session.user.firstName;
      _lastNameController.text = session.user.lastName;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
          }

          if (state is ProfileSuccess) {
            await context.read<SessionCubit>().restoreSession();

            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isBusy = state is ProfileSubmitting;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('editName')),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _firstNameController,
                        labelText: context.tr('firstName'),
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'firstNameRequired',
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _lastNameController,
                        labelText: context.tr('lastName'),
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'lastNameRequired',
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: context.tr('saveChanges'),
                        isBusy: isBusy,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          context.read<ProfileCubit>().updateName(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
