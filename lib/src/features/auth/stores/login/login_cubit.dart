import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/input_sanitizer.dart';
import '../../../../utils/types/app_role.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const LoginInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> login({
    required String email,
    required String password,
    required AppRole selectedRole,
  }) async {
    emit(const LoginLoading());

    try {
      final credential = await _authService.login(
        email: InputSanitizer.clean(email),
        password: InputSanitizer.clean(password),
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        emit(const LoginFailure(messageKey: 'genericAuthError'));
        return;
      }

      final user = await _firestoreService.getUser(uid);
      if (user == null) {
        await _authService.logout();
        emit(const LoginFailure(messageKey: 'profileMissing'));
        return;
      }

      if (user.role != selectedRole) {
        await _authService.logout();
        emit(
          LoginFailure(
            messageKey: 'accountNotAvailable',
            parameterKey: selectedRole == AppRole.customer
                ? 'customerPortal'
                : 'technicianPortal',
          ),
        );
        return;
      }

      emit(const LoginSuccess());
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          emit(const LoginFailure(messageKey: 'userNotFound'));
          break;
        case 'wrong-password':
        case 'invalid-credential':
          emit(const LoginFailure(messageKey: 'invalidCredentials'));
          break;
        case 'invalid-email':
          emit(const LoginFailure(messageKey: 'invalidEmailAuth'));
          break;
        case 'user-disabled':
          emit(const LoginFailure(messageKey: 'userDisabled'));
          break;
        default:
          emit(const LoginFailure(messageKey: 'genericAuthError'));
      }
    } catch (_) {
      emit(const LoginFailure(messageKey: 'somethingWentWrong'));
    }
  }
}

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  const LoginFailure({
    required this.messageKey,
    this.parameterKey,
  });

  final String messageKey;
  final String? parameterKey;
}
