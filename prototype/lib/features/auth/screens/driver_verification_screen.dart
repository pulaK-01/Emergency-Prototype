import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medirapid/core/routes/app_routes.dart';

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
  final Map<_DriverDocument, PlatformFile> _documents = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _vehicleRegistrationController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(_DriverDocument document) async {
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

  void _removeDocument(_DriverDocument document) {
    setState(() => _documents.remove(document));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    final missingDocuments = _DriverDocument.values
        .where((document) => !_documents.containsKey(document))
        .toList();
    if (missingDocuments.isNotEmpty) {
      _showMessage('Please attach all required documents to continue.');
      return;
    }

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
          'Your information is ready for review. Document verification '
          'will be completed once the app is connected to its verification service.',
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
      AppRoutes.driverHome,
      (route) => false,
    );
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
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
                  'Enter your vehicle details and attach clear copies of the '
                  'required documents.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _licenseNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Driving licence number',
                    hintText: 'Enter licence number',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _requiredField(value, 'licence number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vehicleRegistrationController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle registration number',
                    hintText: 'Enter ambulance registration number',
                    prefixIcon: Icon(Icons.airport_shuttle_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _requiredField(value, 'vehicle registration number'),
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
                      '$uploadedCount/${_DriverDocument.values.length}',
                      style: TextStyle(
                        color: uploadedCount == _DriverDocument.values.length
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
                const SizedBox(height: 12),
                for (final document in _DriverDocument.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DocumentUploadTile(
                      document: document,
                      file: _documents[document],
                      onTap: () => _pickDocument(document),
                      onRemove: () => _removeDocument(document),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Files are selected on this device only. Online upload '
                          'and document review require a verification service.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
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

enum _DriverDocument {
  drivingLicence(
    title: 'Driving licence',
    subtitle: 'A valid licence for ambulance driving',
    icon: Icons.badge_outlined,
  ),
  vehicleRegistration(
    title: 'Vehicle registration certificate',
    subtitle: 'Registration for the ambulance vehicle',
    icon: Icons.airport_shuttle_outlined,
  ),
  vehicleInsurance(
    title: 'Vehicle insurance',
    subtitle: 'Current insurance document',
    icon: Icons.shield_outlined,
  ),
  ambulancePermit(
    title: 'Ambulance permit / fitness certificate',
    subtitle: 'Valid permit or fitness certification',
    icon: Icons.health_and_safety_outlined,
  );

  const _DriverDocument({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.document,
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  final _DriverDocument document;
  final PlatformFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isUploaded = file != null;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isUploaded ? Icons.description_outlined : document.icon,
          color: isUploaded ? Colors.green : Colors.blueAccent,
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isUploaded ? file!.name : document.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isUploaded
            ? IconButton(
                tooltip: 'Remove ${document.title}',
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.redAccent),
              )
            : const Icon(Icons.upload_file_outlined),
      ),
    );
  }
}
