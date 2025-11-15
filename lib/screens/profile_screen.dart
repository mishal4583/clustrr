import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _loading = true;

  String name = '';
  String email = '';
  String role = '';
  String batch = '';
  String avatar = '👤';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() => _loading = false);
        return;
      }

      final data = doc.data() ?? {};

      setState(() {
        name = data['name'] ?? 'Unknown';
        email = data['email'] ?? user.email ?? 'No Email';
        batch = data['batchId'] ?? 'N/A';

        // 🔥 Safe role normalization
        final rawRole = (data['role'] ?? '').toString();
        if (rawRole.isNotEmpty) {
          role = rawRole.toUpperCase();
          // Show pretty version
          role = role[0] + role.substring(1).toLowerCase();
        } else {
          role = 'Unknown';
        }

        // 🔥 Avatar fallback (avoid crash if field missing)
        avatar = data.containsKey('avatar') ? data['avatar'] : '👤';

        _loading = false;
      });
    } catch (e) {
      debugPrint("Profile load error: $e");
      setState(() => _loading = false); // <-- IMPORTANT FIX
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                      Color(0xFF533483),
                    ],
                    transform: GradientRotation(_controller.value * 6.28318),
                  ),
                ),
              );
            },
          ),

          // Loading state
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                      ),
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 55)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 25),

                  glassCard(
                    child: Column(
                      children: [
                        infoRow("Role", role),
                        const SizedBox(height: 12),
                        infoRow("Batch", batch),
                        const SizedBox(height: 12),
                        infoRow("Status", "Active"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  glassCard(
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Colors.white70),
                      title: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white60,
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
