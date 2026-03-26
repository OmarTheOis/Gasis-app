import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/types/app_user.dart';
import '../../../../utils/types/bill.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const HomeInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> load() async {
    emit(const HomeLoading());

    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        emit(const HomeFailure('genericAuthError'));
        return;
      }

      final user = await _firestoreService.getUser(uid);
      if (user == null) {
        emit(const HomeFailure('profileMissing'));
        return;
      }

      final bill = await _firestoreService.getCurrentBill(uid);

      emit(HomeLoaded(
        user: user,
        bill: bill,
      ));
    } catch (_) {
      emit(const HomeFailure('somethingWentWrong'));
    }
  }
}

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.user,
    required this.bill,
  });

  final AppUser user;
  final Bill? bill;
}

class HomeFailure extends HomeState {
  const HomeFailure(this.messageKey);

  final String messageKey;
}
