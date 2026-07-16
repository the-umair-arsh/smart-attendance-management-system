import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Manage Students", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search by Roll No or Name...",
                prefixIcon: const Icon(Icons.search, color: primaryBlue),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Student').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                var docs = snapshot.data!.docs.where((d) {
                  var data = d.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toString().toLowerCase();
                  String roll = (data['rollNo'] ?? "").toString().toLowerCase();
                  return name.contains(searchQuery) || roll.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    var studentData = docs[index].data() as Map<String, dynamic>;
                    String studentId = docs[index].id;
                    String studentName = studentData['name'] ?? 'No Name';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: primaryBlue),
                        ),
                        title: Text(studentName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        subtitle: Text("Roll No: ${studentData['rollNo'] ?? 'N/A'}"),

                        // --- Updated Delete Button ---
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(studentId, studentName),
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsScreen(studentData: studentData, studentId: studentId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddStudentScreen())),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Add Student", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- Professional Warning Dialog (Yes/No) ---
  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Warning!"),
          ],
        ),
        content: Text("Are you sure you want to delete student '$name'? This will permanently remove their profile and records."),
        actions: [
          // Cancel Button
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No, Cancel", style: TextStyle(color: Colors.grey))
          ),
          // Confirm Delete Button
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Student deleted successfully."), backgroundColor: Colors.redAccent),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}