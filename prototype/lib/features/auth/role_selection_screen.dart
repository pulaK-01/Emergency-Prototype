import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emergency_prototype/core/routes/app_routes.dart';
import 'package:emergency_prototype/models/user_model.dart';
import 'package:emergency_prototype/shared/widgets/custom_button2.dart';
import 'package:emergency_prototype/shared/widgets/custom_button1.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height:100),
                Container(
                  /* decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ), */
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // description about our App
                /* Padding(padding: EdgeInsets.only(left:36),
                  child: Text(
                    "Emergency help,when every second matters ",
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ), */
                const SizedBox(height: 80),
                Text(
                  'Welcome',
                  style: GoogleFonts.sora(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),

                /* const Text(
                  'Choose how you want to continues',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ), */
                const SizedBox(height: 20),
                CustomButton1(
                  label: 'Continue as Patient',
                  icon: Icons.medical_services,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.patientHome,
                      arguments: const UserModel(
                        name: 'Patient User',
                        role: UserRole.patient,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomButton2(
                  label: 'Continue as Driver',
                  icon: Icons.local_taxi,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.driverHome,
                      arguments: const UserModel(
                        name: 'Driver User',
                        role: UserRole.driver,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),

                Text('Need help?',style:TextStyle(fontSize:20,color:Colors.black))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
