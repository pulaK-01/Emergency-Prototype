import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/auth/models/driver_verification_document.dart';
import 'package:medirapid/features/auth/providers/driver_verification_provider.dart';
import 'package:medirapid/features/auth/widgets/driver_document_upload_tile.dart';

class DriverVerificationScreen extends StatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _vehicleRegistrationController = TextEditingController();
  final _uppercaseInputFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) => newValue.copyWith(
      text: newValue.text.toUpperCase(),
      composing: TextRange.empty,
    ),
  );
  final Map<DriverVerificationDocument, PlatformFile> _documents = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _vehicleRegistrationController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(DriverVerificationDocument document) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null || !mounted) return;

      final fileSize = await file.length();
      if (!mounted) return;
      if (fileSize == null) {
        _showMessage('Could not determine the selected document size.');
        return;
      }
      if (fileSize > 10 * 1024 * 1024) {
        _showMessage('Choose a document smaller than 10 MB.');
        return;
      }

      setState(() => _documents[document] = file);
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage('Could not open the document picker: ${error.message}');
      }
    }
  }

  void _removeDocument(DriverVerificationDocument document) {
    setState(() => _documents.remove(document));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    final missingDocuments = DriverVerificationDocument.values
        .where((document) => !_documents.containsKey(document))
        .toList();
    if (missingDocuments.isNotEmpty) {
      _showMessage('Please attach all required documents to continue.');
      return;
    }

    await DriverVerificationProvider.instance.submitForReview();
    setState(() => _isSubmitting = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.verified_outlined,
          color: Colors.green,
          size: 40,
        ),
        title: const Text('Documents submitted'),
        content: const Text(
          'Your verification request is pending. We’ll notify you after review.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.driverVerificationPending,
      (route) => false,
    );
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    final requiredError = _requiredField(value, 'licence number');
    if (requiredError != null) return requiredError;

    final normalized = value!.trim();
    if (!RegExp(r'^[A-Za-z0-9 -]+$').hasMatch(normalized)) {
      return 'Use only letters, numbers, spaces, or hyphens.';
    }

    final compactLength = normalized
        .replaceAll(RegExp(r'[\s-]'), '')
        .length;
    if (compactLength < 8 || compactLength > 20) {
      return 'Licence number must contain 8–20 letters or numbers.';
    }
    return null;
  }

  String? _validateVehicleRegistrationNumber(String? value) {
    final requiredError = _requiredField(
      value,
      'vehicle registration number',
    );
    if (requiredError != null) return requiredError;

    final normalized = value!.trim().toUpperCase();
    final compact = normalized.replaceAll(RegExp(r'[\s-]'), '');
    final isStateRegistration = RegExp(
      r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{1,4}$',
    ).hasMatch(compact);
    final isBharatRegistration = RegExp(
      r'^\d{2}BH\d{4}[A-Z]{2}$',
    ).hasMatch(compact);

    if (!isStateRegistration && !isBharatRegistration) {
      return 'Enter a valid Indian registration number, e.g. MH 12 AB 1234 or 22 BH 1234 AA.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount = _documents.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver Verification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.fact_check_outlined,
                  size: 52,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Verify your driver account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your vehicle details and attach clear copies of the required documents.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _licenseNumberController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_uppercaseInputFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Driving licence number',
                    hintText: 'Enter licence number',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateLicenseNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vehicleRegistrationController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_uppercaseInputFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Vehicle registration number',
                    hintText: 'Enter ambulance registration number',
                    prefixIcon: Icon(Icons.airport_shuttle_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateVehicleRegistrationNumber,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Required documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$uploadedCount/${DriverVerificationDocument.values.length}',
                      style: TextStyle(
                        color:
                            uploadedCount ==
                                DriverVerificationDocument.values.length
                            ? Colors.green
                            : Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, JPG, or PNG · maximum 10 MB each',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                for (final document in DriverVerificationDocument.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DriverDocumentUploadTile(
                      document: document,
                      file: _documents[document],
                      onTap: () => _pickDocument(document),
                      onRemove: () => _removeDocument(document),
                    ),
                  ),
                const SizedBox(height: 12),

                const SizedBox(height: 24),
                FilledButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: _isSubmitting ? null : _submitForReview,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit for Verification',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
