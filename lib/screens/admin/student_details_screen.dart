import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final String studentId;

  const StudentDetailsScreen({super.key, required this.studentData, required this.studentId});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primaryBlue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(studentData['name'] ?? 'N/A', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            _infoTile(Icons.numbers, "Roll Number", studentData['rollNo']),
            _infoTile(Icons.email, "Email", studentData['email']),
            _infoTile(Icons.school, "Department", studentData['department']),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D47A1)),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}