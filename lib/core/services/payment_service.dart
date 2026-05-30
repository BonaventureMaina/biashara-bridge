import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class IPaymentService {
  /// Initiate an M‑Pesa STK push (or any payment provider) for a given amount.
  /// Returns a checkout request ID to track the transaction.
  Future<Either<Failure, String>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  });

  /// Query the status of a payment by checkout request ID.
  Future<Either<Failure, String>> queryPaymentStatus(String checkoutRequestId);

  /// Simulate a payment callback (for sandbox testing only).
  Future<Either<Failure, Unit>> simulateCallback({
    required String checkoutRequestId,
    required bool success,
  });
}
