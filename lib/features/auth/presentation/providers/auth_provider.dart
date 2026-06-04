import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

// 1. Datasource provider
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource(firebaseAuth: FirebaseAuth.instance);
});

// 2. Repository provider
final authRepositoryProvider = Provider<IAuthService>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(firebaseAuthDatasourceProvider),
  );
});

// 3. Auth state changes stream
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authRepositoryProvider);
  return authService.authStateChanges;
});

// 4. Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(authService: ref.watch(authRepositoryProvider));
});

class AuthController {
  final IAuthService _authService;

  AuthController({required IAuthService authService}) : _authService = authService;

  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  Future<Either<Failure, AppUser>> signUpWithEmail(String email, String password) {
    return _authService.signUpWithEmailAndPassword(email, password);
  }

  Future<Either<Failure, Unit>> signOut() {
    return _authService.signOut();
  }
}
