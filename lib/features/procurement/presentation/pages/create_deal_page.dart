import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/procurement_provider.dart';

class CreateDealPage extends ConsumerStatefulWidget {
  const CreateDealPage({super.key});

  @override
  ConsumerState<CreateDealPage> createState() => _CreateDealPageState();
}

class _CreateDealPageState extends ConsumerState<CreateDealPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _availableController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minOrderController.dispose();
    _availableController.dispose();
    super.dispose();
  }

  Future<void> _createDeal() async {
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      setState(() => _statusMessage = 'Title and price are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final controller = ref.read(procurementControllerProvider);
    final result = await controller.createBulkDeal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      pricePerUnit: double.parse(_priceController.text.trim()),
      minOrderQuantity: int.tryParse(_minOrderController.text.trim()) ?? 1,
      availableQuantity: int.tryParse(_availableController.text.trim()) ?? 100,
      expiresAt: _expiryDate,
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        setState(() => _statusMessage = failure.message);
      },
      (_) {
        setState(() => _statusMessage = 'Deal created successfully!');
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bulk Deal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per unit (KES) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Min order quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _availableController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Available quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expiry date'),
                subtitle: Text(
                  '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage!.contains('success')
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_statusMessage!),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createDeal,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Deal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
