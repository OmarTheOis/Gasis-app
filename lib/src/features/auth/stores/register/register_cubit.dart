import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/input_sanitizer.dart';
import '../../../../utils/types/app_role.dart';
import '../../../../utils/types/app_user.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const RegisterInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    emit(const RegisterLoading());

    try {
      final cleanedFirstName = InputSanitizer.clean(firstName);
      final cleanedLastName = InputSanitizer.clean(lastName);
      final cleanedEmail = InputSanitizer.clean(email);

      final credential = await _authService.register(
        email: cleanedEmail,
        password: InputSanitizer.clean(password),
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        emit(const RegisterFailure('registrationFailed'));
        return;
      }

      await _authService.updateDisplayName(
        '$cleanedFirstName $cleanedLastName'.trim(),
      );

      await _firestoreService.createUser(
        AppUser(
          uid: uid,
          firstName: cleanedFirstName,
          lastName: cleanedLastName,
          email: cleanedEmail,
          role: role,
        ),
      );

      emit(const RegisterSuccess());
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          emit(const RegisterFailure('emailAlreadyInUse'));
          break;
        default:
          emit(const RegisterFailure('registrationFailed'));
      }
    } catch (_) {
      emit(const RegisterFailure('somethingWentWrong'));
    }
  }
}

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

class RegisterFailure extends RegisterState {
  const RegisterFailure(this.messageKey);

  final String messageKey;
}
