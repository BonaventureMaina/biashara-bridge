import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasource({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Left(Failure.authFailure(message: 'Sign in failed'));
      }
      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(Failure.authFailure(message: _mapAuthError(e.code)));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, User>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Left(Failure.authFailure(message: 'Sign up failed'));
      }
      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(Failure.authFailure(message: _mapAuthError(e.code)));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
