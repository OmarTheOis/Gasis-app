import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/input_sanitizer.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  EmergencyCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const EmergencyInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> submit({
    required String type,
    required String description,
    required double? latitude,
    required double? longitude,
  }) async {
    emit(const EmergencySubmitting());

    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        emit(const EmergencyFailure('genericAuthError'));
        return;
      }

      await _firestoreService.createEmergency(
        userId: uid,
        type: InputSanitizer.clean(type),
        description: InputSanitizer.clean(description),
        latitude: latitude,
        longitude: longitude,
      );

      emit(const EmergencySuccess());
    } catch (_) {
      emit(const EmergencyFailure('emergencyFailed'));
    }
  }
}

abstract class EmergencyState {
  const EmergencyState();
}

class EmergencyInitial extends EmergencyState {
  const EmergencyInitial();
}

class EmergencySubmitting extends EmergencyState {
  const EmergencySubmitting();
}

class EmergencySuccess extends EmergencyState {
  const EmergencySuccess();
}

class EmergencyFailure extends EmergencyState {
  const EmergencyFailure(this.messageKey);

  final String messageKey;
}
