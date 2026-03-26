import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../components/request_card.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/types/payment_receipt.dart';
import '../../../../utils/types/bill.dart';
import 'payment_receipt_screen.dart';

class BillHistoryScreen extends StatelessWidget {
  const BillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final uid = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('billHistory')),
      ),
      body: FutureBuilder<List<Bill>>(
        future: uid == null
            ? Future.value(const <Bill>[])
            : context.read<FirestoreService>().getPaidBills(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = snapshot.data!;
          if (bills.isEmpty) {
            return Center(child: Text(context.tr('noBillsFound')));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];

              return RequestCard(
                title: '${bill.amount.toStringAsFixed(2)} AED',
                subtitle: bill.dueDate,
                status: 'completed',
                isEmergency: false,
                onTap: () {
                  Navigator.of(context).push(
                    AppRouter.route(
                      PaymentReceiptScreen(
                        receipt: PaymentReceipt(
                          amount: bill.amount.toStringAsFixed(2),
                          transactionId: bill.id,
                          date: bill.dueDate,
                          paymentMethod: context.tr('card'),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
