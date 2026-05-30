import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/business_repository.dart';
import '../../features/registration/domain/entities/business.dart';
import '../datasources/remote/firestore_business_datasource.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements IBusinessRepository {
  final FirestoreBusinessDatasource _datasource;

  BusinessRepositoryImpl({required FirestoreBusinessDatasource datasource})
      : _datasource = datasource;

  @override
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
  }) async {
    // Create the domain entity (without id/biasharaCode yet)
    final now = DateTime.now();
    final domain = Business(
      id: '', // will be set from Firestore doc ID
      ownerId: ownerId,
      name: name,
      registrationNumber: registrationNumber,
      biasharaCode: '', // will be set by Cloud Function
      location: GeoPoint(latitude, longitude),
      addressLine: addressLine,
      category: category,
      createdAt: now,
      phoneNumber: phoneNumber,
      description: description,
    );

    final model = BusinessModel.fromDomain(domain);
    final result = await _datasource.registerBusiness(business: model);
    return result.fold(
      (failure) => Left(failure),
      (savedModel) => Right(savedModel.toDomain()),
    );
  }

  @override
  Future<Either<Failure, Business>> getByBiasharaCode(String code) async {
    final result = await _datasource.getByBiasharaCode(code);
    return result.fold(
      (failure) => Left(failure),
      (model) {
        if (model == null) {
          return const Left(Failure.notFoundFailure(
              message: 'Business not found'));
        }
        return Right(model.toDomain());
      },
    );
  }

  @override
  Stream<Either<Failure, List<Business>>> getBusinessesByOwner(
      String ownerId) {
    return _datasource.getBusinessesByOwner(ownerId).map((either) {
      return either.fold(
        (failure) => Left(failure),
        (models) => Right(models.map((m) => m.toDomain()).toList()),
      );
    });
  }

  @override
  Stream<Either<Failure, List<Business>>> getAllBusinesses() {
    return _datasource.getAllBusinesses().map((either) {
      return either.fold(
        (failure) => Left(failure),
        (models) => Right(models.map((m) => m.toDomain()).toList()),
      );
    });
  }
}
