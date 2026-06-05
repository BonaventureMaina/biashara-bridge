import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:biashara_bridge/core/errors/failures.dart';
import 'package:biashara_bridge/core/services/auth_service.dart';
import 'package:biashara_bridge/core/services/business_repository.dart';
import 'package:biashara_bridge/features/auth/domain/entities/user.dart';
import 'package:biashara_bridge/features/auth/presentation/providers/auth_provider.dart';
import 'package:biashara_bridge/features/auth/presentation/pages/login_page.dart';
import 'package:biashara_bridge/features/registration/domain/entities/business.dart';
import 'package:biashara_bridge/features/registration/presentation/providers/registration_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock classes
class MockAuthService extends Mock implements IAuthService {}
class MockBusinessRepository extends Mock implements IBusinessRepository {}

void main() {
  group('AuthController', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('signInWithEmail returns Right on success', () async {
      const email = 'test@example.com';
      const password = 'password';
      final user = AppUser(id: '123', email: email);
      when(() => mockAuthService.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Right(user));

      final controller = container.read(authControllerProvider);
      final result = await controller.signInWithEmail(email, password);

      expect(result, equals(Right(user)));
    });

    test('signUpWithEmail returns Right on success', () async {
      const email = 'new@example.com';
      const password = 'pass123';
      final user = AppUser(id: '456', email: email);
      when(() => mockAuthService.signUpWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Right(user));

      final controller = container.read(authControllerProvider);
      final result = await controller.signUpWithEmail(email, password);

      expect(result, equals(Right(user)));
    });
  });

  group('RegistrationController', () {
    late MockBusinessRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockBusinessRepository();
      container = ProviderContainer(
        overrides: [
          businessRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('registerBusiness returns Business with Biashara Code', () async {
      const name = 'Test Shop';
      const lat = -1.2921;
      const lon = 36.8219;
      const address = 'Nairobi';
      const category = 'retail';
      const ownerId = 'owner123';

      final now = DateTime.now();
      final expectedBusiness = Business(
        id: 'doc1',
        ownerId: ownerId,
        name: name,
        biasharaCode: 'BSH-NAI-1234',
        location: const GeoPoint(lat, lon),
        addressLine: address,
        category: category,
        createdAt: now,
      );

      when(() => mockRepo.registerBusiness(
        ownerId: ownerId,
        name: name,
        latitude: lat,
        longitude: lon,
        addressLine: address,
        category: category,
        registrationNumber: any(named: 'registrationNumber'),
        phoneNumber: any(named: 'phoneNumber'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Right(expectedBusiness));

      final controller = container.read(registrationControllerProvider);
      final result = await controller.registerBusiness(
        ownerId: ownerId,
        name: name,
        latitude: lat,
        longitude: lon,
        addressLine: address,
        category: category,
      );

      expect(result.isRight(), true);
      final business = result.getOrElse(() => throw Exception('Failed'));
      expect(business.biasharaCode, startsWith('BSH-'));
    });
  });

  group('LoginPage', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    testWidgets('shows error on failed sign-in', (tester) async {
      // Arrange: mock sign-in to return failure
      when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => const Left(Failure.authFailure(message: 'Invalid credentials')));

      // Build widget with the overridden provider
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      // Enter credentials
      await tester.enterText(find.byType(TextField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      // Tap sign-in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Expect SnackBar with error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
