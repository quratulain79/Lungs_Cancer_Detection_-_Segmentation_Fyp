// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:ui';
import 'upload_ctscan_page.dart'; // Ensure filename is correct

class PatientDetailsPage extends StatefulWidget {
  final dynamic patientData;

  const PatientDetailsPage({super.key, required this.patientData});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final patientData = widget.patientData;
    final name = patientData['name'] ?? 'No Name';
    final age = patientData['age'] ?? '';
    final email = patientData['email'] ?? '';
    final gender = patientData['gender'] ?? '';
    final phone = patientData['phone'] ?? '';
    final uid = patientData['uid'] ?? ''; 

    // ✅ Mobile Status Bar Padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      // ✅ Frosted Glass AppBar
      appBar: AppBar(
        title: Text(
          "$name's Profile",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌄 Background Image
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),

          // 🌫️ Blur Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black.withOpacity(0.3),
            ),
          ),

          // 🌟 Profile Content
          SingleChildScrollView(
            // ✅ FIX: Spacing adjusted for Mobile (Navbar Height + Status Bar)
            padding: EdgeInsets.symmetric(
              horizontal: 24, 
              vertical: kToolbarHeight + topPadding + 40 // Dynamic Spacing
            ),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🧾 Patient Info
                _buildInfoRow('Age', age.toString()),
                _buildInfoRow('Email', email),
                _buildInfoRow('Gender', gender),
                _buildInfoRow('Phone', phone),
                _buildInfoRow('UID', uid, color: Colors.white70),
                const SizedBox(height: 50),

                // 🔘 Button (Only Upload CT-Scan remains)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (uid == '' || uid == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Patient UID missing!')),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadCTScanPage(
                              patientId: uid,    // Pass UID
                              patientName: name, // Pass Name
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text(
                        'Upload CT-Scan',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                    ),
                    
                    // ❌ View History Button Removed
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for info rows
  Widget _buildInfoRow(String label, String value,
      {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}