import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/request_card.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/date_format_helper.dart';
import '../../../../utils/types/ticket.dart';
import '../../stores/history/history_cubit.dart';
import 'emergency_status_screen.dart';
import 'request_status_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      )..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('myRequests')),
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryInitial || state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HistoryFailure) {
              return Center(
                child: Text(context.tr(state.messageKey)),
              );
            }

            final tickets = (state as HistoryLoaded).tickets;
            if (tickets.isEmpty) {
              return Center(child: Text(context.tr('noRequestsYet')));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HistoryCubit>().load(),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final subtitle = _subtitle(ticket);

                  return RequestCard(
                    title: ticket.type,
                    subtitle: subtitle,
                    status: ticket.status,
                    isEmergency: ticket.isEmergency,
                    onTap: () {
                      Navigator.of(context).push(
                        AppRouter.route(
                          ticket.isEmergency
                              ? EmergencyStatusScreen(ticket: ticket)
                              : RequestStatusScreen(ticket: ticket),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _subtitle(Ticket ticket) {
    if (ticket.displayDate.isNotEmpty) {
      return ticket.displayDate;
    }

    return DateFormatHelper.format(ticket.createdAt);
  }
}
