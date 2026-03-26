import 'package:flutter/material.dart';

import '../../../../components/info_card.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/types/payment_receipt.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.receipt,
  });

  final PaymentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('paymentSuccessful')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.success.withOpacity(0.12),
                foregroundColor: AppColors.success,
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('paymentSuccessful'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('paymentSuccessMessage'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              InfoCard(
                title: context.tr('amountPaid'),
                value: '${receipt.amount} AED',
              ),
              InfoCard(
                title: context.tr('transactionId'),
                value: receipt.transactionId,
              ),
              InfoCard(
                title: context.tr('dateTime'),
                value: receipt.date,
              ),
              InfoCard(
                title: context.tr('paymentMethod'),
                value: receipt.paymentMethod,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: context.tr('backToHome'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
