// ignore_for_file: deprecated_member_use

import 'dart:ui'; // 👈 for blur effect
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool isLoading = false;
  bool showPasswordHint = false;
  String? emailErrorText;
  String selectedRole = 'Doctor';

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'At least one uppercase';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'At least one lowercase';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'At least one number';
    if (!RegExp(r'[!@#\$&*~%^()]').hasMatch(value)) {
      return 'At least one special';
    }
    return null;
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': selectedRole,
      });

      await userCred.user!.sendEmailVerification();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Verify Email'),
          content: const Text(
            'Registration successful!\n\nA verification link has been sent to your email. Please verify before logging in.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        emailErrorText = (e.code == 'email-already-in-use')
            ? 'Email already in use'
            : 'Registration failed';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dynamicNameLabel =
        selectedRole == 'Doctor' ? 'Doctor Name' : 'Radiologist Name';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Background image
          Image.asset(
            'assets/welcome.jpeg',
            fit: BoxFit.cover,
          ),

          // 🔹 Blurred overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 🔹 Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 370,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 Bigger logo
                          Image.asset(
                            'assets/logo.png',
                            height: 200,
                          ),
                          const SizedBox(height: 0),

                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Name
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: dynamicNameLabel,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? '$dynamicNameLabel is required'
                                : null,
                          ),
                          const SizedBox(height: 10),

                          // Email
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              errorText: emailErrorText,
                              prefixIcon:
                                  const Icon(Icons.email_outlined, size: 22),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _validatePassword,
                          ),

                          if (showPasswordHint)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '• At least 8 characters\n• 1 uppercase\n• 1 lowercase\n• 1 number\n• 1 special character',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),

                          // Role Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            items: ['Doctor', 'Radiologist']
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedRole = value!),
                            decoration: InputDecoration(
                              labelText: 'Select Role',
                              prefixIcon: const Icon(Icons.account_box),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Register button
                          ElevatedButton(
                            onPressed: isLoading ? null : handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),

                          // Login link
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                                context, '/login'),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
