import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/section_title.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../stores/home/home_cubit.dart';
import 'emergency_screen.dart';
import 'my_requests_screen.dart';
import 'pay_bill_screen.dart';
import 'request_service_screen.dart';
import 'submit_reading_screen.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeFailure) {
          return Center(
            child: Text(context.tr(state.messageKey)),
          );
        }

        final data = state as HomeLoaded;
        final bill = data.bill;

        return RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.tr(
                  'welcomeBackName',
                  params: {'name': data.user.firstName},
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
                      context.tr('currentBill'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      bill == null
                          ? '0.00 AED'
                          : '${bill.amount.toStringAsFixed(2)} AED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bill == null
                          ? context.tr('noCurrentBill')
                          : '${context.tr('dueDate')}: ${bill.dueDate}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTitle(context.tr('quickActions')),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickActionCard(
                    icon: Icons.payment,
                    label: context.tr('payBill'),
                    onTap: () async {
                      await Navigator.of(context).push(
                        AppRouter.route(const PayBillScreen()),
                      );
                      if (context.mounted) {
                        context.read<HomeCubit>().load();
                      }
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.home_repair_service,
                    label: context.tr('requestService'),
                    onTap: () {
                      Navigator.of(context).push(
                        AppRouter.route(const RequestServiceScreen()),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.warning_amber_rounded,
                    label: context.tr('emergency'),
                    onTap: () {
                      Navigator.of(context).push(
                        AppRouter.route(const EmergencyScreen()),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.document_scanner_outlined,
                    label: context.tr('submitReading'),
                    onTap: () async {
                      await Navigator.of(context).push(
                        AppRouter.route(const SubmitReadingScreen()),
                      );
                      if (context.mounted) {
                        context.read<HomeCubit>().load();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WideActionCard(
                icon: Icons.fact_check_outlined,
                label: context.tr('myRequests'),
                onTap: () {
                  Navigator.of(context).push(
                    AppRouter.route(const MyRequestsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.primary.withOpacity(0.12),
              foregroundColor: theme.primary,
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideActionCard extends StatelessWidget {
  const _WideActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            const Icon(Icons.list_alt_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
