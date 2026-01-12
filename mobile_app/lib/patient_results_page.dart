// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class PatientResultsPage extends StatelessWidget {
  final String? patientId;

  const PatientResultsPage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uidToUse = patientId ?? currentUser?.uid;
    
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      // ✅ Frosted Glass AppBar
      appBar: AppBar(
        title: const Text('Test Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Transparent
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🌄 Background
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 🌟 Content Area
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + topPadding + 20, 
              left: 16, 
              right: 16
            ),
            
            // 🔥 STEP 1: Check Karo ke dekhne wala Banda "Doctor" hai ya nahi?
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
              builder: (context, userSnapshot) {
                
                // Loading State for User Check
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.teal));
                }

                // Default Role check
                bool isDoctor = false;
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                   var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                   // Check role field (Adjust 'Doctor' if your DB uses 'Radiologist')
                   if (userData['role'] == 'Doctor') {
                     isDoctor = true;
                   }
                }

                // 🔥 STEP 2: Ab Scans Load Karo
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('patients')
                      .doc(uidToUse)
                      .collection('scans')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.teal));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No medical reports found.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        
                        final diagnosis = data['diagnosis'] ?? 'Unknown';
                        final confidence = data['confidence']?.toString() ?? '0';
                        Timestamp? t = data['timestamp'];
                        String dateStr = t != null 
                            ? "${t.toDate().day}-${t.toDate().month}-${t.toDate().year}" 
                            : "N/A";
                        
                        // Extract URLs
                        final segmentationUrl = data['segmentationUrl'];
                        final maskUrl = data['maskUrl'];
                        final heatmapUrl = data['heatmapUrl'];
                        final bboxUrl = data['bboxUrl'];

                        bool hasThreeImages = maskUrl != null && heatmapUrl != null && bboxUrl != null;

                        final isMalignant = diagnosis.toString().toLowerCase().contains('malignant');
                        final statusColor = isMalignant ? Colors.redAccent : Colors.greenAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.6), width: 2),
                            boxShadow: [
                              const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                            ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row (Date & Icon)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                    Icon(
                                      isMalignant ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                      color: statusColor,
                                      size: 28,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                
                                // Diagnosis Text
                                Text(
                                  "Diagnosis: $diagnosis",
                                  style: TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold,
                                    color: isMalignant ? Colors.red.shade900 : Colors.green.shade900
                                  ),
                                ),
                                Text(
                                  "AI Confidence: $confidence%",
                                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                                
                                // 🔥 LOGIC: Images sirf tab dikhayo agar Banda DOCTOR hai
                                if (isDoctor) ...[
                                   const SizedBox(height: 10),
                                   const Divider(),
                                   
                                   if (hasThreeImages) ...[
                                       const Text("AI Visualization Layers:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                       const SizedBox(height: 10),
                                       SingleChildScrollView(
                                         scrollDirection: Axis.horizontal,
                                         physics: const BouncingScrollPhysics(),
                                         child: Row(
                                           children: [
                                             _buildSmallImageCard("Binary Mask", maskUrl),
                                             _buildSmallImageCard("Heatmap", heatmapUrl),
                                             _buildSmallImageCard("Detection", bboxUrl),
                                           ],
                                         ),
                                       )
                                   ] else if (segmentationUrl != null) ...[
                                      // Fallback for old data
                                      ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        title: const Text("View Scan Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        children: [
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.network(
                                              segmentationUrl, 
                                              height: 250,
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                   ]
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Helper Widget to build small cards for 3 images
  Widget _buildSmallImageCard(String title, String? url) {
    if (url == null) return const SizedBox.shrink();
    return Container(
      width: 130, 
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.5))
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, 
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Image.network(
              url, 
              height: 110, 
              width: double.infinity, 
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 110,
                  color: Colors.grey.shade900,
                  child: const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}