class Bill {
  const Bill({
    required this.id,
    required this.userId,
    required this.amount,
    required this.isPaid,
    required this.dueDate,
  });

  final String id;
  final String userId;
  final double amount;
  final bool isPaid;
  final String dueDate;

  factory Bill.fromMap(String id, Map<String, dynamic> map) {
    return Bill(
      id: id,
      userId: '${map['userId'] ?? ''}',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      isPaid: map['isPaid'] == true,
      dueDate: '${map['dueDate'] ?? ''}',
    );
  }
}
