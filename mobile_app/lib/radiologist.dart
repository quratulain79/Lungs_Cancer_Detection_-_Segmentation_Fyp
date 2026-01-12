// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'register_patient_page.dart';
import 'view_patient_profile_page.dart';

class RadiologistPage extends StatefulWidget {
  // ✅ CHANGE: Name variable add kiya
  final String radiologistName;

  const RadiologistPage({super.key, required this.radiologistName});

  @override
  State<RadiologistPage> createState() => _RadiologistPageState();
}

class _RadiologistPageState extends State<RadiologistPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      
      appBar: AppBar(
        title: const Text(
          'Radiologist Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, 
        elevation: 0, 

        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2), 
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => isDarkMode = !isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.3),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: kToolbarHeight + topPadding + 40),

                Image.asset(
                  'assets/logo.png',
                  height: 160,
                  width: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),

                // ✅ CHANGE: Yahan ab Asli Naam show hoga
                Text(
                  'Welcome, ${widget.radiologistName}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      buildSquareCard(
                        icon: Icons.person_add,
                        title: 'Register\nPatient',
                        color: Colors.teal,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPatientPage(),
                            ),
                          );
                        },
                      ),
                      buildSquareCard(
                        icon: Icons.account_circle,
                        title: 'View\nProfile',
                        color: Colors.deepPurple,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ViewPatientProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSquareCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}