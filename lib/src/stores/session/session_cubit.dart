import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/types/app_user.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const SessionInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> restoreSession() async {
    emit(const SessionLoading());

    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      emit(const SessionUnauthenticated());
      return;
    }

    try {
      final user = await _firestoreService.getUser(firebaseUser.uid);

      if (user == null) {
        emit(const SessionFailure('profileMissing'));
        return;
      }

      emit(SessionAuthenticated(user));
    } catch (_) {
      emit(const SessionFailure('somethingWentWrong'));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(const SessionUnauthenticated());
  }
}

abstract class SessionState {
  const SessionState();
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

class SessionFailure extends SessionState {
  const SessionFailure(this.messageKey);

  final String messageKey;
}

class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.user);

  final AppUser user;
}
