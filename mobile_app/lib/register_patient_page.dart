// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  bool showPasswordHint = false;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        showPasswordHint = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        title: const Text(
          'Patient Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        
        // ✅ FIXED: Color moved inside decoration
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.5), // ✅ Color yahan hona chahiye
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
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/welcome.jpeg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24, 
                vertical: kToolbarHeight + topPadding + 40 
              ), 
              
              child: Container(
                width: isWide ? 500 : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        '🩺 Register A New Patient',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 25),

                      _buildTextField(_nameController, 'Full Name', Icons.person),
                      _buildTextField(_emailController, 'Email', Icons.email,
                          inputType: TextInputType.emailAddress),
                      _buildTextField(
                        _phoneController,
                        'Phone Number',
                        Icons.phone,
                        inputType: TextInputType.phone,
                      ),
                      _buildTextField(
                        _ageController,
                        'Age',
                        Icons.cake,
                        inputType: TextInputType.number,
                      ),
                      _buildGenderField(),

                      _buildPasswordField(
                        _passwordController,
                        'Password',
                        focusNode: _passwordFocusNode,
                      ),
                      _buildPasswordField(
                        _confirmPasswordController,
                        'Confirm Password',
                      ),

                      if (showPasswordHint) _buildPasswordRequirements(),

                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.teal)
                          : ElevatedButton.icon(
                              onPressed: _registerPatient,
                              icon: const Icon(Icons.person_add,
                                  color: Colors.white),
                              label: const Text('Register',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                      const SizedBox(height: 10), 
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Reusable Widgets
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';

          if (label == 'Full Name' &&
              !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
            return 'Name can only contain letters';
          }

          if (label == 'Phone Number' &&
              !RegExp(r'^03[0-9]{9}$').hasMatch(value)) {
            return 'Enter valid 11-digit number (03XXXXXXXXX)';
          }

          if (label == 'Age') {
            final age = int.tryParse(value);
            if (age == null || age <= 0 || age > 120) {
              return 'Enter valid age (1–120)';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: _gender,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.transgender, color: Colors.teal),
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => _gender = v),
        validator: (v) => v == null ? 'Please select gender' : null,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      {FocusNode? focusNode}) {
    bool isPassword = label == 'Password';
    bool isConfirm = label == 'Confirm Password';
    bool obscureText = isPassword ? _obscurePassword : _obscureConfirmPassword;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        validator: (value) {
          if (isConfirm && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          if (isPassword) {
            if (value == null || value.isEmpty) return 'Password required';
            if (value.length < 8) return 'Minimum 8 characters';
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Include at least 1 uppercase letter';
            }
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Include at least 1 lowercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Include at least 1 number';
            }
            if (!RegExp(r'[!@#\$&*~%^()]').hasMatch(value)) {
              return 'Include at least 1 special character';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.teal),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: IconButton(
            icon:
                Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Text(
          'Password must be at least 8 characters.\nInclude uppercase, lowercase, number & special character.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  // 🧠 Register Logic
  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text);

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(credential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _gender,
        'uid': credential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user!.sendEmailVerification();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Verify Email'),
          content: const Text(
              '✅ Registered successfully!\nCheck your email for verification link.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') message = 'Email already in use';
      if (e.code == 'weak-password') message = 'Weak password';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}