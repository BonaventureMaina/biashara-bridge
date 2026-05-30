import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../models/business_model.dart';

class FirestoreBusinessDatasource {
  final FirebaseFirestore _firestore;

  FirestoreBusinessDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Save a new business document and return it with its generated Biashara Code.
  Future<Either<Failure, BusinessModel>> registerBusiness({
    required BusinessModel business,
  }) async {
    try {
      final docRef = await _firestore.collection('businesses').add(
            business.toFirestore(),
          );
      // Fetch the saved document to get the Biashara Code (written by Cloud Function)
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        return const Left(Failure.serverFailure(
            message: 'Failed to create business record.'));
      }
      return Right(BusinessModel.fromFirestore(
          snapshot.data()!, snapshot.id));
    } on FirebaseException catch (e) {
      return Left(Failure.serverFailure(message: e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  /// Fetch a business by its Biashara Code.
  Future<Either<Failure, BusinessModel?>> getByBiasharaCode(String code) async {
    try {
      final query = await _firestore
          .collection('businesses')
          .where('biasharaCode', isEqualTo: code)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return const Right(null);
      final doc = query.docs.first;
      return Right(BusinessModel.fromFirestore(doc.data(), doc.id));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  /// Stream businesses owned by a user.
  Stream<Either<Failure, List<BusinessModel>>> getBusinessesByOwner(
      String ownerId) {
    return _firestore
        .collection('businesses')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          try {
            final businesses = snapshot.docs
                .map((doc) =>
                    BusinessModel.fromFirestore(doc.data(), doc.id))
                .toList();
            return Right(businesses);
          } catch (e) {
            return Left(Failure.serverFailure(message: e.toString()));
          }
        });
  }

  /// Stream all businesses (for map / analytics).
  Stream<Either<Failure, List<BusinessModel>>> getAllBusinesses() {
    return _firestore.collection('businesses').snapshots().map((snapshot) {
      try {
        final businesses = snapshot.docs
            .map((doc) => BusinessModel.fromFirestore(doc.data(), doc.id))
            .toList();
        return Right(businesses);
      } catch (e) {
        return Left(Failure.serverFailure(message: e.toString()));
      }
    });
  }
}
