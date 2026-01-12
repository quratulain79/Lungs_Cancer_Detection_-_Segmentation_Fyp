// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'patient_details_page.dart';

class ViewPatientProfilePage extends StatefulWidget {
  const ViewPatientProfilePage({super.key});

  @override
  State<ViewPatientProfilePage> createState() => _ViewPatientProfilePageState();
}

class _ViewPatientProfilePageState extends State<ViewPatientProfilePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // ✅ Mobile Status Bar Padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      // ✅ Frosted Glass AppBar
      appBar: AppBar(
        title: const Text(
          'All Patients Profiles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Transparent for Glass Effect
        elevation: 0,
        centerTitle: true,
        
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

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // ⚪ White Color
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),

        actions: [],
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withOpacity(0.3), // Fixed Overlay
            ),
          ),

          Column(
            children: [
              // ✅ FIX: Spacing adjusted for Mobile
              SizedBox(height: kToolbarHeight + topPadding + 20),

              // 🔍 Search bar (frosted style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name or email',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.teal),
                        ),
                        onChanged: (value) =>
                            setState(() => searchQuery = value.toLowerCase()),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 🩺 Patients list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('patients')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.teal),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No patients found.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    final allPatients = snapshot.data!.docs;
                    final filteredPatients = allPatients.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final email = (data['email'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(searchQuery) ||
                          email.contains(searchQuery);
                    }).toList();

                    if (filteredPatients.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matching patients found.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredPatients[index].data()
                                as Map<String, dynamic>;
                        final name = data['name'] ?? 'Unnamed';
                        final age = data['age']?.toString() ?? '';
                        final email = data['email'] ?? '';

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                subtitle: Text(
                                  'Age: $age\nEmail: $email',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientDetailsPage(
                                          patientData: data,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}