import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../stores/profile/profile_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController     = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
          }

          if (state is ProfileSuccess) {
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
              title: Text(context.tr('changePassword')),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _currentPasswordController,
                        labelText: context.tr('currentPassword'),
                        obscureText: !_showCurrent,
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'currentPasswordRequired',
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showCurrent = !_showCurrent;
                            });
                          },
                          icon: Icon(
                            _showCurrent
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _newPasswordController,
                        labelText: context.tr('newPassword'),
                        obscureText: !_showNew,
                        validator: (value) =>
                            FormValidators.strongPassword(context, value),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showNew = !_showNew;
                            });
                          },
                          icon: Icon(
                            _showNew
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmPasswordController,
                        labelText: context.tr('confirmPassword'),
                        obscureText: !_showConfirm,
                        validator: (value) => FormValidators.confirmPassword(
                          context,
                          value,
                          _newPasswordController.text,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showConfirm = !_showConfirm;
                            });
                          },
                          icon: Icon(
                            _showConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
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

                          context.read<ProfileCubit>().changePassword(
                                currentPassword: _currentPasswordController.text,
                                newPassword: _newPasswordController.text,
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
