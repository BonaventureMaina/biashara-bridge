import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

class DarajaApiDatasource {
  // Local emulator endpoint
  static const String _functionUrl =
      'http://127.0.0.1:5001/biashara-bridge-dev/us-central1/initiatePayment';

  Future<Either<Failure, String>> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'amount': amount,
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final checkoutRequestID = data['checkoutRequestID'] as String;
        return Right(checkoutRequestID);
      }
      return Left(Failure.serverFailure(
          message: 'Payment failed: ${response.body}'));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
