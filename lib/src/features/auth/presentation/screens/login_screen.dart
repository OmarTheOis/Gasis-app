import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../stores/session/session_cubit.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../../../utils/types/app_role.dart';
import '../../stores/login/login_cubit.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AppRole _selectedRole = AppRole.customer;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _messageText(BuildContext context, LoginFailure state) {
    if (state.parameterKey == null) {
      return context.tr(state.messageKey);
    }

    return context.tr(
      state.messageKey,
      params: {
        'portal': context.tr(state.parameterKey!),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_messageText(context, state)),
              ),
            );
          }

          if (state is LoginSuccess) {
            await context.read<SessionCubit>().restoreSession();

            if (!mounted) {
              return;
            }

            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          final theme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('login')),
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
                      const SizedBox(height: 12),
                      Center(
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          child: const Icon(
                            Icons.local_fire_department,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('signInToPortal'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('portalRoleHint'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _RoleSelector(
                        selectedRole: _selectedRole,
                        onChanged: (role) {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
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
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'passwordRequired',
                        ),
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
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: context.tr('login'),
                        isBusy: isLoading,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          context.read<LoginCubit>().login(
                                email: _emailController.text,
                                password: _passwordController.text,
                                selectedRole: _selectedRole,
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              AppRouter.route(const RegisterScreen()),
                            );
                          },
                          child: Text(
                            '${context.tr('noAccount')} ${context.tr('register')}',
                          ),
                        ),
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

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  final AppRole selectedRole;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    Widget buildOption(AppRole role, String label) {
      final selected = selectedRole == role;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onChanged(role),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: selected ? theme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          buildOption(AppRole.customer, context.tr('customer')),
          const SizedBox(width: 8),
          buildOption(AppRole.technician, context.tr('technician')),
        ],
      ),
    );
  }
}
