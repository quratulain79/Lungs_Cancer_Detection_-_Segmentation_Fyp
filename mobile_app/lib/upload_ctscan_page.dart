// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadCTScanPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const UploadCTScanPage({
    super.key, 
    required this.patientId, 
    required this.patientName
  });

  @override
  State<UploadCTScanPage> createState() => _UploadCTScanPageState();
}

class _UploadCTScanPageState extends State<UploadCTScanPage> {
  io.File? _imageFile;
  Uint8List? _imageBytes;
  String? _result;
  double? _confidence;
  
  // ✅ New Variables for 3 Generated Images
  String? _maskUrl;
  String? _heatmapUrl;
  String? _bboxUrl;
  
  bool _isLoading = false;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null;
          _resetResults();
        });
      } else {
        setState(() {
          _imageFile = io.File(pickedFile.path);
          _imageBytes = null;
          _resetResults();
        });
      }
    }
  }

  void _resetResults() {
    _result = null;
    _confidence = null;
    _maskUrl = null;
    _heatmapUrl = null;
    _bboxUrl = null;
  }

  Future<void> _uploadAndPredict() async {
    if (_imageFile == null && _imageBytes == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select an image first!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("http://quratulain79.pythonanywhere.com/predict");
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('image', _imageBytes!, filename: 'upload.png'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path, filename: basename(_imageFile!.path)));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final decoded = jsonDecode(responseData.body);
        
        // Time stamp to force refresh images
        String t = DateTime.now().millisecondsSinceEpoch.toString();

        setState(() {
          _result = decoded['prediction'];
          _confidence = decoded['confidence'];
          
          if (decoded['mask_url'] != null) {
            _maskUrl = '${decoded['mask_url']}?t=$t';
            _heatmapUrl = '${decoded['heatmap_url']}?t=$t';
            _bboxUrl = '${decoded['bbox_url']}?t=$t';
          } else {
            _maskUrl = null;
            _heatmapUrl = null;
            _bboxUrl = null;
          }
        });

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('✅ Prediction Complete! Check Visualization Layers.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('❌ Failed! Status: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResultToPatientProfile() async {
    if (_result == null) {
       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('⚠️ Pehle Scan Predict karo!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.patientId.isEmpty) {
       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('❌ Error: Patient ID Missing!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? radiologist = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('scans')
          .add({
            'diagnosis': _result,
            'confidence': _confidence,
            'radiologistId': radiologist?.uid,
            'radiologistEmail': radiologist?.email,
            'timestamp': FieldValue.serverTimestamp(),
            
            'maskUrl': _maskUrl,
            'heatmapUrl': _heatmapUrl,
            'bboxUrl': _bboxUrl,
            'segmentationUrl': _bboxUrl, // For Doctor Dashboard

            'status': 'Finalized'
          });

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('✅ Result Saved Successfully!'), backgroundColor: Colors.green),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context as BuildContext);

    } catch (e) {
      print("❌ SAVE ERROR: $e");
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('❌ Save Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _refreshPage() {
    setState(() {
      _imageFile = null;
      _imageBytes = null;
      _resetResults();
    });
  }

  Widget _buildResultCard(String title, String? imageUrl) {
    if (imageUrl == null) return const SizedBox.shrink();
    return Container(
      width: 150, 
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.6), width: 1.5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, 
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Image.network(
              imageUrl, 
              height: 130, 
              width: double.infinity, 
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 130,
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        title: const Text('CT-Scan Analysis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.teal.withOpacity(0.5)),
          ),
        ),
      ),
      
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.only(left: 20, right: 20, top: kToolbarHeight + topPadding + 20, bottom: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                  child: Text('Scanning: ${widget.patientName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 20),

                // 2. Original Image Display (FIXED: BoxFit.contain)
                if (_imageFile != null || _imageBytes != null)
                  Column(
                    children: [
                      const Text("Original Scan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      
                      // 🔥 MAIN FIX: Box Fit Contain se image stretch nahi hogi
                      Container(
                        height: 250, // Thoda height barha di taaki clear dikhe
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white24)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb
                              ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                              : Image.file(_imageFile!, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white38, style: BorderStyle.solid, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.white70),
                          SizedBox(height: 10),
                          Text("Tap to Upload CT Scan", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // 3. Analyze Button
                if (_imageFile != null || _imageBytes != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadAndPredict,
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.analytics, color: Colors.white),
                      label: Text(_isLoading ? 'Processing AI Models...' : 'Run Analysis', style: const TextStyle(color: Colors.white, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                    ),
                  ),

                // 4. RESULTS SECTION
                if (_result != null) ...[
                  const SizedBox(height: 30),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _result!.contains('Malignant') ? Colors.redAccent : Colors.greenAccent,
                        width: 2
                      ),
                      boxShadow: [
                         BoxShadow(
                           color: _result!.contains('Malignant') ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                           blurRadius: 10,
                           spreadRadius: 2
                         )
                      ]
                    ),
                    child: Column(
                      children: [
                        Text('Diagnosis', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(_result!, style: TextStyle(
                          color: _result!.contains('Malignant') ? Colors.redAccent : Colors.greenAccent, 
                          fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        if (_confidence != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                            child: Text('AI Confidence: ${_confidence!.toStringAsFixed(1)}%', 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                  ),

                  if (_maskUrl != null) ...[
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft, 
                      child: Text("AI Visualization Layers:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                    ),
                    const SizedBox(height: 15),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildResultCard("Binary Mask", _maskUrl),
                          _buildResultCard("Heatmap Overlay", _heatmapUrl),
                          _buildResultCard("Detection Box", _bboxUrl),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveResultToPatientProfile,
                          icon: const Icon(Icons.save_alt, color: Colors.white),
                          label: Text(_isSaving ? 'Saving...' : 'Save Report', style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _refreshPage,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('New Scan', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}