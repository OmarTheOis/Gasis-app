import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/types/app_user.dart';
import '../../../../utils/types/ticket.dart';

class TechnicianJobsCubit extends Cubit<TechnicianJobsState> {
  TechnicianJobsCubit({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const TechnicianJobsInitial());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Future<void> load() async {
    emit(const TechnicianJobsLoading());

    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        emit(const TechnicianJobsFailure('genericAuthError'));
        return;
      }

      final technician = await _firestoreService.getUser(uid);
      if (technician == null) {
        emit(const TechnicianJobsFailure('profileMissing'));
        return;
      }

      final jobs = await _firestoreService.getTechnicianJobs(
        technicianId: uid,
      );

      emit(
        TechnicianJobsLoaded(
          technician: technician,
          jobs: jobs,
        ),
      );
    } catch (_) {
      emit(const TechnicianJobsFailure('somethingWentWrong'));
    }
  }

  Future<void> acceptJob({
    required String collection,
    required String ticketId,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final technician = await _firestoreService.getUser(uid);
    if (technician == null) {
      return;
    }

    await _firestoreService.acceptTicket(
      collection: collection,
      ticketId: ticketId,
      technicianId: uid,
      technicianName: technician.fullName,
    );

    await load();
  }

  Future<void> completeJob({
    required String collection,
    required String ticketId,
  }) async {
    await _firestoreService.completeTicket(
      collection: collection,
      ticketId: ticketId,
    );

    await load();
  }
}

abstract class TechnicianJobsState {
  const TechnicianJobsState();
}

class TechnicianJobsInitial extends TechnicianJobsState {
  const TechnicianJobsInitial();
}

class TechnicianJobsLoading extends TechnicianJobsState {
  const TechnicianJobsLoading();
}

class TechnicianJobsLoaded extends TechnicianJobsState {
  const TechnicianJobsLoaded({
    required this.technician,
    required this.jobs,
  });

  final AppUser technician;
  final List<Ticket> jobs;
}

class TechnicianJobsFailure extends TechnicianJobsState {
  const TechnicianJobsFailure(this.messageKey);

  final String messageKey;
}
