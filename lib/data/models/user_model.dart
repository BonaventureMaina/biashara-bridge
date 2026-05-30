import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AppUser toDomain() {
    return AppUser(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
