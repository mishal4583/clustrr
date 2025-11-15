import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import 'screens/student_home.dart';
import 'screens/cr_home.dart';
import 'screens/teacher_home.dart';
import 'screens/login_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const ClustrrApp());
}

class ClustrrApp extends StatelessWidget {
  const ClustrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clustrr',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF0D0D0D)),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/student_home': (context) => const StudentHomeScreen(),
        '/cr_home': (context) => const CRHomeScreen(),
        '/teacher_home': (context) => const TeacherHomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

/// 🧭 Role-Based Navigation after Login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      final dynamic role = data['role'];
      if (role is String) return role.trim();

      return null;
    } catch (e) {
      debugPrint("ERROR FETCHING USER ROLE: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Note: Since this is stateless, the FutureBuilder will rebuild when the
    // user stream changes, but typically it is wrapped in StreamBuilder/Listener for real-time auth changes.
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        // Waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No user, error, or no role found
        final role = snapshot.data;
        if (role == null || snapshot.hasError) return const LoginScreen();

        // Navigate based on role
        switch (role.toUpperCase()) {
          case 'STUDENT':
            return const StudentHomeScreen();
          case 'CR':
            return const CRHomeScreen();
          case 'TEACHER':
            return const TeacherHomeScreen();
          default:
            // Fallback for an unrecognised role string
            return const LoginScreen();
        }
      },
    );
  }
}
