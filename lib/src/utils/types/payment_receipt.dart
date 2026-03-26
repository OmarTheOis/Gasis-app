class PaymentReceipt {
  const PaymentReceipt({
    required this.amount,
    required this.transactionId,
    required this.date,
    required this.paymentMethod,
  });

  final String amount;
  final String transactionId;
  final String date;
  final String paymentMethod;
}
