import 'dart:typed_data';
import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseMaterialScreen extends StatefulWidget {
  final String role; // teacher | cr | student
  const CourseMaterialScreen({super.key, required this.role});

  @override
  State<CourseMaterialScreen> createState() => _CourseMaterialScreenState();
}

class _CourseMaterialScreenState extends State<CourseMaterialScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _uploading = false;

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true, // Ensures bytes are available on web
      );
      if (result == null) return;

      final picked = result.files.single;
      final fileName = picked.name;
      final Uint8List? fileBytes = picked.bytes;
      final String? filePath = picked.path;

      if (kIsWeb && fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File bytes not available on web')),
        );
        return;
      }
      if (!kIsWeb && (filePath == null || filePath.isEmpty)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid file path')));
        return;
      }

      final titleCtrl = TextEditingController(text: fileName);
      final descCtrl = TextEditingController();

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Upload Material',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Upload'),
              onPressed: () async {
                Navigator.pop(context);
                await _uploadFile(
                  fileName: fileName,
                  title: titleCtrl.text.trim(),
                  desc: descCtrl.text.trim(),
                  fileBytes: fileBytes,
                  filePath: filePath,
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('File pick error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File pick error: $e')));
    }
  }

  Future<void> _uploadFile({
    required String fileName,
    required String title,
    required String desc,
    Uint8List? fileBytes,
    String? filePath,
  }) async {
    setState(() => _uploading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload')),
        );
        return;
      }

      final ref = FirebaseStorage.instance.ref().child(
        'materials/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      UploadTask uploadTask;

      // Platform-specific upload
      if (kIsWeb) {
        uploadTask = ref.putData(fileBytes!);
      } else {
        uploadTask = ref.putFile(File(filePath!));
      }

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // Store metadata in Firestore
      await _firestore.collection('course_materials').add({
        'title': title.isEmpty ? fileName : title,
        'description': desc,
        'fileUrl': url,
        'uploadedBy': user.email ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload successful ✅')));
      }
    } catch (e) {
      debugPrint('Upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteMaterial(String docId, String fileUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.delete();
      await _firestore.collection('course_materials').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted successfully ✅')));
      }
    } catch (e) {
      debugPrint('Delete failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _openFile(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open file');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canModify = widget.role == 'teacher' || widget.role == 'cr';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Course Materials',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: canModify
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF8B5CF6),
              onPressed: _pickAndUploadFile,
              child: _uploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                    ),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('course_materials')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No materials uploaded yet.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final title = data['title'] ?? 'Untitled';
              final desc = data['description'] ?? '';
              final url = data['fileUrl'] ?? '';
              final author = data['uploadedBy'] ?? 'Unknown';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                color: const Color(0xFF1A1F2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (desc.isNotEmpty)
                        Text(
                          desc,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        'Uploaded by: $author',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _openFile(url),
                      ),
                      if (canModify)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteMaterial(id, url),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
