// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'patient_results_page.dart';

class PatientPage extends StatefulWidget {
  // ✅ CHANGE 1: Name variable add kiya
  final String patientName;

  const PatientPage({super.key, required this.patientName});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Mobile Status Bar Padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Transparent for Glass Effect
        elevation: 0,

        // ✨ Glass Effect Code
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.5), // Teal Tint
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

      // 🌄 Background with blur
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

          // 🌟 Main content
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ FIX: Spacing adjusted for Mobile
                SizedBox(height: kToolbarHeight + topPadding + 60),

                // 🔹 Logo
                Image.asset(
                  'assets/logo.png',
                  height: 160, // Adjusted size
                  width: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),

                // ✅ CHANGE 2: Yahan ab Asli Naam show hoga
                Text(
                  'Welcome, ${widget.patientName}!',
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

                // 🌈 Frosted option cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Center(
                    // Wrap ko Center kia taake akela button beech ma aye
                    child: buildSquareCard(
                      icon: Icons.receipt_long,
                      title: 'View\nTest Results',
                      color: Colors.teal,
                      onPressed: () {
                        // Check login status
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PatientResultsPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login again!'),
                            ),
                          );
                        }
                      },
                    ),
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

  // 🌟 Cute frosted square cards
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
            height: 160, // Thoda size barha diya kyunki ab akela hai
            width: 160,
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
                  child: Icon(icon, size: 45, color: Colors.white),
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
