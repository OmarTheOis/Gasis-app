import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/request_card.dart';
import '../../../../components/section_title.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/helpers/date_format_helper.dart';
import '../../../../utils/types/ticket.dart';
import '../../stores/jobs/technician_jobs_cubit.dart';
import 'technician_ticket_details_screen.dart';

class TechnicianDashboardScreen extends StatelessWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicianJobsCubit, TechnicianJobsState>(
      builder: (context, state) {
        if (state is TechnicianJobsInitial || state is TechnicianJobsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TechnicianJobsFailure) {
          return Center(
            child: Text(context.tr(state.messageKey)),
          );
        }

        final data = state as TechnicianJobsLoaded;
        final pending = data.jobs.where((job) => job.status == 'pending').length;
        final inProgress =
            data.jobs.where((job) => job.status == 'in_progress').length;
        final completed =
            data.jobs.where((job) => job.status == 'completed').length;

        return RefreshIndicator(
          onRefresh: () => context.read<TechnicianJobsCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.tr(
                  'technicianWelcomeName',
                  params: {'name': data.technician.firstName},
                ),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('todaysJobs'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${data.jobs.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('pendingCount')}: $pending • ${context.tr('inProgressCount')}: $inProgress • ${context.tr('completedCount')}: $completed',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: context.tr('pending'),
                      value: pending,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: context.tr('inProgress'),
                      value: inProgress,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: context.tr('completed'),
                      value: completed,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionTitle(context.tr('assignedJobs')),
              const SizedBox(height: 14),
              if (data.jobs.isEmpty)
                Center(child: Text(context.tr('noRequestsYet')))
              else
                ...data.jobs.map(
                  (job) => RequestCard(
                    title: job.type,
                    subtitle: _subtitle(job),
                    status: job.status,
                    isEmergency: job.isEmergency,
                    onTap: () async {
                      final jobsCubit = context.read<TechnicianJobsCubit>();

                      await Navigator.of(context).push(
                        AppRouter.route(
                          BlocProvider.value(
                            value: jobsCubit,
                            child: TechnicianTicketDetailsScreen(ticket: job),
                          ),
                        ),
                      );

                      if (context.mounted) {
                        jobsCubit.load();
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _subtitle(Ticket ticket) {
    if (ticket.address.isNotEmpty) {
      return ticket.address;
    }

    if (ticket.latitude != null && ticket.longitude != null) {
      return '${ticket.latitude!.toStringAsFixed(5)}, ${ticket.longitude!.toStringAsFixed(5)}';
    }

    return DateFormatHelper.format(ticket.createdAt);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
