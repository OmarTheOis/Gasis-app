import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  const Ticket({
    required this.id,
    required this.collection,
    required this.userId,
    required this.type,
    required this.description,
    required this.status,
    required this.technicianId,
    required this.technicianName,
    required this.address,
    required this.preferredDate,
    required this.latitude,
    required this.longitude,
    required this.eta,
    required this.createdAt,
  });

  final String id;
  final String collection;
  final String userId;
  final String type;
  final String description;
  final String status;
  final String technicianId;
  final String technicianName;
  final String address;
  final String preferredDate;
  final double? latitude;
  final double? longitude;
  final String eta;
  final DateTime? createdAt;

  bool get isEmergency => collection == 'emergencies';

  String get displayDate => preferredDate.trim().isNotEmpty ? preferredDate : '';

  factory Ticket.fromMap(
    String id,
    String collection,
    Map<String, dynamic> map,
  ) {
    final timestamp = map['createdAt'];
    return Ticket(
      id: id,
      collection: collection,
      userId: '${map['userId'] ?? ''}',
      type: '${map['type'] ?? ''}',
      description: '${map['description'] ?? ''}',
      status: '${map['status'] ?? 'pending'}',
      technicianId: '${map['technicianId'] ?? ''}',
      technicianName: '${map['technicianName'] ?? ''}',
      address: '${map['address'] ?? ''}',
      preferredDate: '${map['preferredDate'] ?? ''}',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      eta: '${map['eta'] ?? ''}',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
