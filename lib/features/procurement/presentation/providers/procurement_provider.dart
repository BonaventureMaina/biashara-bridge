import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/bulk_deal_repository.dart';
import '../../../../data/datasources/remote/firestore_bulk_deal_datasource.dart';
import '../../../../data/repositories/bulk_deal_repository_impl.dart';
import '../../domain/entities/bulk_deal.dart';

// Datasource
final firestoreBulkDealDatasourceProvider =
    Provider<FirestoreBulkDealDatasource>((ref) {
  return FirestoreBulkDealDatasource(firestore: FirebaseFirestore.instance);
});

// Repository
final bulkDealRepositoryProvider = Provider<IBulkDealRepository>((ref) {
  return BulkDealRepositoryImpl(
    datasource: ref.watch(firestoreBulkDealDatasourceProvider),
  );
});

// Stream of active deals
final activeDealsProvider = StreamProvider<List<BulkDeal>>((ref) {
  final repository = ref.watch(bulkDealRepositoryProvider);
  return repository.getActiveDeals().map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (deals) => deals,
    );
  });
});

// Procurement controller
final procurementControllerProvider =
    Provider<ProcurementController>((ref) {
  return ProcurementController(
    repository: ref.watch(bulkDealRepositoryProvider),
  );
});

class ProcurementController {
  final IBulkDealRepository _repository;

  ProcurementController({required IBulkDealRepository repository})
      : _repository = repository;

  Future<Either<Failure, BulkDeal>> createBulkDeal({
    required String title,
    required String description,
    required double pricePerUnit,
    required int minOrderQuantity,
    required int availableQuantity,
    required DateTime expiresAt,
  }) {
    return _repository.createBulkDeal(
      title: title,
      description: description,
      pricePerUnit: pricePerUnit,
      minOrderQuantity: minOrderQuantity,
      availableQuantity: availableQuantity,
      expiresAt: expiresAt,
    );
  }

  Future<Either<Failure, BulkDeal>> claimDeal({
    required String dealId,
    required String businessId,
  }) {
    return _repository.claimDeal(dealId: dealId, businessId: businessId);
  }
}
