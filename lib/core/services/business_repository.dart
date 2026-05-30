import 'package:dartz/dartz.dart';
import '../../features/registration/domain/entities/business.dart';
import '../errors/failures.dart';

abstract class IBusinessRepository {
  /// Register a new business. Returns the created Business with its Biashara Code.
  Future<Either<Failure, Business>> registerBusiness({
    required String ownerId,
    required String name,
    required double latitude,
    required double longitude,
    required String addressLine,
    required String category,
    String? registrationNumber,
    String? phoneNumber,
    String? description,
  });

  /// Look up a business by its Biashara Code.
  Future<Either<Failure, Business>> getByBiasharaCode(String code);

  /// Get all businesses owned by a specific user.
  Stream<Either<Failure, List<Business>>> getBusinessesByOwner(String ownerId);

  /// Get all businesses (for the map view / analytics).
  Stream<Either<Failure, List<Business>>> getAllBusinesses();
}
