import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/types/ticket.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const HistoryInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> load() async {
    emit(const HistoryLoading());

    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        emit(const HistoryFailure('genericAuthError'));
        return;
      }

      final tickets = await _firestoreService.getMyTickets(uid);
      emit(HistoryLoaded(tickets));
    } catch (_) {
      emit(const HistoryFailure('somethingWentWrong'));
    }
  }
}

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.tickets);

  final List<Ticket> tickets;
}

class HistoryFailure extends HistoryState {
  const HistoryFailure(this.messageKey);

  final String messageKey;
}
