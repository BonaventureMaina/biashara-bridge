import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class IPaymentService {
  /// Initiate an M‑Pesa STK push.
  /// Returns the CheckoutRequestID.
  Future<Either<Failure, String>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  });

  /// Query the status of a payment by CheckoutRequestID.
  Future<Either<Failure, String>> queryPaymentStatus(String checkoutRequestId);

  /// Simulate a payment callback (for sandbox).
  Future<Either<Failure, Unit>> simulateCallback({
    required String checkoutRequestId,
    required bool success,
  });
}
