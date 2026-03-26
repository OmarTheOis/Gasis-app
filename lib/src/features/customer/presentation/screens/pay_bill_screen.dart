import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_router.dart';
import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../../../utils/types/bill.dart';
import 'payment_receipt_screen.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Bill? _bill;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    final uid = context.read<AuthService>().currentUser?.uid;

    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final bill = await context.read<FirestoreService>().getCurrentBill(uid);
    if (!mounted) return;

    setState(() {
      _bill = bill;
      _loading = false;
    });
  }

  String _formatCardNumber(String value) {
    final digits = value.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final digits = value.replaceAll('/', '');
    if (digits.length <= 2) {
      return digits;
    }
    final end = digits.length > 4 ? 4 : digits.length;
    return '${digits.substring(0, 2)}/${digits.substring(2, end)}';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('payBill'))),
        body: Center(child: Text(context.tr('noCurrentBill'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('payBill')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
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
                        '${_bill!.amount.toStringAsFixed(2)} AED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${context.tr('dueDate')}: ${_bill!.dueDate}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _cardNumberController,
                  labelText: context.tr('cardNumber'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  validator: (value) => FormValidators.cardNumber(context, value),
                  onChanged: (value) {
                    final formatted = _formatCardNumber(value);
                    _cardNumberController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cardHolderController,
                  labelText: context.tr('cardHolderName'),
                  validator: (value) => FormValidators.requiredText(
                    context,
                    value,
                    'cardHolderNameRequired',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _expiryController,
                        labelText: context.tr('expiry'),
                        keyboardType: TextInputType.number,
                        validator: (value) => FormValidators.expiry(context, value),
                        onChanged: (value) {
                          final formatted = _formatExpiry(value);
                          _expiryController.value = TextEditingValue(
                            text: formatted,
                            selection:
                                TextSelection.collapsed(offset: formatted.length),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _cvvController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        labelText: context.tr('cvv'),
                        keyboardType: TextInputType.number,
                        validator: (value) => FormValidators.cvv(context, value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: context.tr('payNow'),
                  isBusy: _submitting,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    setState(() {
                      _submitting = true;
                    });

                    final receipt = await context
                        .read<FirestoreService>()
                        .markBillPaid(
                          bill: _bill!,
                          paymentMethod: context.tr('card'),
                        );

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _submitting = false;
                    });

                    Navigator.of(context).pushReplacement(
                      AppRouter.route(
                        PaymentReceiptScreen(receipt: receipt),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
