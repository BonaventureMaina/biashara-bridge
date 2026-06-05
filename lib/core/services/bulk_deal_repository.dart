import 'package:dartz/dartz.dart';
import '../../features/procurement/domain/entities/bulk_deal.dart';
import '../errors/failures.dart';

abstract class IBulkDealRepository {
  /// Admin posts a new bulk deal.
  Future<Either<Failure, BulkDeal>> createBulkDeal({
    required String title,
    required String description,
    required double pricePerUnit,
    required int minOrderQuantity,
    required int availableQuantity,
    required DateTime expiresAt,
  });

  /// Get all active (not expired) deals.
  Stream<Either<Failure, List<BulkDeal>>> getActiveDeals();

  /// A business claims a deal (adds its businessId to claimedBy).
  Future<Either<Failure, BulkDeal>> claimDeal({
    required String dealId,
    required String businessId,
  });
}
