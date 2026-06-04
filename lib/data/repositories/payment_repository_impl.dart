import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/payment_service.dart';
import '../datasources/remote/daraja_api_datasource.dart';

class PaymentRepositoryImpl implements IPaymentService {
  final DarajaApiDatasource _datasource;

  PaymentRepositoryImpl({required DarajaApiDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, String>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) {
    return _datasource.stkPush(
      phoneNumber: phoneNumber,
      amount: amount,
      accountReference: accountReference,
      transactionDesc: transactionDesc,
    );
  }

  @override
  Future<Either<Failure, String>> queryPaymentStatus(
      String checkoutRequestId) async {
    // Sandbox: Daraja doesn't expose a direct query endpoint for STK Push.
    // In production, you'd use the confirmation callback.
    return const Left(Failure.serverFailure(
        message: 'Query status not implemented in sandbox'));
  }

  @override
  Future<Either<Failure, Unit>> simulateCallback({
    required String checkoutRequestId,
    required bool success,
  }) async {
    // Placeholder: in sandbox, use Daraja's simulate endpoint to trigger a callback.
    // We'll implement this later when we have a Cloud Function URL.
    return const Left(Failure.serverFailure(
        message: 'Simulate callback not implemented yet'));
  }
}
