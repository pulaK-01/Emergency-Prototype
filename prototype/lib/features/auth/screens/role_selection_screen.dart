import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medirapid/features/patient/models/user_model.dart';
import 'package:medirapid/shared/widgets/custom_button2.dart';
import 'package:medirapid/shared/widgets/custom_button1.dart';
import 'package:medirapid/features/auth/screens/phone_authentication.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.25, .5, 0.75, 1.0],
            colors: [
              Colors.red,
              Color(0xFFF8F8F8),
              Colors.white,
              Color(0xFFF8F8F8),
              Color(0xFF185FA5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 280,
                    height: 200,
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  Text(
                    'How Would You Like\nto Continue?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade500,
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    "Your role cannot be changed later.",
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  CustomButton1(
                    label: 'I need Emergency Help',
                    icon: Icons.medical_services,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneAuthenticationScreen(
                            role: UserRole.patient,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton2(
                    label: "I'm an Ambulance Driver",
                    icon: Icons.airport_shuttle_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneAuthenticationScreen(
                            role: UserRole.driver,
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // help button
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    iconAlignment: IconAlignment.end,
                    label: const Text(
                      'Need help',
                      style: TextStyle(fontSize: 20),
                    ),
                    icon: const Icon(Icons.help_outlined),

                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Choose the role for your account'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Choose this if you may need emergency help.',
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Ambulance driver',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Choose this if you respond to emergency  as a driver.",
                              ),
                              SizedBox(height: 24),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),

                              Text(
                                "Your choice will be saved to your account and used to open the right home screen when you sign'in.",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Got it',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
