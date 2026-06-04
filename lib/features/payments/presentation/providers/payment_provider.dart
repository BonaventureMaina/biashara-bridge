import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../data/datasources/remote/daraja_api_datasource.dart';
import '../../../../data/repositories/payment_repository_impl.dart';

// Datasource
final darajaApiDatasourceProvider = Provider<DarajaApiDatasource>((ref) {
  return DarajaApiDatasource();
});

// Repository
final paymentRepositoryProvider = Provider<IPaymentService>((ref) {
  return PaymentRepositoryImpl(
    datasource: ref.watch(darajaApiDatasourceProvider),
  );
});

// Payment controller
final paymentControllerProvider = Provider<PaymentController>((ref) {
  return PaymentController(
    paymentService: ref.watch(paymentRepositoryProvider),
  );
});

class PaymentController {
  final IPaymentService _paymentService;

  PaymentController({required IPaymentService paymentService})
      : _paymentService = paymentService;

  Future<Either<Failure, String>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) {
    return _paymentService.initiatePayment(
      phoneNumber: phoneNumber,
      amount: amount,
      accountReference: accountReference,
      transactionDesc: transactionDesc,
    );
  }
}
