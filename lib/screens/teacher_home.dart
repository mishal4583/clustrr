// lib/screens/teacher_home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clustrr/features/announcements/announcements_screen.dart';
import 'package:clustrr/screens/chat_screen.dart';
import 'package:clustrr/screens/course_material_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool _loading = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? statsData;

  @override
  void initState() {
    super.initState();
    _loadUserAndStats();
  }

  Future<void> _loadUserAndStats() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // No signed-in user — navigate to login or show fallback.
        setState(() {
          userData = null;
          statsData = null;
          _loading = false;
        });
        return;
      }

      final uid = user.uid;

      // 1) Load user document from users/{uid}
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // 2) Load teacher stats doc (optional) at teacher_stats/{uid}
      final statsDoc = await FirebaseFirestore.instance
          .collection('teacher_stats')
          .doc(uid)
          .get();

      setState(() {
        userData = userDoc.exists ? (userDoc.data() ?? {}) : {};
        statsData = statsDoc.exists ? (statsDoc.data() ?? {}) : {};
        _loading = false;
      });
    } catch (e, st) {
      // Keep a small debug print; UI shows fallback values.
      debugPrint('Error loading teacher home data: $e\n$st');
      setState(() {
        userData = {};
        statsData = {};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gradient = const LinearGradient(
      colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Pull values from Firestore or set defaults
    final name = (userData?['name'] as String?) ?? 'Professor';
    final role = (userData?['role'] as String?) ?? 'Teacher';
    final department =
        (userData?['department'] as String?) ??
        (userData?['batchId'] as String?) ??
        'Computer Science';
    final coursesCount = (userData?['coursesCount'] as int?) ?? 4;
    final studentsCount = (userData?['studentsCount'] as int?) ?? 127;
    final avatar = (userData?['avatarUrl'] as String?);

    // Stats (try statsData then fallback)
    final avgAttendance =
        (statsData?['avgAttendance'] as num?)?.toString() ??
        (statsData?['attendance']?.toString()) ??
        '94%';
    final assignmentCompletion =
        (statsData?['assignmentCompletion'] as num?)?.toString() ?? '78%';
    final pendingGrading =
        (statsData?['pendingGrading'] as int?) ??
        (statsData?['pending'] as int?) ??
        12;
    final avgRating =
        (statsData?['avgRating'] as num?)?.toStringAsFixed(1) ?? '4.2';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          // animated background
          const _AnimatedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // App title
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                gradient.createShader(bounds),
                            child: const Text(
                              'Clustrr',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          // Avatar + name + role
                          Row(
                            children: [
                              Container(
                                width: size.width * 0.095,
                                height: size.width * 0.095,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradient,
                                ),
                                child: avatar == null
                                    ? Center(
                                        child: Text(
                                          _initialsFromName(name),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: size.width * 0.04,
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          size.width * 0.095,
                                        ),
                                        child: Image.network(
                                          avatar,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              _initialsFromName(name),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: size.width * 0.04,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.38,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * 0.037,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: size.width * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Welcome section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFA855F7),
                              Color(0xFF3B82F6),
                              Color(0xFF06B6D4),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Welcome back, ${_firstName(name)}!',
                            style: TextStyle(
                              fontSize: size.width * 0.065,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Department: $department | Courses: $coursesCount | Students: $studentsCount',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: size.width * 0.036,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Stats Section (GridView)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildStatsGrid(
                      context,
                      avgAttendance,
                      assignmentCompletion,
                      pendingGrading,
                      avgRating,
                    ),
                  ),

                  // Dashboard Tabs (GridView)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _buildDashboardGrid(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAction(context),
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, size: 28),
      ),

      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  // helper: build stats section using GridView for proper layout
  Widget _buildStatsGrid(
    BuildContext context,
    String avgAttendance,
    String assignmentCompletion,
    int pendingGrading,
    String avgRating,
  ) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final tiles = [
      (
        avgAttendance,
        'Average Attendance',
        '+2%',
        true,
        Icons.bar_chart_rounded,
      ),
      (
        assignmentCompletion,
        'Assignment Completion',
        '+5%',
        true,
        Icons.task_alt_rounded,
      ),
      (
        pendingGrading.toString(),
        'Pending Grading',
        '-3',
        false,
        Icons.pending_actions_rounded,
      ),
      ('💬', 'Messages', 'Chat', true, Icons.chat_bubble_outline_rounded),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: tiles.map((t) {
        final (value, label, trend, up, icon) = t;

        if (label == 'Messages') {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatRoomId: 'general'),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: _glassStyle(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                    ).createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: width * 0.1),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.04,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }

        // Default stat card
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: _glassStyle(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: up
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: up ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.028,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                    ).createShader(bounds),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: width * 0.085,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.034,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // dashboard tabs built with GridView for proper layout
  Widget _buildDashboardGrid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final tabs = [
      (
        'Class Announcements',
        FontAwesomeIcons.bullhorn,
        'Post and manage ',
        '2 New',
      ),
      (
        'Course Materials',
        FontAwesomeIcons.folderOpen,
        'Upload and organize resources',
        null,
      ),
      (
        'Assignments',
        FontAwesomeIcons.tasks,
        'Create, manage, and grade assignments',
        null,
      ),
      (
        'Grade Center',
        FontAwesomeIcons.chartBar,
        'Track student performance',
        null,
      ),
      (
        'Attendance',
        FontAwesomeIcons.clipboardCheck,
        'Track and manage attendance',
        null,
      ),
      (
        'Analytics',
        FontAwesomeIcons.chartPie,
        'View performance insights',
        null,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        children: tabs.map((t) {
          final (title, icon, desc, badge) = t;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (title == 'Class Announcements') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementsScreen(role: 'teacher'),
                  ),
                );
              } else if (title == 'Course Materials') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseMaterialScreen(role: 'teacher'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open: $title (to be implemented)')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: _glassStyle(),
              child: Stack(
                children: [
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                        ).createShader(bounds),
                        child: Icon(
                          icon,
                          size: width * 0.07,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: width * 0.03,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showQuickAction(BuildContext context) {
    final actions = [
      "Create New Assignment",
      "Schedule Office Hours",
      "Upload Lecture Notes",
      "Send Class Announcement",
      "Generate Progress Report",
    ];
    final randomAction = (actions..shuffle()).first;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Quick Action: $randomAction"),
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _firstName(String full) {
    if (full.trim().isEmpty) return 'Professor';
    return full.trim().split(' ').first;
  }

  static String _initialsFromName(String full) {
    final parts = full.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

/// Animated background used by teacher/home and others
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
                Color(0xFF533483),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_controller.value * 6.28319),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom nav — static visual only (adjust later)
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.chat_bubble_outline, 'Chat'),
      (Icons.campaign_outlined, 'Announcements'),
      (Icons.folder_open, 'Materials'),
      (Icons.person, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((it) {
          return GestureDetector(
            onTap: () {
              if (it.$2 == 'Chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(chatRoomId: 'general'),
                  ),
                );
              } else if (it.$2 == 'Announcements') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementsScreen(role: 'teacher'),
                  ),
                );
              } else if (it.$2 == 'Materials') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseMaterialScreen(role: 'teacher'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile page coming soon!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF7C3AED),
                  ),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(it.$1, color: Colors.white70, size: 22),
                const SizedBox(height: 3),
                Text(
                  it.$2,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Shared glassmorphism style used by cards
BoxDecoration _glassStyle() {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 8,
        offset: const Offset(0, 5),
      ),
    ],
    backgroundBlendMode: BlendMode.overlay,
  );
}
