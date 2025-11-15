// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_home.dart';
import 'cr_home.dart';
import 'teacher_home.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  String selectedRole = '';
  bool loading = false;

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final batchId = batchController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (selectedRole.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Select a role')));
      }
      return;
    }

    if (name.isEmpty || email.isEmpty || batchId.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 chars')),
        );
      }
      return;
    }

    if (password != confirm) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      }
      return;
    }

    setState(() => loading = true);

    try {
      // 1) Create Firebase auth user
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      final user = userCred.user;
      if (user == null) throw Exception("User creation failed");

      // 2) Create Firestore doc
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'batchId': batchId,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 3) Navigate by role
      if (selectedRole == 'Student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
        );
      } else if (selectedRole == 'CR') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CRHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    batchController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Clustrr',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF66D3FF),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),

                // ROLE SELECT
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Student'),
                      selected: selectedRole == 'Student',
                      onSelected: (_) =>
                          setState(() => selectedRole = 'Student'),
                      selectedColor: Colors.purple.shade700,
                      backgroundColor: Colors.white12,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    ChoiceChip(
                      label: const Text('CR'),
                      selected: selectedRole == 'CR',
                      onSelected: (_) => setState(() => selectedRole = 'CR'),
                      selectedColor: Colors.purple.shade700,
                      backgroundColor: Colors.white12,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    ChoiceChip(
                      label: const Text('Teacher'),
                      selected: selectedRole == 'Teacher',
                      onSelected: (_) =>
                          setState(() => selectedRole = 'Teacher'),
                      selectedColor: Colors.purple.shade700,
                      backgroundColor: Colors.white12,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // NAME
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    hintText: 'Full name',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 12),

                // EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 12),

                // BATCH
                TextField(
                  controller: batchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge, color: Colors.white70),
                    hintText: 'Batch ID (eg. CS2024)',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 12),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 12),

                // CONFIRM
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.white70,
                    ),
                    hintText: 'Confirm password',
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 18),

                ElevatedButton(
                  onPressed: loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 6,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Account'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.white70),
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
