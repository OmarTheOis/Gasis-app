import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/input_sanitizer.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const ProfileInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    emit(const ProfileSubmitting());

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        emit(const ProfileFailure('genericAuthError'));
        return;
      }

      final cleanFirst = InputSanitizer.clean(firstName);
      final cleanLast = InputSanitizer.clean(lastName);

      await _firestoreService.updateUserName(
        uid: currentUser.uid,
        firstName: cleanFirst,
        lastName: cleanLast,
      );
      await _authService.updateDisplayName('$cleanFirst $cleanLast'.trim());

      emit(const ProfileSuccess('nameUpdated'));
    } catch (_) {
      emit(const ProfileFailure('somethingWentWrong'));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ProfileSubmitting());

    try {
      await _authService.changePassword(
        currentPassword: InputSanitizer.clean(currentPassword),
        newPassword: InputSanitizer.clean(newPassword),
      );

      emit(const ProfileSuccess('passwordUpdated'));
    } on FirebaseAuthException catch (_) {
      emit(const ProfileFailure('wrongCurrentPass'));
    } catch (_) {
      emit(const ProfileFailure('somethingWentWrong'));
    }
  }
}

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileSubmitting extends ProfileState {
  const ProfileSubmitting();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.messageKey);

  final String messageKey;
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.messageKey);

  final String messageKey;
}
