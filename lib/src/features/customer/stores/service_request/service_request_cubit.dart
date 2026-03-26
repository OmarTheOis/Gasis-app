import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/input_sanitizer.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  ServiceRequestCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const ServiceRequestInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> submit({
    required String type,
    required String description,
    required String address,
    required String preferredDate,
    required double? latitude,
    required double? longitude,
  }) async {
    emit(const ServiceRequestSubmitting());

    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        emit(const ServiceRequestFailure('genericAuthError'));
        return;
      }

      await _firestoreService.createServiceRequest(
        userId: uid,
        type: InputSanitizer.clean(type),
        description: InputSanitizer.clean(description),
        address: InputSanitizer.clean(address),
        preferredDate: preferredDate,
        latitude: latitude,
        longitude: longitude,
      );

      emit(const ServiceRequestSuccess());
    } catch (_) {
      emit(const ServiceRequestFailure('serviceRequestFailed'));
    }
  }
}

abstract class ServiceRequestState {
  const ServiceRequestState();
}

class ServiceRequestInitial extends ServiceRequestState {
  const ServiceRequestInitial();
}

class ServiceRequestSubmitting extends ServiceRequestState {
  const ServiceRequestSubmitting();
}

class ServiceRequestSuccess extends ServiceRequestState {
  const ServiceRequestSuccess();
}

class ServiceRequestFailure extends ServiceRequestState {
  const ServiceRequestFailure(this.messageKey);

  final String messageKey;
}
