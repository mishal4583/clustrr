import 'package:flutter/material.dart';

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData icon;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}
