import 'package:clustrr/screens/chat_screen.dart';
import 'package:clustrr/screens/course_material_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clustrr/features/announcements/announcements_screen.dart';
import 'package:clustrr/screens/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  int _selectedIndex = 0;

  final LinearGradient _gradient = const LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() => loading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> get _pages => [
    _buildHomeContent(),
    const ChatScreen(chatRoomId: 'general'),
    const CourseMaterialScreen(role: 'student'),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
        body: Center(
          child: Text(
            'User data not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: _buildAppBar(),
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    final name = userData!['name'] ?? 'Student';
    final role = userData!['role'] ?? 'STUDENT';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) => _gradient.createShader(bounds),
        child: const Text(
          'Clustrr',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _gradient,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    role.toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    final name = userData!['name'] ?? 'Student';
    final batch = userData!['batchId'] ?? 'Unknown Batch';
    final role = userData!['role'] ?? 'STUDENT';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => _gradient.createShader(bounds),
            child: Text(
              "Welcome back, $name!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Batch: $batch | Role: ${role.toUpperCase()}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTab(
                context,
                FontAwesomeIcons.bullhorn,
                "Announcements",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AnnouncementsScreen(role: 'student'),
                    ),
                  );
                },
                badge: "3 New",
              ),
              _buildTab(
                context,
                FontAwesomeIcons.comments,
                "Chat",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ChatScreen(chatRoomId: 'general'),
                    ),
                  );
                },
              ),
              _buildTab(
                context,
                FontAwesomeIcons.folderOpen,
                "Resources",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CourseMaterialScreen(role: 'student'),
                    ),
                  );
                },
              ),
              _buildTab(context, FontAwesomeIcons.tasks, "CR Board"),
              _buildTab(context, FontAwesomeIcons.clock, "Reminders"),
              _buildTab(context, FontAwesomeIcons.users, "Study Rooms"),
            ],
          ),

          const SizedBox(height: 30),
          _buildQuickStats(_gradient),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: _gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Quick Action pressed")));
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0B0F14).withOpacity(0.9),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFA855F7),
      unselectedItemColor: Colors.white60,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open),
          label: "Resources",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    IconData icon,
    String title, {
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main content (icon + text)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => _gradient.createShader(bounds),
                  child: Icon(icon, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            // Red badge (like "3 New")
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(LinearGradient gradient) {
    final stats = [
      {"label": "Active Students", "value": "127"},
      {"label": "Resources", "value": "15"},
      {"label": "Rooms", "value": "8"},
      {"label": "Tasks", "value": "3"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: Text(
                  stat["value"]!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stat["label"]!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
