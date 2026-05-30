import '../../features/auth/domain/entities/user.dart';
import '../errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class IAuthService {
  Stream<AppUser?> get authStateChanges;
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(
      String email, String password);
  Future<Either<Failure, AppUser>> signUpWithEmailAndPassword(
      String email, String password);
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, Unit>> signOut();
  Future<Option<AppUser>> getSignedInUser();
}
