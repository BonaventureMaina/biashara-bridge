import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../features/procurement/domain/entities/bulk_deal.dart';

class FirestoreBulkDealDatasource {
  final FirebaseFirestore _firestore;

  FirestoreBulkDealDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Either<Failure, BulkDeal>> createBulkDeal({
    required String supplierId,
    required String title,
    required String description,
    required double pricePerUnit,
    required int minOrderQuantity,
    required int availableQuantity,
    required DateTime expiresAt,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection('bulkDeals').add({
        'supplierId': supplierId,
        'title': title,
        'description': description,
        'pricePerUnit': pricePerUnit,
        'minOrderQuantity': minOrderQuantity,
        'availableQuantity': availableQuantity,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'claimedBy': [],
      });
      final snapshot = await docRef.get();
      final data = snapshot.data()!;
      return Right(_docToDeal(snapshot.id, data));
    } on FirebaseException catch (e) {
      return Left(Failure.serverFailure(message: e.message ?? 'Failed to create deal'));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  Stream<Either<Failure, List<BulkDeal>>> getActiveDeals() {
    final now = DateTime.now();
    return _firestore
        .collection('bulkDeals')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) {
          try {
            final deals = snapshot.docs
                .map((doc) => _docToDeal(doc.id, doc.data()))
                .toList();
            return Right(deals);
          } catch (e) {
            return Left(Failure.serverFailure(message: e.toString()));
          }
        });
  }

  Future<Either<Failure, BulkDeal>> claimDeal({
    required String dealId,
    required String businessId,
  }) async {
    try {
      final docRef = _firestore.collection('bulkDeals').doc(dealId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Deal not found');
        }
        final data = snapshot.data()!;
        final claimedBy = List<String>.from(data['claimedBy'] ?? []);
        if (claimedBy.contains(businessId)) {
          throw Exception('Already claimed');
        }
        claimedBy.add(businessId);
        transaction.update(docRef, {'claimedBy': claimedBy});
      });
      final updated = await docRef.get();
      return Right(_docToDeal(dealId, updated.data()!));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  BulkDeal _docToDeal(String id, Map<String, dynamic> data) {
    return BulkDeal(
      id: id,
      supplierId: data['supplierId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      pricePerUnit: (data['pricePerUnit'] as num).toDouble(),
      minOrderQuantity: data['minOrderQuantity'] as int,
      availableQuantity: data['availableQuantity'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      claimedBy: List<String>.from(data['claimedBy'] ?? []),
    );
  }
}
