import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? selectedTeacherId;
  String? selectedTeacherName;
  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Create New Course",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course Details",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryBlue)),
            const SizedBox(height: 20),

            // Course Name Field
            _buildTextField(
              controller: _nameController,
              label: "Course Name",
              hint: "e.g. Mobile App Development",
              icon: Icons.book_outlined,
            ),
            const SizedBox(height: 20),

            // Course Code Field
            _buildTextField(
              controller: _codeController,
              label: "Course Code",
              hint: "e.g. CS-401",
              icon: Icons.qr_code_rounded,
            ),
            const SizedBox(height: 25),

            Text("Assign Faculty",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryBlue)),
            const SizedBox(height: 15),

            // --- TEACHER DROPDOWN ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Teacher')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0D47A1)),
                    ),
                    hint: const Text("Select Teacher"),
                    isExpanded: true,
                    items: snapshot.data!.docs.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(t['name'], style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTeacherId = val;
                        selectedTeacherName = snapshot.data!.docs
                            .firstWhere((d) => d.id == val)['name'];
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            // Save Button
            ElevatedButton(
              onPressed: _saveCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              child: Text("SAVE & ASSIGN COURSE",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }

  // Helper Widget for TextFields
  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.blue.shade50,
        labelStyle: TextStyle(color: primaryBlue.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  void _saveCourse() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty || selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and assign a teacher!"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('courses').add({
        'courseName': _nameController.text.trim(),
        'courseCode': _codeController.text.trim().toUpperCase(),
        'teacherId': selectedTeacherId,
        'teacherName': selectedTeacherName,
        'createdAt': FieldValue.serverTimestamp(),
        'students': [], // Default empty list for auto-enrollment
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Course Created Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}