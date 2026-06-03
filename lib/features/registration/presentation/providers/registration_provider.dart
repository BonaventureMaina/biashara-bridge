import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/business_repository.dart';
import '../../../../data/datasources/remote/firestore_business_datasource.dart';
import '../../../../data/repositories/business_repository_impl.dart';
import '../../domain/entities/business.dart';

// Datasource
final firestoreBusinessDatasourceProvider =
    Provider<FirestoreBusinessDatasource>((ref) {
  return FirestoreBusinessDatasource(firestore: FirebaseFirestore.instance);
});

// Repository
final businessRepositoryProvider = Provider<IBusinessRepository>((ref) {
  return BusinessRepositoryImpl(
    datasource: ref.watch(firestoreBusinessDatasourceProvider),
  );
});

// Registration controller
final registrationControllerProvider =
    Provider<RegistrationController>((ref) {
  return RegistrationController(
    repository: ref.watch(businessRepositoryProvider),
  );
});

// Stream of businesses owned by a user
final businessesByOwnerProvider =
    StreamProvider.family<List<Business>, String>((ref, ownerId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessesByOwner(ownerId).map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (businesses) => businesses,
    );
  });
});

// Future provider for a single business by Biashara Code
final businessByBiasharaCodeProvider =
    FutureProvider.family<Business?, String>((ref, code) async {
  final repository = ref.watch(businessRepositoryProvider);
  final result = await repository.getByBiasharaCode(code);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (business) => business,
  );
});

class RegistrationController {
  final IBusinessRepository _repository;

  RegistrationController({required IBusinessRepository repository})
      : _repository = repository;

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
  }) {
    return _repository.registerBusiness(
      ownerId: ownerId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      addressLine: addressLine,
      category: category,
      registrationNumber: registrationNumber,
      phoneNumber: phoneNumber,
      description: description,
    );
  }

  Future<Either<Failure, Business>> getByBiasharaCode(String code) {
    return _repository.getByBiasharaCode(code);
  }
}
