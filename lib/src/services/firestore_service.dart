import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/types/app_user.dart';
import '../utils/types/bill.dart';
import '../utils/types/payment_receipt.dart';
import '../utils/types/ticket.dart';

class FirestoreService {
  FirestoreService() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return AppUser.fromMap(snapshot.data()!);
  }

  Future<void> updateUserName({
    required String uid,
    required String firstName,
    required String lastName,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Future<Bill?> getCurrentBill(String userId) async {
    final query = await _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return Bill.fromMap(doc.id, doc.data());
  }

  Future<List<Bill>> getPaidBills(String userId) async {
    final query = await _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: true)
        .get();

    final bills = query.docs
        .map((doc) => Bill.fromMap(doc.id, doc.data()))
        .toList();

    bills.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return bills;
  }

  Future<void> createBill({
    required String userId,
    required double amount,
    required String dueDate,
  }) async {
    await _firestore.collection('bills').add({
      'userId': userId,
      'amount': amount,
      'isPaid': false,
      'dueDate': dueDate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<PaymentReceipt> markBillPaid({
    required Bill bill,
    required String paymentMethod,
  }) async {
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

    await _firestore.collection('bills').doc(bill.id).update({
      'isPaid': true,
    });

    await _firestore.collection('payments').add({
      'userId': bill.userId,
      'billId': bill.id,
      'amount': bill.amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return PaymentReceipt(
      amount: bill.amount.toStringAsFixed(2),
      transactionId: transactionId,
      date: DateTime.now().toIso8601String(),
      paymentMethod: paymentMethod,
    );
  }

  Future<void> submitReading({
    required String userId,
    required int reading,
  }) async {
    await _firestore.collection('readings').add({
      'userId': userId,
      'reading': reading,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final amount = reading * 2.0;
    final dueDate = DateTime.now().add(const Duration(days: 30));
    final dueDateText =
        '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';

    await createBill(
      userId: userId,
      amount: amount,
      dueDate: dueDateText,
    );
  }

  Future<void> createServiceRequest({
    required String userId,
    required String type,
    required String description,
    required String address,
    required String preferredDate,
    required double? latitude,
    required double? longitude,
  }) async {
    await _firestore.collection('requests').add({
      'userId': userId,
      'type': type,
      'description': description,
      'address': address,
      'preferredDate': preferredDate,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'pending',
      'technicianId': '',
      'technicianName': '',
      'eta': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createEmergency({
    required String userId,
    required String type,
    required String description,
    required double? latitude,
    required double? longitude,
  }) async {
    final document = _firestore.collection('emergencies').doc();

    await document.set({
      'id': document.id,
      'userId': userId,
      'type': type,
      'description': description,
      'address': '',
      'preferredDate': '',
      'latitude': latitude,
      'longitude': longitude,
      'status': 'pending',
      'technicianId': '',
      'technicianName': '',
      'eta': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Ticket>> getMyTickets(String userId) async {
    final requests = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .get();

    final emergencies = await _firestore
        .collection('emergencies')
        .where('userId', isEqualTo: userId)
        .get();

    final tickets = <Ticket>[
      ...requests.docs.map(
        (doc) => Ticket.fromMap(doc.id, 'requests', doc.data()),
      ),
      ...emergencies.docs.map(
        (doc) => Ticket.fromMap(doc.id, 'emergencies', doc.data()),
      ),
    ];

    tickets.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return tickets;
  }

  Stream<Ticket?> watchTicket({
    required String collection,
    required String id,
  }) {
    return _firestore.collection(collection).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Ticket.fromMap(doc.id, collection, doc.data()!);
    });
  }

  Future<List<Ticket>> getTechnicianJobs({
    required String technicianId,
  }) async {
    final requestsPending = await _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .get();
    final requestsAssigned = await _firestore
        .collection('requests')
        .where('technicianId', isEqualTo: technicianId)
        .get();

    final emergenciesPending = await _firestore
        .collection('emergencies')
        .where('status', isEqualTo: 'pending')
        .get();
    final emergenciesAssigned = await _firestore
        .collection('emergencies')
        .where('technicianId', isEqualTo: technicianId)
        .get();

    final deduplicated = <String, Ticket>{};

    for (final doc in requestsPending.docs) {
      deduplicated['requests_${doc.id}'] =
          Ticket.fromMap(doc.id, 'requests', doc.data());
    }
    for (final doc in requestsAssigned.docs) {
      deduplicated['requests_${doc.id}'] =
          Ticket.fromMap(doc.id, 'requests', doc.data());
    }
    for (final doc in emergenciesPending.docs) {
      deduplicated['emergencies_${doc.id}'] =
          Ticket.fromMap(doc.id, 'emergencies', doc.data());
    }
    for (final doc in emergenciesAssigned.docs) {
      deduplicated['emergencies_${doc.id}'] =
          Ticket.fromMap(doc.id, 'emergencies', doc.data());
    }

    final jobs = deduplicated.values.toList();
    jobs.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return jobs;
  }

  Future<void> acceptTicket({
    required String collection,
    required String ticketId,
    required String technicianId,
    required String technicianName,
  }) async {
    await _firestore.collection(collection).doc(ticketId).update({
      'status': 'in_progress',
      'technicianId': technicianId,
      'technicianName': technicianName,
    });
  }

  Future<void> completeTicket({
    required String collection,
    required String ticketId,
  }) async {
    await _firestore.collection(collection).doc(ticketId).update({
      'status': 'completed',
    });
  }
}
