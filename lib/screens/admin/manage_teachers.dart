import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teacher_profile_screen.dart';
import 'add_teacher_screen.dart';

class ManageTeachers extends StatefulWidget {
  const ManageTeachers({super.key});

  @override
  State<ManageTeachers> createState() => _ManageTeachersState();
}

class _ManageTeachersState extends State<ManageTeachers> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Manage Teachers", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search teacher name...",
                prefixIcon: const Icon(Icons.search, color: primaryBlue),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Teacher').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs.where((d) {
                  return d['name'].toString().toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    var teacher = docs[index].data() as Map<String, dynamic>;
                    String teacherId = docs[index].id;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person, color: primaryBlue)),
                        title: Text(teacher['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Emp ID: ${teacher['empId'] ?? 'N/A'}"),
                        // --- DELETE BUTTON ---
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(teacherId, teacher['name']),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherProfileScreen(
                                  teacherId: teacherId,
                                  teacherName: teacher['name']
                              ),
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
      // --- ADD TEACHER BUTTON IS BACK ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTeacherScreen())),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Add Teacher", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- DELETE CONFIRMATION DIALOG ---
  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Warning!"),
          ],
        ),
        content: Text("Are you sure you want to delete '$name'? This will remove the teacher from all records."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No, Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Teacher removed successfully.")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}