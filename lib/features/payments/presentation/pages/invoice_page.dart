import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../providers/payment_provider.dart';

class InvoicePage extends ConsumerStatefulWidget {
  const InvoicePage({super.key});

  @override
  ConsumerState<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends ConsumerState<InvoicePage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  String? _checkoutRequestId;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    final phone = _phoneController.text.trim();
    final amountText = _amountController.text.trim();
    if (phone.isEmpty || amountText.isEmpty) {
      setState(() => _statusMessage = 'Phone number and amount are required.');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _statusMessage = 'Enter a valid amount.');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final controller = ref.read(paymentControllerProvider);
    final result = await controller.initiatePayment(
      phoneNumber: phone,
      amount: amount,
      accountReference:
          _referenceController.text.trim().isEmpty
              ? 'Invoice'
              : _referenceController.text.trim(),
      transactionDesc: 'Payment via Biashara Bridge',
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        setState(() => _statusMessage = failure.message);
      },
      (checkoutRequestId) {
        setState(() {
          _checkoutRequestId = checkoutRequestId;
          _statusMessage = 'STK Push sent. Check your phone to complete payment.';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Customer phone number (e.g. 0712345678)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference (e.g. Invoice #)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (_statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _statusMessage!.startsWith('Error') ||
                            _statusMessage!.contains('failed')
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_statusMessage!),
                ),
              if (_checkoutRequestId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text('Checkout Request ID: $_checkoutRequestId',
                      style: const TextStyle(fontFamily: 'monospace')),
                ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _initiatePayment,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Payment Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
