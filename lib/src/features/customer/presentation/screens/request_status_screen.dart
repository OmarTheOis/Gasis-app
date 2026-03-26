import 'package:flutter/material.dart';

import '../../../../components/info_card.dart';
import '../../../../components/location_map_card.dart';
import '../../../../components/status_chip.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/date_format_helper.dart';
import '../../../../utils/types/ticket.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  String _statusMessage(BuildContext context, String status) {
    switch (status) {
      case 'completed':
        return context.tr('completedMessage');
      case 'in_progress':
        return context.tr('inProgressMessage');
      default:
        return context.tr('pendingMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('serviceStatus')),
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
                const SizedBox(height: 12),
                Text(
                  _statusMessage(context, currentTicket.status),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
                  title: context.tr('preferredDate'),
                  value: currentTicket.displayDate.isNotEmpty
                      ? currentTicket.displayDate
                      : DateFormatHelper.format(currentTicket.createdAt),
                ),
                InfoCard(
                  title: context.tr('serviceAddress'),
                  value: currentTicket.address.isEmpty
                      ? context.tr('notAvailable')
                      : currentTicket.address,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
