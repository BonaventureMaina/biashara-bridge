import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/registration_provider.dart';
import 'map_picker_page.dart';

class BusinessRegistrationPage extends ConsumerStatefulWidget {
  const BusinessRegistrationPage({super.key});

  @override
  ConsumerState<BusinessRegistrationPage> createState() =>
      _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState
    extends ConsumerState<BusinessRegistrationPage> {
  final _nameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'retail';
  LatLng? _pickedLocation;
  String? _addressLine;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _registrationNumberController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final initial = _pickedLocation ??
        const LatLng(-1.2921, 36.8219); // Default: Nairobi CBD
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialLocation: initial),
      ),
    );
    if (selected != null) {
      setState(() {
        _pickedLocation = selected;
        _addressLine = null; // will be resolved below
      });
      // Reverse geocode
      final address = await LocationUtils.reverseGeocode(
        selected.latitude,
        selected.longitude,
      );
      setState(() {
        _addressLine = address ?? 'Unknown location';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Business name is required.');
      return;
    }
    if (_pickedLocation == null) {
      setState(() => _errorMessage = 'Please pick your business location.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authState = ref.read(authStateChangesProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be signed in to register a business.';
        _isLoading = false;
      });
      return;
    }

    final controller = ref.read(registrationControllerProvider);
    final result = await controller.registerBusiness(
      ownerId: user.id,
      name: _nameController.text.trim(),
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      addressLine: _addressLine ?? 'Unknown location',
      category: _selectedCategory,
      registrationNumber:
          _registrationNumberController.text.trim().isEmpty
              ? null
              : _registrationNumberController.text.trim(),
      phoneNumber:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        setState(() => _errorMessage = failure.message);
      },
      (business) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Business registered! Your Biashara Code: ${business.biasharaCode}'),
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register your business'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'retail', child: Text('Retail')),
                  DropdownMenuItem(value: 'agritech', child: Text('Agritech')),
                  DropdownMenuItem(
                      value: 'logistics', child: Text('Logistics')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _registrationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Registration number (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone number (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Location picker
              OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(
                  _pickedLocation == null
                      ? 'Pick your location *'
                      : 'Location selected',
                ),
                onPressed: _openMapPicker,
              ),
              if (_addressLine != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Address: $_addressLine',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register Business'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
