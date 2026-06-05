import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/bulk_deal_repository.dart';
import '../../features/procurement/domain/entities/bulk_deal.dart';
import '../datasources/remote/firestore_bulk_deal_datasource.dart';

class BulkDealRepositoryImpl implements IBulkDealRepository {
  final FirestoreBulkDealDatasource _datasource;

  BulkDealRepositoryImpl({required FirestoreBulkDealDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, BulkDeal>> createBulkDeal({
    required String title,
    required String description,
    required double pricePerUnit,
    required int minOrderQuantity,
    required int availableQuantity,
    required DateTime expiresAt,
  }) async {
    // In a real app, supplierId comes from the authenticated user.
    // For MVP, we use a hardcoded admin ID.
    return _datasource.createBulkDeal(
      supplierId: 'admin_user_001',
      title: title,
      description: description,
      pricePerUnit: pricePerUnit,
      minOrderQuantity: minOrderQuantity,
      availableQuantity: availableQuantity,
      expiresAt: expiresAt,
    );
  }

  @override
  Stream<Either<Failure, List<BulkDeal>>> getActiveDeals() {
    return _datasource.getActiveDeals();
  }

  @override
  Future<Either<Failure, BulkDeal>> claimDeal({
    required String dealId,
    required String businessId,
  }) async {
    return _datasource.claimDeal(dealId: dealId, businessId: businessId);
  }
}
