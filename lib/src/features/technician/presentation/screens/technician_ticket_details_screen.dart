import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../components/info_card.dart';
import '../../../../components/location_map_card.dart';
import '../../../../components/primary_button.dart';
import '../../../../components/status_chip.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/date_format_helper.dart';
import '../../../../utils/types/ticket.dart';
import '../../stores/jobs/technician_jobs_cubit.dart';

class TechnicianTicketDetailsScreen extends StatelessWidget {
  const TechnicianTicketDetailsScreen({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('requestDetails')),
      ),
      body: StreamBuilder<Ticket?>(
        stream: FirestoreService().watchTicket(
          collection: ticket.collection,
          id: ticket.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentTicket = snapshot.data;
          if (currentTicket == null) {
            return Center(child: Text(context.tr('somethingWentWrong')));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTicket.type,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                StatusChip(status: currentTicket.status),
                const SizedBox(height: 20),
                InfoCard(
                  title: context.tr('status'),
                  value: currentTicket.status == 'completed'
                      ? context.tr('completed')
                      : currentTicket.status == 'in_progress'
                          ? context.tr('inProgress')
                          : context.tr('pending'),
                ),
                InfoCard(
                  title: context.tr('technicianName'),
                  value: currentTicket.technicianName.isEmpty
                      ? context.tr('notAssigned')
                      : currentTicket.technicianName,
                ),
                InfoCard(
                  title: context.tr('serviceAddress'),
                  value: currentTicket.address.isEmpty
                      ? context.tr('notAvailable')
                      : currentTicket.address,
                ),
                InfoCard(
                  title: context.tr('preferredDate'),
                  value: currentTicket.displayDate.isNotEmpty
                      ? currentTicket.displayDate
                      : DateFormatHelper.format(currentTicket.createdAt),
                ),
                InfoCard(
                  title: context.tr('details'),
                  value: currentTicket.description,
                ),
                const SizedBox(height: 8),
                LocationMapCard(
                  latitude: currentTicket.latitude,
                  longitude: currentTicket.longitude,
                  title: context.tr('location'),
                ),
                const SizedBox(height: 24),
                if (currentTicket.status == 'pending')
                  PrimaryButton(
                    label: context.tr('acceptJob'),
                    onPressed: () async {
                      await context.read<TechnicianJobsCubit>().acceptJob(
                            collection: currentTicket.collection,
                            ticketId: currentTicket.id,
                          );

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('jobAccepted'))),
                      );
                     // Navigator.of(context).pop();
                    },
                  ),
                if (currentTicket.status == 'in_progress')
                  PrimaryButton(
                    label: context.tr('completeJob'),
                    onPressed: () async {
                      await context.read<TechnicianJobsCubit>().completeJob(
                            collection: currentTicket.collection,
                            ticketId: currentTicket.id,
                          );

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('jobCompleted'))),
                      );
                     // Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
