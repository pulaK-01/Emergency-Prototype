import 'package:medirapid/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medirapid/features/patient/models/user_model.dart';

class PhoneAuthenticationScreen extends StatefulWidget {
  const PhoneAuthenticationScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<PhoneAuthenticationScreen> createState() =>
      _PhoneAuthenticationScreenState();
}

class _PhoneAuthenticationScreenState extends State<PhoneAuthenticationScreen> {
  final _detailsFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpStep = false;

  bool get _isPatient => widget.role == UserRole.patient;

  Color get _roleColor => _isPatient ? Colors.redAccent : Colors.blueAccent;

  String get _roleName => _isPatient ? 'Patient' : 'Driver';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showVerificationPreview() {
    if (!_detailsFormKey.currentState!.validate()) return;
    setState(() => _showOtpStep = true);
  }

  void _changePhoneNumber() {
    setState(() {
      _showOtpStep = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _showOtpStep ? 'Verify your number' : 'Create your account';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: _roleColor,
        backgroundColor: Colors.grey.shade200,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _showOtpStep ? _otpFormKey : _detailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      _isPatient
                          ? Icons.medical_services
                          : Icons.airport_shuttle_rounded,
                      color: _roleColor,
                      size: 24,
                    ),
                    label: Text(
                      '$_roleName account',
                      style: TextStyle(fontSize: 18),
                    ),
                    side: BorderSide(color: _roleColor.withValues(alpha: 0.4)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _showOtpStep
                      ? 'Enter the one-time code'
                      : 'Get started with your phone',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showOtpStep
                      ? 'The code would be sent to ${_phoneController.text.trim()}'
                      : 'We’ll use your phone number to create and access your account.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                if (!_showOtpStep) ...[
                  // account details screen

                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(value.trim())) {
                        return 'Only letters and spaces are allowed';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: 'Include your country code',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                      if (digits.length < 10 || digits.length > 15) {
                        return 'Enter a valid phone number with country code';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    style: FilledButton.styleFrom(
                      backgroundColor: _roleColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _showVerificationPreview,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ] else ...[
                  //---> otp screen

                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: '4-digit code',
                      hintText: '••••',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length != 4) {
                        return 'Enter the 4-digit code';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text(''),
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    onPressed: () {
                      if (_isPatient) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.patientHome,
                          (route) => false,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.driverVerification,
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_forward_rounded),
                    label: const Text('Verify', style: TextStyle(fontSize: 20)),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _changePhoneNumber,
                      child: const Text('Change phone number'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
