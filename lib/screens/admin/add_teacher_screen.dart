import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _empIdController = TextEditingController(); // Employee ID as Password
  final _deptController = TextEditingController();  // Department Field
  bool _isLoading = false;

  Future<void> _registerTeacher() async {
    //
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _empIdController.text.isEmpty ||
        _deptController.text.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      //
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _empIdController.text.trim(),
      );

      // 2. Firestore mein teacher ka poora data save karna
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'empId': _empIdController.text.trim(),
        'department': _deptController.text.trim(),
        'role': 'Teacher',
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;
      _showSnackBar("Teacher Registered Successfully!", Colors.green);
      Navigator.pop(context); // Wapis List screen par

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Registration Failed", Colors.red);
    } catch (e) {
      _showSnackBar("An error occurred", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      appBar: AppBar(
        title: Text("Register Teacher", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      // SingleChildScrollView overflow se bachata hai
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 70, color: primaryBlue),
            const SizedBox(height: 30),

            _buildTextField(_nameController, "Full Name", Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(_emailController, "Email Address", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildTextField(_empIdController, "Password", Icons.badge_outlined),
            const SizedBox(height: 15),
            _buildTextField(_deptController, "Department (e.g., Computing)", Icons.account_tree_outlined),

            const SizedBox(height: 40),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _registerTeacher,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                  "ADD TEACHER",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
    );
  }
}