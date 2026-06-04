import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/auth_service.dart';
import '../../features/auth/domain/entities/user.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements IAuthService {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl({required FirebaseAuthDatasource datasource})
      : _datasource = datasource;

  @override
  Stream<AppUser?> get authStateChanges {
    return _datasource.authStateChanges.map((firebaseUser) {
      final appUser = firebaseUser != null
          ? UserModel.fromFirebaseUser(firebaseUser).toDomain()
          : null;
      print('AUTH STREAM emitted: $appUser');
      return appUser;
    });
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(
      String email, String password) async {
    final result = await _datasource.signInWithEmailAndPassword(email, password);
    return result.fold(
      (failure) => Left(failure),
      (firebaseUser) => Right(UserModel.fromFirebaseUser(firebaseUser).toDomain()),
    );
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailAndPassword(
      String email, String password) async {
    final result = await _datasource.signUpWithEmailAndPassword(email, password);
    return result.fold(
      (failure) => Left(failure),
      (firebaseUser) => Right(UserModel.fromFirebaseUser(firebaseUser).toDomain()),
    );
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return _datasource.signOut();
  }

  @override
  Future<Option<AppUser>> getSignedInUser() async {
    final user = _datasource.currentUser;
    if (user == null) return none();
    return some(UserModel.fromFirebaseUser(user).toDomain());
  }
}
