import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyAfOxIOZK7WKsEEZIB2QzWct7YMyiM4qRI',
      appId: '1:875043425835:web:251237dd14789de273e46e',
      messagingSenderId: '875043425835',
      projectId: 'biashara-bridge-dev',
      storageBucket: 'biashara-bridge-dev.firebasestorage.app',
      authDomain: 'biashara-bridge-dev.firebaseapp.com',
    );
  }
}
