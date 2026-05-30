import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.serverFailure({required String message}) = ServerFailure;
  const factory Failure.networkFailure({required String message}) = NetworkFailure;
  const factory Failure.authFailure({required String message}) = AuthFailure;
  const factory Failure.notFoundFailure({required String message}) = NotFoundFailure;
  const factory Failure.validationFailure({required String message}) = ValidationFailure;
}
