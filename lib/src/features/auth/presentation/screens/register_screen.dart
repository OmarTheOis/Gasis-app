import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../stores/session/session_cubit.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../../../utils/types/app_role.dart';
import '../../stores/register/register_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AppRole _selectedRole = AppRole.customer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) async {
          if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
          }

          if (state is RegisterSuccess) {
            await context.read<SessionCubit>().restoreSession();

            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('registeredSuccessfully'))),
            );

            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;
          final theme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('register')),
              backgroundColor: theme.primary,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('createAccount'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<AppRole>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: context.tr('accountType'),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: AppRole.customer,
                            child: Text(context.tr('customer')),
                          ),
                          DropdownMenuItem(
                            value: AppRole.technician,
                            child: Text(context.tr('technician')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        labelText: context.tr('email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => FormValidators.email(context, value),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        labelText: context.tr('password'),
                        obscureText: _obscurePassword,
                        validator: (value) =>
                            FormValidators.strongPassword(context, value),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmPasswordController,
                        labelText: context.tr('confirmPassword'),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) => FormValidators.confirmPassword(
                          context,
                          value,
                          _passwordController.text,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: context.tr('register'),
                        isBusy: isLoading,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          context.read<RegisterCubit>().register(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                role: _selectedRole,
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
